@isTest
public with sharing class CourseEmailSubscribeHandlerTest {
    // @TestSetup
    // static void makeData() {
    //     TestDataFactory.insertEncryptionKey();
    //     Profile guestProfile = [SELECT Id FROM Profile WHERE Name = 'Guest License User' LIMIT 1];
    //     User guestUser = new User(
    //         FirstName = 'Kurs',
    //         LastName = 'Site Guest User',
    //         Alias = 'kursgu',
    //         Email = 'kurs.fakeemail@nav.no.scratchorg',
    //         Username = 'kurs.fakeemail@nav.no.scratchorg',
    //         CommunityNickname = 'kursguest',
    //         ProfileId = guestProfile.Id,
    //         TimeZoneSidKey = 'Europe/Oslo',
    //         LocaleSidKey = 'en_US',
    //         EmailEncodingKey = 'UTF-8',
    //         LanguageLocaleKey = 'en_US'
    //     );
    //     insert guestUser;
    // }
    // @isTest
    // public static void testInsert() {
    //     HOT_CourseSubscriber__c courseSubscriber = new HOT_CourseSubscriber__c(
    //         Email__c = 'fakeemail@nav.no.scratchorg',
    //         SubCategories__c = 'Bolig;Syn'
    //     );
    //     Test.startTest();
    //     insert courseSubscriber;
    //     Test.stopTest();
    //     HOT_CourseSubscriber__c insertedSubscriber = [
    //         SELECT Id, EncryptedId__c
    //         FROM HOT_CourseSubscriber__c
    //         WHERE Id = :courseSubscriber.Id
    //         LIMIT 1
    //     ];
    //     Assert.isNotNull(insertedSubscriber.EncryptedId__c, 'Encrypted Id should get filled out after insert');
    // }
}
