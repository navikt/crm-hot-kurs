public without sharing class CourseDeleteContactBatch_Batch implements Database.Batchable<sObject>{
        public Integer recordsProcessed = 0;

        public Database.QueryLocator start(Database.BatchableContext bc) {
            return Database.getQueryLocator('SELECT id, name from contact WHERE Id NOT IN (SELECT CourseParticipant__c FROM CourseRegistration__c) AND Id NOT IN (SELECT Contact__c FROM CustomOpportunity__c)');
        }
        
            public void execute(Database.BatchableContext bc, List<Contact> scope){
    
                List<Contact> contactsToDelete = CourseDeleteContactBatch.courseDeleteContact(scope);

                Delete contactsToDelete;

            }
    
    public void finish(Database.BatchableContext bc){
            System.debug(recordsProcessed);
        }
    }
