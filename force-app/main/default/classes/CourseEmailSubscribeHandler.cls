public without sharing class CourseEmailSubscribeHandler extends MyTriggers {
    public override void onAfterInsert() {
        addEncryptedString((List<HOT_CourseSubscriber__c>) records);
    }
    public static void addEncryptedString(List<HOT_CourseSubscriber__c> registrations) {
        System.debug('GÅR DEN INN HER');
        List<HOT_CourseSubscriber__c> toUpdatee = new List<HOT_CourseSubscriber__c>();
        for (HOT_CourseSubscriber__c reg : registrations) {
            System.debug('OKOERFGKERGTRSGER');
            HOT_CourseSubscriber__c updated = new HOT_CourseSubscriber__c(Id = reg.Id, Email__c = 'hei@ho.no');
            toUpdatee.add(updated);
        }
        update toUpdatee;
    }
}
