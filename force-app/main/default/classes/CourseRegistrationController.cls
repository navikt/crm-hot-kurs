public with sharing class CourseRegistrationController {

	@AuraEnabled
	public static String createRegistration( String fields, String courseId ) {
		try {

			/*Id contactId  = findOrCreateContact( fields ).Id;
			   Boolean duplicate = checkForDuplicates( contactId, courseId );
			   if ( duplicate ) { return 'Du er allerede påmeldt dette kurset'; }
			   insertRegistration( contactId, courseId );*/

			insertRegistration( fields, courseId );

			return 'Du er påmeldt kurset. Du vil om kort tid motta en bekreftelse på epost';

		} catch ( Exception e ) {
			return 'Det oppsto en feil. Prøv igjen senere.';
		}

	}

	public static void insertRegistration( String fields, Id courseId ) {
		if ( fields != null ) {
			CourseRegistrationModel model = CourseRegistrationModel.parse( fields );
			CourseRegistration__c registration = new CourseRegistration__c();

			registration.ContactFirstName__c = model.firstName;
			registration.ContactLastName__c = model.lastName;
			registration.ContactEmail__c = model.email;
			registration.ContactPhone__c = model.phone;
			registration.Status__c = 'Påmeldt';
			registration.Course__c = courseId;

			insert registration;
		}
	}

	@AuraEnabled
	public static String getInvitationCode( Id courseId ) {
		String invitationCode = [SELECT InvitationCode__c FROM Course__c WHERE Id =:courseId LIMIT 1].InvitationCode__c;

		if ( String.isBlank( invitationCode ) ) {
			invitationCode = '';
		}

		return invitationCode;
	}

	/*public static Contact findOrCreateContact( String fields ) {
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
	   }*/

	/*public static void insertRegistration( Id contactId, Id courseId ) {
	    CourseRegistration__c registration = new CourseRegistration__c( Course__c = courseId, CourseParticipant__c = contactId, Status__c = 'Påmeldt' );
	    insert registration;
	   }

	   public static Boolean checkForDuplicates( Id contactId, Id courseId ) {
	    List<CourseRegistration__c> existingRecord =
	    [SELECT Id, Course__c, CourseParticipant__c
	     FROM CourseRegistration__c
	     WHERE Course__c =: courseId
	                       AND CourseParticipant__c =: contactId LIMIT 1];

	    Boolean exists = existingRecord.size() > 0 ? true : false;

	    return exists;
	   }*/
}
