public with sharing class EmailConfirmationModalHelper {

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

	public static void sendEmailToCourseRecipients( Id recordId, List<Contact> contacts, String template, Boolean useDoNotReply ) {

		Map<Id, Contact> contactMap = new Map<Id, Contact>( contacts );

		List<Process_SendEmail.Request> requests = new List<Process_SendEmail.Request>();
		for ( Contact con : contacts ) {
			Process_SendEmail.Request request = new Process_SendEmail.Request();
			request.emailTemplateName = template;
			request.recipientContactId = con.Id;
			request.useDoNotReply = useDoNotReply;
			request.relatedToId = recordId;
			requests.add( request );
		}

		Process_SendEmail.sendEmail( requests );
	}
}
