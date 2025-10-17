@isTest
private with sharing class CourseUnsubscribeControllerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testCourseUnsubscribe() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        Contact participant = new Contact(
            FirstName = 'Test',
            LastName = 'Testesen',
            Email = 'test.testesen@test.no',
            TAG_Informed__c = true
        );
        insert participant;

        CourseRegistration__c courseReg = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = participant.Id,
            Status__c = 'Påmeldt'
        );
        insert courseReg;

        String encrypted = EncodingUtil.urlDecode(
            [SELECT EncryptedId__c FROM CourseRegistration__c WHERE Id = :courseReg.Id LIMIT 1].EncryptedId__c,
            'UTF-8'
        );

        Test.startTest();
        CourseRegistration__c result = CourseUnsubscribeController.getCourseRegistrationFields(encrypted);
        CourseRegistration__c unsubscribed = CourseUnsubscribeController.updateCourseRegistrationStatusToAvmeldt(
            encrypted
        );
        Test.stopTest();

        System.assertEquals('Avmeldt', unsubscribed.Status__c, 'Participant is unsubscribed');
    }

    @isTest
    private static void testUpdateNumberOfParticipants() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        Contact participant = new Contact(
            FirstName = 'Test',
            LastName = 'Testesen',
            Email = 'test.testesen@test.no',
            TAG_Informed__c = true
        );
        insert participant;

        CourseRegistration__c courseReg = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = participant.Id,
            Status__c = 'Påmeldt',
            NumberOfParticipants__c = 3
        );
        insert courseReg;

        String encrypted = EncodingUtil.urlDecode(
            [SELECT EncryptedId__c FROM CourseRegistration__c WHERE Id = :courseReg.Id LIMIT 1].EncryptedId__c,
            'UTF-8'
        );

        Test.startTest();
        Integer newCount = 5;
        CourseRegistration__c updated = CourseUnsubscribeController.updateCourseRegistrationNumberOfParticipants(
            encrypted,
            newCount
        );
        Test.stopTest();

        System.assertEquals(newCount, updated.NumberOfParticipants__c, 'NumberOfParticipants should be updated');

        CourseRegistration__c reloaded = [
            SELECT NumberOfParticipants__c, Status__c
            FROM CourseRegistration__c
            WHERE Id = :courseReg.Id
        ];
        System.assertEquals(newCount, reloaded.NumberOfParticipants__c, 'Persisted value mismatch');
        System.assertEquals('Påmeldt', reloaded.Status__c, 'Status should remain unchanged');
    }
}
