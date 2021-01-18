public without sharing class EmailConfirmationModalHelper {

	public static List<Contact> fetchOrCreateContacts( List<EmailConfirmationModalModel> recipients ) {

		List<SharedFunctions_ContactModel> wrapperList = new List<SharedFunctions_ContactModel>();

		for ( EmailConfirmationModalModel recipient : recipients ) {
			List<String> name = recipient.fullName.split( ' ' );
			String lastName = name[name.size() - 1];
			String firstName;
			if ( name.size() > 1 ) {
				firstName = recipient.fullName.removeEnd( ' ' + lastName );
			}

			SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();
			wrapper.firstName = firstName;
			wrapper.lastName = lastName;
			wrapper.email = recipient.email;
			wrapper.source = 'Kurs';
			wrapperList.add( wrapper );
		}

		Map<String, Contact> contacts = SharedFunctions.fetchOrCreateContact( wrapperList, new Map<String, Account>() );

		return contacts.values();
	}

	public static void sendEmailToCourseRecipients( Id recordId, List<Contact> contacts, Id templateId ) {

		List<EmailQueue__c> requests = new List<EmailQueue__c>();
		for ( Contact con : contacts ) {
			EmailQueue__c request = new EmailQueue__c();
			request.TemplateId__c = templateId;
			request.TargetObjectId__c = con.Id;
			request.WhatId__c = recordId;
			request.Status__c = 'Instant';
			request.Priority__c = '5';
			request.SaveAsActivity__c = true;
			requests.add( request );
		}

		insert requests;
	}
}
