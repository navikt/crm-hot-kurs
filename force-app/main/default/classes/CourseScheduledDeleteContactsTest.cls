@isTest
public with sharing class CourseScheduledDeleteContactsTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }
    @isTest
    private static void testContactsForDeletion() {
        Course__c course1 = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course1.RegistrationToDateTime__c = Datetime.Now().addDays(-85);
        update course1;

        Account accountCourse = new Account(Name = 'Kontakter uten konto');
        insert accountCourse;

        Contact contact1 = getContact(accountCourse.Id, 'test1@test.no');
        Contact contact2 = getContact(accountCourse.Id, 'test2@test.no');

        CourseRegistration__c cr1 = getCourseRegistration(course1.Id, contact1.Id);
        CourseRegistration__c cr2 = getCourseRegistration(course1.Id, contact2.Id);

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(2, contacts.size(), 'Should be 2 contacts');
        System.assertEquals(2, crList.size(), 'Should be 2 registrations');

        Test.StartTest();
        CourseScheduledDeleteContacts.courseScheduledDeleteContacts();
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crListAfter = [SELECT Id FROM CourseRegistration__c];
        List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation];
        CourseRegistration__c cr1After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr1.Id
        ];
        CourseRegistration__c cr2After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr2.Id
        ];
        System.assertEquals(0, contactsAfter.size(), 'Should be 0 contacts');
        System.assertEquals(2, crListAfter.size(), 'Should be 2 registrations');
        System.assertEquals(0, acrList.size(), 'Should be 0 Account-Contact relations');
        System.assertEquals(null, cr1After.CourseParticipant__c, 'Should be no contact for cr1');
        System.assertEquals(null, cr2After.CourseParticipant__c, 'Should be no contact for cr2');
    }

    @isTest
    private static void testEmailForDeletion() {
        Course__c course1 = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course1.RegistrationToDateTime__c = Datetime.Now().addDays(-85);
        update course1;

        Account accountCourse = new Account(Name = 'Kontakter uten konto');
        insert accountCourse;

        Contact contact1 = getContact(accountCourse.Id, 'test1@test.no');
        Contact contact2 = getContact(accountCourse.Id, 'test2@test.no');

        CourseRegistration__c cr1 = getCourseRegistration(course1.Id, contact1.Id);
        CourseRegistration__c cr2 = getCourseRegistration(course1.Id, contact2.Id);

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        EmailMessage email1 = new EmailMessage();
        email1.Subject = 'Test';
        email1.FromAddress = 'fakeemail@nav.no.scratchorg';
        email1.ToAddress = 'fakeemail@nav.no.scratchorg';
        email1.TextBody = 'Test';
        email1.RelatedToId = cr1.Id;
        email1.Status = '3';
        insert email1;

        EmailMessage email2 = new EmailMessage();
        email2.Subject = 'Test';
        email2.FromAddress = 'fakeemail@nav.no.scratchorg';
        email2.ToAddress = 'fakeemail@nav.no.scratchorg';
        email2.TextBody = 'Test';
        email2.Status = '3';
        email2.RelatedToId = cr2.Id;
        insert email2;

        List<EmailMessage> emailList = [SELECT Id FROM EmailMessage WHERE RelatedToId IN :crList];
        System.assertEquals(2, contacts.size(), 'Should be 2 contacts');
        System.assertEquals(2, crList.size(), 'Should be 2 registrations');
        System.assertEquals(2, emailList.size(), 'Should be 2 emails');

        Test.StartTest();
        CourseScheduledDeleteContacts.courseScheduledDeleteContacts();
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crListAfter = [SELECT Id FROM CourseRegistration__c];
        List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation];
        CourseRegistration__c cr1After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr1.Id
        ];
        CourseRegistration__c cr2After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr2.Id
        ];
        List<EmailMessage> emailListAfter = [SELECT Id FROM EmailMessage WHERE RelatedToId IN :crList];
        System.assertEquals(0, contactsAfter.size(), 'Should be 0 contacts');
        System.assertEquals(2, crListAfter.size(), 'Should be 2 registrations');
        System.assertEquals(0, emailListAfter.size(), 'Should be 0 Email messages');
    }

    @isTest
    private static void testContactWithRelationToOtherAccounts() {
        Course__c course1 = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course1.RegistrationToDateTime__c = Datetime.Now().addDays(-85);
        update course1;

        Account accountCourse = new Account(Name = 'Kontakter uten konto');
        Account accountNotCourse1 = new Account(Name = 'Not Kursdeltakere');
        Account accountNotCourse2 = new Account(Name = 'Test Account');
        insert new List<Account>{ accountCourse, accountNotCourse1, accountNotCourse2 };

        Contact contactCourseAcc1 = getContact(accountCourse.Id, 'test1@test.no'); //Only this one should be deleted
        Contact contactCourseAccAndNotCourseAcc1 = getContact(accountCourse.Id, 'test2@test.no');
        Contact contactNotCourseAcc1 = getContact(accountNotCourse1.Id, 'test3@test.no');

        AccountContactRelation relation = new AccountContactRelation(
            AccountId = accountNotCourse2.Id,
            ContactId = contactCourseAccAndNotCourseAcc1.Id
        );
        insert relation;

        CourseRegistration__c cr1 = getCourseRegistration(course1.Id, contactCourseAcc1.Id);
        CourseRegistration__c cr2 = getCourseRegistration(course1.Id, contactCourseAccAndNotCourseAcc1.Id);
        CourseRegistration__c cr3 = getCourseRegistration(course1.Id, contactNotCourseAcc1.Id);

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation];
        System.assertEquals(3, contacts.size(), 'Should be 3 contacts');
        System.assertEquals(3, crList.size(), 'Should be 3 registrations');
        System.assertEquals(4, acrList.size(), 'Should be 4 relations');

        Test.StartTest();
        CourseScheduledDeleteContacts.courseScheduledDeleteContacts();
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crListAfter = [SELECT Id FROM CourseRegistration__c];
        List<AccountContactRelation> acrListAfter = [SELECT Id FROM AccountContactRelation];
        CourseRegistration__c cr1After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr1.Id
        ];
        CourseRegistration__c cr2After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr2.Id
        ];
        CourseRegistration__c cr3After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr3.Id
        ];
        System.assertEquals(2, contactsAfter.size(), 'Should be 2 contacts');
        System.assertEquals(3, crListAfter.size(), 'Should be 3 registrations');
        System.assertEquals(3, acrListAfter.size(), 'Should be 3 Account-Contact relations');
        System.assertEquals(null, cr1After.CourseParticipant__c, 'Should be no contact for cr1');
        System.assertEquals(null, cr2After.CourseParticipant__c, 'Should be no contact for cr2');
        System.assertEquals(null, cr3After.CourseParticipant__c, 'Should be no contact for cr3');
    }

    @isTest
    private static void testContactAttendingSoonerCourse() {
        Course__c course1 = CourseRegistrationHandlerTest.getCourse('Testkurs');
        Course__c course2 = CourseRegistrationHandlerTest.getCourse('Testkurs2');
        course1.RegistrationToDateTime__c = Datetime.Now().addDays(-85);
        course2.RegistrationToDateTime__c = Datetime.Now().addDays(-83);
        update new List<Course__c>{ course1, course2 };

        Account accountCourse = new Account(Name = 'Kontakter uten konto');
        insert accountCourse;

        Contact contactCourse1 = getContact(accountCourse.Id, 'test1@test.no'); //Only this one should be deleted
        Contact contactCourse2 = getContact(accountCourse.Id, 'test2@test.no');
        Contact contactCourse3 = getContact(accountCourse.Id, 'test3@test.no');

        CourseRegistration__c cr1 = getCourseRegistration(course1.Id, contactCourse1.Id);
        CourseRegistration__c cr2 = getCourseRegistration(course2.Id, contactCourse2.Id);
        CourseRegistration__c cr3 = getCourseRegistration(course1.Id, contactCourse2.Id);
        CourseRegistration__c cr4 = getCourseRegistration(course2.Id, contactCourse3.Id);

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(3, contacts.size(), 'Should be 3 contacts');
        System.assertEquals(4, crList.size(), 'Should be 4 registrations');

        Test.StartTest();
        CourseScheduledDeleteContacts.courseScheduledDeleteContacts();
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crListAfter = [SELECT Id FROM CourseRegistration__c];
        CourseRegistration__c cr1After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr1.Id
        ];
        CourseRegistration__c cr2After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr2.Id
        ];
        CourseRegistration__c cr3After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr3.Id
        ];
        CourseRegistration__c cr4After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr4.Id
        ];
        System.assertEquals(2, contactsAfter.size(), 'Should be 2 contacts');
        System.assertEquals(4, crListAfter.size(), 'Should be 4 registrations');
        System.assertEquals(null, cr1After.CourseParticipant__c, 'Should be no contact for cr1');
        System.assertEquals(
            contactCourse2.Id,
            cr2After.CourseParticipant__c,
            'Should be contactCourse2 relation for cr2'
        );
        System.assertEquals(null, cr3After.CourseParticipant__c, 'Should be no contact relation for cr3');
        System.assertEquals(
            contactCourse3.Id,
            cr4After.CourseParticipant__c,
            'Should be contactCourse3 relation for cr4'
        );
    }

    @isTest
    private static void testContactAttendingLaterCourse() {
        Course__c course1 = CourseRegistrationHandlerTest.getCourse('Testkurs');
        Course__c course2 = CourseRegistrationHandlerTest.getCourse('Testkurs2');
        course1.RegistrationToDateTime__c = Datetime.Now().addDays(-85);
        course2.RegistrationToDateTime__c = Datetime.Now().addDays(-83);
        update new List<Course__c>{ course1, course2 };

        Account accountCourse = new Account(Name = 'Kontakter uten konto');
        insert accountCourse;

        Contact contactCourse1 = getContact(accountCourse.Id, 'test1@test.no'); //Only this one should be deleted
        Contact contactCourse2 = getContact(accountCourse.Id, 'test2@test.no');
        Contact contactCourse3 = getContact(accountCourse.Id, 'test3@test.no');

        CourseRegistration__c cr1 = getCourseRegistration(course1.Id, contactCourse1.Id);
        CourseRegistration__c cr2 = getCourseRegistration(course2.Id, contactCourse2.Id);
        CourseRegistration__c cr3 = getCourseRegistration(course1.Id, contactCourse2.Id);
        CourseRegistration__c cr4 = getCourseRegistration(course2.Id, contactCourse3.Id);

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(3, contacts.size(), 'Should be 3 contacts');
        System.assertEquals(4, crList.size(), 'Should be 4 registrations');

        Test.StartTest();
        CourseScheduledDeleteContacts.courseScheduledDeleteContacts();
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crListAfter = [SELECT Id FROM CourseRegistration__c];
        CourseRegistration__c cr1After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr1.Id
        ];
        CourseRegistration__c cr2After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr2.Id
        ];
        CourseRegistration__c cr3After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr3.Id
        ];
        CourseRegistration__c cr4After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr4.Id
        ];
        System.assertEquals(2, contactsAfter.size(), 'Should be 2 contacts');
        System.assertEquals(4, crListAfter.size(), 'Should be 4 registrations');
        System.assertEquals(null, cr1After.CourseParticipant__c, 'Should be no contact for cr1');
        System.assertEquals(
            contactCourse2.Id,
            cr2After.CourseParticipant__c,
            'Should be contactCourse2 relation for cr2'
        );
        System.assertEquals(null, cr3After.CourseParticipant__c, 'Should be no contact relation for cr3');
        System.assertEquals(
            contactCourse3.Id,
            cr4After.CourseParticipant__c,
            'Should be contactCourse3 relation for cr4'
        );
    }

    public static CourseRegistration__c getCourseRegistration(String courseId, String contactId) {
        CourseRegistration__c cr = new CourseRegistration__c(
            CourseParticipant__c = contactId,
            Course__c = courseId,
            Status__c = 'Invitert'
        );
        insert cr;
        return cr;
    }

    public static Contact getContact(Id accountId, String email) {
        Contact c = new Contact(
            FirstName = 'Per',
            LastName = 'Hansen',
            Email = email,
            TAG_Informed__c = true,
            AccountId = accountid
        );
        insert c;
        return c;
    }
}
