public with sharing class CourseEmailSchedulingLog {
    @AuraEnabled(cacheable=true)
    public static List<EmailSchedulingLog.LogData> getLogDataWithCanceledEmails(Id recordId) {
        List<EmailQueue__c> emailQueue = getCourseEmails(recordId);

        Map<Id, String> templateSubjects = EmailSchedulingLog.getTemplateSubjects(emailQueue);
        Map<Id, String> contactNames = EmailSchedulingLog.getContactNames(emailQueue);

        List<EmailSchedulingLog.LogData> logData = EmailSchedulingLog.createData(
            emailQueue,
            templateSubjects,
            contactNames
        );

        return logData;
    }

    private static List<EmailQueue__c> getCourseEmails(Id recordId) {
        Set<Id> courseRegistrationIds = new Set<Id>();

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
}
