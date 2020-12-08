global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		Boolean templatesAreMissing = EmailSchedulingHelper.checkIfTemplatesMissing( courses );
		if ( templatesAreMissing ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		Map<Id, String> coursesWithErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );
		// EmailSchedulingHelper.createTask( recipients );
		EmailSchedulingHelper.updateCoursesWithEmailStatus( courses, coursesWithErrors );
	}
}
