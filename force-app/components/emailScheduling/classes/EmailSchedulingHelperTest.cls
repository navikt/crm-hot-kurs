@isTest
private without sharing class EmailSchedulingHelperTest {
    @TestSetup
    static void makeData() {
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
        EmailTemplate et3 = new EmailTemplate(
            DeveloperName = 'courseScheduledEmailAfter',
            Name = 'courseScheduledEmailAfter',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Invitasjon til kurs',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>'
        );
        EmailTemplate et4 = new EmailTemplate(
            DeveloperName = 'courseScheduledEmailManual',
            Name = 'courseScheduledEmailManual',
            IsActive = true,
            FolderId = UserInfo.getOrganizationId(),
            UiType = 'sfx',
            TemplateType = 'custom',
            Subject = 'Invitasjon til kurs',
            HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>'
        );
        Database.insert(new List<EmailTemplate>{ et1, et2, et3, et4 }, false);

        addCoursesAndRegistrations(1, 2, true, true, true, true, '');
    }

    @isTest
    private static void testGetCoursesWithScheduledEmails() {
        Test.StartTest();
        Map<Id, Course__c> results = EmailSchedulingHelper.getCoursesWithScheduledEmails();
        Test.StopTest();

        System.assertEquals(
            4,
            results.size(),
            'four courses should have scheduled emails for "today"'
        );
    }

    @isTest
    private static void testGetCourseRegistrations() {
        Map<Id, Course__c> courses = EmailSchedulingHelper.getCoursesWithScheduledEmails();

        Test.StartTest();
        List<CourseRegistration__c> results = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );
        Test.StopTest();

        System.assertEquals(
            8,
            results.size(),
            'four courses with two course participants each'
        );
    }

    @isTest
    private static void testPrepareEmails() {
        Map<Id, Course__c> courses = EmailSchedulingHelper.getCoursesWithScheduledEmails();
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );

        Test.StartTest();
        List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        Test.StopTest();

        System.assertEquals(
            8,
            results.size(),
            'four courses with two course participants each, resulting in 8 emails to be sent'
        );

        for (EmailSchedulingHelper.ScheduleModel model : results) {
            System.assertNotEquals(
                null,
                model.courseId,
                'courseId should be set nad NOT null'
            );
            System.assertNotEquals(
                null,
                model.contactId,
                'contactId should be set nad NOT null'
            );
            System.assertNotEquals(
                null,
                model.emailTemplate,
                'emailTemplate should be set nad NOT null'
            );
        }
    }

    @isTest
    private static void testPrepareEmails_after() {
        Map<Id, Course__c> courses = new Map<Id, Course__c>(
            [
                SELECT
                    Id,
                    EmailAfterDate__c,
                    EmailBeforeDate__c,
                    EmailManualDate__c,
                    EmailReminderDate__c
                FROM Course__c
                WHERE Name = 'after'
                LIMIT 1
            ]
        );
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );

        Test.StartTest();
        List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        Test.StopTest();

        EmailTemplate template = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'courseScheduledEmailAfter'
            LIMIT 1
        ];

        System.assertEquals(
            2,
            results.size(),
            'four courses with two course participants each, resulting in 8 emails to be sent'
        );
        System.assertEquals(
            template.Id,
            results[0].emailTemplate,
            'Should have the "after" template'
        );
        System.assertEquals(
            template.Id,
            results[1].emailTemplate,
            'Should have the "after" template'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[0].courseId,
            'Should have the same course id'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[1].courseId,
            'Should have the same course id'
        );
    }

    @isTest
    private static void testPrepareEmails_before() {
        Map<Id, Course__c> courses = new Map<Id, Course__c>(
            [
                SELECT
                    Id,
                    EmailAfterDate__c,
                    EmailBeforeDate__c,
                    EmailManualDate__c,
                    EmailReminderDate__c
                FROM Course__c
                WHERE Name = 'before'
                LIMIT 1
            ]
        );
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );

        Test.StartTest();
        List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        Test.StopTest();

        EmailTemplate template = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'courseScheduledEmailBefore'
            LIMIT 1
        ];

        System.assertEquals(
            2,
            results.size(),
            'four courses with two course participants each, resulting in 8 emails to be sent'
        );
        System.assertEquals(
            template.Id,
            results[0].emailTemplate,
            'Should have the "before" template'
        );
        System.assertEquals(
            template.Id,
            results[1].emailTemplate,
            'Should have the "before" template'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[0].courseId,
            'Should have the same course id'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[1].courseId,
            'Should have the same course id'
        );
    }

    @isTest
    private static void testPrepareEmails_manual() {
        Map<Id, Course__c> courses = new Map<Id, Course__c>(
            [
                SELECT
                    Id,
                    EmailAfterDate__c,
                    EmailBeforeDate__c,
                    EmailManualDate__c,
                    EmailReminderDate__c
                FROM Course__c
                WHERE Name = 'manual'
                LIMIT 1
            ]
        );
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );

        Test.StartTest();
        List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        Test.StopTest();

        EmailTemplate template = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'courseScheduledEmailManual'
            LIMIT 1
        ];

        System.assertEquals(
            2,
            results.size(),
            'four courses with two course participants each, resulting in 8 emails to be sent'
        );
        System.assertEquals(
            template.Id,
            results[0].emailTemplate,
            'Should have the "manual" template'
        );
        System.assertEquals(
            template.Id,
            results[1].emailTemplate,
            'Should have the "manual" template'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[0].courseId,
            'Should have the same course id'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[1].courseId,
            'Should have the same course id'
        );
    }

    @isTest
    private static void testPrepareEmails_reminder() {
        Map<Id, Course__c> courses = new Map<Id, Course__c>(
            [
                SELECT
                    Id,
                    EmailAfterDate__c,
                    EmailBeforeDate__c,
                    EmailManualDate__c,
                    EmailReminderDate__c
                FROM Course__c
                WHERE Name = 'reminder'
                LIMIT 1
            ]
        );
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );

        Test.StartTest();
        List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        Test.StopTest();

        EmailTemplate template = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'courseScheduledEmailReminder'
            LIMIT 1
        ];

        System.assertEquals(
            2,
            results.size(),
            'four courses with two course participants each, resulting in 8 emails to be sent'
        );
        System.assertEquals(
            template.Id,
            results[0].emailTemplate,
            'Should have the "reminder" template'
        );
        System.assertEquals(
            template.Id,
            results[1].emailTemplate,
            'Should have the "reminder" template'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[0].courseId,
            'Should have the same course id'
        );
        System.assertEquals(
            courses.values()[0].Id,
            results[1].courseId,
            'Should have the same course id'
        );
    }

    // makes sure datetime field used is converted correctly to date to avoid any timing issues
    @isTest
    private static void testPrepareEmails_differentTime() {
        Contact con = new Contact(
            LastName = 'test',
            email = 'ola.nordmann2@test.com',
            TAG_Informed__c = true
        );
        insert con;
        DateTime d = Datetime.now().addDays(+7);
        Course__c course = new Course__c(
            Name = 'unique',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region__c = 'Oslo',
            RegistrationDeadline__c = d,
            RegistrationFromDateTime__c = d,
            RegistrationToDateTime__c = d.addDays(1),
            EmailBeforeContent__c = 'test',
            EmailBeforeConfirmation__c = true
        );
        insert course;
        CourseRegistration__c courseReg = new CourseRegistration__c(
            Course__c = course.Id,
            CourseParticipant__c = con.Id,
            Status__c = 'Påmeldt'
        );
        insert courseReg;

        Map<Id, Course__c> courses = new Map<Id, Course__c>(
            [
                SELECT
                    Id,
                    EmailAfterDate__c,
                    EmailBeforeDate__c,
                    EmailManualDate__c,
                    EmailReminderDate__c
                FROM Course__c
                WHERE Name = 'unique'
                LIMIT 1
            ]
        );
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );

        Test.StartTest();
        List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        Test.StopTest();

        EmailTemplate template = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = 'courseScheduledEmailBefore'
            LIMIT 1
        ];

        System.assertEquals(1, results.size(), 'only one reg');
        System.assertEquals(
            template.Id,
            results[0].emailTemplate,
            'Should have the "before" template'
        );
    }

    @isTest
    private static void testQueueEmails() {
        Map<Id, Course__c> courses = EmailSchedulingHelper.getCoursesWithScheduledEmails();
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );
        List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );

        Test.StartTest();
        EmailSchedulingHelper.queueEmails(recipients);
        Test.StopTest();

        System.assertEquals(
            8,
            [SELECT Id FROM EmailQueue__c].size(),
            'should be 8 email queues as 4 courses with 2 participants each'
        );
    }

    @isTest
    private static void testGetCoursesWithEmailErrors() {
        Map<Id, Course__c> courses = EmailSchedulingHelper.getCoursesWithScheduledEmails();
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );
        List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        List<EmailQueue__c> queuedEmails = EmailSchedulingHelper.queueEmails(
            recipients
        );

        Test.StartTest();
        Map<Id, List<String>> results = EmailSchedulingHelper.getCoursesWithEmailQueue(
            queuedEmails
        );
        Test.StopTest();

        System.assertEquals(4, results.size(), 'four courses');

        for (Id key : results.keySet()) {
            System.assertEquals(
                2,
                results.get(key).size(),
                'should be two email queues for each course__c'
            );
        }
    }

    @isTest
    private static void testUpdateCourses() {
        Map<Id, Course__c> courses = EmailSchedulingHelper.getCoursesWithScheduledEmails();
        System.assertEquals(
            4,
            courses.size(),
            'all four courses should have one email ready to be sent'
        );
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );
        List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        List<EmailQueue__c> queuedEmails = EmailSchedulingHelper.queueEmails(
            recipients
        );
        Map<Id, List<String>> coursesWithEmailQueue = EmailSchedulingHelper.getCoursesWithEmailQueue(
            queuedEmails
        );

        Test.StartTest();
        EmailSchedulingHelper.updateCourses(courses, coursesWithEmailQueue);
        Test.StopTest();

        courses = EmailSchedulingHelper.getCoursesWithScheduledEmails();
        System.assertEquals(
            0,
            courses.size(),
            'all four courses should have emails sent'
        );

        Course__c beforeCourse = [
            SELECT EmailBeforeEmailQueueId__c
            FROM Course__c
            WHERE Name = 'before'
            LIMIT 1
        ];
        Course__c afterCourse = [
            SELECT EmailAfterEmailQueueId__c
            FROM Course__c
            WHERE Name = 'after'
            LIMIT 1
        ];
        Course__c reminderCourse = [
            SELECT EmailReminderEmailQueueId__c
            FROM Course__c
            WHERE Name = 'reminder'
            LIMIT 1
        ];
        Course__c manualCourse = [
            SELECT EmailManualEmailQueueId__c
            FROM Course__c
            WHERE Name = 'manual'
            LIMIT 1
        ];

        List<EmailQueue__c> beforeQueue = [
            SELECT Id
            FROM EmailQueue__c
            WHERE WhatId__c = :beforeCourse.Id
        ];
        List<EmailQueue__c> afterQueue = [
            SELECT Id
            FROM EmailQueue__c
            WHERE WhatId__c = :afterCourse.Id
        ];
        List<EmailQueue__c> reminderQueue = [
            SELECT Id
            FROM EmailQueue__c
            WHERE WhatId__c = :reminderCourse.Id
        ];
        List<EmailQueue__c> manualQueue = [
            SELECT Id
            FROM EmailQueue__c
            WHERE WhatId__c = :manualCourse.Id
        ];

        System.assert(
            beforeCourse.EmailBeforeEmailQueueId__c.contains(beforeQueue[0].Id),
            'EmailBeforeEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            beforeQueue[0].Id
        );
        System.assert(
            beforeCourse.EmailBeforeEmailQueueId__c.contains(beforeQueue[1].Id),
            'EmailBeforeEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            beforeQueue[1].Id
        );

        System.assert(
            afterCourse.EmailAfterEmailQueueId__c.contains(afterQueue[0].Id),
            'EmailAfterEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            afterQueue[0].Id
        );
        System.assert(
            afterCourse.EmailAfterEmailQueueId__c.contains(afterQueue[1].Id),
            'EmailAfterEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            afterQueue[1].Id
        );

        System.assert(
            reminderCourse.EmailReminderEmailQueueId__c.contains(
                reminderQueue[0].Id
            ),
            'EmailReminderEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            reminderQueue[0].Id
        );
        System.assert(
            reminderCourse.EmailReminderEmailQueueId__c.contains(
                reminderQueue[1].Id
            ),
            'EmailReminderEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            reminderQueue[1].Id
        );

        System.assert(
            manualCourse.EmailManualEmailQueueId__c.contains(manualQueue[0].Id),
            'EmailManualEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            manualQueue[0].Id
        );
        System.assert(
            manualCourse.EmailManualEmailQueueId__c.contains(manualQueue[1].Id),
            'EmailManualEmailQueueId__c should contain one of two EmailQueue__c Id\'s: ' +
            manualQueue[1].Id
        );
    }

    @isTest
    private static void testCreateTasks() {
        Map<Id, Course__c> courses = EmailSchedulingHelper.getCoursesWithScheduledEmails();
        List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations(
            courses
        );
        List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.prepareEmails(
            courses,
            courseRegistrations
        );
        List<EmailQueue__c> queuedEmails = EmailSchedulingHelper.queueEmails(
            recipients
        );
        Map<Id, List<String>> coursesWithEmailQueue = EmailSchedulingHelper.getCoursesWithEmailQueue(
            queuedEmails
        );

        Test.StartTest();
        EmailSchedulingHelper.createTasks(courses, coursesWithEmailQueue);
        Test.StopTest();

        List<Task> tasks = [
            SELECT Id, Description, Subject, WhatId, Status
            FROM Task
            WHERE WhatId IN :courses.keySet()
        ];
        Course__c after = [
            SELECT Id, EmailAfterContent__c, EmailAfterSent__c
            FROM Course__c
            WHERE Name = 'after'
            LIMIT 1
        ];
        Course__c before = [
            SELECT Id, EmailBeforeContent__c, EmailBeforeSent__c
            FROM Course__c
            WHERE Name = 'before'
            LIMIT 1
        ];
        Course__c manual = [
            SELECT Id, EmailManualContent__c, EmailManualSent__c
            FROM Course__c
            WHERE Name = 'manual'
            LIMIT 1
        ];
        Course__c reminder = [
            SELECT Id, EmailReminderContent__c, EmailReminderSent__c
            FROM Course__c
            WHERE Name = 'reminder'
            LIMIT 1
        ];

        System.assertEquals(4, tasks.size(), 'four tasks created');

        for (Task task : tasks) {
            System.assertEquals(
                'Completed',
                task.Status,
                'Status should be completed'
            );

            if (task.WhatId == after.Id) {
                System.assertEquals(
                    after.EmailAfterContent__c,
                    task.Description,
                    'EmailAfterContent__c should be the tasks description'
                );
                System.assertEquals(
                    'Evaluerings e-post sendt',
                    task.Subject,
                    'Subject should "Evaluerings e-post sendt"'
                );
            } else if (task.WhatId == before.Id) {
                System.assertEquals(
                    before.EmailBeforeContent__c,
                    task.Description,
                    'EmailBeforeContent__c should be the tasks description'
                );
                System.assertEquals(
                    'E-post med informasjon før kurs sendt',
                    task.Subject,
                    'Subject should "E-post med informasjon før kurs sendt"'
                );
            } else if (task.WhatId == manual.Id) {
                System.assertEquals(
                    manual.EmailManualContent__c,
                    task.Description,
                    'EmailManualContent__c should be the tasks description'
                );
                System.assertEquals(
                    'Manuell e-post sendt',
                    task.Subject,
                    'Subject should "Manuell e-post sendt"'
                );
            } else if (task.WhatId == reminder.Id) {
                System.assertEquals(
                    reminder.EmailReminderContent__c,
                    task.Description,
                    'EmailReminderContent__c should be the tasks description'
                );
                System.assertEquals(
                    'Påminnelse om kurs er sendt på e-post',
                    task.Subject,
                    'Subject should "Påminnelse om kurs er sendt på e-post"'
                );
            }
        }
    }

    // ------------------------------------------------
    // ------------ HELPER FUNCTIONS TESTS ------------
    // ------------------------------------------------

    @isTest
    private static void testCheckEmailType() {
        Course__c after = [
            SELECT
                Id,
                EmailAfterDate__c,
                EmailBeforeDate__c,
                EmailManualDate__c,
                EmailReminderDate__c
            FROM Course__c
            WHERE Name = 'after'
            LIMIT 1
        ];
        Course__c before = [
            SELECT
                Id,
                EmailAfterDate__c,
                EmailBeforeDate__c,
                EmailManualDate__c,
                EmailReminderDate__c
            FROM Course__c
            WHERE Name = 'before'
            LIMIT 1
        ];
        Course__c manual = [
            SELECT
                Id,
                EmailAfterDate__c,
                EmailBeforeDate__c,
                EmailManualDate__c,
                EmailReminderDate__c
            FROM Course__c
            WHERE Name = 'manual'
            LIMIT 1
        ];
        Course__c reminder = [
            SELECT
                Id,
                EmailAfterDate__c,
                EmailBeforeDate__c,
                EmailManualDate__c,
                EmailReminderDate__c
            FROM Course__c
            WHERE Name = 'reminder'
            LIMIT 1
        ];

        Test.StartTest();
        EmailSchedulingHelper.EmailTypes afterResult = EmailSchedulingHelper.checkEmailType(
            after
        );
        EmailSchedulingHelper.EmailTypes beforeResult = EmailSchedulingHelper.checkEmailType(
            before
        );
        EmailSchedulingHelper.EmailTypes manualResult = EmailSchedulingHelper.checkEmailType(
            manual
        );
        EmailSchedulingHelper.EmailTypes reminderResult = EmailSchedulingHelper.checkEmailType(
            reminder
        );
        Test.StopTest();

        System.assertEquals(
            EmailSchedulingHelper.EmailTypes.AFTER,
            afterResult,
            'enum should be after'
        );
        System.assertEquals(
            EmailSchedulingHelper.EmailTypes.BEFORE,
            beforeResult,
            'enum should be before'
        );
        System.assertEquals(
            EmailSchedulingHelper.EmailTypes.MANUAL,
            manualResult,
            'enum should be manual'
        );
        System.assertEquals(
            EmailSchedulingHelper.EmailTypes.REMINDER,
            reminderResult,
            'enum should be reminder'
        );
    }

    // ------------------------------------------------
    // --------------- HELPER FUNCTIONS ---------------
    // ------------------------------------------------

    public static void addCoursesAndRegistrations(
        Integer amountOfEach,
        Integer amountOfContacts,
        Boolean createBefore,
        Boolean createReminder,
        Boolean createAfter,
        Boolean createManual,
        String unique
    ) {
        for (Integer i = 0; i < amountOfEach; i++) {
            List<Course__c> courses = new List<Course__c>();

            DateTime beforeDate = Date.today().addDays(+7);
            DateTime reminderDate = Date.today().addDays(+1);
            DateTime afterDate = Date.today().addDays(-1);
            DateTime manualDate = Date.today();

            Course__c beforeCourse = !createBefore
                ? null
                : new Course__c(
                      Name = 'before',
                      Active__c = true,
                      MaxNumberOfParticipants__c = 4,
                      CommunityUrl__c = 'test',
                      Region__c = 'Oslo',
                      RegistrationDeadline__c = beforeDate,
                      RegistrationFromDateTime__c = beforeDate,
                      RegistrationToDateTime__c = beforeDate.addDays(1),
                      EmailBeforeContent__c = 'test',
                      EmailBeforeConfirmation__c = true
                  );
            Course__c reminderCourse = !createReminder
                ? null
                : new Course__c(
                      Name = 'reminder',
                      Active__c = true,
                      MaxNumberOfParticipants__c = 4,
                      CommunityUrl__c = 'test',
                      Region__c = 'Oslo',
                      RegistrationDeadline__c = reminderDate,
                      RegistrationFromDateTime__c = reminderDate,
                      RegistrationToDateTime__c = reminderDate.addDays(1),
                      EmailReminderContent__c = 'test',
                      EmailReminderConfirmation__c = true
                  );
            Course__c afterCourse = !createAfter
                ? null
                : new Course__c(
                      Name = 'after',
                      Active__c = true,
                      MaxNumberOfParticipants__c = 4,
                      CommunityUrl__c = 'test',
                      Region__c = 'Oslo',
                      RegistrationDeadline__c = afterDate,
                      RegistrationFromDateTime__c = afterDate.addDays(-2),
                      RegistrationToDateTime__c = afterDate,
                      EmailAfterContent__c = 'test',
                      EmailAfterConfirmation__c = true,
                      EmailAfterURL__c = 'https://nav.no'
                  );
            Course__c manualCourse = !createManual
                ? null
                : new Course__c(
                      Name = 'manual',
                      Active__c = true,
                      MaxNumberOfParticipants__c = 4,
                      CommunityUrl__c = 'test',
                      Region__c = 'Oslo',
                      RegistrationDeadline__c = manualDate.addDays(-1),
                      RegistrationFromDateTime__c = manualDate.addDays(-1),
                      RegistrationToDateTime__c = Date.today(),
                      EmailManualContent__c = 'test',
                      EmailManualDate__c = Date.today(),
                      EmailManualConfirmation__c = true
                  );
            if (beforeCourse != null) {
                courses.add(beforeCourse);
            }
            if (reminderCourse != null) {
                courses.add(reminderCourse);
            }
            if (afterCourse != null) {
                courses.add(afterCourse);
            }
            if (manualCourse != null) {
                courses.add(manualCourse);
            }
            insert courses;

            List<Contact> contacts = new List<Contact>();
            for (Integer k = 0; k < amountOfContacts; k++) {
                contacts.add(
                    new Contact(
                        LastName = 'test' + k + unique + i,
                        email = k + unique + i + 'ola.nordmann@test.com',
                        TAG_Informed__c = true
                    )
                );
            }
            insert contacts;

            List<CourseRegistration__c> registrations = new List<CourseRegistration__c>();
            for (Contact contact : contacts) {
                if (createBefore) {
                    registrations.add(
                        new CourseRegistration__c(
                            Course__c = beforeCourse.Id,
                            CourseParticipant__c = contact.Id,
                            Status__c = 'Påmeldt'
                        )
                    );
                }
                if (createReminder) {
                    registrations.add(
                        new CourseRegistration__c(
                            Course__c = reminderCourse.Id,
                            CourseParticipant__c = contact.Id,
                            Status__c = 'Påmeldt'
                        )
                    );
                }
                if (createAfter) {
                    registrations.add(
                        new CourseRegistration__c(
                            Course__c = afterCourse.Id,
                            CourseParticipant__c = contact.Id,
                            Status__c = 'Påmeldt'
                        )
                    );
                }
                if (createManual) {
                    registrations.add(
                        new CourseRegistration__c(
                            Course__c = manualCourse.Id,
                            CourseParticipant__c = contact.Id,
                            Status__c = 'Påmeldt'
                        )
                    );
                }
            }
            insert registrations;
        }
    }
}
