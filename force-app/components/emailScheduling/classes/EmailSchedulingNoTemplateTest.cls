@isTest
private without sharing class EmailSchedulingNoTemplateTest {

	@testSetup
	private static void setup() {
		Database.delete( [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN ( 'courseScheduledEmailAfter', 'courseScheduledEmailBefore', 'courseScheduledEmailManual', 'courseScheduledEmailReminder' )], false );
	}

	@isTest
	private static void testcheckIfTemplatesMissing_doesNotExist() {

		DateTime manualDate = Date.today();
		insert new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                      RegistrationDeadline__c = manualDate.addDays( -1 ), RegistrationFromDateTime__c = manualDate.addDays( -1 ), RegistrationToDateTime__c = Date.today(),
		                      EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		System.assertEquals( 1, courses.size(), 'verify one course have emails scheduled' );

		Test.StartTest();
		Boolean result = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		Test.StopTest();

		System.assertEquals( true, result, 'no templates exists, so should return true' );
	}

	@isTest
	private static void testExecute_noTemplates() {
		DateTime manualDate = Date.today();
		insert new Course__c( Name = 'manual', Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo',
		                      RegistrationDeadline__c = manualDate.addDays( -1 ), RegistrationFromDateTime__c = manualDate.addDays( -1 ), RegistrationToDateTime__c = Date.today(),
		                      EmailManualContent__c = 'test', EmailManualDate__c = Date.today(), EmailManualConfirmation__c = true );

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		System.assertEquals( 1, courses.size(), 'verify one course have emails scheduled' );

		String CRON_EXP = '0 0 0 3 9 ? 2022';

		Test.StartTest();
		System.schedule( 'EmailSchedulingServiceTest', CRON_EXP, new EmailSchedulingService() );
		Test.StopTest();

		courses = EmailSchedulingHelper.findScheduledEmails();
		System.assertEquals( 1, courses.size(), 'verify still one course have emails scheduled' );
		courses = [SELECT EmailManualErrorMessage__c FROM Course__c];
		System.assertEquals( 1, courses.size(), 'verify still one course have emails scheduled' );
		System.assertEquals ( 'Email template missing!', courses[0].EmailManualErrorMessage__c, 'verify one course with email error' );
	}
}