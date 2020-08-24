public with sharing class CourseRegistrationEmailHelper {
	public static List<Contact> fetchOrCreateContacts( List<CourseRegistrationEmailController.EmailRecipients> recipients ) {
		List<Contact> contacts = new List<Contact>();

		return contacts;
	}

	public static List<CourseRegistration__c> createCourseRegistrations( List<Contact> contacts ) {
		List<CourseRegistration__c> courseRegistrations = new List<CourseRegistration__c>();

		return courseRegistrations;
	}

	public static void sendEmailToCourseRecipients( List<Contact> contacts ) {
		// Set<Id> contactIds = new Set<Id>();
		// for ( TemporaryLayoff__c tl : (List<TemporaryLayoff__c>) records ) {
		// 	contactIds.add( tl.Contact__c );
		// }

		// Map<Id, Contact> contacts = new Map<Id, Contact> ( [SELECT Id, Email FROM Contact WHERE Id IN: contactIds] );

		// List<Process_SendEmail.Request> requests = new List<Process_SendEmail.Request>();
		// for ( TemporaryLayoff__c tl : (List<TemporaryLayoff__c>) records ) {
		// 	Process_SendEmail.Request request = new Process_SendEmail.Request();
		// 	request.emailTemplateName = 'tempLayoffReceiptSubsidiary';
		// 	request.recipientContact = contacts.containsKey( tl.Contact__c ) ? contacts.get( tl.Contact__c ) : null;
		// 	request.useDoNotReply = true;
		// 	request.relatedToId = tl.Id;
		// 	requests.add( request );
		// }

		// Process_SendEmail.sendEmail( requests );
	}
}
