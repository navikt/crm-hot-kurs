@isTest
private without sharing class CourseEmailSchedulingLogHelperTest {
    @TestSetup
    static void createData() {
        EmailTemplate emailTemplate = new EmailTemplate(
            DeveloperName = 'MY_UNIQUE_TEMPLATE',
            Name = 'MY_UNIQUE_TEMPLATE',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'HEI OG VELKOMMEN',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>'
        );
        insert emailTemplate;

        EmailTemplate emailTemplate2 = new EmailTemplate(
            DeveloperName = 'MY_UNIQUE_TEMPLATE2',
            Name = 'MY_UNIQUE_TEMPLATE2',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'HEI OG VELKOMMEN',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}!.</p></body></html>'
        );
        insert emailTemplate2;

        Contact con = new Contact(LastName = 'McSmith', Email = 'test@test.com', TAG_Informed__c = true);
        insert con;

        Case c = new Case();
        insert c;

        insert new EmailQueue__c(
            Priority__c = '5',
            SaveAsActivity__c = true,
            WhatId__c = c.Id,
            Status__c = 'Queued',
            TargetObjectId__c = con.Id,
            TemplateId__c = emailTemplate.Id
        );
    }

    @isTest
    private static void testGetEmailQueueTemplateIdAsKey() {
        EmailTemplate et1 = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1];

        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);
        Map<Id, String> templateSubjects = CourseEmailSchedulingLog.getTemplateSubjects(emailQueue);

        Test.StartTest();
        Map<Id, List<EmailQueue__c>> emailQueueTemplateIdAsKey = CourseEmailSchedulingLogHelper.getEmailQueueTemplateIdAsKey(
            emailQueue,
            templateSubjects
        );
        Test.StopTest();

        EmailQueue__c email = [SELECT Id, LastModifiedDate FROM EmailQueue__c LIMIT 1];

        System.assertEquals(1, emailQueueTemplateIdAsKey.size(), 'only one email subject, only one category');

        System.assertEquals(1, emailQueueTemplateIdAsKey.get(et1.Id).size(), 'only one email queue per template');
        System.assertEquals(email.Id, emailQueueTemplateIdAsKey.get(et1.Id)[0].Id, 'only one email queue per template');
    }

    @isTest
    private static void testGetEmailQueueTemplateIdAsKey_twoTemplates() {
        EmailTemplate et1 = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1];
        EmailTemplate et2 = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE2' LIMIT 1];

        Contact con1 = new Contact(LastName = 'McSmith1', Email = 'test1@test.com', TAG_Informed__c = true);
        Contact con2 = new Contact(LastName = 'McSmith2', Email = 'test2@test.com', TAG_Informed__c = true);
        insert con1;
        insert con2;

        Case c = new Case();
        insert c;

        EmailQueue__c eq1 = new EmailQueue__c(
            Priority__c = '5',
            SaveAsActivity__c = true,
            WhatId__c = c.Id,
            Status__c = 'Queued',
            TargetObjectId__c = con1.Id,
            TemplateId__c = et1.Id
        );
        EmailQueue__c eq2 = new EmailQueue__c(
            Priority__c = '5',
            SaveAsActivity__c = true,
            WhatId__c = c.Id,
            Status__c = 'Queued',
            TargetObjectId__c = con2.Id,
            TemplateId__c = et2.Id
        );
        insert eq1;
        insert eq2;

        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(c.Id);
        Map<Id, String> templateSubjects = CourseEmailSchedulingLog.getTemplateSubjects(emailQueue);

        Test.StartTest();
        Map<Id, List<EmailQueue__c>> emailQueueTemplateIdAsKey = CourseEmailSchedulingLogHelper.getEmailQueueTemplateIdAsKey(
            emailQueue,
            templateSubjects
        );
        Test.StopTest();

        System.assertEquals(2, emailQueueTemplateIdAsKey.size(), 'only one email subject, only one category');
        System.assertEquals(1, emailQueueTemplateIdAsKey.get(et1.Id).size(), 'only one email queue per template');
        System.assertEquals(eq1.Id, emailQueueTemplateIdAsKey.get(et1.Id)[0].Id, 'only one email queue per template');

        System.assertEquals(1, emailQueueTemplateIdAsKey.get(et2.Id).size(), 'only one email queue per template');
        System.assertEquals(eq2.Id, emailQueueTemplateIdAsKey.get(et2.Id)[0].Id, 'only one email queue per template');
    }

    @isTest
    private static void testGetEmailQueueTemplateIdAsKey_twoEmails() {
        EmailTemplate et1 = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1];

        Contact con1 = new Contact(LastName = 'McSmith1', Email = 'test1@test.com', TAG_Informed__c = true);
        Contact con2 = new Contact(LastName = 'McSmith2', Email = 'test2@test.com', TAG_Informed__c = true);
        insert con1;
        insert con2;

        Case c = new Case();
        insert c;

        EmailQueue__c eq1 = new EmailQueue__c(
            Priority__c = '5',
            SaveAsActivity__c = true,
            WhatId__c = c.Id,
            Status__c = 'Queued',
            TargetObjectId__c = con1.Id,
            TemplateId__c = et1.Id
        );
        EmailQueue__c eq2 = new EmailQueue__c(
            Priority__c = '5',
            SaveAsActivity__c = true,
            WhatId__c = c.Id,
            Status__c = 'Queued',
            TargetObjectId__c = con2.Id,
            TemplateId__c = et1.Id
        );
        insert eq1;
        insert eq2;

        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(c.Id);
        Map<Id, String> templateSubjects = CourseEmailSchedulingLog.getTemplateSubjects(emailQueue);

        Test.StartTest();
        Map<Id, List<EmailQueue__c>> emailQueueTemplateIdAsKey = CourseEmailSchedulingLogHelper.getEmailQueueTemplateIdAsKey(
            emailQueue,
            templateSubjects
        );
        Test.StopTest();

        System.assertEquals(1, emailQueueTemplateIdAsKey.size(), 'only one email subject, only one category');
        System.assertEquals(2, emailQueueTemplateIdAsKey.get(et1.Id).size(), 'only one email queue per template');
        System.assert(
            emailQueueTemplateIdAsKey.get(et1.Id)[0].Id == eq1.Id ||
                emailQueueTemplateIdAsKey.get(et1.Id)[0].Id == eq2.Id,
            'only one email queue per template'
        );
        System.assert(
            emailQueueTemplateIdAsKey.get(et1.Id)[1].Id == eq1.Id ||
                emailQueueTemplateIdAsKey.get(et1.Id)[1].Id == eq2.Id,
            'only one email queue per template'
        );
    }

    @isTest
    private static void testCreateChildren() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);
        Map<Id, String> contactNames = CourseEmailSchedulingLog.getContactNames(emailQueue);

        Test.StartTest();
        List<CourseEmailSchedulingLog.LogChildren> children = CourseEmailSchedulingLogHelper.createChildren(
            emailQueue,
            contactNames
        );
        Test.StopTest();

        EmailQueue__c email = [SELECT Id, LastModifiedDate FROM EmailQueue__c LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact LIMIT 1];

        System.assertEquals(1, children.size(), 'only one email queue, only one child');
        System.assertEquals(email.Id, children[0].name, 'name should be set');
        System.assertEquals(con.Id, children[0].TargetObjectId, 'TargetObjectId should be set');
        System.assertEquals(con.Name, children[0].label, 'label should be set');
        System.assertEquals('⏱ I utsendingskø', children[0].metatext, 'metatext should be set');
    }

    @isTest
    private static void testGetStatus() {
        System.assertEquals(
            'Sendt',
            CourseEmailSchedulingLogHelper.getStatus('Sent'),
            'english sent in should be translated'
        );
        System.assertEquals(
            '⏱ I utsendingskø',
            CourseEmailSchedulingLogHelper.getStatus('Queued'),
            'english sent in should be translated'
        );
        System.assertEquals(
            '⏱ Sendes straks',
            CourseEmailSchedulingLogHelper.getStatus('Instant'),
            'english sent in should be translated'
        );
        System.assertEquals(
            '❌ Feilet ved utsending, kontakt en administrator',
            CourseEmailSchedulingLogHelper.getStatus('Error'),
            'english sent in should be translated'
        );
        System.assertEquals(
            'wfrefrefefrfr',
            CourseEmailSchedulingLogHelper.getStatus('wfrefrefefrfr'),
            'english sent in should be translated'
        );
    }

    @isTest
    private static void testGetParentMetatext_queued() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);
        emailQueue[0].Status__c = 'Queued';

        Test.StartTest();
        String results = CourseEmailSchedulingLogHelper.getParentMetatext(emailQueue);
        Test.StopTest();

        System.assertEquals('⏱ I utsendingskø', results, 'queued status should be received');
    }

    @isTest
    private static void testGetParentMetatext_instant() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);
        emailQueue[0].Status__c = 'Instant';

        Test.StartTest();
        String results = CourseEmailSchedulingLogHelper.getParentMetatext(emailQueue);
        Test.StopTest();

        System.assertEquals('⏱ Sendes straks', results, 'instant status should be received');
    }

    @isTest
    private static void testGetParentMetatext_error() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);
        emailQueue[0].Status__c = 'Error';

        Test.StartTest();
        String results = CourseEmailSchedulingLogHelper.getParentMetatext(emailQueue);
        Test.StopTest();

        System.assertEquals(
            '❌ En eller flere e-poster feiler, klikk for mer informasjon',
            results,
            'error status should be received'
        );
    }

    @isTest
    private static void testGetParentMetatext_sent() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);
        emailQueue[0].Status__c = 'Sent';

        Test.StartTest();
        String results = CourseEmailSchedulingLogHelper.getParentMetatext(emailQueue);
        Test.StopTest();

        System.assertEquals(
            'Sendt (' + Date.today().day() + '.' + Date.today().month() + '.' + Date.today().year() + ')',
            results,
            'queued status should be received'
        );
    }
}
