@isTest
private without sharing class EmailSchedulingJobTest {
	@testSetup
	private static void setup() {
		EmailTemplate et1 = new EmailTemplate( DeveloperName = 'courseScheduledEmailBefore', Name = 'courseScheduledEmailBefore', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et2 = new EmailTemplate( DeveloperName = 'courseScheduledEmailReminder', Name = 'courseScheduledEmailReminder', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et3 = new EmailTemplate( DeveloperName = 'courseScheduledEmailAfter', Name = 'courseScheduledEmailAfter', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et4 = new EmailTemplate( DeveloperName = 'courseScheduledEmailManual', Name = 'courseScheduledEmailManual', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		Database.insert( new List<EmailTemplate> { et1, et2, et3, et4 }, false );
	}

	@isTest
	private static void testExecute_beforeSuccess() {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
		insert new List<Contact> { c1, c2 };

		DateTime beforeDate = Date.today().addDays( +7 );

		Course__c before =      new Course__c( Name = 'before', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                                       RegistrationDeadline__c = beforeDate, RegistrationFromDateTime__c = beforeDate, RegistrationToDateTime__c = beforeDate.addDays( 1 ),
		                                       EmailBeforeContent__c = 'test', EmailBeforeConfirmation__c = true );
		insert before;

		CourseRegistration__c before1 = new CourseRegistration__c( Course__c = before.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
		CourseRegistration__c before2 = new CourseRegistration__c( Course__c = before.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
		insert new List<CourseRegistration__c> { before1, before2 };

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );

		Test.StartTest();
		System.enqueueJob( new EmailSchedulingJob( courses, courseRegistrations, recipients ) );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailBeforeSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailMessage].size(), '2 emails sent, 2 EmailMessages created' );
	}

	@isTest
	private static void testExecute_reminderSuccess() {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
		insert new List<Contact> { c1, c2 };

		DateTime reminderDate = Date.today().addDays( +1 );

		Course__c reminder =    new Course__c( Name = 'reminder', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                                       RegistrationDeadline__c = reminderDate, RegistrationFromDateTime__c = reminderDate, RegistrationToDateTime__c = reminderDate.addDays( 1 ),
		                                       EmailReminderContent__c = 'test', EmailReminderConfirmation__c = true );
		insert reminder;

		CourseRegistration__c reminder1 = new CourseRegistration__c( Course__c = reminder.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
		CourseRegistration__c reminder2 = new CourseRegistration__c( Course__c = reminder.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
		insert new List<CourseRegistration__c> { reminder1, reminder2 };

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );

		Test.StartTest();
		System.enqueueJob( new EmailSchedulingJob( courses, courseRegistrations, recipients ) );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailReminderSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailMessage].size(), '2 emails sent, 2 EmailMessages created' );
	}

	@isTest
	private static void testExecute_afterSuccess() {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
		insert new List<Contact> { c1, c2 };

		DateTime afterDate = Date.today().addDays( -1 );

		Course__c after =       new Course__c( Name = 'after', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                                       RegistrationDeadline__c = afterDate, RegistrationFromDateTime__c = afterDate.addDays( -2 ), RegistrationToDateTime__c = afterDate,
		                                       EmailAfterContent__c = 'test', EmailAfterConfirmation__c = true, EmailAfterURL__c = 'https://nav.no' );
		insert after;

		CourseRegistration__c after1 = new CourseRegistration__c( Course__c = after.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
		CourseRegistration__c after2 = new CourseRegistration__c( Course__c = after.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
		insert new List<CourseRegistration__c> { after1, after2 };

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );

		Test.StartTest();
		System.enqueueJob( new EmailSchedulingJob( courses, courseRegistrations, recipients ) );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailAfterSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailMessage].size(), '2 emails sent, 2 EmailMessages created' );
	}

	@isTest
	private static void testExecute_manualSuccess() {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
		insert new List<Contact> { c1, c2 };

		DateTime manualDate = Date.today();

		Course__c manual =      new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                                       RegistrationDeadline__c = manualDate.addDays( -1 ), RegistrationFromDateTime__c = manualDate.addDays( -1 ), RegistrationToDateTime__c = Date.today(),
		                                       EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );
		insert manual;

		CourseRegistration__c manual1 = new CourseRegistration__c( Course__c = manual.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
		CourseRegistration__c manual2 = new CourseRegistration__c( Course__c = manual.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
		insert new List<CourseRegistration__c> { manual1, manual2 };

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );

		Test.StartTest();
		System.enqueueJob( new EmailSchedulingJob( courses, courseRegistrations, recipients ) );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailManualSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailMessage].size(), '2 emails sent, 2 EmailMessages created' );
	}

	@isTest
	private static void testExecute_noParticipants() {

		DateTime manualDate = Date.today();
		insert new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                      RegistrationDeadline__c = manualDate.addDays( -1 ), RegistrationFromDateTime__c = manualDate.addDays( -1 ), RegistrationToDateTime__c = Date.today(),
		                      EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );

		System.assertEquals( 1, EmailSchedulingHelper.findScheduledEmails().size(), 'verify one course have emails scheduled' );

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );

		Test.StartTest();
		System.enqueueJob( new EmailSchedulingJob( courses, courseRegistrations, recipients ) );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one course should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailManualSent__c = true].size(), 'one course should be marked as sent' );
		System.assertEquals( 0, [SELECT Id FROM CourseRegistration__c].size(), '0 courses with two course participants each' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '0 emails sent as no participants' );
	}
}
