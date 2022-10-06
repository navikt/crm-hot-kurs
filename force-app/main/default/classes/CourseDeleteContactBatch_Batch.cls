public without sharing class CourseDeleteContactBatch_Batch implements Database.Batchable<sObject>{
        public Integer recordsToDelete = 0;
        public static final Id COURSE_ACCOUNT2 = [SELECT Id FROM Account WHERE Name = 'Kontakter uten konto'].Id;

        public Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator('SELECT id from contact WHERE Account.name = \'Kontakter uten konto\' AND Id NOT IN (SELECT CourseParticipant__c FROM CourseRegistration__c) AND Id NOT IN (SELECT Contact__c FROM CustomOpportunity__c) AND IsPersonAccount = false');
        }
        
        public void execute(Database.BatchableContext bc, List<Contact> scope){
            
            Set<Id> contactsMayBeDeleted = fetchContactIds(scope);
            Set<Id> contactsThatShouldNotBeDeleted = findContactsWithOtherAccount(contactsMayBeDeleted);
    
            contactsMayBeDeleted.removeAll(contactsThatShouldNotBeDeleted);
    
            List<Contact> contactsForDeletion = [SELECT Id FROM Contact WHERE Id IN :contactsMayBeDeleted AND IsPersonAccount = false];
    
            recordsToDelete = contactsForDeletion.size();

            Delete contactsForDeletion;          
        }
      
        public void finish(Database.BatchableContext bc){
            System.debug('Records to delete ' + recordsToDelete);
        }
        
        public static Set<Id> findContactsWithOtherAccount(Set<Id> contactIds) {
                        
            Set<Id> contactsOtherThanCourseParticipants = new Set<Id>();
            List<AccountContactRelation> accountContactsOtherThanCourseParticipants = [
                SELECT Id, ContactId
                FROM AccountContactRelation
                WHERE ContactId IN :contactIds AND AccountId != :COURSE_ACCOUNT2
            ];

            for (AccountContactRelation acr : accountContactsOtherThanCourseParticipants) {
                contactsOtherThanCourseParticipants.add(acr.ContactId);
            }
            return contactsOtherThanCourseParticipants;
        }

        public static Set<Id> fetchContactIds(List<Contact> contactsToClean) {
            Set<Id> contactsFromRegistrations = new Set<Id>();
            for (Contact cr : contactsToClean) {
                contactsFromRegistrations.add(cr.Id);
            }
            return contactsFromRegistrations;
    }
}
