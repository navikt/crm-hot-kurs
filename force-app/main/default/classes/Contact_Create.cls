global class Contact_Create extends MyTriggers {
	global override void onBeforeInsert( ) {
		CreateContactFromCourseRegistration.findOrCreateContact( (List<CourseRegistration__c>) records );
	}
}
