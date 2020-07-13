public with sharing class CourseRegistrationController {
	@AuraEnabled
	public static void findOrCreateContact( String fields ) {
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
		createRegistration( con.Id, courseId );

	}

	public static Id getCourseId() {
		Network myNetwork = [SELECT Id, UrlPathPrefix FROM Network WHERE Name = 'kurs' ];
		ConnectApi.Community myCommunity = ConnectApi.Communities.getCommunity( myNetwork.id );
		Id courseId = [SELECT Id FROM Course__c WHERE RegistrationUrl__c = : myCommunity.siteUrl LIMIT 1].Id;

		return courseId;
	}

	public static Course_Registration__c createRegistration( Id contactId, Id courseId ) {
		Course_Registration__c registration = new Course_Registration__c( Course_registration__c = courseId, Course_participant__c = contactId, Status__c = 'Påmeldt' );
		insert registration;

		return registration;
	}

}
