global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<CourseRegistration__c> emailsToSchedule = EmailSchedulingHelper.findEmailsToSchedule( );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.prepareEmails( emailsToSchedule );
		List<EmailQueue__c> emailQueue = EmailSchedulingHelper.queueEmails( recipients );

		// EmailSchedulingHelper.createTasks( courses );

		// Map<Id, String> coursesWithErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( emailQueue );
		// EmailSchedulingHelper.updateCoursesWithEmailStatus( courses, coursesWithErrors );
	}

	// TODO add async function
}