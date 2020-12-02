global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {
		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( courses, courseRegistrations );
		EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
	}
}