public with sharing class CourseRegistrationEmailController {


	public static void sendCourseEmail( Id courseId, String jsonData ) {

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( jsonData, List<CourseRegistrationEmailModel>.class );

		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		List<CourseRegistration__c> registrations = CourseRegistrationEmailHelper.createCourseRegistrations( courseId, contacts );

		CourseRegistrationEmailHelper.sendEmailToCourseRecipients( registrations, contacts );
	}
}
