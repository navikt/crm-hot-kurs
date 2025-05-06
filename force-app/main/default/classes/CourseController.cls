public with sharing class CourseController {
    @AuraEnabled
    public static Boolean isCourseActive(Id courseId) {
        if (courseId == null) {
            throw new AuraHandledException('Course ID cannot be null');
        }
        Course__c course = [
            SELECT Id, Active__c
            FROM Course__c
            WHERE Id = :courseId
            LIMIT 1
        ];
        return course.Active__c;
    }
}
