public without sharing class CourseUnsubscribeController {
    @AuraEnabled(cacheable=true)
    public static CourseRegistration__c getCourseRegistrationFields(String courseRegId) {
        try {
            String recordId = CryptoService.decryptString(courseRegId);
            return [
                SELECT CourseParticipantName__c, Course__r.Name, NumberOfParticipants__c, Status__c
                FROM CourseRegistration__c
                WHERE Id = :recordId
            ];
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
            throw e;
        }
    }

    @AuraEnabled
    public static CourseRegistration__c updateCourseRegistrationStatusToAvmeldt(String courseRegId) {
        CourseRegistration__c courseReg;
        try {
            String recordId = CryptoService.decryptString(courseRegId);
            courseReg = [
                SELECT Id, Status__c
                FROM CourseRegistration__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            courseReg.Status__c = 'Avmeldt';
            update courseReg;
            return courseReg;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            if (courseReg != null) {
                logger.exception(e, courseReg, CRM_ApplicationDomain.Domain.HOT);
            } else {
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            }
            logger.publishSynch();
            throw e;
        }
    }

    @AuraEnabled
    public static CourseRegistration__c updateCourseRegistrationNumberOfParticipants(
        String courseRegId,
        Integer numberOfParticipants
    ) {
        CourseRegistration__c courseReg;
        try {
            String recordId = CryptoService.decryptString(courseRegId);
            courseReg = [
                SELECT Id, NumberOfParticipants__c
                FROM CourseRegistration__c
                WHERE Id = :recordId
                LIMIT 1
            ];
            courseReg.NumberOfParticipants__c = numberOfParticipants;
            update courseReg;
            return courseReg;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            if (courseReg != null) {
                logger.exception(e, courseReg, CRM_ApplicationDomain.Domain.HOT);
            } else {
                logger.exception(e, CRM_ApplicationDomain.Domain.HOT);
            }
            logger.publishSynch();
            throw e;
        }
    }
}
