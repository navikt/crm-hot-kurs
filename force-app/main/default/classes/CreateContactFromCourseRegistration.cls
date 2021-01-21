public with sharing class CreateContactFromCourseRegistration {


	public static Map<String, Account> fetchAccount( ) {
		Map<String, Account> accountMap = new Map<String, Account>();
		for ( Account a : [SELECT Id, INT_OrganizationNumber__c, INT_MunicipalityNumber__c FROM Account WHERE Name = 'Kursdeltakere' LIMIT 1] ) {
			accountMap.put( a.INT_OrganizationNumber__c, a );
		}

		return accountMap;

	}

	public static void findOrCreateContact( List<CourseRegistration__c> registrations ) {
		Map<String, Account> accountMap = fetchAccount();
		for ( CourseRegistration__c reg : registrations ) {

			// ! to skip trigger and soql inside for loop set contact before insert
			if ( reg.CourseParticipant__c != null ) { continue; }

			SharedFunctions_ContactModel wrapper = new SharedFunctions_ContactModel();
			wrapper.firstName = reg.ContactFirstName__c;
			wrapper.lastName = reg.ContactLastName__c;
			wrapper.email = reg.ContactEmail__c;
			wrapper.phone = reg.ContactPhone__c;
			wrapper.source = 'Kurs';
			wrapper.companyNumber = 'Kurs';
			List<SharedFunctions_ContactModel> wrapperList = new List<SharedFunctions_ContactModel> { wrapper };

			// ! need to use soql inside for loop because id doest exist in before insert
			Map<String, Contact> contacts = SharedFunctions.fetchOrCreateContact( wrapperList, accountMap );

			if ( contacts.containsKey( reg.ContactEmail__c ) ) {
				reg.CourseParticipant__c = contacts.get( reg.ContactEmail__c ).Id;

				reg.ContactFirstName__c = '';
				reg.ContactLastName__c = '';
				reg.ContactEmail__c = '';
				reg.ContactPhone__c = '';

			}
		}
	}

	public static void addEncryptedString( List<CourseRegistration__c> registrations ) {
		List<CourseRegistration__c> recordsToUpdate = new List<CourseRegistration__c>();

		for ( CourseRegistration__c reg : registrations ) {
			CourseRegistration__c cr = new CourseRegistration__c( Id = reg.id );
			cr.EncryptedId__c = CryptoService.encryptString( cr.Id );
			recordsToUpdate.add( cr );
		}
		update recordsToUpdate;
	}
}