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

		String CRON_EXP = '0 0 0 3 9 ? 2022';
		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		// ! no tests, as queueable is not possible to run inside scheduled class
	}
}