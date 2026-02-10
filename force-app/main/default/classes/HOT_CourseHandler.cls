public without sharing class HOT_CourseHandler extends MyTriggers {
    public override void onAfterInsert() {
        List<Course__c> courses = (List<Course__c>) records;

        HOT_CourseCalendarGenerator.generateCalendarUrls(courses);
    }
    public override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<Course__c> updatedCourses = new List<Course__c>();

        for (Course__c course : (List<Course__c>) records) {
            Course__c oldCourse = (Course__c) triggerOldMap.get(course.Id);
            Boolean hasChanged =
                (oldCourse.RegistrationFromDateTime__c != course.RegistrationFromDateTime__c) ||
                (oldCourse.RegistrationToDateTime__c != course.RegistrationToDateTime__c) ||
                (oldCourse.Name != course.Name) ||
                (oldCourse.RegistrationPlaceName__c != course.RegistrationPlaceName__c) ||
                (oldCourse.VideoLink__c != course.VideoLink__c);

            if (hasChanged) {
                updatedCourses.add(course);
            }
        }
        if (!updatedCourses.isEmpty()) {
            HOT_CourseCalendarGenerator.generateCalendarUrls(updatedCourses);
        }
    }
}
