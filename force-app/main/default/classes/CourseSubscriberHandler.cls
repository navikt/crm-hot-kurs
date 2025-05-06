public with sharing class CourseSubscriberHandler {
    global override void onAfterInsert() {
        addEncryptedString((List<HOT_CourseSubscriber__c>) records);
    }

    public static void addEncryptedString(List<HOT_CourseSubscriber__c> registrations) {
        List<HOT_CourseSubscriber__c> recordsToUpdate = new List<HOT_CourseSubscriber__c>();

        for (HOT_CourseSubscriber__c reg : registrations) {
            HOT_CourseSubscriber__c cr = new HOT_CourseSubscriber__c(Id = reg.id);
            cr.EncryptedId__c = EncodingUtil.urlEncode(CryptoService.encryptString(cr.Id), 'UTF-8');
            recordsToUpdate.add(cr);
        }
        update recordsToUpdate;
    }
}
