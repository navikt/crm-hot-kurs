global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<Course__c> courses = EmailSchedulingHelper.findScheduledEmails();

		if ( EmailSchedulingHelper.checkIfTemplatesMissing( courses ) ) { return; }

		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		// List<List<CourseRegistration__c> > courseRegistrationBulks = EmailSchedulingHelper.separateRegistrationsIntoBulks( courseRegistrations );

		// for ( List<CourseRegistration__c> bulkedRecipients : courseRegistrationBulks ) {
		// 	System.enqueueJob( new EmailSchedulingJob( courses, bulkedRecipients ) );
		// }

		List<Course__c> filteredCourses = EmailSchedulingHelper.removeCourses( courses, courseRegistrations );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.getEmailsToSend( filteredCourses, courseRegistrations );
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( recipients );
		Map<Id, String> coursesWithErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( courseRegistrations, emailResults );
		EmailSchedulingHelper.createTasks( filteredCourses );
		EmailSchedulingHelper.updateCoursesWithEmailStatus( filteredCourses, coursesWithErrors );
	}
}