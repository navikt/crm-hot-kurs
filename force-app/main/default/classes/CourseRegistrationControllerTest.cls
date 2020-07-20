@isTest
private without sharing class CourseRegistrationControllerTest {

	@isTest
	private static void testCreateRegistration() {

		Course__c course = new Course__c( Name = 'Testkurs', Max_number_of_participants__c = 10 );
		insert course;

		String courseId = [SELECT Id FROM Course__c LIMIT 1].Id;
		String noCourseId;

		List<CourseRegistrationModel> wrapperList = new List<CourseRegistrationModel>();
		CourseRegistrationModel wrapper = new CourseRegistrationModel();
		wrapper.firstName = 'test';
		wrapper.lastName = 'etternavn';
		wrapper.phone = '90080900';
		wrapper.email = '';
		wrapper.companyNumber = '677777';
		wrapperList.add( wrapper );

		String fields = JSON.serialize( wrapper );

		Test.StartTest();
		String result = CourseRegistrationController.createRegistration( fields, courseId );
		String error = CourseRegistrationController.createRegistration( fields, noCourseId );
		Test.StopTest();
		System.assertEquals( 'Du er påmeldt kurset. Du vil om kort tid motta en bekreftelse på epost', result );
		System.assertEquals( 'Det oppsto en feil. Prøv igjen senere.', error );

	}

}
