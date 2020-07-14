public with sharing class CourseRegistrationController {

	@AuraEnabled
	public static String findOrCreateContact( String fields ) {
		CourseRegistrationModel model = CourseRegistrationModel.parse( fields );
		SharedIntegrationFunctions_Helper.ContactWrapper wrapper = new SharedIntegrationFunctions_Helper.ContactWrapper();
		wrapper.firstName = model.firstName;
		wrapper.lastName = model.lastName;
		wrapper.email = model.email;
		wrapper.phone = model.phone;
		List<SharedIntegrationFunctions_Helper.ContactWrapper> wrapperList = new List<SharedIntegrationFunctions_Helper.ContactWrapper> { wrapper };

		Map<String, Account> accountMap = new Map<String, Account>();
		Map<String, Contact> conts = SharedIntegrationFunctions.fetchOrCreateContact( wrapperList, accountMap );

		Contact con = conts.get( model.email );
		Id courseId = getCourseId();
		String message;
		Boolean recordExist = checkForDuplicates( con.Id, courseId );
		if ( !recordExist ) {
			createRegistration( con.Id, courseId );
		} else {
			message = 'Du er allerede påmeldt dette kurset';
		}

		return message;
	}

	public static Id getCourseId() {
		Network myNetwork = [SELECT Id, UrlPathPrefix FROM Network WHERE Name = 'kurs' ];
		ConnectApi.Community myCommunity = ConnectApi.Communities.getCommunity( myNetwork.id );
		Id courseId = [SELECT Id FROM Course__c WHERE RegistrationUrl__c = : myCommunity.siteUrl LIMIT 1].Id;

		return courseId;
	}
	@AuraEnabled
	public static void createRegistration( Id contactId, Id courseId ) {

		Course_Registration__c registration = new Course_Registration__c( Course_registration__c = courseId, Course_participant__c = contactId, Status__c = 'Påmeldt' );
		insert registration;

	}

	public static Boolean checkForDuplicates( Id contactId, Id courseId ) {
		List<Course_Registration__c> existingRecord = [SELECT Id, Course_registration__c, Course_participant__c FROM Course_Registration__c WHERE Course_registration__c =: courseId AND Course_participant__c =: contactId LIMIT 1];
		Boolean exists = existingRecord.size() > 0 ? true : false;

		return exists;
	}

}
