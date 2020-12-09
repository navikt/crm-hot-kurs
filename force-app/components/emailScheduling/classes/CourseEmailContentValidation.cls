global class CourseEmailContentValidation extends MyTriggers {

	private static Set<String> FIELDS = new Set<String> { 'EmailBeforeContent__c', 'EmailReminderContent__c', 'EmailAfterContent__c', 'EmailManualContent__c' };
	private static Set<String> ILLEGAL_TAG = new Set<String> { '<img' };

	global override void onBeforeInsert() {
		validateEmailContent( (List<Course__c>) records );
	}

	global override void onBeforeUpdate( Map<Id, SObject> triggerOldMap ) {
		validateEmailContent( ( List<Course__c> ) records );
	}

	public static void validateEmailContent( List<Course__c> courses ) {

		for ( Course__c course : courses ) {
			for ( String field : FIELDS ) {
				if ( !String.isBlank( (String) course.get( field ) ) ) {
					for ( String illegalTag : ILLEGAL_TAG ) {
						if ( ( (String) course.get( field ) ).contains( illegalTag ) ) {
							course.addError( field, Label.EmailConfirmation_ImageUploadError );
						}
					}
				}
			}
		}
	}
}