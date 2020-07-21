public with sharing class CourseRegistrationController {

	@AuraEnabled
	public static String createRegistration( String fields, String courseId ) {
		try {

			Id contactId  = findOrCreateContact( fields ).Id;
			Boolean duplicate = checkForDuplicates( contactId, courseId );
			if ( duplicate ) { return 'Du er allerede påmeldt dette kurset'; }
			insertRegistration( contactId, courseId );

			return 'Du er påmeldt kurset. Du vil om kort tid motta en bekreftelse på epost';
		} catch ( Exception e ) {
			return 'Det oppsto en feil. Prøv igjen senere.';
		}

	}

	public static Contact findOrCreateContact( String fields ) {
		Contact con;

		if ( fields != null ) {
			CourseRegistrationModel model = CourseRegistrationModel.parse( fields );
			SharedFunctions_Helper.ContactWrapper wrapper = new SharedFunctions_Helper.ContactWrapper();
			wrapper.firstName = model.firstName;
			wrapper.lastName = model.lastName;
			wrapper.email = model.email;
			wrapper.phone = model.phone;
			wrapper.source = 'Kurs';
			List<SharedFunctions_Helper.ContactWrapper> wrapperList = new List<SharedFunctions_Helper.ContactWrapper> { wrapper };

			Map<String, Account> accountMap = new Map<String, Account>();
			Map<String, Contact> contacts = SharedFunctions.fetchOrCreateContact( wrapperList, accountMap );

			con = contacts.get( model.email );
		}

		return con;
	}

	public static void insertRegistration( Id contactId, Id courseId ) {

		Course_Registration__c registration = new Course_Registration__c( Course_registration__c = courseId, Course_participant__c = contactId, Status__c = 'Påmeldt' );
		insert registration;

	}

	public static Boolean checkForDuplicates( Id contactId, Id courseId ) {
		List<Course_Registration__c> existingRecord =
		[SELECT Id, Course_registration__c, Course_participant__c
		 FROM Course_Registration__c
		 WHERE Course_registration__c =: courseId
		                                AND Course_participant__c =: contactId LIMIT 1];

		Boolean exists = existingRecord.size() > 0 ? true : false;

		return exists;
	}
}
