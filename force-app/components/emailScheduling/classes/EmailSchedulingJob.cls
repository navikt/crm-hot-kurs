public with sharing class EmailSchedulingJob implements Queueable, Database.AllowsCallouts {

	private List<Course__c> courses { get; set; }
	private List<CourseRegistration__c> courseRegistrations { get; set; }
	private List<EmailSchedulingHelper.ScheduleModel> recipients { get; set; }

	public EmailSchedulingJob( List<Course__c> courses, List<CourseRegistration__c> courseRegistrations, List<EmailSchedulingHelper.ScheduleModel> recipients ) {
		this.courses = courses;
		this.courseRegistrations = courseRegistrations;
		this.recipients = recipients;
	}

	public void execute( QueueableContext context ) {
		List<Messaging.SendEmailResult> emailResults = EmailSchedulingHelper.sendEmailToCourseRecipients( this.recipients );
		Map<Id, String> coursesWithErrors = EmailSchedulingHelper.getCoursesWithEmailErrors( this.courseRegistrations, emailResults );
		// EmailSchedulingHelper.createTask( recipients );
		EmailSchedulingHelper.updateCoursesWithEmailStatus( this.courses, coursesWithErrors );

	}
}
