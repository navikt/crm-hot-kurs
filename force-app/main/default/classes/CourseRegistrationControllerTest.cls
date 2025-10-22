@isTest
private with sharing class CourseRegistrationControllerTest {
    @TestSetup
    static void setupData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    static void testMissingParameters() {
        CourseRegistrationController.RegistrationResult res1 = CourseRegistrationController.createRegistration(
            null,
            null
        );
        System.assertEquals(false, res1.success);
        System.assert(res1.message.contains('Nødvendig informasjon mangler'));

        String dummy = '{"email":"x@y.com"}';
        CourseRegistrationController.RegistrationResult res2 = CourseRegistrationController.createRegistration(
            dummy,
            ''
        );
        System.assertEquals(false, res2.success);
        System.assert(res2.message.contains('Nødvendig informasjon mangler'));
    }

    @isTest
    static void testInvalidJson() {
        // Invalid JSON yields failure
        CourseRegistrationController.RegistrationResult res = CourseRegistrationController.createRegistration(
            'not a json',
            '001000000000001'
        );
        System.assertEquals(false, res.success);
        // Message should indicate either parsing error or unexpected error
        System.assert(
            res.message.contains('ugyldige') || res.message.contains('feil'),
            'Expected error message for invalid JSON'
        );
    }

    @isTest
    static void testCourseCancelled() {
        Course__c c = new Course__c(Name = 'Cancelled', MaxNumberOfParticipants__c = 5, Cancel__c = true);
        insert c;

        CourseRegistrationModel m = new CourseRegistrationModel();
        m.firstName = 'F';
        m.lastName = 'L';
        m.email = 'a@b.com';
        String json = JSON.serialize(m);

        CourseRegistrationController.RegistrationResult res = CourseRegistrationController.createRegistration(
            json,
            c.Id
        );
        System.assertEquals(false, res.success);
        System.assert(res.message.contains('Kurset er avlyst'));
    }

    @isTest
    static void testSuccessful() {
        Course__c c = new Course__c(Name = 'Open', MaxNumberOfParticipants__c = 2);
        insert c;

        CourseRegistrationModel m1 = new CourseRegistrationModel();
        m1.firstName = 'A';
        m1.lastName = 'A';
        m1.email = 'a@a.com';
        m1.numberOfParticipants = 1;
        String j1 = JSON.serialize(m1);
        CourseRegistrationController.RegistrationResult r1 = CourseRegistrationController.createRegistration(j1, c.Id);
        System.assertEquals(true, r1.success);
        System.assert(r1.message.contains('Påmelding vellykket'));
    }
    @isTest
    static void testDuplicate() {
        Course__c c = new Course__c(
            Name = 'duplicateCourseTest',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'description',
            Active__c = true
        );
        insert c;

        CourseRegistrationModel crDuplicate = new CourseRegistrationModel();
        crDuplicate.firstName = 'dup';
        crDuplicate.lastName = 'dup';
        crDuplicate.email = 'duplicate@duplicate.com';
        crDuplicate.phone = '99999999';
        crDuplicate.county = 'Agder';
        crDuplicate.numberOfParticipants = 1;
        String j1 = JSON.serialize(crDuplicate);
        CourseRegistrationController.RegistrationResult r1 = CourseRegistrationController.createRegistration(j1, c.Id);

        Test.startTest();
        CourseRegistrationModel crDuplicate2 = new CourseRegistrationModel();
        crDuplicate2.firstName = 'dup';
        crDuplicate2.lastName = 'dup';
        crDuplicate2.email = 'duplicate@duplicate.com';
        crDuplicate2.phone = '99999999';
        crDuplicate2.county = 'Agder';
        String j2 = JSON.serialize(crDuplicate2);
        CourseRegistrationController.RegistrationResult r2 = CourseRegistrationController.createRegistration(j2, c.Id);
        Test.stopTest();
        System.assertEquals(false, r2.success);
        System.assert(r2.message.contains('allerede påmeldt'));
    }

    @isTest
    static void testInsufficientCapacity() {
        Course__c c = new Course__c(Name = 'Small', MaxNumberOfParticipants__c = 1, NumberOfParticipants__c = 0);
        insert c;

        CourseRegistrationModel m = new CourseRegistrationModel();
        m.firstName = 'X';
        m.lastName = 'Y';
        m.email = 'x@y.com';
        m.numberOfParticipants = 2;
        String j = JSON.serialize(m);

        CourseRegistrationController.RegistrationResult res = CourseRegistrationController.createRegistration(j, c.Id);
        System.assertEquals(false, res.success);
        System.assert(res.message.contains('ikke nok ledige plasser'));
    }

    @isTest
    static void testWaitlistLogic() {
        Course__c c = new Course__c(Name = 'Full', MaxNumberOfParticipants__c = 1, NumberOfParticipants__c = 1);
        insert c;

        CourseRegistrationModel mw = new CourseRegistrationModel();
        mw.firstName = 'M';
        mw.lastName = 'W';
        mw.email = 'm@w.com';
        mw.numberOfParticipants = 2;
        String jm = JSON.serialize(mw);
        CourseRegistrationController.RegistrationResult rm = CourseRegistrationController.createRegistration(jm, c.Id);
        System.assertEquals(false, rm.success);
        System.assert(rm.message.contains('én deltaker'));

        CourseRegistrationModel sw = new CourseRegistrationModel();
        sw.firstName = 'S';
        sw.lastName = 'W';
        sw.email = 's@w.com';
        sw.numberOfParticipants = 1;
        String js = JSON.serialize(sw);
        CourseRegistrationController.RegistrationResult rs = CourseRegistrationController.createRegistration(js, c.Id);
        System.assertEquals(true, rs.success);
        System.assert(rs.message.contains('venteliste'));
    }

    @isTest
    static void testGetCourseFields() {
        DateTime fromDT = System.now().addDays(1);
        DateTime toDT = System.now().addDays(5);
        Course__c c = new Course__c(
            Name = 'Fields',
            RegistrationDeadline__c = Date.today().addDays(10),
            RegistrationFromDateTime__c = fromDT,
            RegistrationToDateTime__c = toDT,
            Type__c = 'Kurs',
            MaxNumberOfParticipants__c = 50,
            Waitinglist__c = 1,
            ShowCompany__c = true,
            ShowCounty__c = true,
            ShowRole__c = true,
            Cancel__c = false
        );
        insert c;

        Course__c f = CourseRegistrationController.getCourseFields(c.Id);
        System.assertEquals(c.Name, f.Name);
        System.assertEquals(c.Type__c, f.Type__c);
        System.assertEquals(c.MaxNumberOfParticipants__c, f.MaxNumberOfParticipants__c);
        System.assertEquals(c.RegistrationDeadline__c, f.RegistrationDeadline__c);
        System.assertEquals(c.RegistrationFromDateTime__c, f.RegistrationFromDateTime__c);
        System.assertEquals(c.RegistrationToDateTime__c, f.RegistrationToDateTime__c);
        System.assertEquals(c.Waitinglist__c, f.Waitinglist__c);
    }

    @IsTest
    static void getOrganizationInfoTest() {
        Account acc = new Account();
        acc.Name = 'The Organization';
        acc.INT_OrganizationNumber__c = '213456784';
        insert acc;

        Test.startTest();
        List<Account> accounts = CourseRegistrationController.getOrganizationInfo('213456784');
        Test.stopTest();
        System.assertEquals(1, accounts.size());
        System.assertEquals('The Organization', accounts[0].Name, 'Account name should match');
        System.assertEquals('213456784', accounts[0].INT_OrganizationNumber__c, 'Account number should match');
    }

    @IsTest
    static void getOrganizationInfoTestWithNoAccounts() {

        Test.startTest();
        List<Account> accounts = CourseRegistrationController.getOrganizationInfo('999999999');
        Test.stopTest();

        System.assertEquals(0, accounts.size(), 'No accounts should be returned when the organization number is not found');
    }
}
