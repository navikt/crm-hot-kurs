public without sharing class CourseEmailSubscriberController {
    @AuraEnabled
    public static HOT_CourseSubscriber__c getCourseEmailSubscriber(Id Id) {
        HOT_CourseSubscriber__c emailCourseSubscriber = [
            SELECT Id, Categories__c, SubCategories__c, isActive__c, Email__c, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :Id
        ];
        return emailCourseSubscriber;
    }
}
