public with sharing class EmailSchedulingHelper {

	public static final String AFTER_TEMPLATE =    'courseScheduledEmailAfter';
	public static final String BEFORE_TEMPLATE =   'courseScheduledEmailBefore';
	public static final String MANUAL_TEMPLATE =   'courseScheduledEmailManual';
	public static final String REMINDER_TEMPLATE = 'courseScheduledEmailReminder';
	public static final List<String> TEMPLATES =   new List<String> { AFTER_TEMPLATE, BEFORE_TEMPLATE, MANUAL_TEMPLATE, REMINDER_TEMPLATE };

	public enum EmailTypes { AFTER, REMINDER, BEFORE, MANUAL }

	public class ScheduleModel {
		public Id courseId;
		public Id contactId;
		public String emailTemplate;
	}

	public static Map<Id, Course__c> getCoursesWithScheduledEmails() {
		List<Course__c> courses = [SELECT Id,

		                           EmailAfterDate__c, EmailBeforeDate__c, EmailManualDate__c, EmailReminderDate__c,
		                           EmailAfterContent__c, EmailBeforeContent__c, EmailManualContent__c, EmailReminderContent__c

		                           FROM Course__c
		                           WHERE
		                               ( EmailAfterDate__c = TODAY AND EmailAfterSent__c = false AND EmailAfterConfirmation__c = true ) OR
		                               ( EmailBeforeDate__c = TODAY AND EmailBeforeSent__c = false AND EmailBeforeConfirmation__c = true ) OR
		                               ( EmailManualDate__c = TODAY AND EmailManualSent__c = false AND EmailManualConfirmation__c = true ) OR
		                               ( EmailReminderDate__c = TODAY AND EmailReminderSent__c = false AND EmailReminderConfirmation__c = true )];

		return new Map<Id, Course__c>( courses );
	}

	public static List<CourseRegistration__c> getCourseRegistrations( Map<Id, Course__c> courses ) {

		return [SELECT Id, Course__c, CourseParticipant__c, Attendance__c FROM CourseRegistration__c
		        WHERE
		        Course__c IN : courses.keySet() AND
		        Status__c = 'Påmeldt'];
	}

	public static List<ScheduleModel> prepareEmails( Map<Id, Course__c> courses, List<CourseRegistration__c> courseRegistrations ) {

		Map<String, Id> emailTemplates = getTemplates();

		List<ScheduleModel> recipients = new List<ScheduleModel>();

		for ( CourseRegistration__c courseRegistration : courseRegistrations ) {

			ScheduleModel recipient = new ScheduleModel();
			Course__c course = courses.get( courseRegistration.Course__c );
			recipient.courseId = courseRegistration.Course__c;
			recipient.contactId = courseRegistration.CourseParticipant__c;

			switch on checkEmailType( course ) {
				when AFTER      { recipient.emailTemplate = emailTemplates.get( AFTER_TEMPLATE ); }
				when BEFORE     { recipient.emailTemplate = emailTemplates.get( BEFORE_TEMPLATE ); }
				when MANUAL     { recipient.emailTemplate = emailTemplates.get( MANUAL_TEMPLATE ); }
				when REMINDER   { recipient.emailTemplate = emailTemplates.get( REMINDER_TEMPLATE ); }
			}

			if ( recipient.courseId != null && recipient.contactId != null && recipient.emailTemplate != null ) {
				recipients.add( recipient );
			}
		}

		return recipients;
	}


	public static List<EmailQueue__c> queueEmails( List<ScheduleModel> recipients ) {

		List<EmailQueue__c> emailQueue = new List<EmailQueue__c>();

		for ( ScheduleModel recipient : recipients ) {
			EmailQueue__c email = new EmailQueue__c();
			email.TemplateId__c = recipient.emailTemplate;
			email.TargetObjectId__c = recipient.contactId;
			email.WhatId__c = recipient.courseId;
			email.Priority__c = '5';
			email.Status__c = 'Queued';
			email.SaveAsActivity__c = false;
			emailQueue.add( email );
		}

		insert emailQueue;

		return emailQueue;
	}

	public static Map<Id, List<String> > getCoursesWithEmailQueue( List<EmailQueue__c> emailQueue ) {

		Map<Id, List<String> > courses = new Map<Id, List<String> >();

		for ( EmailQueue__c email : emailQueue ) {
			if ( courses.containsKey( email.WhatId__c ) ) {
				courses.get( email.WhatId__c ).add( email.Id );
			} else {
				courses.put( email.WhatId__c, new List<String> { email.Id } );
			}
		}

		return courses;
	}


	public static void updateCourses( Map<Id, Course__c> courseMap, Map<Id, List<String> > coursesWithEmailQueue ) {

		List<Course__c> courses = new List<Course__c>();

		for ( Id courseId : coursesWithEmailQueue.keySet() ) {

			Course__c course = courseMap.get( courseId );

			switch on checkEmailType( course ) {
				when AFTER      { course.EmailAfterSent__c = true; }
				when BEFORE     { course.EmailBeforeSent__c = true; }
				when MANUAL     { course.EmailManualSent__c = true; }
				when REMINDER   { course.EmailReminderSent__c = true; }
				// TODO add emailQueue__c ids
			}

			courses.add( course );
		}

		update courses;
	}

	// public static void updateCourseRegistrations( Map<Id, List<String> > courses ) {
	// }

	public static void createTasks( Map<Id, Course__c> courseMap, Map<Id, List<String> > coursesWithEmailQueue ) {

		List<Task> tasks = new List<Task>();

		for ( Id courseId : coursesWithEmailQueue.keySet() ) {

			Task task = new Task( WhatId = courseId, Status = 'Completed', TAG_NoPersonInformation__c = true );
			Course__c course = courseMap.get( courseId );

			switch on checkEmailType( course ) {
				when AFTER {
					task.Subject = 'Evaluerings e-post sendt';
					task.Description = course.EmailAfterContent__c;
				} when BEFORE {
					task.Subject = 'E-post med informasjon før kurs sendt';
					task.Description = course.EmailBeforeContent__c;
				} when MANUAL {
					task.Subject = 'Manuell e-post sendt';
					task.Description = course.EmailManualContent__c;
				} when REMINDER {
					task.Subject = 'Påminnelse om kurs er sendt på e-post';
					task.Description = course.EmailReminderContent__c;
				}
			}

			tasks.add( task );
		}

		insert tasks;
	}

	// ------------------------------------------------
	// --------------- HELPER FUNCTIONS ---------------
	// ------------------------------------------------

	public static EmailTypes checkEmailType( Course__c course ) {
		if      ( Date.today() == course.EmailAfterDate__c )    { return EmailTypes.AFTER; }
		else if ( Date.today() == course.EmailBeforeDate__c )   { return EmailTypes.BEFORE; }
		else if ( Date.today() == course.EmailManualDate__c )   { return EmailTypes.MANUAL; }
		else if ( Date.today() == course.EmailReminderDate__c ) { return EmailTypes.REMINDER; }

		return null;
	}

	public static Map<String, Id> getTemplates() {

		List<EmailTemplate> emailTemplates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN : TEMPLATES ];
		Map<String, Id> emailTemplateMap = new Map<String, Id>();

		if ( emailTemplates.size() < TEMPLATES.size() ) {
			// TODO throw error
		}

		for ( EmailTemplate emailTemplate : emailTemplates ) {
			emailTemplateMap.put( emailTemplate.DeveloperName, emailTemplate.Id );
		}

		return emailTemplateMap;
	}

}