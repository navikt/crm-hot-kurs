public without sharing class HOT_CourseHandler extends MyTriggers {
    public override void onAfterInsert() {
        List<Course__c> courses = (List<Course__c>) records;

        HOT_CourseCalendarGenerator.generateCalendarUrlsFromRegistrations(courses);
    }
}