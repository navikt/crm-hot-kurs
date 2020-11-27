@isTest
private without sharing class EmailSchedulingHelperTest {

	@TestSetup
	static void makeData() {
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
}
