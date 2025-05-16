@isTest
public with sharing class CourseEmailSubscribeHandlerTest {
    @isTest
    public static void testInsert() {
        HOT_CourseSubscriber__c courseSubscriber = new HOT_CourseSubscriber__c(
            Email__c = 'fakeemail@nav.no.scratchorg',
            SubCategories__c = 'Bolig;Syn'
        );
        Test.startTest();
        insert courseSubscriber;
        Test.stopTest();
        HOT_CourseSubscriber__c insertedSubscriber = [
            SELECT Id, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseSubscriber.Id
            LIMIT 1
        ];
        Assert.isNotNull(insertedSubscriber.EncryptedId__c, 'Encrypted Id should get filled out after insert');
    }
}
