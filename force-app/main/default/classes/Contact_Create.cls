global class Contact_Create extends MyTriggers {
	global override void onBeforeInsert( ) {
		CreateContactFromCourseRegistration.findOrCreateContact( (List<CourseRegistration__c>) records );
	}
	global override void onAfterInsert( ) {
		addEncryptedString( (List<CourseRegistration__c>) records );
	}

	public static void addEncryptedString( List<CourseRegistration__c> registrations ) {
	    List<CourseRegistration__c> recordsToUpdate = new List<CourseRegistration__c>();

	    for ( CourseRegistration__c reg : registrations ) {
	        CourseRegistration__c cr = new CourseRegistration__c( Id = reg.id );
	        cr.EncryptedId__c = CryptoService.encryptString( cr.Id );
	        recordsToUpdate.add( cr );
	    }
	    update recordsToUpdate;
	   }
}