public with sharing class CourseInvitationController {

	@AuraEnabled
	public static List<CourseRegistration__c> createCourseRegistrations( Id courseId, List<Contact> contacts ) {

		// get contacts with an existing course registration
		Set<Id> contactIds = new Map<Id, Contact> ( contacts ).keySet();
		List<CourseRegistration__c> registrations = [SELECT Id, CourseParticipant__c, Course__c FROM CourseRegistration__c WHERE Course__c = : courseId AND CourseParticipant__c IN : contactIds];

		Set<Id> contactsWithRegistrations = new Set<Id>();
		for ( CourseRegistration__c reg : registrations ) {
			contactsWithRegistrations.add( reg.CourseParticipant__c );
		}

		// create new course registrations for new contacts
		List<CourseRegistration__c> newCourseRegistrations = new List<CourseRegistration__c>();
		for ( Contact con : contacts ) {
			if ( !contactsWithRegistrations.contains( con.Id ) ) {
				newCourseRegistrations.add( new CourseRegistration__c( Course__c = courseId, CourseParticipant__c = con.Id, Status__c = 'Invitert' ) );
			}
		}

		insert newCourseRegistrations;

		registrations.addAll( newCourseRegistrations );

		return registrations;
	}
}
