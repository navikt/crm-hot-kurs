@isTest
private with sharing class CreateContactFromCourseRegistrationTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testFetchAccount() {
        Account a = new Account();
        a.Name = 'Kursdeltakere';
        a.INT_OrganizationNumber__c = 'Kurs';
        insert a;

        Test.startTest();
        Map<String, Account> result = CreateContactFromCourseRegistration.fetchAccount();
        Test.stopTest();

        System.assertEquals(
            a.Id,
            result.get(a.INT_OrganizationNumber__c).Id,
            'Should be the same account'
        );
    }

    @isTest
    private static void testFindOrCreateContact() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true
        );
        insert course;
        List<CourseRegistration__c> registrations = new List<CourseRegistration__c>();
        CourseRegistration__c registration = new CourseRegistration__c(
            ContactFirstName__c = 'Per',
            ContactLastName__c = 'Hansen',
            ContactPhone__c = '99887766',
            ContactEmail__c = 'per.hansen@test.no',
            Course__c = course.Id,
            Status__c = 'Påmeldt'
        );
        insert registration;

        registrations.add(registration);

        CreateContactFromCourseRegistration.findOrCreateContact(registrations);
    }
}
