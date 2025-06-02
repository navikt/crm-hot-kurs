public class CourseRegistrationHelper {
    public static void validateRegistrationsAgainstCourseCapacity(
        List<CourseRegistration__c> registrationsToValidate,
        Map<Id, CourseRegistration__c> oldRegistrationsMap
    ) {
        Set<Id> courseIds = new Set<Id>();
        List<CourseRegistration__c> regsRequiringValidation = new List<CourseRegistration__c>();

        for (CourseRegistration__c cr : registrationsToValidate) {
            Boolean needsValidation = (oldRegistrationsMap == null || oldRegistrationsMap.get(cr.Id) == null);
            if (!needsValidation && oldRegistrationsMap != null && oldRegistrationsMap.get(cr.Id) != null) {
                CourseRegistration__c oldCr = oldRegistrationsMap.get(cr.Id);
                if (cr.Course__c != oldCr.Course__c || cr.NumberOfParticipants__c != oldCr.NumberOfParticipants__c) {
                    needsValidation = true;
                }
            }

            // Only validate if relevant fields are populated and validation is determined to be needed.
            if (
                needsValidation &&
                cr.Course__c != null &&
                cr.NumberOfParticipants__c != null &&
                cr.NumberOfParticipants__c > 0
            ) {
                courseIds.add(cr.Course__c);
                regsRequiringValidation.add(cr);
            }
        }

        if (regsRequiringValidation.isEmpty()) {
            return; // No registrations require this specific validation.
        }

        // Query for course capacities
        Map<Id, Course__c> coursesWithCapacity = new Map<Id, Course__c>();
        if (!courseIds.isEmpty()) {
            for (Course__c course : [SELECT Id, MaxNumberOfParticipants__c FROM Course__c WHERE Id IN :courseIds]) {
                coursesWithCapacity.put(course.Id, course);
            }
        }

        // Perform the validation
        for (CourseRegistration__c cr : regsRequiringValidation) {
            Course__c relatedCourse = coursesWithCapacity.get(cr.Course__c);

            if (relatedCourse != null) {
                if (relatedCourse.MaxNumberOfParticipants__c != null && relatedCourse.MaxNumberOfParticipants__c > 0) {
                    if (cr.NumberOfParticipants__c > relatedCourse.MaxNumberOfParticipants__c) {
                        cr.addError(
                            'Antall deltakere (' +
                            cr.NumberOfParticipants__c.intValue() +
                            ') for denne påmeldingen overstiger kursets maksimale kapasitet (' +
                            relatedCourse.MaxNumberOfParticipants__c.intValue() +
                            '). Vennligst reduser antall deltakere. ' +
                            'Hvis gruppen din er større enn kursets kapasitet og du ønsker at noen skal settes på venteliste, ' +
                            'kan det hende du må opprette flere, mindre påmeldinger.'
                        );
                    }
                } else {
                    System.debug(
                        LoggingLevel.WARN,
                        'CourseRegistrationHelper: MaxNumberOfParticipants__c is not defined or not positive for Course ID ' +
                        relatedCourse.Id +
                        '. Skipping capacity validation for Registration ID ' +
                        cr.Id
                    );
                }
            } else {
                System.debug(
                    LoggingLevel.WARN,
                    'CourseRegistrationHelper: Could not find Course details for Registration ID ' +
                    cr.Id +
                    ' with Course__c = ' +
                    cr.Course__c +
                    '. Skipping capacity validation.'
                );
            }
        }
    }

    private static void processCourseRegistrations(
        List<CourseRegistration__c> registrations,
        Boolean isIncreaseOperation // true for increase, false for reduce
    ) {
        List<CourseRegistration__c> regsForAttending = new List<CourseRegistration__c>();
        List<CourseRegistration__c> regsForWaiting = new List<CourseRegistration__c>();

        for (CourseRegistration__c cr : registrations) {
            if (cr.Status__c == 'Påmeldt') {
                regsForAttending.add(cr);
            } else if (cr.Status__c == 'Venteliste') {
                regsForWaiting.add(cr);
            }
        }

        if (!regsForAttending.isEmpty()) {
            if (isIncreaseOperation) {
                countCourseIdsToIncreaseAttending(regsForAttending);
            } else {
                countCourseIdsToReduceAttending(regsForAttending);
            }
        }
        if (!regsForWaiting.isEmpty()) {
            if (isIncreaseOperation) {
                countCourseIdsToIncreaseWaiting(regsForWaiting);
            } else {
                countCourseIdsToReduceWaiting(regsForWaiting);
            }
        }
    }

    public static void getCourseIdToReduce(List<CourseRegistration__c> registrations) {
        processCourseRegistrations(registrations, false); // false indicates a reduction
    }

    public static void getCourseIdToIncrease(List<CourseRegistration__c> registrations) {
        processCourseRegistrations(registrations, true); // true indicates an increase
    }

    // Private consolidated helper for accumulating participant changes into a map.
    private static void accumulateParticipantChanges(
        List<CourseRegistration__c> registrations,
        Map<Id, Integer> changeMap,
        boolean isPositiveIncrement // true for +N (increase), false for -N (reduce)
    ) {
        for (CourseRegistration__c cr : registrations) {
            Integer numParticipants = (cr.NumberOfParticipants__c == null ||
                cr.NumberOfParticipants__c < 1)
                ? 1
                : cr.NumberOfParticipants__c.intValue();

            Integer currentChange = changeMap.get(cr.Course__c);
            if (currentChange == null) {
                currentChange = 0;
            }

            if (isPositiveIncrement) {
                changeMap.put(cr.Course__c, currentChange + numParticipants);
            } else {
                changeMap.put(cr.Course__c, currentChange - numParticipants);
            }
        }
    }

    public static void countCourseIdsToReduceAttending(List<CourseRegistration__c> registrationsToReduce) {
        Map<Id, Integer> courseParticipantChanges = new Map<Id, Integer>();
        accumulateParticipantChanges(registrationsToReduce, courseParticipantChanges, false); // false for reduce
        if (!courseParticipantChanges.isEmpty()) {
            updateCoursesParticipants(courseParticipantChanges);
        }
    }

    public static void countCourseIdsToIncreaseAttending(List<CourseRegistration__c> registrationsToIncrease) {
        Map<Id, Integer> courseParticipantChanges = new Map<Id, Integer>();
        accumulateParticipantChanges(registrationsToIncrease, courseParticipantChanges, true); // true for increase
        if (!courseParticipantChanges.isEmpty()) {
            updateCoursesParticipants(courseParticipantChanges);
        }
    }

    public static void updateCoursesParticipants(Map<Id, Integer> coursesCountChanges) {
        if (coursesCountChanges == null || coursesCountChanges.isEmpty())
            return;

        List<Course__c> coursesToUpdate = new List<Course__c>();
        for (Course__c course : [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Id IN :coursesCountChanges.keySet()
        ]) {
            Decimal currentParticipants = course.NumberOfParticipants__c == null ? 0 : course.NumberOfParticipants__c;
            Integer change = coursesCountChanges.get(course.Id);

            course.NumberOfParticipants__c = currentParticipants + change;
            if (course.NumberOfParticipants__c < 0) {
                course.NumberOfParticipants__c = 0;
            }
            coursesToUpdate.add(course);
        }

        if (!coursesToUpdate.isEmpty()) {
            try {
                update coursesToUpdate;
            } catch (Exception e) {
                System.debug(
                    LoggingLevel.ERROR,
                    'Error updating course participants: ' +
                    e.getMessage() +
                    ' Stacktrace: ' +
                    e.getStackTraceString()
                );
            }
        }
    }

    public static void countCourseIdsToReduceWaiting(List<CourseRegistration__c> registrationsToReduce) {
        Map<Id, Integer> courseWaitlistChanges = new Map<Id, Integer>();
        accumulateParticipantChanges(registrationsToReduce, courseWaitlistChanges, false); // false for reduce
        if (!courseWaitlistChanges.isEmpty()) {
            updateCourseWaiting(courseWaitlistChanges);
        }
    }

    public static void countCourseIdsToIncreaseWaiting(List<CourseRegistration__c> registrationsToIncrease) {
        Map<Id, Integer> courseWaitlistChanges = new Map<Id, Integer>();
        accumulateParticipantChanges(registrationsToIncrease, courseWaitlistChanges, true); // true for increase
        if (!courseWaitlistChanges.isEmpty()) {
            updateCourseWaiting(courseWaitlistChanges);
        }
    }

    public static void updateCourseWaiting(Map<Id, Integer> coursesWaitlistChanges) {
        if (coursesWaitlistChanges == null || coursesWaitlistChanges.isEmpty())
            return;

        List<Course__c> coursesToUpdate = new List<Course__c>();
        for (Course__c course : [
            SELECT Id, Waitinglist__c
            FROM Course__c
            WHERE Id IN :coursesWaitlistChanges.keySet()
        ]) {
            Decimal currentWaitlist = course.Waitinglist__c == null ? 0 : course.Waitinglist__c;
            Integer change = coursesWaitlistChanges.get(course.Id);

            course.Waitinglist__c = currentWaitlist + change;
            if (course.Waitinglist__c < 0) {
                course.Waitinglist__c = 0;
            }
            coursesToUpdate.add(course);
        }

        if (!coursesToUpdate.isEmpty()) {
            try {
                update coursesToUpdate;
            } catch (Exception e) {
                System.debug(
                    LoggingLevel.ERROR,
                    'Error updating course waitlist: ' +
                    e.getMessage() +
                    ' Stacktrace: ' +
                    e.getStackTraceString()
                );
            }
        }
    }

    public static void countCourseIdsToCheckWaiting(Set<Id> courseIds) {
        if (courseIds == null || courseIds.isEmpty())
            return;
        updateCourseWaitlistPromotions(courseIds);
    }

    public static void updateCourseWaitlistPromotions(Set<Id> courseIdsToProcess) {
        if (courseIdsToProcess == null || courseIdsToProcess.isEmpty()) {
            return;
        }

        List<CourseRegistration__c> registrationsToPromote = new List<CourseRegistration__c>();
        Map<Id, Integer> courseParticipantIncreases = new Map<Id, Integer>();
        Map<Id, Integer> courseWaitlistDecreases = new Map<Id, Integer>();

        List<Course__c> courses = [
            SELECT Id, NumberOfParticipants__c, Waitinglist__c, MaxNumberOfParticipants__c
            FROM Course__c
            WHERE Id IN :courseIdsToProcess
        ];

        Map<Id, Course__c> courseMap = new Map<Id, Course__c>(courses);

        for (Id courseId : courseIdsToProcess) {
            Course__c currentCourse = courseMap.get(courseId);

            if (currentCourse == null) {
                System.debug(
                    LoggingLevel.WARN,
                    'Course not found for ID: ' +
                    courseId +
                    '. Skipping waitlist promotion.'
                );
                continue;
            }
            if (currentCourse.MaxNumberOfParticipants__c == null || currentCourse.MaxNumberOfParticipants__c <= 0) {
                // MaxNumberOfParticipants__c must be positive
                System.debug(
                    LoggingLevel.WARN,
                    'MaxNumberOfParticipants__c is null or not positive for Course ID: ' +
                    courseId +
                    '. Skipping waitlist promotion.'
                );
                continue;
            }

            Decimal currentParticipants = currentCourse.NumberOfParticipants__c == null
                ? 0
                : currentCourse.NumberOfParticipants__c;
            Decimal currentWaitlistParticipants = currentCourse.Waitinglist__c == null
                ? 0
                : currentCourse.Waitinglist__c;
            Decimal maxCapacity = currentCourse.MaxNumberOfParticipants__c;

            if (currentWaitlistParticipants <= 0) {
                continue;
            }

            Decimal availableSlots = maxCapacity - currentParticipants;
            if (availableSlots <= 0) {
                continue;
            }

            List<CourseRegistration__c> waitlistedRegistrations = [
                SELECT Id, Status__c, Course__c, CreatedDate, NumberOfParticipants__c
                FROM CourseRegistration__c
                WHERE Course__c = :courseId AND Status__c = 'Venteliste'
                ORDER BY CreatedDate ASC
            ];

            if (waitlistedRegistrations.isEmpty()) {
                continue;
            }

            Integer participantsPromotedForThisCourse = 0;
            Integer waitlistParticipantsRemovedForThisCourse = 0;

            for (CourseRegistration__c crWait : waitlistedRegistrations) {
                Integer numParticipantsInRegistration = (crWait.NumberOfParticipants__c == null ||
                    crWait.NumberOfParticipants__c < 1)
                    ? 1
                    : crWait.NumberOfParticipants__c.intValue();

                if (availableSlots >= numParticipantsInRegistration) {
                    crWait.Status__c = 'Påmeldt';
                    registrationsToPromote.add(crWait);

                    availableSlots -= numParticipantsInRegistration;
                    participantsPromotedForThisCourse += numParticipantsInRegistration;
                    waitlistParticipantsRemovedForThisCourse += numParticipantsInRegistration;
                } else {
                    break;
                }
            }

            if (participantsPromotedForThisCourse > 0) {
                courseParticipantIncreases.put(courseId, participantsPromotedForThisCourse);
            }
            if (waitlistParticipantsRemovedForThisCourse > 0) {
                courseWaitlistDecreases.put(courseId, -waitlistParticipantsRemovedForThisCourse);
            }
        }

        if (!registrationsToPromote.isEmpty()) {
            try {
                update registrationsToPromote;

                /* if (!courseParticipantIncreases.isEmpty()) {
                    updateCoursesParticipants(courseParticipantIncreases);
                }
                if (!courseWaitlistDecreases.isEmpty()) {
                    updateCourseWaiting(courseWaitlistDecreases);
                } */
            } catch (Exception e) {
                System.debug(
                    LoggingLevel.ERROR,
                    'Error promoting waitlisted registrations or updating course counts: ' +
                    e.getMessage() +
                    ' Stacktrace: ' +
                    e.getStackTraceString()
                );
            }
        }
    }
}
