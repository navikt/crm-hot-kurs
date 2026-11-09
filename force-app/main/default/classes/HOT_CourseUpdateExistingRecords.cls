public with sharing class HOT_CourseUpdateExistingRecords implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    ContactFirstName__c,
                    ContactLastName__c,
                    ContactPhone__c,
                    CourseParticipant__r.FirstName,
                    CourseParticipant__r.LastName,
                    CourseParticipant__r.MobilePhone
                FROM CourseRegistration__c
                WHERE
                    CourseParticipant__c != NULL
                    AND Course__r.Active__c = TRUE
                    AND (ContactFirstName__c = NULL
                    OR ContactLastName__c = NULL
                    OR ContactPhone__c = NULL)
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<CourseRegistration__c> registrationsToUpdate = new List<CourseRegistration__c>();
        for (SObject record : records) {
            CourseRegistration__c registration = (CourseRegistration__c) record;
            CourseRegistration__c updatedRegistration = new CourseRegistration__c(Id = registration.Id);
            Boolean hasChanges = false;
            if (
                String.isBlank(registration.ContactFirstName__c) &&
                !String.isBlank(registration.CourseParticipant__r.FirstName)
            ) {
                updatedRegistration.ContactFirstName__c = registration.CourseParticipant__r.FirstName;
                hasChanges = true;
            }
            if (
                String.isBlank(registration.ContactLastName__c) &&
                !String.isBlank(registration.CourseParticipant__r.LastName)
            ) {
                updatedRegistration.ContactLastName__c = registration.CourseParticipant__r.LastName;
                hasChanges = true;
            }
            if (
                String.isBlank(registration.ContactPhone__c) &&
                !String.isBlank(registration.CourseParticipant__r.MobilePhone)
            ) {
                updatedRegistration.ContactPhone__c = registration.CourseParticipant__r.MobilePhone;
                hasChanges = true;
            }
            if (hasChanges) {
                registrationsToUpdate.add(updatedRegistration);
            }
        }
        if (!registrationsToUpdate.isEmpty()) {
            update registrationsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
