@isTest
private with sharing class CourseRegistrationControllerTest {

	@testSetup
	private static void setup() {

	}

	@isTest
	private static void testCreateRegistration() {
		Course__c course = new Course__c( Name = 'Testkurs', MaxNumberOfParticipants__c = 10, DescriptionFormatted__c = 'Testkurs', Active__c = true );
		insert course;

		String courseId = [SELECT Id FROM Course__c WHERE Name = 'Testkurs' LIMIT 1].Id;
		String noCourseId;

		CourseRegistrationModel wrapper = new CourseRegistrationModel();
		wrapper.firstName = 'test';
		wrapper.lastName = 'etternavn';
		wrapper.phone = '90080900';
		wrapper.email = 'test@test.com';
		wrapper.companyNumber = '677777';
		wrapper.source = 'Kurs';

		String fields = JSON.serialize( wrapper );

		Test.StartTest();
		String result = CourseRegistrationController.createRegistration( fields, courseId );
		String result2 = CourseRegistrationController.createRegistration( fields, noCourseId );
		Test.StopTest();
		System.assertEquals( 'Du er påmeldt kurset. Du vil om kort tid motta en bekreftelse på epost', result, 'Registration successfull' );
		System.assertEquals( 'Det oppsto en feil. Prøv igjen senere.', result2, 'Course id missing' );
	}
	@isTest
	private static void testGetInvitationCode() {

		Course__c courseWithInvitationCode = new Course__c( Name = 'Test invitasjon', MaxNumberOfParticipants__c = 20, DescriptionFormatted__c = 'Invitasjon', GenerateInvitationCode__c = true );
		insert courseWithInvitationCode;

		Course__c courseWithoutInvitationCode = new Course__c( Name = 'Test invitasjon uten kode', MaxNumberOfParticipants__c = 20, DescriptionFormatted__c = 'Invitasjon', GenerateInvitationCode__c = false );
		insert courseWithoutInvitationCode;

		Course__c getCourseWithInvitationCode = [SELECT Id, InvitationCode__c FROM Course__c WHERE InvitationCode__c != null LIMIT 1];
		Course__c getCourseWithoutInvitationCode = [SELECT Id, InvitationCode__c FROM Course__c WHERE GenerateInvitationCode__c = false LIMIT 1];

		Test.startTest();
		String result = CourseRegistrationController.getInvitationCode( getCourseWithInvitationCode.Id );
		String result2 = CourseRegistrationController.getInvitationCode( getCourseWithoutInvitationCode.Id );
		Test.stopTest();
		System.assertNotEquals( result, null, 'InvitationCode is not null' );
		System.assertEquals( result2, '', 'InvitationCode is null' );
	}

}
