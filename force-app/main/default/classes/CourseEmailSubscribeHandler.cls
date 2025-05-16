public without sharing class CourseEmailSubscribeHandler extends MyTriggers {
    public override void onAfterInsert() {
        addEncryptedString((List<HOT_CourseSubscriber__c>) records);
    }
    public static void addEncryptedString(List<HOT_CourseSubscriber__c> courseEmailSubscribers) {
        List<HOT_CourseSubscriber__c> recordsToUpdate = new List<HOT_CourseSubscriber__c>();
        for (HOT_CourseSubscriber__c emailSubscriber : courseEmailSubscribers) {
            HOT_CourseSubscriber__c record = new HOT_CourseSubscriber__c(Id = emailSubscriber.id);
            record.EncryptedId__c = EncodingUtil.urlEncode(CryptoService.encryptString(record.Id), 'UTF-8');
            recordsToUpdate.add(record);
        }
        update recordsToUpdate;
    }
}
