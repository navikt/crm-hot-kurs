public with sharing class EmailSchedulingHelperTest {

	@isTest
	private static void testFindScheduledEmails() {

		Test.StartTest();
		List<Course__c> results = EmailSchedulingHelper.findScheduledEmails();
		Test.StopTest();
	}

	@isTest
	private static void testgGtCourseRegistrations() {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Test.StartTest();
		List<CourseRegistration__c> results = EmailSchedulingHelper.getCourseRegistrations( courses );
		Test.StopTest();
	}

	@isTest
	private static void testgetCourseRegistrations() {
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		Test.StartTest();
		List<ScheduleModel> results = EmailSchedulingHelper.getCourseRegistrations(  courses,  courseRegistrations );
		Test.StopTest();
	}

	@isTest
	private static void testSendEmailToCourseRecipients() {
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<ScheduleModel> recipients = EmailSchedulingHelper.getCourseRegistrations(  courses,  courseRegistrations );

		Test.StartTest();
		EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		Test.StopTest();
	}
}
