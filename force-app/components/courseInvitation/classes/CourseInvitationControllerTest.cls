@isTest
private without sharing class CourseInvitationControllerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    private static void testCreateCourseRegistrations() {
        DateTime d = Date.today().addDays(1);
        Course__c course = new Course__c(
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region__c = 'Oslo',
            RegistrationDeadline__c = d,
            RegistrationFromDateTime__c = d,
            RegistrationToDateTime__c = d.addDays(1)
        );
        insert course;

        List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize(
            EmailConfirmationModalModelTest.jsonData,
            List<EmailConfirmationModalModel>.class
        );
        List<Contact> contacts = EmailConfirmationModalHelper.fetchOrCreateContacts(
            recipients
        );

        System.assertEquals(3, contacts.size(), 'three contacts should exist');

        List<CourseRegistration__c> registrations = [
            SELECT Id
            FROM CourseRegistration__c
        ];
        System.assertEquals(
            0,
            registrations.size(),
            'no registrations before test'
        );

        Test.StartTest();
        CourseInvitationController.createCourseRegistrations(
            course.Id,
            contacts
        );
        Test.StopTest();

        registrations = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(
            3,
            registrations.size(),
            'three registrations after test'
        );
    }

    @isTest
    private static void testCreateCourseRegistrations_allRegistrationsExists() {
        Contact c1 = new Contact(
            LastName = 'test',
            email = 'ola.nordmann@test.com',
            TAG_Informed__c = true
        );
        Contact c2 = new Contact(
            LastName = 'test',
            email = 'kari.nordmann@test.com',
            TAG_Informed__c = true
        );
        Contact c3 = new Contact(
            LastName = 'test',
            email = 'per.nordmann@test.com',
            TAG_Informed__c = true
        );
        insert new List<Contact>{ c1, c2, c3 };

        DateTime d = Date.today().addDays(1);
        Course__c course = new Course__c(
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region__c = 'Oslo',
            RegistrationDeadline__c = d,
            RegistrationFromDateTime__c = d,
            RegistrationToDateTime__c = d.addDays(1)
        );
        insert course;
        CourseRegistration__c reg1 = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = c1.Id,
            Status__c = 'Påmeldt'
        );
        CourseRegistration__c reg2 = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = c2.Id,
            Status__c = 'Påmeldt'
        );
        CourseRegistration__c reg3 = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = c3.Id,
            Status__c = 'Påmeldt'
        );
        insert new List<CourseRegistration__c>{ reg1, reg2, reg3 };

        List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize(
            EmailConfirmationModalModelTest.jsonData,
            List<EmailConfirmationModalModel>.class
        );
        List<Contact> contacts = EmailConfirmationModalHelper.fetchOrCreateContacts(
            recipients
        );

        System.assertEquals(3, contacts.size(), 'three contacts should exist');

        List<CourseRegistration__c> registrations = [
            SELECT Id
            FROM CourseRegistration__c
        ];
        System.assertEquals(
            3,
            registrations.size(),
            'three registrations before test'
        );

        Test.StartTest();
        registrations = CourseInvitationController.createCourseRegistrations(
            course.Id,
            contacts
        );
        Test.StopTest();

        System.assertEquals(
            3,
            registrations.size(),
            'three registrations return in function'
        );
    }

    @isTest
    private static void testCreateCourseRegistrations_alreadyExists() {
        Contact con = new Contact(
            LastName = 'test',
            email = 'ola.nordmann@test.com',
            TAG_Informed__c = true
        );
        insert con;
        DateTime d = Date.today().addDays(1);
        Course__c course = new Course__c(
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region__c = 'Oslo',
            RegistrationDeadline__c = d,
            RegistrationFromDateTime__c = d,
            RegistrationToDateTime__c = d.addDays(1)
        );
        insert course;
        CourseRegistration__c reg = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = con.Id,
            Status__c = 'Påmeldt'
        );
        insert reg;

        List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize(
            EmailConfirmationModalModelTest.jsonData,
            List<EmailConfirmationModalModel>.class
        );
        List<Contact> contacts = EmailConfirmationModalHelper.fetchOrCreateContacts(
            recipients
        );

        System.assertEquals(3, contacts.size(), 'three contacts should exist');

        List<CourseRegistration__c> registrations = [
            SELECT Id
            FROM CourseRegistration__c
        ];
        System.assertEquals(
            1,
            registrations.size(),
            'one registration before test'
        );

        Test.StartTest();
        CourseInvitationController.createCourseRegistrations(
            course.Id,
            contacts
        );
        Test.StopTest();

        registrations = [
            SELECT Id
            FROM CourseRegistration__c
            WHERE Status__c = 'Invitert'
        ];
        System.assertEquals(
            2,
            registrations.size(),
            'two invited registrations after test'
        );

        registrations = [
            SELECT Id
            FROM CourseRegistration__c
            WHERE Status__c = 'Påmeldt'
        ];
        System.assertEquals(
            1,
            registrations.size(),
            'one attending registrations after test'
        );
    }
}
