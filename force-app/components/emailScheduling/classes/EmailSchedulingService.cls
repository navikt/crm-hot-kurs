global class EmailSchedulingService implements Schedulable {
	global void execute( SchedulableContext ctx ) {
		run();
	}

	@future
	public static void run() {
		Map<Id, Course__c> courses = EmailSchedulingHelper.getCoursesWithScheduledEmails( );
		List<CourseRegistration__c> courseRegistrations = EmailSchedulingHelper.getCourseRegistrations( courses );
		List<EmailSchedulingHelper.ScheduleModel> recipients = EmailSchedulingHelper.prepareEmails( courses, courseRegistrations );
		List<EmailQueue__c> emailQueue = EmailSchedulingHelper.queueEmails( recipients );

		Map<Id, List<String> > coursesWithEmailQueue = EmailSchedulingHelper.getCoursesWithEmailQueue( emailQueue );
		EmailSchedulingHelper.updateCourses( courses, coursesWithEmailQueue );
		// EmailSchedulingHelper.createTasks( courses, coursesWithEmailQueue );
	}
}
