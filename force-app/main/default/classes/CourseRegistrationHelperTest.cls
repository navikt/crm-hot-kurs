@isTest
public with sharing class CourseRegistrationHelperTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }
    @isTest
    private static void testCountCourseIdsToReduceAttending() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course.NumberOfParticipants__c = 5;
        update course;
        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);

        List<String> courseIds = new List<String>();
        courseIds.add(cr1.Course__c);
        courseIds.add(cr2.Course__c);

        Test.StartTest();
        CourseRegistrationHelper.countCourseIdsToReduceAttending(courseIds);
        Test.stopTest();

        Course__c courseAfter = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1];
        System.assertEquals(3, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 3 participants');
    }

    @isTest
    private static void testCountCourseIdsToIncreaseAttending() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);

        List<String> courseIds = new List<String>();
        courseIds.add(cr1.Course__c);
        courseIds.add(cr2.Course__c);

        Test.StartTest();
        CourseRegistrationHelper.countCourseIdsToIncreaseAttending(courseIds);
        Test.stopTest();

        Course__c courseAfter = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1];
        System.assertEquals(2, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 2 participants');
    }

    @isTest
    private static void testCountCourseIdsToReduceWaiting() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course.Waitinglist__c = 5;
        update course;
        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);

        List<String> courseIds = new List<String>();
        courseIds.add(cr1.Course__c);
        courseIds.add(cr2.Course__c);

        Test.StartTest();
        CourseRegistrationHelper.countCourseIdsToReduceWaiting(courseIds);
        Test.stopTest();

        Course__c courseAfter = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1];
        System.assertEquals(3, Integer.valueOf(courseAfter.Waitinglist__c), 'Should be 3 on waiting list');
    }

    @isTest
    private static void testCountCourseIdsToIncreaseWaiting() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);

        List<String> courseIds = new List<String>();
        courseIds.add(cr1.Course__c);
        courseIds.add(cr2.Course__c);

        Test.StartTest();
        CourseRegistrationHelper.countCourseIdsToIncreaseWaiting(courseIds);
        Test.stopTest();

        Course__c courseAfter = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1];
        System.assertEquals(2, Integer.valueOf(courseAfter.Waitinglist__c), 'Should be 2 on waiting list');
    }

    @isTest
    private static void testUpdateCoursesParticipants() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);

        Map<String, Integer> testParticipant = new Map<String, Integer>();
        testParticipant.put(course.Id, 5);

        Test.StartTest();
        CourseRegistrationHelper.updateCoursesParticipants(testParticipant);
        Test.stopTest();

        Course__c courseAfter = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1];
        System.assertEquals(5, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 5 participants');
    }

    @isTest
    private static void testUpdateCourseWaiting() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course.Waitinglist__c = 5;
        update course;
        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);

        Map<String, Integer> testWaiting = new Map<String, Integer>();
        testWaiting.put(course.Id, -2);

        Test.StartTest();
        CourseRegistrationHelper.updateCourseWaiting(testWaiting);
        Test.stopTest();

        Course__c courseAfter = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1];
        System.assertEquals(3, Integer.valueOf(courseAfter.Waitinglist__c), 'Should be 3 on waiting list');
    }

    @isTest
    private static void testWaitingListFunction() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        CourseRegistration__c cr1 = CourseRegistrationHandlerTest.getCourseRegistration('Påmeldt', course.Id);
        CourseRegistration__c cr2 = CourseRegistrationHandlerTest.getCourseRegistration('Påmeldt', course.Id);
        CourseRegistration__c cr3 = CourseRegistrationHandlerTest.getCourseRegistration('Venteliste', course.Id);
        CourseRegistration__c cr4 = CourseRegistrationHandlerTest.getCourseRegistration('Venteliste', course.Id);

        Course__c courseBefore = [
            SELECT Id, NumberOfParticipants__c, Waitinglist__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ];
        System.assertEquals(2, courseBefore.NumberOfParticipants__c, 'Should be 2 participants');
        System.assertEquals(2, courseBefore.Waitinglist__c, 'Should be 2 on waiting list');

        List<String> courseIdsUpdated = new List<String>();
        courseIdsUpdated.add(cr1.Course__c);
        courseIdsUpdated.add(cr2.Course__c);

        CourseRegistrationHelper.countCourseIdsToCheckWaiting(courseIdsUpdated);

        String cr3Status = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr3.Id LIMIT 1].Status__c;
        String cr4Status = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr4.Id LIMIT 1].Status__c;

        System.assertEquals('Påmeldt', cr3Status, 'cr3 should have status Påmeldt');
        System.assertEquals('Påmeldt', cr4Status, 'cr4 should have status Påmeldt');
    }
}
