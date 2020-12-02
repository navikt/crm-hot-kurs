@isTest
private without sharing class EmailSchedulingServiceTest {

	@testSetup
	private static void setup() {
		EmailTemplate et1 = new EmailTemplate( DeveloperName = 'courseScheduledEmailBefore', Name = 'courseScheduledEmailBefore', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et2 = new EmailTemplate( DeveloperName = 'courseScheduledEmailReminder', Name = 'courseScheduledEmailReminder', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et3 = new EmailTemplate( DeveloperName = 'courseScheduledEmailAfter', Name = 'courseScheduledEmailAfter', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		EmailTemplate et4 = new EmailTemplate( DeveloperName = 'courseScheduledEmailManual', Name = 'courseScheduledEmailManual', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		Database.insert( new List<EmailTemplate> { et1, et2, et3, et4 }, false );
	}

	@isTest
	private static void testExecute_success() {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
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
		                                       EmailAfterContent__c = 'test', EmailAfterConfirmation__c = true );
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

		String CRON_EXP = '0 0 0 3 9 ? 2022';

		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		System.assertEquals( 4, [SELECT Id FROM Course__c].size(), 'four courses should have scheduled emails for "today"' );
		System.assertEquals( 8, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 16, [SELECT Id FROM EmailMessage].size(), '8 emails sent, 8 EmailMessages created' );
	}


	@isTest
	private static void testExecute_noParticipants() {

		DateTime manualDate = Date.today();
		insert new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                      RegistrationDeadline__c = manualDate.addDays( -1 ), RegistrationFromDateTime__c = manualDate.addDays( -1 ), RegistrationToDateTime__c = Date.today(),
		                      EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );

		System.assertEquals( 1, EmailSchedulingHelper.findScheduledEmails().size(), 'verify one course have emails scheduled' );

		String CRON_EXP = '0 0 0 3 9 ? 2022';

		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'four courses should have scheduled emails for "today"' );
		System.assertEquals( 0, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 0, [SELECT Id FROM EmailMessage].size(), '8 emails sent, 8 EmailMessages created' );
	}

	@isTest
	private static void testExecute_noTemplates() {

	}
}
