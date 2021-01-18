@isTest
private with sharing class CourseUnsubscribeControllerTest {
	@isTest
	private static void testCourseUnsubscribe() {
		Course__c course = new Course__c( Name = 'Testkurs', MaxNumberOfParticipants__c = 10, DescriptionFormatted__c = 'Testkurs', Active__c = true );
		insert course;

		Contact participant = new Contact( FirstName = 'Test', LastName = 'Testesen', Email = 'test.testesen@test.no' );
		insert participant;

		CourseRegistration__c courseReg = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = participant.Id, Status__c = 'Påmeldt' );
		insert courseReg;

		Test.startTest();
		CourseRegistration__c result = CourseUnsubscribeController.getCourseRegistrationFields( courseReg.Id );
		CourseRegistration__c unsubscribed = CourseUnsubscribeController.updateCourseRegistration( courseReg.Id );
		Test.stopTest();

		System.assertEquals( unsubscribed.Status__c, 'Avmeldt', 'Participant is unsubscribed' );

	}
}
