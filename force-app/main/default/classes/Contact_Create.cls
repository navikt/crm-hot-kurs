global class Contact_Create extends MyTriggers {
	global override void onBeforeInsert( ) {
		CreateContactFromCourseRegistration.findOrCreateContact( (List<CourseRegistration__c>) records );
	}
	global override void onAfterInsert( ) {
		CreateContactFromCourseRegistration.addEncryptedString( (List<CourseRegistration__c>) records );
	}
}
