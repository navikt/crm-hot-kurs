public with sharing class CourseRegistrationEmailController {


	public static void sendCourseEmail( Id courseId, String jsonData ) {

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( jsonData, List<CourseRegistrationEmailModel>.class );

		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		List<CourseRegistration__c> courseRegistrations = CourseRegistrationEmailHelper.createCourseRegistrations( contacts );

		CourseRegistrationEmailHelper.sendEmailToCourseRecipients( contacts );
	}
}
