public with sharing class EmailSchedulingHelper {

	public class ScheduleModel {
		public Id courseId;
		public Id contactId;
		public String emailTemplate;
	}

	public static List<Course__c> findScheduledEmails() {
		return [SELECT Id, EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c FROM Course__c
		        WHERE
		            ( EmailAfterDate__c = TODAY AND EmailAfterSent__c = false AND EmailAfterConfirmation__c = true ) OR
		            ( EmailBeforeDate__c = TODAY AND EmailBeforeSent__c = false AND EmailBeforeConfirmation__c = true ) OR
		            ( EmailManualDate__c = TODAY AND EmailManualSent__c = false AND EmailManualConfirmation__c = true ) OR
		            ( EmailReminderDate__c = TODAY AND EmailReminderSent__c = false AND EmailReminderConfirmation__c = true )];
	}

	public static List<CourseRegistration__c> getCourseRegistrations( List<Course__c> courses ) {
		Set<Id> courseIds = new Map<Id, Course__c> ( courses ).keySet();

		// TODO attendance = true for after
		return [SELECT Id, Course__c, CourseParticipant__c, Attendance__c FROM CourseRegistration__c
		        WHERE
		        Course__c IN : courseIds AND
		        Status__c = 'Påmeldt'];

	}

	public static List<ScheduleModel> getEmailsToSend( List<Course__c> courses, List<CourseRegistration__c> courseRegistrations ) {

		List<ScheduleModel> recipients = new List<ScheduleModel>();
		Map<Id, Course__c> courseMap = new Map<Id, Course__c> ( courses );

		for ( CourseRegistration__c reg : courseRegistrations ) {

			ScheduleModel recipient = new ScheduleModel();
			recipient.courseId = reg.Course__c;
			recipient.contactId = reg.CourseParticipant__c;

			Course__c course = courseMap.get( reg.Course__c ); // TODO check containsKey

			if ( Date.today() == course.EmailAfterDate__c ) {
				recipient.emailTemplate = 'courseScheduledEmailAfter';
			} else if ( Date.today() == course.EmailBeforeDate__c ) {
				recipient.emailTemplate = 'courseScheduledEmailBefore';
			} else if ( Date.today() == course.EmailManualDate__c ) { // TODO fix if manual is same day as other dates
				recipient.emailTemplate = 'courseScheduledEmailManual';
			} else if ( Date.today() == course.EmailReminderDate__c ) {
				recipient.emailTemplate = 'courseScheduledEmailReminder';
			}

			if ( recipient.emailTemplate != null ) {
				recipients.add( recipient );
			}
		}

		return recipients;
	}

	public static void sendEmailToCourseRecipients( List<ScheduleModel> recipients ) {

		List<Process_SendEmail.Request> requests = new List<Process_SendEmail.Request>();
		for ( ScheduleModel recipient : recipients ) {

			Process_SendEmail.Request request = new Process_SendEmail.Request();
			request.emailTemplateName = recipient.emailTemplate;
			request.recipientContactId = recipient.contactId;
			request.useDoNotReply = true;
			request.relatedToId = recipient.courseId;
			requests.add( request );
			System.debug( 'recipient.emailTemplate: ' + recipient.emailTemplate );
			System.debug( 'recipient.contactId: ' + recipient.contactId );
			System.debug( 'recipient.courseId: ' + recipient.courseId );
		}

		Process_SendEmail.sendEmail( requests );

	}
}