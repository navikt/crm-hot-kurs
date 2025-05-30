public with sharing class HOT_CourseUpdateExistingRecords implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, Subject FROM EmailMessage ' +
                'WHERE (Subject = \'Bekreftelse på kurspåmelding\' ' +
                'OR Subject = \'Ny påmelding til kurs\' ' +
                'OR Subject = \'Invitasjon til kurs\' ' +
                'OR Subject = \'Kurs avlyst\') ' +
                'AND RelatedToId IN (SELECT Id FROM CourseRegistration__c WHERE CourseParticipant__c = null)'
        );
    }

    public void execute(Database.BatchableContext bc, List<EmailMessage> records) {
        delete records;
    }
    public void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }
}
