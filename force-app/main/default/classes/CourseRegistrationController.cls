public with sharing class CourseRegistrationController {

	@AuraEnabled
	public static String createRegistration( String fields, String courseId ) {
		try {
			/*  Boolean duplicate = checkForDuplicates( contactId, courseId );
			   if ( duplicate ) { return 'Du er allerede påmeldt dette kurset'; }
			   insertRegistration( contactId, courseId );*/
			if ( fields != null ) { insertRegistration( fields, courseId ); }

			return 'Påmelding vellykket. Du vil om kort tid motta en bekreftelse på epost';

		} catch ( Exception e ) {
			return 'Det oppsto en feil. Prøv igjen senere.';
		}

	}

	public static void insertRegistration( String fields, Id courseId ) {
		if ( fields != null ) {
			CourseRegistrationModel model = CourseRegistrationModel.parse( fields );
			CourseRegistration__c registration = new CourseRegistration__c();

			registration.ContactFirstName__c = model.firstName;
			registration.ContactLastName__c = model.lastName;
			registration.ContactEmail__c = model.email;
			registration.ContactPhone__c = model.phone;
			registration.Status__c = 'Påmeldt';
			registration.Course__c = courseId;

			insert registration;
		}
	}

	@AuraEnabled
	public static Course__c getCourseFields( String courseId ) {
		return [SELECT Name, RegistrationDeadline__c, RegistrationFromDateTime__c, RegistrationToDateTime__c, InvitationCode__c, RegistrationPlaceName__c, Type__c, MaxNumberOfParticipants__c, NumberOfParticipants__c, Waitinglist__c FROM Course__c WHERE Id = : courseId];
	}

/*
       public static Boolean checkForDuplicates( Id contactId, Id courseId ) {
        List<CourseRegistration__c> existingRecord =
        [SELECT Id, Course__c, CourseParticipant__c
         FROM CourseRegistration__c
         WHERE Course__c =: courseId
                           AND CourseParticipant__c =: contactId LIMIT 1];

        Boolean exists = existingRecord.size() > 0 ? true : false;

        return exists;
       }*/
}
