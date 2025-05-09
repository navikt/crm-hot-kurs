public without sharing class CourseSubscriberHandler extends MyTriggers {
    public override void onAfterInsert() {
        addEncryptedString((List<HOT_CourseSubscriber__c>) records);
    }

    public static void addEncryptedString(List<HOT_CourseSubscriber__c> registrations) {
        List<HOT_CourseSubscriber__c> recordsToUpdate = new List<HOT_CourseSubscriber__c>();

        for (HOT_CourseSubscriber__c reg : registrations) {
            HOT_CourseSubscriber__c cs = new HOT_CourseSubscriber__c(Id = reg.id);
            cs.EncryptedId__c = EncodingUtil.urlEncode(CryptoService.encryptString(cs.Id), 'UTF-8');
            recordsToUpdate.add(cs);
        }
        update recordsToUpdate;
    }
}
