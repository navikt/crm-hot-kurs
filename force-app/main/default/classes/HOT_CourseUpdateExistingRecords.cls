public with sharing class HOT_CourseUpdateExistingRecords implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Name FROM Course__c WHERE Active__c = true');
    }

    public void execute(Database.BatchableContext bc, List<Course__c> records) {
        List<Course__c> coursesToUpdate = new List<Course__c>();
        for (Course__c course : (List<Course__c>) records) {
            coursesToUpdate.add(course);
        }
        if (!coursesToUpdate.isEmpty()) {
            HOT_CourseCalendarGenerator.generateCalendarUrls(coursesToUpdate);
            update coursesToUpdate;
        }
    }
    public void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}
