global with sharing class Course_Cancel extends MyTriggers {
    public override void onBeforeUpdate(Map<Id, sObject> triggerOldMap) {
        List<Course__c> canceledCourses = new List<Course__c>();
        for (Course__c course : (List<Course__c>) records) {
            if (
                course.Cancel__c != false ||
                (triggerOldMap.get(course.Id).get('Cancel__c') == true &&
                course.Cancel__c == false &&
                course.Name.contains('AVLYST'))
            ) {
                canceledCourses.add(course);
            }
        }

        if (!canceledCourses.isEmpty()) {
            changeCanceledCourseTitle(canceledCourses, triggerOldMap);
        }
    }

    public static void changeCanceledCourseTitle(List<Course__c> courses, Map<Id, sObject> triggerOldMap) {
        for (Course__c course : courses) {
            if (!course.Name.contains('AVLYST') && Course.Cancel__c == true) {
                course.Name = 'AVLYST ' + course.Name;
            } else if (
                triggerOldMap.get(course.Id).get('Cancel__c') == true &&
                course.Name.contains('AVLYST') &&
                course.Cancel__c == false
            ) {
                course.Name = course.Name.remove('AVLYST');
            }
        }
    }
}
