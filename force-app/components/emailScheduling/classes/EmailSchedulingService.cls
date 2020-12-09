global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );
		List<List<EmailSchedulingHelper.ScheduleModel> > sepratedEmailBulks = EmailSchedulingHelper.seprateEmailsIntoBulks( recipients );

		for ( List<EmailSchedulingHelper.ScheduleModel> bulkedRecipients : sepratedEmailBulks ) {
			System.enqueueJob( new EmailSchedulingJob( courses, courseRegistrations, bulkedRecipients ) );
		}
	}
}
