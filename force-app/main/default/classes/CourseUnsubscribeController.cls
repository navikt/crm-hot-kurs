public without sharing class CourseUnsubscribeController {
    @AuraEnabled
    public static CourseRegistration__c getCourseRegistrationFields(String courseRegId) {
        String recordId = CryptoService.decryptString(courseRegId);

        return [SELECT CourseParticipantName__c, Course__r.Name FROM CourseRegistration__c WHERE Id = :recordId];
    }
    @AuraEnabled
    public static CourseRegistration__c updateCourseRegistration(String courseRegId) {
        String recordId = CryptoService.decryptString(courseRegId);
        CourseRegistration__c courseReg = [
            SELECT Id, Status__c
            FROM CourseRegistration__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        courseReg.Status__c = 'Avmeldt';
        update courseReg;

        return courseReg;
    }
}
