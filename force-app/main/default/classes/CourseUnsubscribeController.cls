public with sharing class CourseUnsubscribeController {
	@AuraEnabled
	public static CourseRegistration__c getCourseRegistrationFields( String courseRegId ) {
		return [SELECT CourseParticipantName__c, Course__r.Name FROM CourseRegistration__c WHERE Id = : courseRegId];
	}
	@AuraEnabled
	public static CourseRegistration__c updateCourseRegistration( String courseRegId ) {
		CourseRegistration__c courseReg = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Id =: courseRegId LIMIT 1];
		courseReg.Status__c = 'Avmeldt';
		update courseReg;

		return courseReg;
	}
}
