@isTest
public with sharing class CourseRegistrationHandlerTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testDeleteUndelteInsert() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;

        System.assertEquals(null, course.NumberOfParticipants__c, 'Should be 0 participants');

        CourseRegistration__c cr = new CourseRegistration__c(
            ContactFirstName__c = 'Per',
            ContactLastName__c = 'Hansen',
            ContactPhone__c = '99887766',
            ContactEmail__c = 'per.hansen@test.no',
            Course__c = courseId,
            Status__c = 'Påmeldt'
        );
        insert cr;

        CourseRegistration__c cr1 = new CourseRegistration__c(
            ContactFirstName__c = 'Per',
            ContactLastName__c = 'Hansen',
            ContactPhone__c = '99887766',
            ContactEmail__c = 'per.hansen@test.no',
            Course__c = courseId,
            Status__c = 'Venteliste'
        );
        insert cr1;

        Decimal ParticipantCount = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        Decimal WaitinglistCount = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Waitinglist__c;

        System.assertEquals(1, ParticipantCount, 'Should be 1 participant');
        System.assertEquals(1, WaitinglistCount, 'Should be 1 on waitinglist');

        Test.StartTest();
        delete cr;
        delete cr1;
        Test.StopTest();

        List <CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        Integer crCount = crList.size();

        System.assertEquals(0, crCount, 'Should be 0 registrations');

        Decimal ParticipantCountDel = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        Decimal WaitinglistCountDel = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Waitinglist__c;
        System.assertEquals(0, ParticipantCountDel, 'Should be 0 participants');
        System.assertEquals(0, WaitinglistCountDel, 'Should be 0 on waitinglist');

        undelete cr;
        undelete cr1;

        List <CourseRegistration__c> crListUnDel = [SELECT Id FROM CourseRegistration__c];
        Integer crCountUnDel = crListUnDel.size();

        System.assertEquals(2, crCountUnDel, 'Should be 2 registrations');

        Decimal ParticipantCountUnDel = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        Decimal WaitinglistCountUnDel = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Waitinglist__c;
        System.assertEquals(1, ParticipantCountUnDel, 'Should be 1 participants');
        System.assertEquals(1, WaitinglistCountUnDel, 'Should be 1 on waitinglist');

    }

    @isTest
    private static void testUpdate() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;

        System.assertEquals(null, course.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course.Waitinglist__c, 'Should be 0 on waitinglist');

        CourseRegistration__c cr1 = new CourseRegistration__c(
            ContactFirstName__c = 'Per',
            ContactLastName__c = 'Hansen',
            ContactPhone__c = '99887766',
            ContactEmail__c = 'per.hansen@test.no',
            Course__c = courseId,
            Status__c = 'Invitert'
        );
        insert cr1;

        CourseRegistration__c cr2 = new CourseRegistration__c(
            ContactFirstName__c = 'Per',
            ContactLastName__c = 'Hansen',
            ContactPhone__c = '99887766',
            ContactEmail__c = 'per.hansen@test.no',
            Course__c = courseId,
            Status__c = 'Invitert'
        );
        insert cr2;

        CourseRegistration__c cr3 = new CourseRegistration__c(
            ContactFirstName__c = 'Per',
            ContactLastName__c = 'Hansen',
            ContactPhone__c = '99887766',
            ContactEmail__c = 'per.hansen@test.no',
            Course__c = courseId,
            Status__c = 'Invitert'
        );
        insert cr3;

        System.assertEquals(null, course.NumberOfParticipants__c, 'Should be 0 participants');
        System.assertEquals(null, course.Waitinglist__c, 'Should be 0 on waitinglist');

        Test.StartTest();
        cr1.Status__c = 'Påmeldt';
        update cr1;
        cr2.Status__c = 'Venteliste';
        update cr2;
        cr3.Status__c = 'Venteliste';
        update cr3;
        Test.StopTest();

        Decimal ParticipantCount = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        Decimal WaitinglistCount = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Waitinglist__c;

        System.assertEquals(1, ParticipantCount, 'Should be 1 participants');
        System.assertEquals(2, WaitinglistCount, 'Should be 2 on waitinglist');

        cr1.Status__c = 'Avmeldt';
        update cr1;

        Decimal ParticipantCountUpd1 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        Decimal WaitinglistCountUpd1 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Waitinglist__c;
        String cr2Id = cr2.Id;
        String cr2IdStatus = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id = :cr2Id LIMIT 1].Status__c;

        System.assertEquals(1, ParticipantCountUpd1, 'Should be 1 participants');
        System.assertEquals(1, WaitinglistCountUpd1, 'Should be 1 on waitinglist');
        System.assertEquals('Påmeldt', cr2IdStatus, 'cr2 should have Påmeldt');

        cr2.Status__c = 'Venteliste';
        update cr2;

        Decimal ParticipantCountUpd2 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        Decimal WaitinglistCountUpd2 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Waitinglist__c;

        System.assertEquals(0, ParticipantCountUpd2, 'Should be 0 participants');
        System.assertEquals(2, WaitinglistCountUpd2, 'Should be 2 on waitinglist');

        cr2.Status__c = 'Avmeldt';
        update cr2;

        Decimal ParticipantCountUpd3 = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        Decimal WaitinglistCountUpd3 = [SELECT Id, Waitinglist__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Waitinglist__c;

        System.assertEquals(0, ParticipantCountUpd3, 'Should be 0 participants');
        System.assertEquals(1, WaitinglistCountUpd3, 'Should be 1 on waitinglist');
    }

}
