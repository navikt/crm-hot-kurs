public with sharing class CourseRegistrationEmailController {

	public class EmailRecipients {
		@AuraEnabled public String firstName;
		@AuraEnabled public String lastName;
		@AuraEnabled public String email;
	}

	public static void sendCourseEmail( Id courseId, String jsonData ) {

		List<EmailRecipients> recipients = (List<EmailRecipients>) System.JSON.deserialize( jsonData, List<EmailRecipients>.class );

		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		List<CourseRegistration__c> courseRegistrations = CourseRegistrationEmailHelper.createCourseRegistrations( contacts );

		CourseRegistrationEmailHelper.sendEmailToCourseRecipients( contacts );
	}
}
