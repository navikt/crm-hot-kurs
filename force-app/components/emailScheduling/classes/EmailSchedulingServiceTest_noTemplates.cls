@isTest
private without sharing class EmailSchedulingServiceTest_noTemplates {
    @testSetup
    private static void setup() {
        TestDataFactory.insertEncryptionKey();
        EmailTemplate et1 = new EmailTemplate(
            DeveloperName = 'courseScheduledEmailBefore',
            Name = 'courseScheduledEmailBefore',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Invitasjon til kurs',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>'
        );
        EmailTemplate et2 = new EmailTemplate(
            DeveloperName = 'courseScheduledEmailReminder',
            Name = 'courseScheduledEmailReminder',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Invitasjon til kurs',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>'
        );
        // EmailTemplate et3 = new EmailTemplate( DeveloperName = 'courseScheduledEmailAfter', Name = 'courseScheduledEmailAfter', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
        // EmailTemplate et4 = new EmailTemplate( DeveloperName = 'courseScheduledEmailManual', Name = 'courseScheduledEmailManual', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
        Database.insert(new List<EmailTemplate>{ et1, et2 }, false);

        delete [
            SELECT Id
            FROM EmailTemplate
            WHERE
                DeveloperName IN (
                    'courseScheduledEmailAfter',
                    'courseScheduledEmailManual'
                )
        ];
    }

    @isTest
    private static void testExecute_beforeSuccess() {
        EmailSchedulingServiceTest.createData(
            new List<EmailSchedulingHelper.EmailTypes>{
                EmailSchedulingHelper.EmailTypes.BEFORE,
                EmailSchedulingHelper.EmailTypes.MANUAL
            },
            true
        );

        System.assertEquals(
            2,
            [SELECT Id FROM Course__c].size(),
            'one courses should have scheduled emails for "today"'
        );
        System.assertEquals(
            4,
            [SELECT Id FROM CourseRegistration__c].size(),
            'four courses with two course participants each'
        );
        System.assertEquals(
            0,
            [SELECT Id FROM EmailQueue__c].size(),
            'no emails sent yet'
        );

        Test.StartTest();
        EmailSchedulingService.run();
        Test.StopTest();

        System.assertEquals(
            1,
            [
                    SELECT Id
                    FROM Course__c
                    WHERE EmailBeforeSent__c = TRUE OR EmailManualSent__c = TRUE
                ]
                .size(),
            'one courses should have marked as sent'
        );
        System.assertEquals(
            2,
            [SELECT Id FROM EmailQueue__c].size(),
            '2 emails sent, 2 EmailQueue__cs created'
        );
        System.assertEquals(
            1,
            EmailSchedulingHelper.getCoursesWithScheduledEmails().size(),
            'one emails should have an error'
        );
    }
}
