public without sharing class CourseEmailSubscriberHandler extends MyTriggers {
    public override void onAfterInsert() {
        System.debug('går den inn her?');
        for (HOT_CourseSubscriber__c reg : (List<HOT_CourseSubscriber__c>) records) {
            reg.EncryptedId__c = 'test';
            System.debug('hva med her?');
        }
        update records;
    }
}
