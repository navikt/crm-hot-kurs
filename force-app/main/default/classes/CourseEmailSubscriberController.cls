public without sharing class CourseEmailSubscriberController {
    @AuraEnabled(cacheable=true)
    public static HOT_CourseSubscriber__c getCourseEmailSubscriber(String Id) {
        String courseEmailSubscriberId = CryptoService.decryptString(Id);
        HOT_CourseSubscriber__c emailCourseSubscriber = [
            SELECT Id, Categories__c, SubCategories__c, isActive__c, Email__c, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseEmailSubscriberId
        ];
        return emailCourseSubscriber;
    }
    @AuraEnabled
    public static void updateCourseEmailSubscriber(String Id, String categories, String subCategories) {
        String courseEmailSubscriberId = CryptoService.decryptString(Id);
        HOT_CourseSubscriber__c recordToUpdate = [
            SELECT Id, Categories__c, SubCategories__c, isActive__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseEmailSubscriberId
        ];

        recordToUpdate.Categories__c = categories;
        recordToUpdate.SubCategories__c = subCategories;
        try {
            update recordToUpdate;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, recordToUpdate, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }
    @AuraEnabled
    public static void activateCourseEmailSubscriber(String Id) {
        String courseEmailSubscriberId = CryptoService.decryptString(Id);
        HOT_CourseSubscriber__c recordToUpdate = [
            SELECT Id, isActive__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseEmailSubscriberId
        ];

        recordToUpdate.isActive__c = true;
        try {
            update recordToUpdate;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, recordToUpdate, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }
    @AuraEnabled
    public static void createCourseEmailSubscriber(Id courseId, String email) {
        Course__c course = [SELECT Id, Theme__c, Sub_category__c FROM Course__c WHERE Id = :courseId];
        List<HOT_CourseSubscriber__c> existingEmailSubscribers = [
            SELECT Id, Email__c, Categories__c, SubCategories__c
            FROM HOT_CourseSubscriber__c
            WHERE Email__c = :email
        ];

        if (!existingEmailSubscribers.isEmpty()) {
            HOT_CourseSubscriber__c subscriber = existingEmailSubscribers[0];

            subscriber.Categories__c = mergeMultiSelectValues(subscriber.Categories__c, course.Theme__c);

            subscriber.SubCategories__c = mergeMultiSelectValues(subscriber.SubCategories__c, course.Sub_category__c);

            try {
                update subscriber;
            } catch (DmlException e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, subscriber, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }
        } else {
            HOT_CourseSubscriber__c newRecord = new HOT_CourseSubscriber__c(
                Email__c = email,
                Categories__c = course.Theme__c,
                SubCategories__c = course.Sub_category__c
            );
            try {
                insert newRecord;
            } catch (DmlException e) {
                LoggerUtility logger = new LoggerUtility();
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
                logger.publishSynch();
            }
        }
    }
    private static String mergeMultiSelectValues(String existingValues, String newValues) {
        Set<String> merged = new Set<String>();

        if (!String.isBlank(existingValues)) {
            merged.addAll(existingValues.split(';'));
        }
        if (!String.isBlank(newValues)) {
            merged.addAll(newValues.split(';'));
        }

        return String.join(new List<String>(merged), ';');
    }
    @AuraEnabled
    public static void deleteCourseEmailSubscriber(String Id) {
        String courseEmailSubscriberId = CryptoService.decryptString(Id);
        HOT_CourseSubscriber__c recordToDelete = [
            SELECT Id, isActive__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseEmailSubscriberId
        ];
        try {
            delete recordToDelete;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, recordToDelete, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }
}
