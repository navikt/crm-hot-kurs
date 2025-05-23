@isTest
private class HOT_CourseUpdateExistingRecordsTest {
    @isTest
    static void testEmailsAreDeletedWhenCriteriaMatch() {
        // Opprett en CourseRegistration__c uten CourseParticipant__c
        CourseRegistration__c registration = new CourseRegistration__c();
        insert registration;

        // Opprett EmailMessages som matcher kriteriene
        List<EmailMessage> emails = new List<EmailMessage>();
        for (
            String subject : new List<String>{
                'Bekreftelse på kurspåmelding',
                'Ny påmelding til kurs',
                'Invitasjon til kurs',
                'Kurs avlyst'
            }
        ) {
            emails.add(
                new EmailMessage(
                    Subject = subject,
                    RelatedToId = registration.Id,
                    Status = '3',
                    FromAddress = 'test@example.com',
                    ToAddress = 'user@example.com'
                )
            );
        }
        insert emails;

        Test.startTest();
        HOT_CourseUpdateExistingRecords job = new HOT_CourseUpdateExistingRecords();
        Database.executeBatch(job, 200);
        Test.stopTest();

        List<EmailMessage> remainingEmails = [SELECT Id FROM EmailMessage WHERE RelatedToId = :registration.Id];
        System.assertEquals(0, remainingEmails.size(), 'Alle e-poster skal være slettet');
    }

    @isTest
    static void testEmailsAreNotDeletedWhenCriteriaDoNotMatch() {
        CourseRegistration__c registration = new CourseRegistration__c(CourseParticipant__c = 'DummyParticipantId');
        insert registration;

        List<EmailMessage> emails = new List<EmailMessage>{
            new EmailMessage(
                Subject = 'Annet emne',
                RelatedToId = registration.Id,
                Status = '3',
                FromAddress = 'test@example.com',
                ToAddress = 'user@example.com'
            )
        };
        insert emails;
        Test.startTest();
        HOT_CourseUpdateExistingRecords job = new HOT_CourseUpdateExistingRecords();
        Database.executeBatch(job, 200);
        Test.stopTest();

        List<EmailMessage> remainingEmails = [SELECT Id FROM EmailMessage WHERE RelatedToId = :registration.Id];
        System.assertEquals(1, remainingEmails.size(), 'E-posten skal ikke være slettet');
    }
}
