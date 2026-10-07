public with sharing class HOT_CourseUpdateExistingRecords implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date twelveWeeksAgo = Date.today().addDays(-84);
        Date today = Date.today();
        return Database.getQueryLocator(
            [
                SELECT Id, CourseParticipant__r.FirstName, CourseParticipant__r.LastName
                FROM CourseRegistration__c
                WHERE
                    CourseParticipant__c != NULL
                    AND DAY_ONLY(Course__r.RegistrationToDateTime__c) > :twelveWeeksAgo
                    AND DAY_ONLY(Course__r.RegistrationToDateTime__c) <= :today
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<SObject> records) {
        List<CourseRegistration__c> registrationsToUpdate = new List<CourseRegistration__c>();
        for (SObject record : records) {
            CourseRegistration__c registration = (CourseRegistration__c) record;
            registrationsToUpdate.add(
                new CourseRegistration__c(
                    Id = registration.Id,
                    ContactFirstName__c = registration.CourseParticipant__r.FirstName,
                    ContactLastName__c = registration.CourseParticipant__r.LastName
                )
            );
        }
        if (!registrationsToUpdate.isEmpty()) {
            update registrationsToUpdate;
        }
    }

    public void finish(Database.BatchableContext bc) {
    }
}
