global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails(); // TODO find only participants
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );

		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		EmailSchedulingHelper.createTasks( courses );

		Map<Id, String> coursesWithErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );
		EmailSchedulingHelper.updateCoursesWithEmailStatus( courses, coursesWithErrors );
	}

	// TODO add async function
}