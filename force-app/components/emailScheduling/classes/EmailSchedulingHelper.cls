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

	public static List<CourseRegistration__c> findEmailsToSchedule( ) {

		return [SELECT

		        Id, Course__c, CourseParticipant__c, Attendance__c,
		        Course__r.EmailAfterDate__c, Course__r.EmailBeforeDate__c, Course__r.EmailManualDate__c, Course__r.EmailReminderDate__c

		        FROM CourseRegistration__c

		        WHERE
		        Status__c = 'Påmeldt' AND (

					( Course__r.EmailAfterDate__c = TODAY AND Course__r.EmailAfterSent__c = false AND Course__r.EmailAfterConfirmation__c = true )
					OR ( Course__r.EmailBeforeDate__c = TODAY AND Course__r.EmailBeforeSent__c = false AND Course__r.EmailBeforeConfirmation__c = true )
					OR ( Course__r.EmailManualDate__c = TODAY AND Course__r.EmailManualSent__c = false AND Course__r.EmailManualConfirmation__c = true )
					OR ( Course__r.EmailReminderDate__c = TODAY AND Course__r.EmailReminderSent__c = false AND Course__r.EmailReminderConfirmation__c = true )
					)];
	}

	public static List<ScheduleModel> prepareEmails( List<CourseRegistration__c> courseRegistrations ) {

		Map<String, Id> emailTemplates = getTemplates();

		List<ScheduleModel> recipients = new List<ScheduleModel>();

		for ( CourseRegistration__c courseRegistration : courseRegistrations ) {

			ScheduleModel recipient = new ScheduleModel();
			recipient.courseId = courseRegistration.Course__c;
			recipient.contactId = courseRegistration.CourseParticipant__c;

			switch on checkEmailType( courseRegistration ) {
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

	public static Map<Id, List<String> > getCourses( List<EmailQueue__c> emailQueue ) {

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

	public static Map<Id, EmailTypes> getCourseTypes( List<CourseRegistration__c> courseRegistrations ) {

		Map<Id, EmailTypes> courseTypes = new Map<Id, EmailTypes>();

		for ( CourseRegistration__c courseRegistration : courseRegistrations ) {

			if ( !courseTypes.containsKey( courseRegistration.Course__c ) ) {
				courseTypes.put( courseRegistration.Course__c, checkEmailType( courseRegistration ) );
			}
		}

		return courseTypes;
	}

	public static void updateCourses( Map<Id, List<String> > courseMap, Map<Id, EmailTypes> courseTypes ) {

		List<Course__c> courses = new List<Course__c>();

		for ( Id courseId : courseMap.keySet() ) {

			Course__c course = new Course__c ( Id = courseId );

			switch on courseTypes.get( courseId ) {
				when AFTER      { course.EmailAfterSent__c = true; }
				when BEFORE     { course.EmailBeforeSent__c = true; }
				when MANUAL     { course.EmailManualSent__c = true; }
				when REMINDER   { course.EmailReminderSent__c = true; }
			}

			courses.add( course );
			// TODO add emailQueue__c ids
		}

		update courses;
	}

	// public static void updateCourseRegistrations( Map<Id, List<String> > courses ) {
	// }

	public static void createTasks( Map<Id, List<String> > courses, Map<Id, EmailTypes> courseTypes ) {

		List<Task> tasks = new List<Task>();

		for ( Id courseId : courses.keySet() ) {

			Task task = new Task( WhatId = courseId, Status = 'Completed' );

			switch on courseTypes.get( courseId ) {
				when AFTER      { task.Subject = 'E-post om evaluering sendt'; }
				when BEFORE     { task.Subject = 'E-post med informasjon før kurs sendt'; }
				when MANUAL     { task.Subject = 'Manuell e-post sendt'; }
				when REMINDER   { task.Subject = 'Påminnelse om kurs er sendt på epost'; }
			}

			tasks.add( task );
		}

		insert tasks;
	}

	// ------------------------------------------------
	// --------------- HELPER FUNCTIONS ---------------
	// ------------------------------------------------

	public static Map<Id, List<CourseRegistration__c> > getMapOfCourseRegistrations( List<CourseRegistration__c> courseRegistrations ) {

		Map<Id, List<CourseRegistration__c> > mapOfCourseRegistrations = new Map<Id, List<CourseRegistration__c> >();

		for ( CourseRegistration__c courseRegistration : courseRegistrations ) {
			if ( mapOfCourseRegistrations.containsKey( courseRegistration.CourseParticipant__c ) ) {
				mapOfCourseRegistrations.get( courseRegistration.CourseParticipant__c ).add( courseRegistration );
			} else {
				mapOfCourseRegistrations.put( courseRegistration.CourseParticipant__c, new List<CourseRegistration__c> { courseRegistration } );
			}
		}

		return mapOfCourseRegistrations;
	}

	public static EmailTypes checkEmailType( Course__c course ) {
		if      ( Date.today() == course.EmailAfterDate__c )    { return EmailTypes.AFTER; }
		else if ( Date.today() == course.EmailBeforeDate__c )   { return EmailTypes.BEFORE; }
		else if ( Date.today() == course.EmailManualDate__c )   { return EmailTypes.MANUAL; }
		else if ( Date.today() == course.EmailReminderDate__c ) { return EmailTypes.REMINDER; }

		return null;
	}

	public static EmailTypes checkEmailType( CourseRegistration__c courseRegistration ) {
		if      ( Date.today() == courseRegistration.Course__r.EmailAfterDate__c )    { return EmailTypes.AFTER; }
		else if ( Date.today() == courseRegistration.Course__r.EmailBeforeDate__c )   { return EmailTypes.BEFORE; }
		else if ( Date.today() == courseRegistration.Course__r.EmailManualDate__c )   { return EmailTypes.MANUAL; }
		else if ( Date.today() == courseRegistration.Course__r.EmailReminderDate__c ) { return EmailTypes.REMINDER; }

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