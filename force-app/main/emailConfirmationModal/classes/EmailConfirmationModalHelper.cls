public with sharing class EmailConfirmationModalHelper {

	public static List<Contact> fetchOrCreateContacts( List<EmailConfirmationModalModel> recipients ) {

		List<SharedFunctions_Helper.ContactWrapper> wrapperList = new List<SharedFunctions_Helper.ContactWrapper>();

		for ( EmailConfirmationModalModel recipient : recipients ) {
			List<String> name = recipient.fullName.split( ' ' );
			String lastName = name[name.size() - 1];
			String firstName;
			if ( name.size() > 1 ) {
				firstName = recipient.fullName.removeEnd( ' ' + lastName );
			}

			SharedFunctions_Helper.ContactWrapper wrapper = new SharedFunctions_Helper.ContactWrapper();
			wrapper.firstName = firstName;
			wrapper.lastName = lastName;
			wrapper.email = recipient.email;
			wrapper.source = 'Kurs';
			wrapperList.add( wrapper );
		}

		Map<String, Contact> contacts = SharedFunctions.fetchOrCreateContact( wrapperList, new Map<String, Account>() );

		return contacts.values();
	}

	public static List<CourseRegistration__c> createCourseRegistrations( Id courseId, List<Contact> contacts ) {

		// get contacts with an existing course registration
		Set<Id> contactIds = new Map<Id, Contact> ( contacts ).keySet();
		List<CourseRegistration__c> registrations = [SELECT Id, CourseParticipant__c, Course__c FROM CourseRegistration__c WHERE Course__c = : courseId AND CourseParticipant__c IN : contactIds];

		Set<Id> contactsWithRegistrations = new Set<Id>();
		for ( CourseRegistration__c reg : registrations ) {
			contactsWithRegistrations.add( reg.CourseParticipant__c );
		}

		// create new course registrations for new contacts
		List<CourseRegistration__c> newCourseRegistrations = new List<CourseRegistration__c>();
		for ( Contact con : contacts ) {
			if ( !contactsWithRegistrations.contains( con.Id ) ) {
				newCourseRegistrations.add( new CourseRegistration__c( Course__c = courseId, CourseParticipant__c = con.Id, Status__c = 'Invitert' ) );
			}
		}

		insert newCourseRegistrations;

		registrations.addAll( newCourseRegistrations );

		return registrations;
	}

	public static void sendEmailToCourseRecipients( List<CourseRegistration__c> registrations, List<Contact> contacts, String template, Boolean useDoNotReply ) {

		Map<Id, Contact> contactMap = new Map<Id, Contact>( contacts );

		List<Process_SendEmail.Request> requests = new List<Process_SendEmail.Request>();
		for ( CourseRegistration__c reg : registrations ) {
			Process_SendEmail.Request request = new Process_SendEmail.Request();
			request.emailTemplateName = template;
			request.recipientContact = contactMap.get( reg.CourseParticipant__c );
			request.useDoNotReply = useDoNotReply;
			request.relatedToId = reg.Course__c;
			requests.add( request );
		}

		Process_SendEmail.sendEmail( requests );
	}
}
