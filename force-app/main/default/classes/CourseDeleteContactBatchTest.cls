@isTest
public with sharing class CourseDeleteContactBatchTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }
    @isTest
    private static void testContactsForDeletion() {
        Account accountCourse = new Account(Name = 'Kontakter uten konto');
        insert accountCourse;

        Id COURSE_ACCOUNT3 = [SELECT Id FROM Account WHERE Name = 'Kontakter uten konto'].Id;

        Contact contact1 = new Contact(FirstName = 'Hans1', LastName = 'Persen', AccountId = COURSE_ACCOUNT3);
        insert contact1;
        Contact contact2 = new Contact(FirstName = 'Hans2', LastName = 'Persen', AccountId = COURSE_ACCOUNT3);
        insert contact2;
        Contact contact3 = new Contact(FirstName = 'Hans3', LastName = 'Persen');
        insert contact3;

        List<Contact> contacts = [SELECT Id FROM Contact];

        System.assertEquals(3, contacts.size(), 'Should be 3 contacts');

        Test.StartTest();
        CourseDeleteContactBatch_Batch testRun = new CourseDeleteContactBatch_Batch();
        Id batchId = Database.executeBatch(testRun);
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];

        System.assertEquals(1, contactsAfter.size(), 'Should be 1 contact');
    }

    @isTest
    private static void testContactWithRelationToOtherAccounts() {
        Course__c Course = new Course__c(name = 'Test kurs', MaxNumberOfParticipants__c = 5, Region2__c = 'Agder');
        insert Course;

        Account accountDummy = new Account(Name = 'Kontakter uten konto');
        Account accountNotDummy = new Account(Name = 'Test konto');
        insert new List<Account>{ accountDummy, accountNotDummy };

        Contact contactRelatedToDummy = getContact(accountDummy.Id, 'test1@test.no'); //Only this one should be deleted
        Contact contactRelatedToNotDummy = getContact(accountNotDummy.Id, 'test2@test.no');
        Contact contactRelatedToCourse = getContact(accountDummy.Id, 'test3@test.no');
        Contact contactRelatedToOtherAccount = getContact(accountDummy.Id, 'test4@test.no');
        Contact contactRelatedToCustomOpportunity = getContact(accountDummy.Id, 'test5@test.no');

        AccountContactRelation relation = new AccountContactRelation(
            AccountId = accountNotDummy.Id,
            ContactId = contactRelatedToOtherAccount.Id
        );
        insert relation;

        CustomOpportunity__c co = new CustomOpportunity__c(
            Contact__c = contactRelatedToCustomOpportunity.id,
            Source__c = 'Kontaktskjema'
        );
        insert co;

        CourseRegistration__c cp = new CourseRegistration__c(
            Course__c = Course.id,
            CourseParticipant__c = contactRelatedToCourse.id,
            Status__c = 'Påmeldt'
        );
        insert cp;

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        List<CustomOpportunity__c> coList = [SELECT Id FROM CustomOpportunity__c];
        List<AccountContactRelation> acrList = [SELECT Id FROM AccountContactRelation];

        System.assertEquals(5, contacts.size(), 'Should be 3 contacts');
        System.assertEquals(6, acrList.size(), 'Should be 4 relations');
        System.assertEquals(1, crList.size(), 'Should be 1 course registration');
        System.assertEquals(1, coList.size(), 'Should be 1 custom opportunity');

        Test.StartTest();
        CourseDeleteContactBatch_Batch testRun = new CourseDeleteContactBatch_Batch();
        Id batchId = Database.executeBatch(testRun);
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crListAfter = [SELECT Id FROM CourseRegistration__c];
        List<CustomOpportunity__c> coListAfter = [SELECT Id FROM CustomOpportunity__c];
        List<AccountContactRelation> acrListAfter = [SELECT Id FROM AccountContactRelation];

        System.assertEquals(4, contactsAfter.size(), 'Should be 2 contacts');
        System.assertEquals(5, acrListAfter.size(), 'Should be 3 Account-Contact relations');
        System.assertEquals(1, crListAfter.size(), 'Should be still 1 course registration');
        System.assertEquals(1, coListAfter.size(), 'Should be still 1 custom opportunity');
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
