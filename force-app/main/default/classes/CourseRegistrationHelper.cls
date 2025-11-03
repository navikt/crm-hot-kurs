public class CourseRegistrationHelper {
    private static Integer resolveParticipantCount(CourseRegistration__c registration) {
        if (registration == null) {
            return 0;
        }
        if (registration.NumberOfParticipants__c == null || registration.NumberOfParticipants__c < 1) {
            return 1;
        }
        return registration.NumberOfParticipants__c.intValue();
    }

    private static Boolean countsTowardsCapacity(CourseRegistration__c registration) {
        return registration != null && registration.Status__c == 'Påmeldt';
    }

    public static void validateRegistrationsAgainstCourseCapacity(
        List<CourseRegistration__c> registrationsToValidate,
        Map<Id, CourseRegistration__c> oldRegistrationsMap
    ) {
        if (registrationsToValidate == null || registrationsToValidate.isEmpty()) {
            return;
        }

        Map<Id, CourseRegistration__c> safeOldMap = oldRegistrationsMap == null
            ? new Map<Id, CourseRegistration__c>()
            : oldRegistrationsMap;

        Set<Id> courseIds = new Set<Id>();
        Map<Id, Decimal> courseDelta = new Map<Id, Decimal>();
        Map<Id, List<CourseRegistration__c>> courseToIncreasingRegistrations = new Map<Id, List<CourseRegistration__c>>();

        for (CourseRegistration__c cr : registrationsToValidate) {
            if (cr == null) {
                continue;
            }

            Id newCourseId = cr.Course__c;
            Integer newParticipants = resolveParticipantCount(cr);
            Boolean newCounts = countsTowardsCapacity(cr);
            Decimal newContribution = (newCourseId != null && newCounts) ? Decimal.valueOf(newParticipants) : 0;

            CourseRegistration__c oldCr = safeOldMap.get(cr.Id);
            Id oldCourseId = oldCr != null ? oldCr.Course__c : null;
            Integer oldParticipants = resolveParticipantCount(oldCr);
            Boolean oldCounts = countsTowardsCapacity(oldCr);
            Decimal oldContribution = (oldCourseId != null && oldCounts) ? Decimal.valueOf(oldParticipants) : 0;

            if (oldCourseId != null && oldContribution > 0) {
                Decimal existingDelta = courseDelta.containsKey(oldCourseId) ? courseDelta.get(oldCourseId) : 0;
                courseDelta.put(oldCourseId, existingDelta - oldContribution);
                courseIds.add(oldCourseId);
            }

            if (newCourseId != null && newContribution > 0) {
                Decimal existingDelta = courseDelta.containsKey(newCourseId) ? courseDelta.get(newCourseId) : 0;
                courseDelta.put(newCourseId, existingDelta + newContribution);
                courseIds.add(newCourseId);

                Boolean increasesOccupancy = true;
                if (oldCourseId != null && oldCourseId == newCourseId) {
                    increasesOccupancy = newContribution > oldContribution;
                }

                if (increasesOccupancy) {
                    List<CourseRegistration__c> regsForCourse = courseToIncreasingRegistrations.containsKey(newCourseId)
                        ? courseToIncreasingRegistrations.get(newCourseId)
                        : new List<CourseRegistration__c>();
                    regsForCourse.add(cr);
                    courseToIncreasingRegistrations.put(newCourseId, regsForCourse);
                }
            } else if (newCourseId != null) {
                courseIds.add(newCourseId);
            }
        }

        if (courseIds.isEmpty()) {
            return;
        }

        Map<Id, Course__c> coursesWithCapacity = new Map<Id, Course__c>();
        for (Course__c course : [
            SELECT Id, MaxNumberOfParticipants__c, Registration_Signups_Count__c
            FROM Course__c
            WHERE Id IN :courseIds
        ]) {
            coursesWithCapacity.put(course.Id, course);
        }

        for (Id courseId : courseIds) {
            Course__c relatedCourse = coursesWithCapacity.get(courseId);
            if (relatedCourse == null) {
                System.debug(
                    LoggingLevel.WARN,
                    'CourseRegistrationHelper: Could not find Course details for Course ID ' + courseId
                );
                continue;
            }

            Decimal maxCapacity = relatedCourse.MaxNumberOfParticipants__c == null
                ? 0
                : relatedCourse.MaxNumberOfParticipants__c;
            if (maxCapacity <= 0) {
                continue;
            }

            Decimal currentSignups = relatedCourse.Registration_Signups_Count__c == null
                ? 0
                : relatedCourse.Registration_Signups_Count__c;
            Decimal netDelta = courseDelta.containsKey(courseId) ? courseDelta.get(courseId) : 0;
            if (netDelta <= 0) {
                continue;
            }

            Decimal projectedSignups = currentSignups + netDelta;
            if (projectedSignups <= maxCapacity) {
                continue;
            }

            Decimal availableSeatsDecimal = maxCapacity - currentSignups;
            Integer availableSeats = availableSeatsDecimal > 0 ? availableSeatsDecimal.intValue() : 0;
            List<CourseRegistration__c> impactedRegistrations = courseToIncreasingRegistrations.get(courseId);

            if (impactedRegistrations == null || impactedRegistrations.isEmpty()) {
                continue;
            }

            for (CourseRegistration__c cr : impactedRegistrations) {
                Integer regParticipants = resolveParticipantCount(cr);
                cr.addError(
                    'Antall deltakere (' +
                        regParticipants +
                        ') for denne påmeldingen overstiger tilgjengelige plasser (' +
                        availableSeats +
                        ') på kurset (maks ' +
                        maxCapacity.intValue() +
                        '). Vennligst reduser antall deltakere eller sett påmeldingen på venteliste.'
                );
            }
        }
    }

    public static void countCourseIdsToCheckWaiting(Set<Id> courseIds) {
        if (courseIds == null || courseIds.isEmpty())
            return;
        System.enqueueJob(new CourseWaitlistPromotionJob(new List<Id>(courseIds)));
    }

    public static void updateCourseWaitlistPromotions(Set<Id> courseIdsToProcess) {
        if (courseIdsToProcess == null || courseIdsToProcess.isEmpty())
            return;

        List<CourseRegistration__c> registrationsToPromote = new List<CourseRegistration__c>();

        List<Course__c> courses = [
            SELECT Id, Registration_Signups_Count__c, Registration_Waitlisted_Count__c, MaxNumberOfParticipants__c
            FROM Course__c
            WHERE Id IN :courseIdsToProcess
        ];
        Map<Id, Course__c> courseMap = new Map<Id, Course__c>(courses);

        for (Id courseId : courseIdsToProcess) {
            Course__c currentCourse = courseMap.get(courseId);
            if (
                currentCourse == null ||
                currentCourse.MaxNumberOfParticipants__c == null ||
                currentCourse.MaxNumberOfParticipants__c <= 0
            ) {
                continue;
            }

            Decimal currentParticipants = currentCourse.Registration_Signups_Count__c == null
                ? 0
                : currentCourse.Registration_Signups_Count__c;
            Decimal currentWaitlistParticipants = currentCourse.Registration_Waitlisted_Count__c == null
                ? 0
                : currentCourse.Registration_Waitlisted_Count__c;
            Decimal maxCapacity = currentCourse.MaxNumberOfParticipants__c;

            if (currentWaitlistParticipants <= 0)
                continue;

            Decimal availableSlots = maxCapacity - currentParticipants;
            if (availableSlots <= 0)
                continue;

            List<CourseRegistration__c> waitlistedRegistrations = [
                SELECT Id, Status__c, Course__c, CreatedDate, NumberOfParticipants__c
                FROM CourseRegistration__c
                WHERE Course__c = :courseId AND Status__c = 'Venteliste'
                ORDER BY CreatedDate ASC
            ];
            if (waitlistedRegistrations.isEmpty())
                continue;

            Integer availableSlotsInt = Integer.valueOf(availableSlots);
            for (CourseRegistration__c crWait : waitlistedRegistrations) {
                Integer numParticipantsInRegistration = (crWait.NumberOfParticipants__c == null ||
                    crWait.NumberOfParticipants__c < 1)
                    ? 1
                    : crWait.NumberOfParticipants__c.intValue();

                if (availableSlotsInt >= numParticipantsInRegistration) {
                    crWait.Status__c = 'Påmeldt';
                    registrationsToPromote.add(crWait);
                    availableSlotsInt -= numParticipantsInRegistration;
                } else {
                    break;
                }
            }
        }

        if (!registrationsToPromote.isEmpty()) {
            try {
                update registrationsToPromote;
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Error promoting waitlisted registrations: ' + e.getMessage());
            }
        }
    }
}
