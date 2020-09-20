public with sharing class CourseRegistrationEmailController {
// TODO rename
	@AuraEnabled
	public static List<Contact> sendCourseEmail( Id courseId, String recipientsJson ) {

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( recipientsJson, List<CourseRegistrationEmailModel>.class );
		System.debug( 'recipients: ' + recipients );

		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );
		System.debug( 'contacts: ' + contacts );

		List<CourseRegistration__c> registrations = CourseRegistrationEmailHelper.createCourseRegistrations( courseId, contacts );
		System.debug( 'registrations: ' + registrations );

		CourseRegistrationEmailHelper.sendEmailToCourseRecipients( registrations, contacts );
		System.debug( 'registrations: ' + registrations );

		return contacts;
	}
}
