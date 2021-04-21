@isTest
public with sharing class CourseRegistrationHandlerTest {

    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testGetCourseIdToUpdate() {
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

        Decimal ParticipantCount = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;

        System.assertEquals(1, ParticipantCount, 'Should be 1 participant');

        Test.StartTest();
        delete cr;
        Test.StopTest();

        List <CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        Integer crCount = crList.size();

        System.assertEquals(0, crCount, 'Should be 0 registrations');

        Decimal ParticipantCountDel = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        System.assertEquals(0, ParticipantCountDel, 'Should be 0 participants');

        undelete cr;

        List <CourseRegistration__c> crListUnDel = [SELECT Id FROM CourseRegistration__c];
        Integer crCountUnDel = crListUnDel.size();

        System.assertEquals(1, crCountUnDel, 'Should be 1 registrations');

        Decimal ParticipantCountUnDel = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].NumberOfParticipants__c;
        System.assertEquals(1, ParticipantCountUnDel, 'Should be 1 participants');

    }

}
