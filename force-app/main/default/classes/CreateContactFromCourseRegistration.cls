public with sharing class CreateContactFromCourseRegistration {

	public static void findOrCreateContact( List<CourseRegistration__c> registrations ) {
		Contact con;
		for ( CourseRegistration__c reg : registrations ) {


			SharedFunctions_Helper.ContactWrapper wrapper = new SharedFunctions_Helper.ContactWrapper();
			wrapper.firstName = reg.ContactFirstName__c;
			wrapper.lastName = reg.ContactLastName__c;
			wrapper.email = reg.ContactEmail__c;
			wrapper.phone = reg.ContactPhone__c;
			wrapper.source = 'Kurs';
			List<SharedFunctions_Helper.ContactWrapper> wrapperList = new List<SharedFunctions_Helper.ContactWrapper> { wrapper };

			Map<String, Account> accountMap = new Map<String, Account>();
			Map<String, Contact> contacts = SharedFunctions.fetchOrCreateContact( wrapperList, accountMap );

			con = contacts.get( reg.ContactEmail__c );
			reg.CourseParticipant__c = con.Id;
			//update reg;
		}


		//insert con;
		//return con;

	}
}
