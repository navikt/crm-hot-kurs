@isTest
public with sharing class CourseRegistrationHandlerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testInsert() {
        Course__c course1 = getCourse('Testkurs');
        Course__c course2 = getCourse('Testkurs2');

        System.assertEquals(null, course1.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course2.NumberOfParticipants__c, 'Should be 0 participants');

        Test.StartTest();
        CourseRegistration__c cr = getCourseRegistration('Påmeldt', course1.Id);
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course2.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', course2.Id);
        Test.StopTest();

        Course__c course1After = fetchCourse('Testkurs');
        Course__c course2After = fetchCourse('Testkurs2');

        System.assertEquals(1, Integer.valueOf(course1After.NumberOfParticipants__c), 'Should be 1 participant');
        System.assertEquals(1, Integer.valueOf(course2After.NumberOfParticipants__c), 'Should be 1 participant');
        System.assertEquals(1, Integer.valueOf(course2After.WaitingList__c), 'Should be 1 on waitinglist');
    }
    @isTest
    private static void testDelete() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr = getCourseRegistration('Påmeldt', course.Id);
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course.Id);

        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(2, crList.size(), 'Should be 2 registrations');

        Test.StartTest();
        delete crList;
        Test.StopTest();

        List<CourseRegistration__c> crListDel = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(0, crListDel.size(), 'Should be 0 registrations');

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
    }
    @isTest
    private static void testUnDelete() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr = getCourseRegistration('Påmeldt', course.Id);
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course.Id);

        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        delete crList;

        Test.StartTest();
        undelete cr;
        undelete cr1;
        Test.StopTest();

        List<CourseRegistration__c> crListUnDel = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(2, crListUnDel.size(), 'Should be 2 registrations');

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(2, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 2 participants');
    }

    @isTest
    private static void updateOneAttending_toOneNotAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course.Id);

        cr1.Status__c = 'Avmeldt';
        Test.StartTest();
        update cr1;
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
    }

    @isTest
    private static void updateOneAttending_toOneWaiting() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course.Id);

        cr1.Status__c = 'Venteliste';
        Test.StartTest();
        update cr1;
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(1, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 1 on waiting list');
    }

    @isTest
    private static void updateOneNotAttending_toOneAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Avmeldt', course.Id);

        cr1.Status__c = 'Påmeldt';
        Test.StartTest();
        update cr1;
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(1, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 1 participant');
    }

    @isTest
    private static void updateOneNotAttending_toOneWaiting() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Avmeldt', course.Id);

        cr1.Status__c = 'Venteliste';
        Test.StartTest();
        update cr1;
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(1, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 1 on waiting list');
    }

    @isTest
    private static void updateOneWaiting_toOneAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Venteliste', course.Id);

        cr1.Status__c = 'Påmeldt';
        Test.StartTest();
        update cr1;
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(1, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 1 participant');
        System.assertEquals(0, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 0 on waiting list');
    }
    @isTest
    private static void updateOneWaiting_toOneNotAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Venteliste', course.Id);

        cr1.Status__c = 'Avmeldt';
        Test.StartTest();
        update cr1;
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(0, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 0 on waiting list');
    }

    @isTest
    private static void updateTwoAttending_toTwoNotAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Påmeldt', course.Id);

        cr1.Status__c = 'Avmeldt';
        cr2.Status__c = 'Avmeldt';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
    }

    @isTest
    private static void updateTwoAttending_toTwoWaiting() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Påmeldt', course.Id);

        cr1.Status__c = 'Venteliste';
        cr2.Status__c = 'Venteliste';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(2, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 2 on waiting list');
    }

    @isTest
    private static void updateTwoNotAttending_toTwoAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Avmeldt', course.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Avmeldt', course.Id);

        cr1.Status__c = 'Påmeldt';
        cr2.Status__c = 'Påmeldt';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(2, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 2 participants');
    }

    @isTest
    private static void updateTwoNotAttending_toTwoWaiting() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Avmeldt', course.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Avmeldt', course.Id);

        cr1.Status__c = 'Venteliste';
        cr2.Status__c = 'Venteliste';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(2, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 2 on waiting list');
    }

    @isTest
    private static void updateTwoWaiting_toTwoAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Venteliste', course.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', course.Id);

        cr1.Status__c = 'Påmeldt';
        cr2.Status__c = 'Påmeldt';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(2, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 2 participants');
        System.assertEquals(0, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 0 on waiting list');
    }

    @isTest
    private static void updateTwoWaiting_toTwoNotAttending() {
        Course__c course = getCourse('Testkurs');
        CourseRegistration__c cr1 = getCourseRegistration('Venteliste', course.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', course.Id);

        cr1.Status__c = 'Avmeldt';
        cr2.Status__c = 'Avmeldt';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c courseAfter = fetchCourse('Testkurs');
        System.assertEquals(0, Integer.valueOf(courseAfter.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(0, Integer.valueOf(courseAfter.WaitingList__c), 'Should be 0 on waiting list');
    }

    @isTest
    private static void updateTwoAttending_toTwoNotAttending_twoCourses() {
        Course__c course1 = getCourse('Testkurs');
        Course__c course2 = getCourse('Testkurs2');
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course1.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Påmeldt', course2.Id);

        cr1.Status__c = 'Avmeldt';
        cr2.Status__c = 'Avmeldt';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c course1After = fetchCourse('Testkurs');
        Course__c course2After = fetchCourse('Testkurs2');
        System.assertEquals(0, Integer.valueOf(course1After.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(0, Integer.valueOf(course2After.NumberOfParticipants__c), 'Should be 0 participants');
    }

    @isTest
    private static void updateTwoAttending_toTwoWaiting_twoCourses() {
        Course__c course1 = getCourse('Testkurs');
        Course__c course2 = getCourse('Testkurs2');
        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course1.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Påmeldt', course2.Id);

        cr1.Status__c = 'Venteliste';
        cr2.Status__c = 'Venteliste';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c course1After = fetchCourse('Testkurs');
        Course__c course2After = fetchCourse('Testkurs2');
        System.assertEquals(0, Integer.valueOf(course1After.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(0, Integer.valueOf(course2After.NumberOfParticipants__c), 'Should be 0 participants');
        System.assertEquals(1, Integer.valueOf(course1After.WaitingList__c), 'Should be 1 on waiting list');
        System.assertEquals(1, Integer.valueOf(course2After.WaitingList__c), 'Should be 1 on waiting list');
    }

    @isTest
    private static void updateTwoNotAttending_toTwoAttending_twoCourses() {
        Course__c course1 = getCourse('Testkurs');
        Course__c course2 = getCourse('Testkurs2');
        CourseRegistration__c cr1 = getCourseRegistration('Avmeldt', course1.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Avmeldt', course2.Id);

        cr1.Status__c = 'Påmeldt';
        cr2.Status__c = 'Påmeldt';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr2 };
        Test.StopTest();

        Course__c course1After = fetchCourse('Testkurs');
        Course__c course2After = fetchCourse('Testkurs2');
        System.assertEquals(1, Integer.valueOf(course1After.NumberOfParticipants__c), 'Should be 1 participant');
        System.assertEquals(1, Integer.valueOf(course2After.NumberOfParticipants__c), 'Should be 1 participant');
    }

    @isTest
    private static void testWaitingListFunctionality() {
        Course__c course1 = getCourse('Testkurs');
        Course__c course2 = getCourse('Testkurs2');

        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', course1.Id);
        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', course1.Id);
        CourseRegistration__c cr3 = getCourseRegistration('Påmeldt', course2.Id);
        CourseRegistration__c cr4 = getCourseRegistration('Venteliste', course2.Id);
        CourseRegistration__c cr5 = getCourseRegistration('Venteliste', course2.Id);

        cr1.Status__c = 'Avmeldt';
        cr3.Status__c = 'Avmeldt';
        Test.StartTest();
        update new List<CourseRegistration__c>{ cr1, cr3 };
        Test.StopTest();

        Course__c course1After = fetchCourse('Testkurs');
        Course__c course2After = fetchCourse('Testkurs2');
        String cr2IdStatus = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr2.Id LIMIT 1].Status__c;
        String cr4IdStatus = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr4.Id LIMIT 1].Status__c;

        System.assertEquals(1, Integer.valueOf(course1After.NumberOfParticipants__c), 'Should be 1 participant');
        System.assertEquals(0, Integer.valueOf(course1After.WaitingList__c), 'Should be 0 on waiting list');
        System.assertEquals(1, Integer.valueOf(course2After.NumberOfParticipants__c), 'Should be 1 participant');
        System.assertEquals(1, Integer.valueOf(course2After.WaitingList__c), 'Should be 1 on waiting list');
        System.assertEquals('Påmeldt', cr2IdStatus, 'cr2 should have Påmeldt status');
        System.assertEquals('Påmeldt', cr4IdStatus, 'cr4 should have Påmeldt status');
    }

    public static CourseRegistration__c getCourseRegistration(String status, String courseId) {
        CourseRegistration__c cr = new CourseRegistration__c(
            ContactFirstName__c = 'Per',
            ContactLastName__c = 'Hansen',
            ContactPhone__c = '99887766',
            ContactEmail__c = 'per.hansen@test.no',
            Course__c = courseId,
            Status__c = status
        );
        insert cr;
        return cr;
    }

    public static Course__c getCourse(String courseName) {
        Course__c course = new Course__c(
            Name = courseName,
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = courseName,
            Active__c = true
        );
        insert course;
        return course;
    }

    public static Course__c fetchCourse(String courseName) {
        Course__c course = [
            SELECT Id, NumberOfParticipants__c, WaitingList__c
            FROM Course__c
            WHERE Name = :courseName
            LIMIT 1
        ];
        return course;
    }
}
