@isTest
private with sharing class CreateContactFromCourseRegistrationTest {

	@isTest
	private static void testFindOrCreateContact() {
		Course__c course = new Course__c( Name = 'Testkurs', MaxNumberOfParticipants__c = 10, Active__c = true );
		insert course;
		List<CourseRegistration__c> registrations = new List<CourseRegistration__c>();
		CourseRegistration__c registration = new CourseRegistration__c( ContactFirstName__c = 'Per', ContactLastName__c = 'Hansen', ContactPhone__c = '99887766', ContactEmail__c = 'per.hansen@test.no', Course__c = course.Id, Status__c = 'Påmeldt' );
		insert registration;

		registrations.add( registration );

		CreateContactFromCourseRegistration.findOrCreateContact( registrations );

	}

}
