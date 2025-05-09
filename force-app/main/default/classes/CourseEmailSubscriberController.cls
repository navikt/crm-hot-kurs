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
    @AuraEnabled
    public static void updateCourseEmailSubscriber(Id subscriberId, String categories, String subCategories) {
        HOT_CourseSubscriber__c recordToUpdate = [
            SELECT Id, Categories__c, SubCategories__c, isActive__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :subscriberId
        ];

        recordToUpdate.Categories__c = categories;
        recordToUpdate.SubCategories__c = subCategories;

        update recordToUpdate;
    }
    @AuraEnabled
    public static void createCourseEmailSubscriber(Id courseId, String email) {
        Course__c course = [SELECT Id, Theme__c, Sub_category__c FROM Course__c WHERE Id = :courseId];

        HOT_CourseSubscriber__c newRecord = new HOT_CourseSubscriber__c(
            Email__c = email,
            Categories__c = course.Theme__c,
            SubCategories__c = course.Sub_category__c
        );
        try {
            insert newRecord;
        } catch (DmlException e) {
            System.debug('Feil ved innsetting av ny post: ' + e.getMessage());
        }
    }
}
