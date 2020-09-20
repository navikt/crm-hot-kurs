public with sharing class EmailConfirmationModalController {
// TODO rename
	@AuraEnabled
	public static List<Contact> sendCourseEmail( Id courseId, String recipientsJson ) {

		List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize( recipientsJson, List<EmailConfirmationModalModel>.class );

		List<Contact> contacts = EmailConfirmationModalHelper.fetchOrCreateContacts( recipients );

		List<CourseRegistration__c> registrations = EmailConfirmationModalHelper.createCourseRegistrations( courseId, contacts );

		EmailConfirmationModalHelper.sendEmailToCourseRecipients( registrations, contacts );

		return contacts;
	}
}
