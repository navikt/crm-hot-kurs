@isTest
private with sharing class CreateContactFromCourseRegistrationTest {

	@isTest
	private static void testFindOrCreateContact() {

		CourseRegistration__c registration = new CourseRegistration__c( ContactFirstName__c = 'Per', ContactLastName__c = 'Hansen', ContactPhone__c = '99887766', ContactEmail__c = 'per.hansen@test.no' );
		insert registration;

		//result = CreateContactFromCourseRegistration.findOrCreateContact( registration );

	}

}
