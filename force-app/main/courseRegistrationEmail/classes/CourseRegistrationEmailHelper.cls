public with sharing class CourseRegistrationEmailHelper {

	public static List<Contact> fetchOrCreateContacts( List<CourseRegistrationEmailModel> recipients ) {

		List<SharedFunctions_Helper.ContactWrapper> wrapperList = new List<SharedFunctions_Helper.ContactWrapper>();

		for ( CourseRegistrationEmailModel recipient : recipients ) {
			SharedFunctions_Helper.ContactWrapper wrapper = new SharedFunctions_Helper.ContactWrapper();
			wrapper.firstName = recipient.firstName;
			wrapper.lastName = recipient.lastName;
			wrapper.email = recipient.email;
			wrapper.source = 'Kurs';
			wrapperList.add( wrapper );
		}

		Map<String, Contact> contacts = SharedFunctions.fetchOrCreateContact( wrapperList, new Map<String, Account>() );

		return contacts.values();
	}

	public static List<CourseRegistration__c> createCourseRegistrations( Id courseId, List<Contact> contacts ) {

		List<Domain> domains = [SELECT Domain FROM Domain];
		if ( domains.size() == 0 ) { throw new AuraException( 'Feil ved utsendelse. Kan ikke finne korrekt URL å sende til bruker.' ); }
		String url = 'https://' + domains[0].Domain + 'kurs/s/?id=' + courseId;

		// get contacts with an existing course registration
		Set<Id> contactIds = new Map<Id, Contact> ( contacts ).keySet();
		List<CourseRegistration__c> registrations = [SELECT Id, CourseParticipant__c, Course__c FROM CourseRegistration__c WHERE Course__c = : courseId AND CourseParticipant__c IN : contactIds];
		Set<Id> contactsWithRegistrations = new Set<Id>();
		for ( CourseRegistration__c reg : registrations ) {
			reg.CommunityUrl__c = url;
			contactsWithRegistrations.add( reg.CourseParticipant__c );
		}

		update registrations;

		// create new course registrations for new contacts
		List<CourseRegistration__c> newCourseRegistrations = new List<CourseRegistration__c>();
		for ( Contact con : contacts ) {
			if ( !contactsWithRegistrations.contains( con.Id ) ) {
				newCourseRegistrations.add( new CourseRegistration__c( Course__c = courseId, CourseParticipant__c = con.Id, Status__c = 'Invitert', CommunityUrl__c = url ) );
			}
		}

		insert newCourseRegistrations;

		registrations.addAll( newCourseRegistrations );

		return registrations;
	}

	public static void sendEmailToCourseRecipients( List<CourseRegistration__c> registrations, List<Contact> contacts ) {

		Map<Id, Contact> contactMap = new Map<Id, Contact>( contacts );

		System.debug( 'registrations: ' + registrations );
		System.debug( 'contacts: ' + contacts );

		List<Process_SendEmail.Request> requests = new List<Process_SendEmail.Request>();
		for ( CourseRegistration__c reg : registrations ) {
			Process_SendEmail.Request request = new Process_SendEmail.Request();
			request.emailTemplateName = 'courseRegistrationInvitation';
			request.recipientContact = contactMap.get( reg.CourseParticipant__c );
			request.useDoNotReply = false;                                                      // TODO set to true
			request.relatedToId = reg.Course__c;
			requests.add( request );
		}

		Process_SendEmail.sendEmail( requests );
	}
}
