global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<List<CourseRegistration__c> > courseRegistrationBulks = EmailSchedulingHelper.separateRegistrationsIntoBulks( courseRegistrations );

		for ( List<CourseRegistration__c> bulkedRecipients : courseRegistrationBulks ) {
			System.enqueueJob( new EmailSchedulingJob( courses, bulkedRecipients ) );
		}
	}
}