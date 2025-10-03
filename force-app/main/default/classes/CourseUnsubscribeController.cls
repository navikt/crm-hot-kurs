public without sharing class CourseUnsubscribeController {
    @AuraEnabled(cacheable=true)
    public static CourseRegistration__c getCourseRegistrationFields(String courseRegId) {
        String recordId = CryptoService.decryptString(courseRegId);
        return [
            SELECT CourseParticipantName__c, Course__r.Name, NumberOfParticipants__c, Status__c
            FROM CourseRegistration__c
            WHERE Id = :recordId
        ];
    }

    @AuraEnabled
    public static CourseRegistration__c updateCourseRegistrationStatusToAvmeldt(String courseRegId) {
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

    @AuraEnabled
    public static CourseRegistration__c updateCourseRegistrationNumberOfParticipants(
        String courseRegId,
        Integer numberOfParticipants
    ) {
        String recordId = CryptoService.decryptString(courseRegId);
        CourseRegistration__c courseReg = [
            SELECT Id, NumberOfParticipants__c
            FROM CourseRegistration__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        courseReg.NumberOfParticipants__c = numberOfParticipants;
        update courseReg;
        return courseReg;
    }
}
