@isTest
public with sharing class CourseRegistrationHelperTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    private static Course__c createCourse(Integer maxSeats) {
        Course__c course = new Course__c(
            Name = 'Helper Test ' + String.valueOf(Math.random()),
            MaxNumberOfParticipants__c = maxSeats,
            DescriptionFormatted__c = 'desc',
            Active__c = true
        );
        insert course;
        return course;
    }

    private static CourseRegistration__c createRegistration(Id courseId, String status, Integer participants) {
        CourseRegistration__c registration = new CourseRegistration__c(
            ContactFirstName__c = 'Test',
            ContactLastName__c = 'User',
            ContactEmail__c = String.valueOf(Math.random()) + '@example.com',
            Course__c = courseId,
            Status__c = status,
            NumberOfParticipants__c = participants
        );
        insert registration;
        return registration;
    }

    @isTest
    static void testCapacityValidationAllowsWithinLimit() {
        Course__c course = createCourse(5);

        CourseRegistration__c pending = new CourseRegistration__c(
            Course__c = course.Id,
            Status__c = 'Påmeldt',
            NumberOfParticipants__c = 3
        );

        CourseRegistrationHelper.validateRegistrationsAgainstCourseCapacity(
            new List<CourseRegistration__c>{ pending },
            null
        );

        System.assertEquals(
            0,
            pending.getErrors().size(),
            'Validation should not block registration when capacity allows'
        );
    }

    @isTest
    static void testCapacityValidationBlocksWhenExceedingLimitWithExistingRegistrations() {
        Course__c course = createCourse(3);
        createRegistration(course.Id, 'Påmeldt', 2);

        CourseRegistration__c pending = new CourseRegistration__c(
            Course__c = course.Id,
            Status__c = 'Påmeldt',
            NumberOfParticipants__c = 2
        );

        CourseRegistrationHelper.validateRegistrationsAgainstCourseCapacity(
            new List<CourseRegistration__c>{ pending },
            null
        );

        System.assertEquals(
            1,
            pending.getErrors().size(),
            'Validation should block registrations that exceed remaining seats'
        );
        System.assert(
            pending.getErrors()[0].getMessage().contains('overstiger'),
            'Error message should explain that the capacity is exceeded'
        );
    }

    @isTest
    static void testUpdateCourseWaitlistPromotions() {
        Course__c course = createCourse(2);
        CourseRegistration__c firstAttendee = createRegistration(course.Id, 'Påmeldt', 1);
        createRegistration(course.Id, 'Påmeldt', 1);

        CourseRegistration__c waitlistOldest = createRegistration(course.Id, 'Venteliste', 1);
        CourseRegistration__c waitlistNewest = createRegistration(course.Id, 'Venteliste', 1);

        firstAttendee.Status__c = 'Avmeldt';
        update firstAttendee;

        Test.startTest();
        CourseRegistrationHelper.countCourseIdsToCheckWaiting(new Set<Id>{ course.Id });
        Test.stopTest();

        Map<Id, CourseRegistration__c> refreshed = new Map<Id, CourseRegistration__c>(
            [
                SELECT Status__c
                FROM CourseRegistration__c
                WHERE Id IN :new List<Id>{ waitlistOldest.Id, waitlistNewest.Id }
            ]
        );

        System.assertEquals(
            'Påmeldt',
            refreshed.get(waitlistOldest.Id).Status__c,
            'Oldest waitlisted registration should be promoted'
        );
        System.assertEquals(
            'Venteliste',
            refreshed.get(waitlistNewest.Id).Status__c,
            'Only one waitlisted registration should be promoted'
        );
    }
}