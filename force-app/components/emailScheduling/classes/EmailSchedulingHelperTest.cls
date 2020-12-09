@isTest
private without sharing class EmailSchedulingHelperTest {

	@TestSetup
	static void makeData() {
		addCoursesAndRegistrations( 1, '' );
	}

	@isTest
	private static void testcheckIfTemplatesMissing_exists() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Test.StartTest();
		Boolean result = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		Test.StopTest();

		System.assertEquals( false, result, 'templates exists, so should return false' );
	}

	@isTest
	private static void testFindScheduledEmails() {

		Test.StartTest();
		List<Course__c> results = EmailSchedulingHelper.findScheduledEmails();
		Test.StopTest();

		System.assertEquals( 4, results.size(), 'four courses should have scheduled emails for "today"' );
	}

	@isTest
	private static void testGetCourseRegistrations() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Test.StartTest();
		List<CourseRegistration__c> results = EmailSchedulingHelper.getCourseRegistrations( courses );
		Test.StopTest();

		System.assertEquals( 8, results.size(), 'four courses with two course participants each' );
	}

	@isTest
	private static void testGetEmailsToSend() {
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		Test.StopTest();

		System.assertEquals( 8, results.size(), 'four courses with two course participants each, resulting in 8 emails to be sent' );
	}

	@isTest
	private static void testGetEmailsToSend_after() {
		List<Course__c> courses = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'after' LIMIT 1];
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		Test.StopTest();

		System.assertEquals( 2, results.size(), 'four courses with two course participants each, resulting in 8 emails to be sent' );
		System.assertEquals( 'courseScheduledEmailAfter', results[0].emailTemplate, 'Should have the "after" template' );
		System.assertEquals( 'courseScheduledEmailAfter', results[1].emailTemplate, 'Should have the "after" template' );
		System.assertEquals( courses[0].Id, results[0].courseId, 'Should have the same course id' );
		System.assertEquals( courses[0].Id, results[1].courseId, 'Should have the same course id' );
	}

	@isTest
	private static void testGetEmailsToSend_before() {
		List<Course__c> courses = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'before' LIMIT 1];
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		Test.StopTest();

		System.assertEquals( 2, results.size(), 'four courses with two course participants each, resulting in 8 emails to be sent' );
		System.assertEquals( 'courseScheduledEmailBefore', results[0].emailTemplate, 'Should have the "before" template' );
		System.assertEquals( 'courseScheduledEmailBefore', results[1].emailTemplate, 'Should have the "before" template' );
		System.assertEquals( courses[0].Id, results[0].courseId, 'Should have the same course id' );
		System.assertEquals( courses[0].Id, results[1].courseId, 'Should have the same course id' );
	}

	@isTest
	private static void testGetEmailsToSend_manual() {
		List<Course__c> courses = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'manual' LIMIT 1];
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		Test.StopTest();

		System.assertEquals( 2, results.size(), 'four courses with two course participants each, resulting in 8 emails to be sent' );
		System.assertEquals( 'courseScheduledEmailManual', results[0].emailTemplate, 'Should have the "manual" template' );
		System.assertEquals( 'courseScheduledEmailManual', results[1].emailTemplate, 'Should have the "manual" template' );
		System.assertEquals( courses[0].Id, results[0].courseId, 'Should have the same course id' );
		System.assertEquals( courses[0].Id, results[1].courseId, 'Should have the same course id' );
	}

	// makes sure datetime field used is converted correctly to date to avoid any timing issues
	@isTest
	private static void testGetEmailsToSend_differentTime() {

		Contact con = new Contact( LastName = 'test', email = 'ola.nordmann2@test.com', TAG_Informed__c = true );
		insert con;
		DateTime d = Datetime.now().addDays( +7 );
		Course__c course = new Course__c( Name = 'unique', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ), EmailBeforeContent__c = 'test', EmailBeforeConfirmation__c = true );
		insert course;
		CourseRegistration__c courseReg = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = con.Id, Status__c = 'Påmeldt' );
		insert courseReg;

		List<Course__c> courses = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'unique' LIMIT 1];
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		Test.StopTest();

		System.assertEquals( 1, results.size(), 'only one reg' );
		System.assertEquals( 'courseScheduledEmailBefore', results[0].emailTemplate, 'Should have the "before" template' );
	}

	@isTest
	private static void testGetEmailsToSend_reminder() {
		List<Course__c> courses = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'reminder' LIMIT 1];
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<EmailSchedulingHelper.ScheduleModel> results = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		Test.StopTest();

		System.assertEquals( 2, results.size(), 'four courses with two course participants each, resulting in 8 emails to be sent' );
		System.assertEquals( 'courseScheduledEmailReminder', results[0].emailTemplate, 'Should have the "reminder" template' );
		System.assertEquals( 'courseScheduledEmailReminder', results[1].emailTemplate, 'Should have the "reminder" template' );
		System.assertEquals( courses[0].Id, results[0].courseId, 'Should have the same course id' );
		System.assertEquals( courses[0].Id, results[1].courseId, 'Should have the same course id' );
	}

	@isTest
	private static void testSeprateEmailsIntoBulks() {

		addCoursesAndRegistrations( 1, 'unique' ); // doubled with makeData()
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );

		System.assertEquals( 8, courses.size(), 'should have 8 courses due to doubled courses' );
		System.assertEquals( 16, courseRegistrations.size(), 'should have 16 registrations due to doubled courses' );
		System.assertEquals( 16, recipients.size(), 'should have 16 recipients due to doubled courses' );

		Test.StartTest();
		List<List<EmailSchedulingHelper.ScheduleModel> > sepratedEmailBulks = EmailSchedulingHelper.seprateEmailsIntoBulks( recipients );
		Test.StopTest();

		System.assertEquals( 2, sepratedEmailBulks.size(), '10 is max emails, thus the 16 emails are separated into two bulks' );
		System.assertEquals( 10, sepratedEmailBulks[0].size(), '10 is max emails, and with 16 total the first batch are 10 emails' );
		System.assertEquals( 6, sepratedEmailBulks[1].size(), '10 is max emails, and with 16 total the second batch are 6 emails' );
	}

	@isTest
	private static void testSendEmailToCourseRecipients() {
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );

		Test.StartTest();
		EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		Test.StopTest();

		List<EmailMessage> emails = [SELECT Id FROM EmailMessage];
		System.assertEquals( 16, emails.size(), '8 emails sent, 8 EmailMessages created' );
	}

	@isTest
	private static void testGetCoursesWithEmailErrors() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		System.debug( 'emailResults: ' + emailResults );
		System.assertEquals( 4, courses.size(), 'four courses' );

		Test.StartTest();
		Map<Id, String> results = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );
		Test.StopTest();

		System.assertEquals( 4, results.size(), 'four courses with email issues' );

		for ( Id key : results.keySet() ) {
			System.assert ( results.get( key ).contains( 'Email limit exceeded' ), '"Email limit exceeded" should be in string' );
		}
	}

	@isTest
	private static void testUpdateCoursesWithEmailStatus() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		courses.remove( 3 );
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		Map<Id, String> cousesWithEmailErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );

		System.assertEquals( 3, courses.size(), 'four courses ready to have emails be sent' );

		Test.StartTest();
		EmailSchedulingHelper.updateCoursesWithEmailStatus( courses, cousesWithEmailErrors );
		Test.StopTest();

		courses = EmailSchedulingHelper.findScheduledEmails();
		System.assertEquals( 1, courses.size(), 'one course have emails that should be sent, but is now lower' );
	}

	@isTest
	private static void testUpdateCoursesWithEmailStatus_errorOnAllEmails() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		Map<Id, String> cousesWithEmailErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );

		for ( EmailSchedulingHelper.ScheduleModel recipient : recipients ) {
			recipient.contactId = null;
		}

		System.assertEquals( 4, courses.size(), 'four courses ready to have emails be sent' );

		Test.StartTest();
		EmailSchedulingHelper.updateCoursesWithEmailStatus( courses, cousesWithEmailErrors );
		Test.StopTest();

		courses = EmailSchedulingHelper.findScheduledEmails();
		System.assertEquals( 4, courses.size(), 'still four new courses have emails that should be sent because of emailing issues' );

		for ( Course__c course : [SELECT EmailAfterErrorMessage__c, EmailBeforeErrorMessage__c, EmailManualErrorMessage__c, EmailReminderErrorMessage__c FROM Course__c] ) {
			System.assert (
				(course.EmailAfterErrorMessage__c != null) ||
				(course.EmailBeforeErrorMessage__c != null) ||
				(course.EmailManualErrorMessage__c != null) ||
				(course.EmailReminderErrorMessage__c != null), 'at least one error message shoulds be set' );
		}
	}

	@isTest
	private static void testCreateTasks() {

		Test.StartTest();
		EmailSchedulingHelper.createTasks();
		Test.StopTest();
	}


	// ------------------------------------------------
	// ------------ HELPER FUNCTIONS TESTS ------------
	// ------------------------------------------------

	@isTest
	private static void testGetMapOfCourseRegistrations() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		Map<Id, List<CourseRegistration__c> > results = EmailSchedulingHelper.getMapOfCourseRegistrations( courseRegistrations );
		Test.StopTest();

		System.assertEquals( 2, results.size(), 'should only be two contacts' );
		for ( Id key : results.keySet() ) {
			System.assertEquals( 4, results.get( key ).size(), 'should be four courses for each contact' );
		}
	}

	@isTest
	private static void testCheckEmailType() {

		Course__c after = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'after' LIMIT 1];
		Course__c before = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'before' LIMIT 1];
		Course__c manual = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'manual' LIMIT 1];
		Course__c reminder = [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c WHERE Name = 'reminder' LIMIT 1];

		Test.StartTest();
		EmailSchedulingHelper.EmailTypes afterResult = EmailSchedulingHelper.checkEmailType( after );
		EmailSchedulingHelper.EmailTypes beforeResult = EmailSchedulingHelper.checkEmailType( before );
		EmailSchedulingHelper.EmailTypes manualResult = EmailSchedulingHelper.checkEmailType( manual );
		EmailSchedulingHelper.EmailTypes reminderResult = EmailSchedulingHelper.checkEmailType( reminder );
		Test.StopTest();

		System.assertEquals( EmailSchedulingHelper.EmailTypes.AFTER, afterResult, 'enum should be after' );
		System.assertEquals( EmailSchedulingHelper.EmailTypes.BEFORE, beforeResult, 'enum should be before' );
		System.assertEquals( EmailSchedulingHelper.EmailTypes.MANUAL, manualResult, 'enum should be manual' );
		System.assertEquals( EmailSchedulingHelper.EmailTypes.REMINDER, reminderResult, 'enum should be reminder' );
	}



	// ------------------------------------------------
	// --------------- HELPER FUNCTIONS ---------------
	// ------------------------------------------------


	public static void addCoursesAndRegistrations( Integer amountOfEach, String unique ) {
		for ( Integer i = 0; i < amountOfEach; i++ ) {
			EmailTemplate et1 = new EmailTemplate( DeveloperName = 'courseScheduledEmailBefore', Name = 'courseScheduledEmailBefore', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
			EmailTemplate et2 = new EmailTemplate( DeveloperName = 'courseScheduledEmailReminder', Name = 'courseScheduledEmailReminder', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
			EmailTemplate et3 = new EmailTemplate( DeveloperName = 'courseScheduledEmailAfter', Name = 'courseScheduledEmailAfter', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
			EmailTemplate et4 = new EmailTemplate( DeveloperName = 'courseScheduledEmailManual', Name = 'courseScheduledEmailManual', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
			Database.insert( new List<EmailTemplate> { et1, et2, et3, et4 }, false );

			Contact c1 = new Contact( LastName = 'test' + unique + i, email = unique + i + 'ola.nordmann@test.com', TAG_Informed__c = true );
			Contact c2 = new Contact( LastName = 'test' + unique + i, email = unique + i + 'kari.nordmann@test.com', TAG_Informed__c = true );
			insert new List<Contact> { c1, c2 };

			DateTime beforeDate = Date.today().addDays( +7 );
			DateTime reminderDate = Date.today().addDays( +1 );
			DateTime afterDate = Date.today().addDays( -1 );
			DateTime manualDate = Date.today();

			Course__c before =      new Course__c( Name = 'before', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                       RegistrationDeadline__c = beforeDate, RegistrationFromDateTime__c = beforeDate, RegistrationToDateTime__c = beforeDate.addDays( 1 ),
			                                       EmailBeforeContent__c = 'test', EmailBeforeConfirmation__c = true );
			Course__c reminder =    new Course__c( Name = 'reminder', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                       RegistrationDeadline__c = reminderDate, RegistrationFromDateTime__c = reminderDate, RegistrationToDateTime__c = reminderDate.addDays( 1 ),
			                                       EmailReminderContent__c = 'test', EmailReminderConfirmation__c = true );
			Course__c after =       new Course__c( Name = 'after', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                       RegistrationDeadline__c = afterDate, RegistrationFromDateTime__c = afterDate.addDays( -2 ), RegistrationToDateTime__c = afterDate,
			                                       EmailAfterContent__c = 'test', EmailAfterConfirmation__c = true, EmailAfterURL__c = 'https://nav.no' );
			Course__c manual =      new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                       RegistrationDeadline__c = manualDate.addDays( -1 ), RegistrationFromDateTime__c = manualDate.addDays( -1 ), RegistrationToDateTime__c = Date.today(),
			                                       EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );
			insert new List<Course__c> { before, reminder, after, manual };

			CourseRegistration__c before1 = new CourseRegistration__c( Course__c = before.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c before2 = new CourseRegistration__c( Course__c = before.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c reminder1 = new CourseRegistration__c( Course__c = reminder.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c reminder2 = new CourseRegistration__c( Course__c = reminder.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c after1 = new CourseRegistration__c( Course__c = after.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c after2 = new CourseRegistration__c( Course__c = after.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c manual1 = new CourseRegistration__c( Course__c = manual.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c manual2 = new CourseRegistration__c( Course__c = manual.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
			insert new List<CourseRegistration__c> { before1, before2, reminder1, reminder2, after1, after2, manual1, manual2 };
		}
	}
}
