@isTest
private without sharing class EmailConfirmationModalHelperTest {
    @testSetup
    private static void setup() {
        EmailTemplate et = new EmailTemplate(
            DeveloperName = 'courseRegistrationInvitation',
            Name = 'courseRegistrationInvitation',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Invitasjon til kurs',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>'
        );
        Database.insert(et, false);
    }

    @isTest
    private static void testFetchOrCreateContacts() {
        List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize(
            EmailConfirmationModalModelTest.jsonData,
            List<EmailConfirmationModalModel>.class
        );

        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(0, contacts.size(), 'no contacts before test');

        Test.StartTest();
        EmailConfirmationModalHelper.fetchOrCreateContacts(recipients);
        Test.StopTest();

        contacts = [SELECT Id FROM Contact];
        System.assertEquals(3, contacts.size(), 'three contacts after test');
    }

    @isTest
    private static void testFetchOrCreateContacts_contactsExists() {
        Contact c1 = new Contact(LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true);
        Contact c2 = new Contact(LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true);
        Contact c3 = new Contact(LastName = 'test', email = 'per.nordmann@test.com', TAG_Informed__c = true);
        insert new List<Contact>{ c1, c2, c3 };

        List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize(
            EmailConfirmationModalModelTest.jsonData,
            List<EmailConfirmationModalModel>.class
        );

        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(3, contacts.size(), 'three contacts before test');

        Test.StartTest();
        contacts = EmailConfirmationModalHelper.fetchOrCreateContacts(recipients);
        Test.StopTest();

        System.assertEquals(3, contacts.size(), 'three contacts returned from function');

        contacts = [SELECT Id FROM Contact];
        System.assertEquals(3, contacts.size(), 'still three contacts after test');
    }

    @isTest
    private static void testSendEmailToCourseRecipients() {
        DateTime d = Date.today().addDays(1);
        Course__c course = new Course__c(
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = d,
            RegistrationFromDateTime__c = d,
            RegistrationToDateTime__c = d.addDays(1)
        );
        insert course;

        List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize(
            EmailConfirmationModalModelTest.jsonData,
            List<EmailConfirmationModalModel>.class
        );
        List<Contact> contacts = EmailConfirmationModalHelper.fetchOrCreateContacts(recipients);

        List<EmailMessage> emails = [SELECT HtmlBody, ToAddress FROM EmailMessage];
        System.assertEquals(0, emails.size(), 'No emails sent before');

        List<EmailTemplate> templates = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'courseRegistrationInvitation'
            LIMIT 1
        ];
        System.assertEquals(1, templates.size(), 'should be one template with name "courseRegistrationInvitation"');

        Test.StartTest();
        EmailConfirmationModalHelper.sendEmailToCourseRecipients(course.Id, contacts, templates[0].Id);
        Test.StopTest();

        emails = [SELECT Id, RelatedToId FROM EmailMessage];
        System.assertEquals(3, emails.size(), 'three emails sent, three EmailMessage created');

        for (EmailMessage email : emails) {
            System.assertEquals(course.Id, email.RelatedToId, 'Should be related to course');
        }
    }
}
