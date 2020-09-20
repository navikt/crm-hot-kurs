public with sharing class CourseRegistrationEmailController {
// TODO rename
	@AuraEnabled
	public static List<Contact> sendCourseEmail( Id courseId, String recipientsJson ) {

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( recipientsJson, List<CourseRegistrationEmailModel>.class );

		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		List<CourseRegistration__c> registrations = CourseRegistrationEmailHelper.createCourseRegistrations( courseId, contacts );

		CourseRegistrationEmailHelper.sendEmailToCourseRecipients( registrations, contacts );

		return contacts;
	}
}
