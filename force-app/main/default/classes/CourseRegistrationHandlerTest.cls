@isTest
public with sharing class CourseRegistrationHandlerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testInsertDeleteUndelete() {
        Course__c course = getCourse('Testkurs');
        insert course;

        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        System.assertEquals(null, course.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course2.NumberOfParticipants__c, 'Should be 0 participants');

        CourseRegistration__c cr = getCourseRegistration('Påmeldt', courseId);
        insert cr;

        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', courseId2);
        insert cr1;

        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', courseId2);
        insert cr2;

        Decimal ParticipantCount = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal ParticipantCount2 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCount2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(1, ParticipantCount, 'Should be 1 participant');
        System.assertEquals(1, ParticipantCount2, 'Should be 1 participant');
        System.assertEquals(1, WaitinglistCount2, 'Should be 1 on waitinglist');

        Test.StartTest();
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        delete crList;
        Test.StopTest();

        List<CourseRegistration__c> crListDel = [SELECT Id FROM CourseRegistration__c];
        Integer crCount = crListDel.size();

        System.assertEquals(0, crCount, 'Should be 0 registrations');

        Decimal ParticipantCountDel = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal ParticipantCount2Del = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCount2Del = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;
        System.assertEquals(0, ParticipantCountDel, 'Should be 0 participants');
        System.assertEquals(0, ParticipantCount2Del, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCount2Del, 'Should be 0 on waitinglist');

        undelete cr;
        undelete cr1;

        List<CourseRegistration__c> crListUnDel = [SELECT Id FROM CourseRegistration__c];
        Integer crCountUnDel = crListUnDel.size();

        System.assertEquals(2, crCountUnDel, 'Should be 2 registrations');

        Decimal ParticipantCountUnDel = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal ParticipantCount2UnDel = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCount2UnDel = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;
        System.assertEquals(1, ParticipantCountUnDel, 'Should be 1 participants');
        System.assertEquals(1, ParticipantCount2UnDel, 'Should be 1 participants');
        System.assertEquals(0, WaitinglistCount2UnDel, 'Should be 0 on waitinglist');
    }

    @isTest
    private static void testUpdateSingleFromAttending() {
        Course__c course = getCourse('Testkurs');
        insert course;
        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        System.assertEquals(null, course.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course.Waitinglist__c, 'Should be 0 on waitinglist');
        System.assertEquals(null, course2.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course2.Waitinglist__c, 'Should be 0 on waitinglist');

        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', courseId);
        insert cr1;

        CourseRegistration__c cr2 = getCourseRegistration('Påmeldt', courseId2);
        insert cr2;

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(1, ParticipantCountC1, 'Should be 1 participants');
        System.assertEquals(0, WaitinglistCountC1, 'Should be 0 on waitinglist');
        System.assertEquals(1, ParticipantCountC2, 'Should be 1 participant');
        System.assertEquals(0, WaitinglistCountC2, 'Should be 0 on waitinglist');

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        cr1.Status__c = 'Avmeldt';
        crListUpd.add(cr1);
        cr2.Status__c = 'Venteliste';
        crListUpd.add(cr2);

        update crListUpd;
        Test.StopTest();

        Decimal ParticipantCountC1Upd1 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1Upd1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2Upd1 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2Upd1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(0, ParticipantCountC1Upd1, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountC1Upd1, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2Upd1, 'Should be 0 participants');
        System.assertEquals(1, WaitinglistCountC2Upd1, 'Should be 1 on waitinglist');
    }
    @isTest
    private static void testUpdateSingleFromNotAttending() {
        Course__c course = getCourse('Testkurs');
        insert course;
        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        CourseRegistration__c cr1 = getCourseRegistration('Avmeldt', courseId);
        insert cr1;
        CourseRegistration__c cr2 = getCourseRegistration('Avmeldt', courseId2);
        insert cr2;

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        cr1.Status__c = 'Påmeldt';
        crListUpd.add(cr1);
        cr2.Status__c = 'Venteliste';
        crListUpd.add(cr2);

        update crListUpd;
        Test.StopTest();

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(1, ParticipantCountC1, 'Should be 1 participants');
        System.assertEquals(0, WaitinglistCountC1, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2, 'Should be 0 participants');
        System.assertEquals(1, WaitinglistCountC2, 'Should be 1 on waitinglist');
    }
    @isTest
    private static void testUpdateSingleFromWaiting() {
        Course__c course = getCourse('Testkurs');
        insert course;
        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        CourseRegistration__c cr1 = getCourseRegistration('Venteliste', courseId);
        insert cr1;
        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', courseId2);
        insert cr2;

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        cr1.Status__c = 'Påmeldt';
        crListUpd.add(cr1);
        cr2.Status__c = 'Avmeldt';
        crListUpd.add(cr2);

        update crListUpd;
        Test.StopTest();

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(1, ParticipantCountC1, 'Should be 1 participants');
        System.assertEquals(0, WaitinglistCountC1, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountC2, 'Should be 0 on waitinglist');
    }
    @isTest
    private static void testUpdateDoubleFromAttending() {
        Course__c course = getCourse('Testkurs');
        insert course;
        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', courseId);
        insert cr1;
        CourseRegistration__c cr2 = getCourseRegistration('Påmeldt', courseId);
        insert cr2;
        CourseRegistration__c cr3 = getCourseRegistration('Påmeldt', courseId2);
        insert cr3;
        CourseRegistration__c cr4 = getCourseRegistration('Påmeldt', courseId2);
        insert cr4;

        Decimal ParticipantCount1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal ParticipantCount2 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .NumberOfParticipants__c;

        System.assertEquals(2, ParticipantCount1, 'Should be 2 participants');
        System.assertEquals(2, ParticipantCount2, 'Should be 2 participants');

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId]) {
            cr.Status__c = 'Avmeldt';
            crListUpd.add(cr);
        }

        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId2]) {
            cr.Status__c = 'Venteliste';
            crListUpd.add(cr);
        }
        update crListUpd;
        Test.StopTest();

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(0, ParticipantCountC1, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountC1, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2, 'Should be 0 participants');
        System.assertEquals(2, WaitinglistCountC2, 'Should be 2 on waitinglist');
    }
    @isTest
    private static void testUpdateDoubleFromNotAttending() {
        Course__c course = getCourse('Testkurs');
        insert course;
        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        CourseRegistration__c cr1 = getCourseRegistration('Avmeldt', courseId);
        insert cr1;
        CourseRegistration__c cr2 = getCourseRegistration('Avmeldt', courseId);
        insert cr2;
        CourseRegistration__c cr3 = getCourseRegistration('Avmeldt', courseId2);
        insert cr3;
        CourseRegistration__c cr4 = getCourseRegistration('Avmeldt', courseId2);
        insert cr4;

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId]) {
            cr.Status__c = 'Påmeldt';
            crListUpd.add(cr);
        }

        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId2]) {
            cr.Status__c = 'Venteliste';
            crListUpd.add(cr);
        }
        update crListUpd;
        Test.StopTest();

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(2, ParticipantCountC1, 'Should be 2 participants');
        System.assertEquals(0, WaitinglistCountC1, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2, 'Should be 0 participants');
        System.assertEquals(2, WaitinglistCountC2, 'Should be 2 on waitinglist');
    }
    @isTest
    private static void testUpdateDoubleFromWaiting() {
        Course__c course = getCourse('Testkurs');
        insert course;
        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        CourseRegistration__c cr1 = getCourseRegistration('Venteliste', courseId);
        insert cr1;
        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', courseId);
        insert cr2;
        CourseRegistration__c cr3 = getCourseRegistration('Venteliste', courseId2);
        insert cr3;
        CourseRegistration__c cr4 = getCourseRegistration('Venteliste', courseId2);
        insert cr4;

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId]) {
            cr.Status__c = 'Påmeldt';
            crListUpd.add(cr);
        }

        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId2]) {
            cr.Status__c = 'Avmeldt';
            crListUpd.add(cr);
        }
        update crListUpd;
        Test.StopTest();

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(2, ParticipantCountC1, 'Should be 2 participants');
        System.assertEquals(0, WaitinglistCountC1, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountC2, 'Should be 0 on waitinglist');
    }
    @isTest
    private static void testWaitingListFunctionality() {
        Course__c course = getCourse('Testkurs');
        insert course;
        Course__c course2 = getCourse('Testkurs2');
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        CourseRegistration__c cr1 = getCourseRegistration('Påmeldt', courseId);
        insert cr1;
        CourseRegistration__c cr2 = getCourseRegistration('Venteliste', courseId);
        insert cr2;
        CourseRegistration__c cr3 = getCourseRegistration('Påmeldt', courseId2);
        insert cr3;
        CourseRegistration__c cr4 = getCourseRegistration('Venteliste', courseId2);
        insert cr4;
        CourseRegistration__c cr5 = getCourseRegistration('Venteliste', courseId2);
        insert cr5;

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        cr1.Status__c = 'Avmeldt';
        crListUpd.add(cr1);

        cr3.Status__c = 'Avmeldt';
        crListUpd.add(cr3);

        update crListUpd;
        Test.StopTest();

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;
        String cr2IdStatus = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr2.Id LIMIT 1].Status__c;
        String cr4IdStatus = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr4.Id LIMIT 1].Status__c;

        System.assertEquals(1, ParticipantCountC1, 'Should be 1 participant');
        System.assertEquals(0, WaitinglistCountC1, 'Should be 0 on waitinglist');
        System.assertEquals(1, ParticipantCountC2, 'Should be 1 participant');
        System.assertEquals(1, WaitinglistCountC2, 'Should be 1 on waitinglist');
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
        return cr;
    }

    public static Course__c getCourse(String courseName) {
        Course__c course = new Course__c(
            Name = courseName,
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = courseName,
            Active__c = true
        );
        return course;
    }
}
