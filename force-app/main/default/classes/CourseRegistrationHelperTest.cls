@isTest
public with sharing class CourseRegistrationHelperTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();

    }
    @isTest
    private static void testCourseRegistrationHelper() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            NumberOfParticipants__c = 2,
            WaitingList__c = 2,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;

        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', courseId);
        insert cr1;
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', courseId);
        insert cr2;

        List<String> courseIds = new List<String>();

        for (CourseRegistration__c cr : [SELECT Id, Course__c FROM CourseRegistration__c]) {
            courseIds.add(cr.Course__c);
        }
        Test.StartTest();
        CourseRegistrationHelper.countCourseIdsToReduceAttending(courseIds);
        Test.stopTest();

        Decimal ParticipantCount = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;

        System.assertEquals(0, ParticipantCount, 'Should be 0 participants');

        CourseRegistrationHelper.countCourseIdsToIncreaseAttending(courseIds);

        Decimal ParticipantCount1 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;

        System.assertEquals(2, ParticipantCount1, 'Should be 2 participants');

        CourseRegistrationHelper.countCourseIdsToReduceWaiting(courseIds);

        Decimal WaitinglistCount = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(0, WaitinglistCount, 'Should be 0 on waiting list');

        CourseRegistrationHelper.countCourseIdsToIncreaseWaiting(courseIds);

        Decimal WaitinglistCount1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(2, WaitinglistCount1, 'Should be 2 on waiting list');

        Map<String, Integer> testParticipant = new Map<String, Integer>();
        testParticipant.put(courseId, 5);

        CourseRegistrationHelper.updateCoursesParticipants(testParticipant);

        Decimal ParticipantCount2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;

        System.assertEquals(7, ParticipantCount2, 'Should be 7 participants');

        Map<String, Integer> testWaiting = new Map<String, Integer>();
        testWaiting.put(courseId, -2);

        CourseRegistrationHelper.updateCourseWaiting(testWaiting);

        Decimal WaitinglistCount2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(0, WaitinglistCount2, 'Should be 0 on waiting list');

    }

    @isTest
    private static void testWaitingListFunction() {

        Course__c course2 = new Course__c(
            Name = 'Testkurs2',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs2',
            Active__c = true
        );
        insert course2;

        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Påmeldt', courseId2);
        insert cr1;
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Påmeldt', courseId2);
        insert cr2;
        CourseRegistration__c cr3 = CourseRegistrationHandlerTest.getCourseRegistration('Venteliste', courseId2);
        insert cr3;
        CourseRegistration__c cr4 = CourseRegistrationHandlerTest.getCourseRegistration('Venteliste', courseId2);
        insert cr4;

        Decimal ParticipantCount = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;

        Decimal WaitingCount = [
            SELECT Id, WaitingList__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .WaitingList__c;

        System.assertEquals(2, ParticipantCount, 'Should be 2 participants');
        System.assertEquals(2, WaitingCount, 'Should be 2 on waiting list');

        List<String> courseIdsUpdated = new List<String>();
        courseIdsUpdated.add(cr1.Course__c);
        courseIdsUpdated.add(cr2.Course__c);

        CourseRegistrationHelper.countCourseIdsToCheckWaiting(courseIdsUpdated);

        String cr3Status = [
            SELECT Id, Status__c
            FROM CourseRegistration__c
            WHERE Id = :cr3.Id
            LIMIT 1
        ]
        .Status__c;

        String cr4Status = [
            SELECT Id, Status__c
            FROM CourseRegistration__c
            WHERE Id = :cr4.Id
            LIMIT 1
        ]
        .Status__c;

        System.assertEquals('Påmeldt', cr3Status, 'cr3 should have status Påmeldt');
        System.assertEquals('Påmeldt', cr4Status, 'cr4 should have status Påmeldt');

    }
}
