@isTest
private class CourseEmailSchedulingLogTest {
    @TestSetup
    static void setupTestData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    static void testGetLogDataWithCanceledEmails() {
        Course__c course = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course.NumberOfParticipants__c = 5;
        update course;

        CourseRegistration__c registration = CourseRegistrationHandlerTest.getCourseRegistration('Invitert', course.Id);

        Contact participant = new Contact(
            FirstName = 'Test',
            LastName = 'Testesen',
            Email = 'test.testesen@test.no',
            TAG_Informed__c = true
        );
        insert participant;

        EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = 'MY_UNIQUE_TEMPLATE',
            Name = 'MY_UNIQUE_TEMPLATE',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Test Subject',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!</p></body></html>'
        );
        insert emailTemplate;

        EmailQueue__c courseEmail = new EmailQueue__c(
            WhatId__c = course.Id,
            Priority__c = '5',
            SaveAsActivity__c = true,
            Status__c = 'Queued',
            TargetObjectId__c = participant.Id,
            TemplateId__c = emailTemplate.Id
        );

        EmailQueue__c registrationEmail = new EmailQueue__c(
            WhatId__c = registration.Id,
            Priority__c = '5',
            SaveAsActivity__c = true,
            Status__c = 'Queued',
            TargetObjectId__c = participant.Id,
            TemplateId__c = emailTemplate.Id
        );

        insert new List<EmailQueue__c>{ courseEmail, registrationEmail };

        Test.startTest();
        List<EmailSchedulingLog.LogData> logData = CourseEmailSchedulingLog.getLogDataWithCanceledEmails(course.Id);
        Test.stopTest();

        System.assertNotEquals(null, logData, 'Log data should not be null');
        System.assert(!logData.isEmpty(), 'Log data should not be empty');

        Boolean subjectFound = false;
        for (EmailSchedulingLog.LogData log : logData) {
            if (log.label == 'Test Subject') {
                subjectFound = true;
                break;
            }
        }
        System.assert(subjectFound, 'Expected subject "Test Subject" not found in log data');
    }
}
