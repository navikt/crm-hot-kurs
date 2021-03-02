global with sharing class Course_Cancel extends MyTriggers {
    public override void onBeforeUpdate(Map<Id, sObject> triggerOldMap) {
        List<Course__c> canceledCourses = new List<Course__c>();
        List<Course__c> previouslyCanceledCourses = new List<Course__c>();
        for (Course__c course : (List<Course__c>) records) {
            if (course.Cancel__c != false) {
                canceledCourses.add(course);
            } else if (
                triggerOldMap.get(course.Id).get('Cancel__c') == true &&
                course.Name.contains('AVLYST') &&
                course.Cancel__c == false
            ) {
                previouslyCanceledCourses.add(course);
            }
        }

        if (!canceledCourses.isEmpty()) {
            changeCanceledCourseTitle(canceledCourses);
        }
        if (!previouslyCanceledCourses.isEmpty()) {
            changeCanceledCourseTitle(previouslyCanceledCourses);
        }
    }

    //public static void changeCanceledCourseTitle(List<Course__c> canceledCourses, Map<Id, sObject> triggerOldMap) {
    public static void changeCanceledCourseTitle(List<Course__c> courses) {
        for (Course__c course : courses) {
            if (!course.Name.contains('AVLYST') && Course.Cancel__c == true) {
                course.Name = 'AVLYST ' + course.Name;
            } else {
                course.Name = course.Name.remove('AVLYST');
            }
        }
    }
}
