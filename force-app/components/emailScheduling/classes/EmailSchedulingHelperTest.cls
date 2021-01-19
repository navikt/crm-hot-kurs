@isTest
private without sharing class EmailSchedulingHelperTest {

	@TestSetup
	static void makeData() {

		EmailTemplate et1 = new EmailTemplate( DeveloperName = 'courseScheduledEmailBefore', Name = 'courseScheduledEmailBefore', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et2 = new EmailTemplate( DeveloperName = 'courseScheduledEmailReminder', Name = 'courseScheduledEmailReminder', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et3 = new EmailTemplate( DeveloperName = 'courseScheduledEmailAfter', Name = 'courseScheduledEmailAfter', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et4 = new EmailTemplate( DeveloperName = 'courseScheduledEmailManual', Name = 'courseScheduledEmailManual', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		Database.insert( new List<EmailTemplate> { et1, et2, et3, et4 }, false );

		addCoursesAndRegistrations( 1, 2, true, true, true, true, '' );
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
	private static void testRemoveCourses_noChanges() {

		addCoursesAndRegistrations( 1, 2, true, true, true, true, 'unique' ); // doubled with makeData()
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<Course__c> changedCourses = EmailSchedulingHelper.removeCourses( courses, courseRegistrations );
		Test.StopTest();

		System.assertEquals( 8, changedCourses.size(), 'should have the same courses' );
	}

	@isTest
	private static void testRemoveCourses_removeHalf() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		addCoursesAndRegistrations( 1, 2, true, true, true, true, 'unique' ); // doubled with makeData()
		courses = EmailSchedulingHelper.findScheduledEmails();

		Test.StartTest();
		List<Course__c> changedCourses = EmailSchedulingHelper.removeCourses( courses, courseRegistrations );
		Test.StopTest();

		System.assertEquals( 4, changedCourses.size(), 'should have the same courses' );
	}

	@isTest
	private static void testSendEmailToCourseRecipients() {
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		courses.remove( 3 );
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );

		Test.StartTest();
		List<Messaging.SendEmailResult> results = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		Test.StopTest();

		System.assertEquals( 6, results.size(), 'should be four logs for email' );
		for ( Messaging.SendEmailResult res : results ) {
			System.assertEquals( true, res.isSuccess(), 'should be no errors' );
		}
	}

	@isTest
	private static void testGetCoursesWithEmailErrors() {

		delete [SELECT Id FROM CourseRegistration__c];
		delete [SELECT Id FROM Course__c];

		addCoursesAndRegistrations( 1, 20, true, false, false, false, 'unique' );

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend(  courses,  courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );

		System.assertEquals( 1, courses.size(), 'one courses' );
		System.assertEquals( 20, courseRegistrations.size(), '20 participants' );
		System.assertEquals( 20, recipients.size(), '20 participants' );
		System.assertEquals( 20, emailResults.size(), '20 participants' );

		Test.StartTest();
		Map<Id, String> results = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );
		Test.StopTest();

		System.assertEquals( 1, results.size(), 'four courses with email issues' );

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

		Map<Id, String> cousesWithEmailErrors = new Map<Id, String>();
		for ( Course__c course : courses ) {
			cousesWithEmailErrors.put( course.Id, 'ERROR' );
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
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Test.StartTest();
		List<Task> results = EmailSchedulingHelper.createTasks( courses );
		Test.StopTest();

		System.assertEquals( 4, results.size(), 'four tasks created' );
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


	public static void addCoursesAndRegistrations( Integer amountOfEach, Integer amountOfContacts, Boolean createBefore, Boolean createReminder, Boolean createAfter, Boolean createManual, String unique ) {

		for ( Integer i = 0; i < amountOfEach; i++ ) {

			List<Course__c> courses = new List<Course__c> ();

			DateTime beforeDate = Date.today().addDays( +7 );
			DateTime reminderDate = Date.today().addDays( +1 );
			DateTime afterDate = Date.today().addDays( -1 );
			DateTime manualDate = Date.today();

			Course__c beforeCourse = !createBefore ? null :     new Course__c( Name = 'before', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                                                   RegistrationDeadline__c = beforeDate, RegistrationFromDateTime__c = beforeDate, RegistrationToDateTime__c = beforeDate.addDays( 1 ),
			                                                                   EmailBeforeContent__c = 'test', EmailBeforeConfirmation__c = true );
			Course__c reminderCourse = !createReminder ? null : new Course__c( Name = 'reminder', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                                                   RegistrationDeadline__c = reminderDate, RegistrationFromDateTime__c = reminderDate, RegistrationToDateTime__c = reminderDate.addDays( 1 ),
			                                                                   EmailReminderContent__c = 'test', EmailReminderConfirmation__c = true );
			Course__c afterCourse = !createAfter ? null :       new Course__c( Name = 'after', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                                                   RegistrationDeadline__c = afterDate, RegistrationFromDateTime__c = afterDate.addDays( -2 ), RegistrationToDateTime__c = afterDate,
			                                                                   EmailAfterContent__c = 'test', EmailAfterConfirmation__c = true, EmailAfterURL__c = 'https://nav.no' );
			Course__c manualCourse = !createManual ? null :     new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
			                                                                   RegistrationDeadline__c = manualDate.addDays( -1 ), RegistrationFromDateTime__c = manualDate.addDays( -1 ), RegistrationToDateTime__c = Date.today(),
			                                                                   EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );
			if ( beforeCourse != null ) { courses.add( beforeCourse ); }
			if ( reminderCourse != null ) { courses.add( reminderCourse ); }
			if ( afterCourse != null ) { courses.add( afterCourse ); }
			if ( manualCourse != null ) { courses.add( manualCourse ); }
			insert courses;

			List<Contact> contacts = new List<Contact>();
			for ( Integer k = 0; k < amountOfContacts; k++ ) {
				contacts.add( new Contact( LastName = 'test' + k + unique + i, email = k + unique + i + 'ola.nordmann@test.com', TAG_Informed__c = true ) );
			}
			insert contacts;

			List<CourseRegistration__c> registrations = new List<CourseRegistration__c> ();
			for ( Contact contact : contacts ) {
				if ( createBefore ) {
					registrations.add( new CourseRegistration__c( Course__c = beforeCourse.Id, CourseParticipant__c = contact.Id, Status__c = 'Påmeldt' ) );
				} if ( createReminder ) {
					registrations.add( new CourseRegistration__c( Course__c = reminderCourse.Id, CourseParticipant__c = contact.Id, Status__c = 'Påmeldt' ) );
				} if ( createAfter ) {
					registrations.add( new CourseRegistration__c( Course__c = afterCourse.Id, CourseParticipant__c = contact.Id, Status__c = 'Påmeldt' ) );
				} if ( createManual ) {
					registrations.add( new CourseRegistration__c( Course__c = manualCourse.Id, CourseParticipant__c = contact.Id, Status__c = 'Påmeldt' ) );
				}
			}
			insert registrations;
		}
	}
}
