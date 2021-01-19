global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {

		List<CourseRegistration__c> emailsToSchedule = EmailSchedulingHelper.findEmailsToSchedule( );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.prepareEmails( emailsToSchedule );
		List<EmailQueue__c> emailQueue = EmailSchedulingHelper.queueEmails( recipients );

		Map<Id, List<String> > courses = EmailSchedulingHelper.getCourses( emailQueue );
		Map<Id, EmailSchedulingHelper.EmailTypes> courseTypes = EmailSchedulingHelper.getCourseTypes( emailsToSchedule );

		EmailSchedulingHelper.updateCourses( courses, courseTypes );
		EmailSchedulingHelper.createTasks( courses, courseTypes );
	}

	// TODO add async function
}