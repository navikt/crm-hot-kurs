@isTest
private class HOT_CourseUpdateExistingRecordsTest {
    @isTest
    static void testEmailsAreDeletedWhenCriteriaMatch() {
        DateTime d = Date.today().addDays(1);
        Course__c course = new Course__c(
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region__c = 'Oslo',
            RegistrationDeadline__c = d,
            RegistrationFromDateTime__c = d,
            RegistrationToDateTime__c = d.addDays(-100)
        );
        Contact c1 = new Contact(LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true);
        insert c1;
        CourseRegistration__c registration = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = c1.Id,
            Status__c = 'Påmeldt'
        );
        insert registration;

        List<EmailMessage> emails = new List<EmailMessage>{
            new EmailMessage(
                Subject = 'Bekreftelse på kurspåmelding',
                RelatedToId = registration.Id,
                Status = '3',
                FromAddress = 'test@example.com',
                ToAddress = 'user@example.com'
            )
        };
        insert emails;
        registration.CourseParticipant__c = null;
        update registration;
        delete c1;

        Test.startTest();
        HOT_CourseUpdateExistingRecords job = new HOT_CourseUpdateExistingRecords();
        Database.executeBatch(job, 200);
        Test.stopTest();

        List<EmailMessage> remainingEmails = [SELECT Id FROM EmailMessage WHERE RelatedToId = :registration.Id];
        System.assertEquals(0, remainingEmails.size(), 'Alle e-poster skal være slettet');
    }

    @isTest
    static void testEmailsAreNotDeletedWhenCriteriaDoNotMatch() {
        DateTime d = Date.today().addDays(1);
        Course__c course = new Course__c(
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region__c = 'Oslo',
            RegistrationDeadline__c = d,
            RegistrationFromDateTime__c = d,
            RegistrationToDateTime__c = d.addDays(1)
        );
        Contact c1 = new Contact(LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true);
        insert c1;
        CourseRegistration__c registration = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = c1.Id,
            Status__c = 'Påmeldt'
        );
        insert registration;

        List<EmailMessage> emails = new List<EmailMessage>{
            new EmailMessage(
                Subject = 'Bekreftelse på kurspåmelding',
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
