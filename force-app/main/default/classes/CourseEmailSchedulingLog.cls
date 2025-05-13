public with sharing class CourseEmailSchedulingLog {
    public class LogData {
        @AuraEnabled
        public String name; // id
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Id TargetObjectId;
        @AuraEnabled
        public Boolean expanded;
        @AuraEnabled
        public String metatext;
        @AuraEnabled
        public List<LogChildren> items;
    }

    public class LogChildren {
        @AuraEnabled
        public String name; // id
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Id TargetObjectId;
        @AuraEnabled
        public String metatext;
    }

    @AuraEnabled
    public static List<LogData> getLogData(Id recordId) {
        List<EmailQueue__c> emailQueue = getEmailQueue(recordId);
        Map<Id, String> templateSubjects = getTemplateSubjects(emailQueue);
        Map<Id, String> contactNames = getContactNames(emailQueue);
        List<LogData> logData = createData(emailQueue, templateSubjects, contactNames);

        return logData;
    }

    // ------------------------------------------------
    // --------------- HELPER FUNCTIONS ---------------
    // ------------------------------------------------

    public static List<EmailQueue__c> getEmailQueue(Id recordId) {
        Set<Id> courseRegistrationIds = new Set<Id>();

        //query canceled course emails where whatId is the course registration
        for (CourseRegistration__c reg : [
            SELECT Id
            FROM CourseRegistration__c
            WHERE Course__c = :recordId
        ]) {
            courseRegistrationIds.add(reg.Id);
        }

        return [
            SELECT Id, TargetObjectId__c, Status__c, TemplateId__c, LastModifiedDate
            FROM EmailQueue__c
            WHERE WhatId__c = :recordId OR WhatId__c IN :courseRegistrationIds
            ORDER BY LastModifiedDate DESC
        ];
    }

    public static Map<Id, String> getTemplateSubjects(List<EmailQueue__c> emailQueue) {
        Set<Id> templateIds = new Set<Id>();
        for (EmailQueue__c email : emailQueue) {
            if (email.TemplateId__c != null) {
                templateIds.add(email.TemplateId__c);
            }
        }

        List<EmailTemplate> emailTemplates = [SELECT Id, Subject FROM EmailTemplate WHERE Id IN :templateIds];

        Map<Id, String> templateSubjects = new Map<Id, String>();
        for (EmailTemplate emailTemplate : emailTemplates) {
            templateSubjects.put(emailTemplate.Id, emailTemplate.Subject);
        }

        return templateSubjects;
    }

    public static Map<Id, String> getContactNames(List<EmailQueue__c> emailQueue) {
        Set<Id> contactIds = new Set<Id>();
        for (EmailQueue__c email : emailQueue) {
            if (email.TargetObjectId__c != null) {
                contactIds.add(email.TargetObjectId__c);
            }
        }

        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id IN :contactIds];

        Map<Id, String> contactNames = new Map<Id, String>();
        for (Contact contact : contacts) {
            contactNames.put(contact.Id, contact.Name);
        }

        return contactNames;
    }

    public static List<LogData> createData(
        List<EmailQueue__c> emailQueue,
        Map<Id, String> templateSubjects,
        Map<Id, String> contactNames
    ) {
        Map<Id, List<EmailQueue__c>> emailQueueSubjectKey = CourseEmailSchedulingLogHelper.getEmailQueueTemplateIdAsKey(
            emailQueue,
            templateSubjects
        );

        List<LogData> parents = new List<LogData>();
        for (Id templateId : emailQueueSubjectKey.keySet()) {
            String subject = templateSubjects.get(templateId);

            LogData parent = new LogData();
            parent.name = subject;
            parent.label = subject;
            parent.expanded = false;

            List<EmailQueue__c> emailQueueChildren = emailQueueSubjectKey.get(templateId);
            parent.metatext = CourseEmailSchedulingLogHelper.getParentMetatext(emailQueueChildren);
            parent.items = CourseEmailSchedulingLogHelper.createChildren(emailQueueChildren, contactNames);

            parents.add(parent);
        }

        return parents;
    }
}
