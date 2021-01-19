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
	private static void testExecute_beforeSuccess() {

		createData( EmailSchedulingHelper.EmailTypes.BEFORE, true );

		String CRON_EXP = '0 0 0 3 9 ? 2022';
		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailBeforeSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailQueue__c].size(), '2 emails sent, 2 EmailQueue__cs created' );
		System.assertEquals( 0, EmailSchedulingHelper.findEmailsToSchedule().size(), 'all emails should be sent' );
	}

	@isTest
	private static void testExecute_reminderSuccess() {

		createData( EmailSchedulingHelper.EmailTypes.REMINDER, true );

		String CRON_EXP = '0 0 0 3 9 ? 2022';
		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailReminderSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailQueue__c].size(), '2 emails sent, 2 EmailQueue__cs created' );
		System.assertEquals( 0, EmailSchedulingHelper.findEmailsToSchedule().size(), 'all emails should be sent' );
	}

	@isTest
	private static void testExecute_afterSuccess() {

		createData( EmailSchedulingHelper.EmailTypes.AFTER, true );

		String CRON_EXP = '0 0 0 3 9 ? 2022';
		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailAfterSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailQueue__c].size(), '2 emails sent, 2 EmailQueue__cs created' );
		System.assertEquals( 0, EmailSchedulingHelper.findEmailsToSchedule().size(), 'all emails should be sent' );
	}

	@isTest
	private static void testExecute_manualSuccess() {

		createData( EmailSchedulingHelper.EmailTypes.MANUAL, true );

		String CRON_EXP = '0 0 0 3 9 ? 2022';
		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one courses should have scheduled emails for "today"' );
		System.assertEquals( 1, [SELECT Id FROM Course__c WHERE EmailManualSent__c = true].size(), 'one courses should have marked as sent' );
		System.assertEquals( 2, [SELECT Id FROM CourseRegistration__c].size(), 'four courses with two course participants each' );
		System.assertEquals( 4, [SELECT Id FROM EmailQueue__c].size(), '2 emails sent, 2 EmailQueue__cs created' );
		System.assertEquals( 0, EmailSchedulingHelper.findEmailsToSchedule().size(), 'all emails should be sent' );
	}

	@isTest
	private static void testExecute_noParticipants() {

		createData( EmailSchedulingHelper.EmailTypes.MANUAL, false );

		System.assertEquals( 2, EmailSchedulingHelper.findEmailsToSchedule().size(), 'verify two emails scheduled' );

		String CRON_EXP = '0 0 0 3 9 ? 2022';
		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		System.assertEquals( 1, [SELECT Id FROM Course__c].size(), 'one course should have scheduled emails for "today"' );
		System.assertEquals( 0, [SELECT Id FROM Course__c WHERE EmailManualSent__c = true].size(), 'one course should be marked as sent' );
		System.assertEquals( 0, [SELECT Id FROM CourseRegistration__c].size(), '0 courses with two course participants each' );
		System.assertEquals( 0, [SELECT Id FROM EmailQueue__c].size(), '0 emails sent as no participants' );
		System.assertEquals( 1, EmailSchedulingHelper.findEmailsToSchedule().size(), 'should still be one more course because no email was sent' );
	}



	// HELPER FUNCTIONS
	public static void createData( EmailSchedulingHelper.EmailTypes type, Boolean createParticipants ) {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
		insert new List<Contact> { c1, c2 };

		Course__c course = getCourse( type );
		insert course;

		if ( createParticipants ) {
			CourseRegistration__c courseParticipant1 = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
			CourseRegistration__c courseParticipant2 = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
			insert new List<CourseRegistration__c> { courseParticipant1, courseParticipant2 };
		}
	}

	public static Course__c getCourse( EmailSchedulingHelper.EmailTypes type ) {

		DateTime d = Date.today();

		switch on type {
			when AFTER {
				return new Course__c( Name = 'before', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
				                      RegistrationDeadline__c = d.addDays( 7 ), RegistrationFromDateTime__c = d.addDays( 7 ), RegistrationToDateTime__c = d.addDays( 8 ),
				                      EmailBeforeContent__c = 'test', EmailBeforeConfirmation__c = true );
			} when BEFORE {
				return new Course__c( Name = 'reminder', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
				                      RegistrationDeadline__c = d.addDays( +1 ), RegistrationFromDateTime__c = d.addDays( +1 ), RegistrationToDateTime__c = d.addDays( 2 ),
				                      EmailReminderContent__c = 'test', EmailReminderConfirmation__c = true );
			} when MANUAL {
				return new Course__c( Name = 'after', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
				                      RegistrationDeadline__c = d.addDays( -1 ), RegistrationFromDateTime__c = d.addDays( -3 ), RegistrationToDateTime__c = d.addDays( -1 ),
				                      EmailAfterContent__c = 'test', EmailAfterConfirmation__c = true, EmailAfterURL__c = 'https://nav.no' );
			} when REMINDER {
				return new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
				                      RegistrationDeadline__c = d.addDays( -1 ), RegistrationFromDateTime__c = d.addDays( -1 ), RegistrationToDateTime__c = d,
				                      EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );
			} when else {
				return null;
			}
		}
	}
}
