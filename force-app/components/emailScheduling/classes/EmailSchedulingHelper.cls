public with sharing class EmailSchedulingHelper {

	public class ScheduleModel {
		public Id courseId;
		public Id contactId;
		public String emailTemplate;
	}

	public static List<Course__c> findScheduledEmails() {
		return null;
	}

	public static List<CourseRegistration__c> getCourseRegistrations( List<Course__c> courses ) {
		return null;
	}

	public static List<ScheduleModel> getCourseRegistrations( List<Course__c> courses, List<CourseRegistration__c> courseRegistrations ) {
		return null;
	}

	public static void sendEmailToCourseRecipients( List<ScheduleModel> recipients ) {

		// 	Map<Id, Contact> contactMap = new Map<Id, Contact>( contacts );

		// 	List<Process_SendEmail.Request> requests = new List<Process_SendEmail.Request>();
		// 	for ( Contact con : contacts ) {
		// 		Process_SendEmail.Request request = new Process_SendEmail.Request();
		// 		request.emailTemplateName = template;
		// 		request.recipientContactId = con.Id;
		// 		request.useDoNotReply = useDoNotReply;
		// 		request.relatedToId = recordId;
		// 		requests.add( request );
		// 	}

		// 	Process_SendEmail.sendEmail( requests );

	}
}