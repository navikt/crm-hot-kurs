@isTest
public with sharing class CourseRegistrationHandlerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testDeleteUndeleteInsert() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        Course__c course2 = new Course__c(
            Name = 'Testkurs2',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs2',
            Active__c = true
        );
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
    private static void testInsertUpdate() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        Course__c course2 = new Course__c(
            Name = 'Testkurs2',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs2',
            Active__c = true
        );
        insert course2;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String courseId2 = [SELECT Id FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1].Id;

        System.assertEquals(null, course.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course.Waitinglist__c, 'Should be 0 on waitinglist');
        System.assertEquals(null, course2.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course2.Waitinglist__c, 'Should be 0 on waitinglist');

        CourseRegistration__c cr1 = getCourseRegistration('Invitert', courseId);
        insert cr1;

        CourseRegistration__c cr2 = getCourseRegistration('Avmeldt', courseId);
        insert cr2;

        CourseRegistration__c cr3 = getCourseRegistration('Venteliste', courseId2);
        insert cr3;

        CourseRegistration__c cr4 = getCourseRegistration('Påmeldt', courseId2);
        insert cr4;

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
        System.assertEquals(1, ParticipantCountC2, 'Should be 1 participant');
        System.assertEquals(1, WaitinglistCountC2, 'Should be 1 on waitinglist');

        Test.StartTest();
        List<CourseRegistration__c> crListUpd = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c]) {
            cr.Status__c = 'Påmeldt';
            crListUpd.add(cr);
        }
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
        String cr3IdStatusUpd1 = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr3.Id LIMIT 1].Status__c;

        System.assertEquals(2, ParticipantCountC1Upd1, 'Should be 2 participants');
        System.assertEquals(0, WaitinglistCountC1Upd1, 'Should be 0 on waitinglist');
        System.assertEquals(2, ParticipantCountC2Upd1, 'Should be 2 participants');
        System.assertEquals(0, WaitinglistCountC2Upd1, 'Should be 0 on waitinglist');
        System.assertEquals('Påmeldt', cr3IdStatusUpd1, 'cr3 should have Påmeldt');

        cr1.Status__c = 'Avmeldt';
        update cr1;
        cr2.Status__c = 'Avmeldt';
        update cr2;
        cr3.Status__c = 'Venteliste';
        update cr3;

        Decimal ParticipantCountC1Upd2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1Upd2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2Upd2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2Upd2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(0, ParticipantCountC1Upd2, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountC1Upd2, 'Should be 0 on waitinglist');
        System.assertEquals(1, ParticipantCountC2Upd2, 'Should be 1 participants');
        System.assertEquals(1, WaitinglistCountC2Upd2, 'Should be 1 on waitinglist');

        cr1.Status__c = 'Venteliste';
        update cr1;
        cr2.Status__c = 'Påmeldt';
        update cr2;

        Decimal ParticipantCountC1Upd3 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1Upd3 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(1, ParticipantCountC1Upd3, 'Should be 1 participants');
        System.assertEquals(1, WaitinglistCountC1Upd3, 'Should be 1 on waitinglist');
        System.assertEquals(1, ParticipantCountC2Upd2, 'Should be 1 participants');
        System.assertEquals(1, WaitinglistCountC2Upd2, 'Should be 1 on waitinglist');

        cr1.Status__c = 'Påmeldt';
        update cr1;
        cr3.Status__c = 'Avmeldt';
        update cr3;
        
        Decimal ParticipantCountC1Upd4 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1Upd4 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2Upd4 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2Upd4 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(2, ParticipantCountC1Upd4, 'Should be 2 participants');
        System.assertEquals(0, WaitinglistCountC1Upd4, 'Should be 0 on waitinglist');
        System.assertEquals(1, ParticipantCountC2Upd4, 'Should be 1 participants');
        System.assertEquals(0, WaitinglistCountC2Upd4, 'Should be 0 on waitinglist');

        List<CourseRegistration__c> crListUpd5 = new List<CourseRegistration__c>();
        cr1.Status__c = 'Avmeldt';
        crListUpd5.add(cr1);
        cr2.Status__c = 'Avmeldt';
        crListUpd5.add(cr2);
        update crListUpd5;

        Decimal ParticipantCountC1Upd5 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1Upd5 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(0, ParticipantCountC1Upd5, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountC1Upd4, 'Should be 0 on waitinglist');
    }
    private static void testDoubleUpdate() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        Course__c course2 = new Course__c(
            Name = 'Testkurs2',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs2',
            Active__c = true
        );
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

        Decimal ParticipantCountC1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .NumberOfParticipants__c;
        Decimal ParticipantCountC2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;

        System.assertEquals(2, ParticipantCountC1, 'Should be 2 participants');
        System.assertEquals(2, ParticipantCountC2, 'Should be 2 participants');

        Test.StartTest();
        List<CourseRegistration__c> crListUpdFromAtt = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId]) {
            cr.Status__c = 'Avmeldt';
            crListUpdFromAtt.add(cr);
        }

        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId2]) {
            cr.Status__c = 'Venteliste';
            crListUpdFromAtt.add(cr);
        }
        update crListUpdFromAtt;
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
        System.assertEquals(2, WaitinglistCountC2Upd1, 'Should be 2 on waitinglist');

        cr3.Status__c = 'Avmeldt';
        update cr3;
        cr4.Status__c = 'Avmeldt';
        update cr4;

        List<CourseRegistration__c> crListUpdFromNotAtt = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId]) {
            cr.Status__c = 'Påmeldt';
            crListUpdFromNotAtt.add(cr);
        }

        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId2]) {
            cr.Status__c = 'Venteliste';
            crListUpdFromNotAtt.add(cr);
        }
        update crListUpdFromNotAtt;
        Test.StopTest();

        Decimal ParticipantCountC1Upd2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1Upd2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2Upd2 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2Upd2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(2, ParticipantCountC1Upd2, 'Should be 2 participants');
        System.assertEquals(0, WaitinglistCountC1Upd2, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2Upd2, 'Should be 0 participants');
        System.assertEquals(2, WaitinglistCountC2Upd2, 'Should be 2 on waitinglist');

        cr1.Status__c = 'Venteliste';
        update cr1;
        cr2.Status__c = 'Venteliste';
        update cr2;

        Decimal WaitinglistCountC1UpdX = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal WaitinglistCountC2UpdX = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(2, WaitinglistCountC1UpdX, 'Should be 2 on waitinglist');
        System.assertEquals(2, WaitinglistCountC2UpdX, 'Should be 2 on waitinglist');

        List<CourseRegistration__c> crListUpdFromWaiting = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId]) {
            cr.Status__c = 'Påmeldt';
            crListUpdFromWaiting.add(cr);
        }

        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c = :courseId2]) {
            cr.Status__c = 'Avmeldt';
            crListUpdFromWaiting.add(cr);
        }
        update crListUpdFromWaiting;
        Test.StopTest();

        Decimal ParticipantCountC1Upd3 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC1Upd3 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1]
        .Waitinglist__c;
        Decimal ParticipantCountC2Upd3 = [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Name = 'Testkurs2'
            LIMIT 1
        ]
        .NumberOfParticipants__c;
        Decimal WaitinglistCountC2Upd3 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs2' LIMIT 1]
        .Waitinglist__c;

        System.assertEquals(2, ParticipantCountC1Upd3, 'Should be 2 participants');
        System.assertEquals(0, WaitinglistCountC1Upd3, 'Should be 0 on waitinglist');
        System.assertEquals(0, ParticipantCountC2Upd3, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountC2Upd3, 'Should be 0 on waitinglist');
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
}
