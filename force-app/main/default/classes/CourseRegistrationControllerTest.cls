@isTest
private with sharing class CourseRegistrationControllerTest {

	@testSetup
	private static void setup() {

	}

	@isTest
	private static void testCreateRegistration() {
		//Setup
		Course__c course = new Course__c( Name = 'Testkurs', MaxNumberOfParticipants__c = 10, Description__c = 'Testkurs' );
		insert course;

		String courseId = [SELECT Id FROM Course__c LIMIT 1].Id;
		String noCourseId;

		List<CourseRegistrationModel> wrapperList = new List<CourseRegistrationModel>();
		CourseRegistrationModel wrapper = new CourseRegistrationModel();
		wrapper.firstName = 'test';
		wrapper.lastName = 'etternavn';
		wrapper.phone = '90080900';
		wrapper.email = 'test@test.com';
		wrapper.companyNumber = '677777';
		wrapper.source = 'Kurs';
		wrapperList.add( wrapper );

		String fields = JSON.serialize( wrapper );


		Test.StartTest();
		String result = CourseRegistrationController.createRegistration( fields, courseId );
		Test.StopTest();
		System.assertEquals( 'Du er påmeldt kurset. Du vil om kort tid motta en bekreftelse på epost', result, 'Registration successfull' );
	}

	private static void testGetInvitationCode() {

		Course__c courseWithInvitationCode = new Course__c( Name = 'Test invitasjon', MaxNumberOfParticipants__c = 20, Description__c = 'Invitasjon', GenerateInvitationCode__c = true );
		insert courseWithInvitationCode;

		Course__c getCourseWithInvitationCode = [SELECT Id, InvitationCode__c FROM Course__c WHERE InvitationCode__c != null LIMIT 1];

		Test.startTest();
		String result = CourseRegistrationController.getInvitationCode( getCourseWithInvitationCode.Id );
		Test.stopTest();
		System.assertNotEquals( result, null, 'InvitationCodxse is not null' );
	}

}
