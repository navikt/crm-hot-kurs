global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<Course__c> filteredCourses = EmailSchedulingHelper.removeCourses( courses, courseRegistrations );

		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( filteredCourses, courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		EmailSchedulingHelper.createTasks( filteredCourses );

		Map<Id, String> coursesWithErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );
		EmailSchedulingHelper.updateCoursesWithEmailStatus( filteredCourses, coursesWithErrors );
	}

	// TODO add async function
}