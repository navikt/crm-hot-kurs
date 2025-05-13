@isTest
private without sharing class CourseEmailSchedulingLogTest {
    @TestSetup
    private static void makeData() {
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
    private static void testGetLogData() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;

        Test.StartTest();
        List<CourseEmailSchedulingLog.LogData> results = CourseEmailSchedulingLog.getLogData(recordId);
        Test.StopTest();

        EmailQueue__c email = [SELECT Id, LastModifiedDate FROM EmailQueue__c LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact LIMIT 1];

        // parent
        System.assertEquals(1, results.size(), 'one emailqueue for the case');
        System.assertEquals('HEI OG VELKOMMEN', results[0].name, 'name should be set');
        System.assertEquals('⏱ I utsendingskø', results[0].metatext, 'metatext should be set');
        System.assertEquals('HEI OG VELKOMMEN', results[0].label, 'label should be set');
        System.assertEquals(false, results[0].expanded, 'expanded should be set');

        // children
        System.assertEquals(1, results[0].items.size(), 'should have one child');
        System.assertEquals(email.Id, results[0].items[0].name, 'name should be set');
        System.assertEquals(con.Id, results[0].items[0].TargetObjectId, 'TargetObjectId should be set');
        System.assertEquals(con.Name, results[0].items[0].label, 'label should be set');
        System.assertEquals('⏱ I utsendingskø', results[0].items[0].metatext, 'metatext should be set');
    }

    @isTest
    private static void testGetEmailQueue() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;

        Test.StartTest();
        List<EmailQueue__c> results = CourseEmailSchedulingLog.getEmailQueue(recordId);
        Test.StopTest();

        System.assertEquals(1, results.size(), 'only one email queue created');
    }

    @isTest
    private static void testGetTemplateSubjects() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);

        Test.StartTest();
        Map<Id, String> results = CourseEmailSchedulingLog.getTemplateSubjects(emailQueue);
        Test.StopTest();

        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'MY_UNIQUE_TEMPLATE' LIMIT 1];

        System.assertEquals(1, results.size(), 'only one email queue created and only one email template on it');
        System.assert(
            results.containsKey(emailTemplate.Id),
            'only one email queue created and only one email template on it'
        );
        System.assertEquals(
            'HEI OG VELKOMMEN',
            results.get(emailTemplate.Id),
            'only one email queue created and only one email template on it'
        );
    }

    @isTest
    private static void testGetContactNames() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);

        Test.StartTest();
        Map<Id, String> results = CourseEmailSchedulingLog.getContactNames(emailQueue);
        Test.StopTest();

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        System.assertEquals(1, results.size(), 'only one email queue created and only one contact on it');
        System.assert(results.containsKey(con.Id), 'only one email queue created and only one contact on it');
        System.assertEquals('McSmith', results.get(con.Id), 'only one email queue created and only one contact on it');
    }

    @isTest
    private static void testCreateData() {
        Id recordId = [SELECT Id FROM Case LIMIT 1].Id;
        List<EmailQueue__c> emailQueue = CourseEmailSchedulingLog.getEmailQueue(recordId);
        Map<Id, String> templateSubjects = CourseEmailSchedulingLog.getTemplateSubjects(emailQueue);
        Map<Id, String> contactNames = CourseEmailSchedulingLog.getContactNames(emailQueue);

        Test.StartTest();
        List<CourseEmailSchedulingLog.LogData> results = CourseEmailSchedulingLog.createData(
            emailQueue,
            templateSubjects,
            contactNames
        );
        Test.StopTest();

        EmailQueue__c email = [SELECT Id, LastModifiedDate FROM EmailQueue__c LIMIT 1];
        Contact con = [SELECT Id, Name FROM Contact LIMIT 1];

        // parent
        System.assertEquals(1, results.size(), 'one emailqueue for the case');
        System.assertEquals('HEI OG VELKOMMEN', results[0].name, 'name should be set');
        System.assertEquals('⏱ I utsendingskø', results[0].metatext, 'metatext should be set');
        System.assertEquals('HEI OG VELKOMMEN', results[0].label, 'label should be set');
        System.assertEquals(false, results[0].expanded, 'expanded should be set');

        // children
        System.assertEquals(1, results[0].items.size(), 'should have one child');
        System.assertEquals(email.Id, results[0].items[0].name, 'name should be set');
        System.assertEquals(con.Id, results[0].items[0].TargetObjectId, 'TargetObjectId should be set');
        System.assertEquals(con.Name, results[0].items[0].label, 'label should be set');
        System.assertEquals('⏱ I utsendingskø', results[0].items[0].metatext, 'metatext should be set');
    }
}
