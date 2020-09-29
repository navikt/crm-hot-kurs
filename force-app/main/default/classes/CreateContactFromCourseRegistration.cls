public with sharing class CreateContactFromCourseRegistration {

	public static void findOrCreateContact( List<CourseRegistration__c> registrations ) {


		for ( CourseRegistration__c reg : registrations ) {

			// ! to skip trigger and soql inside for loop set contact before insert
			if ( reg.CourseParticipant__c != null ) { continue; }

			SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();
			wrapper.firstName = reg.ContactFirstName__c;
			wrapper.lastName = reg.ContactLastName__c;
			wrapper.email = reg.ContactEmail__c;
			wrapper.phone = reg.ContactPhone__c;
			wrapper.source = 'Kurs';
			List<SharedFunctions_ContactModel> wrapperList = new List<SharedFunctions_ContactModel> { wrapper };

			// ! need to use soql inside for loop because id doest exist in before insert
			Map<String, Contact> contacts = SharedFunctions.fetchOrCreateContact( wrapperList, new Map<String, Account>() );

			if ( contacts.containsKey( reg.ContactEmail__c ) ) {
				reg.CourseParticipant__c = contacts.get( reg.ContactEmail__c ).Id;

				reg.ContactFirstName__c = '';
				reg.ContactLastName__c = '';
				reg.ContactEmail__c = '';
				reg.ContactPhone__c = '';

			}
		}
	}
}