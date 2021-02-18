@isTest
private with sharing class CourseRegistrationControllerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testCreateRegistration() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;

        String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
        String noCourseId;

        CourseRegistrationModel wrapper = new CourseRegistrationModel();
        wrapper.firstName = 'test';
        wrapper.lastName = 'etternavn';
        wrapper.phone = '90080900';
        wrapper.email = 'test@test.com';
        wrapper.companyNumber = '677777';
        wrapper.source = 'Kurs';

        String fields = JSON.serialize(wrapper);

        Test.StartTest();
        String result = CourseRegistrationController.createRegistration(fields, courseId);
        String result2 = CourseRegistrationController.createRegistration(fields, noCourseId);
        Test.StopTest();
        System.assertEquals(
            'Påmelding vellykket. Du vil om kort tid motta en bekreftelse på e-post',
            result,
            'Registration successfull'
        );
        System.assertEquals('Det oppsto en feil. Prøv igjen senere.', result2, 'Course id missing');
    }
}
