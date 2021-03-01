global with sharing class Course_Cancel extends MyTriggers {
    public override void onBeforeUpdate(Map<Id, sObject> triggerOldMap) {
        List<Course__c> canceledCourses = new List<Course__c>();
        for (Course__c course : (List<Course__c>) records) {
            if (course.get('Cancel__c') != false) {
                canceledCourses.add(course);
            }
        }
        if (!canceledCourses.isEmpty()) {
            changeCanceledCourseTitle(canceledCourses);
        }
    }

    public static void changeCanceledCourseTitle(List<Course__c> canceledCourses) {
        for (Course__c course : canceledCourses) {
            course.Name = 'AVLYST ' + course.Name;
        }
    }
}
