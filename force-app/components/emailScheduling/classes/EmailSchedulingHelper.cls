public with sharing class EmailSchedulingHelper {

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

		List<ScheduleModel> recipients = new List<ScheduleModel>();

		for ( CourseRegistration__c courseRegistration : courseRegistrations ) {

			ScheduleModel recipient = new ScheduleModel();
			recipient.courseId = courseRegistration.Course__c;
			recipient.contactId = courseRegistration.CourseParticipant__c;

			switch on checkEmailType( courseRegistration ) {
				when AFTER      { recipient.emailTemplate = 'courseScheduledEmailAfter'; }
				when BEFORE     { recipient.emailTemplate = 'courseScheduledEmailBefore'; }
				when MANUAL     { recipient.emailTemplate = 'courseScheduledEmailManual'; }
				when REMINDER   { recipient.emailTemplate = 'courseScheduledEmailReminder'; }
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
			email.SaveAsActivity__c = false;
			emailQueue.add( email );
		}

		insert emailQueue;

		return emailQueue;
	}

	public static Map<Id, String> getCoursesWithEmailErrors( List<EmailQueue__c> emailQueue ) {

		// Map<Id, List<String> > mapOfCoursesWithEmailErrors = new Map<Id, List<String> >();
		// Map<Id, List<CourseRegistration__c> > mapOfCourseRegistrations = getMapOfCourseRegistrations( courseRegistrations );

		// for ( Messaging.SendEmailResult emails : emailResults ) {

		// 	if ( !emails.isSuccess() ) {

		// 		for ( Messaging.SendEmailError error : emails.getErrors() ) {

		// 			Id contactId = error.getTargetObjectId();
		// 			if ( mapOfCourseRegistrations.containsKey( contactId ) ) {

		// 				for ( CourseRegistration__c courseRegistration : mapOfCourseRegistrations.get( contactId ) ) {

		// 					Id courseId = courseRegistration.Course__c;
		// 					String message = contactId + ': ' + error.getMessage();

		// 					if ( mapOfCoursesWithEmailErrors.containsKey( courseId ) ) {
		// 						mapOfCoursesWithEmailErrors.get( courseId ).add( message );
		// 					} else {
		// 						mapOfCoursesWithEmailErrors.put( courseId, new List<String> { message } );
		// 					}
		// 				}
		// 			}
		// 		}
		// 	}
		// }

		// Map<Id, String> mapOfCoursesWithEmailErrorsAsString = new Map<Id, String>();
		// for ( Id key : mapOfCoursesWithEmailErrors.keySet() ) {
		// 	List<String> errors = mapOfCoursesWithEmailErrors.get( key );
		// 	mapOfCoursesWithEmailErrorsAsString.put( key, String.join( errors, '\n' ) );
		// }

		// return mapOfCoursesWithEmailErrorsAsString;

		return null;
	}

	public static void updateCoursesWithEmailStatus( List<Course__c> courses, Map<Id, String> coursesWithErrors ) {

		// for ( Course__c course : courses ) {
		// 	if ( coursesWithErrors.containsKey( course.Id ) ) {
		// 		switch on checkEmailType( course ) {
		// 			when AFTER      { course.EmailAfterErrorMessage__c = coursesWithErrors.get( course.Id ); }
		// 			when BEFORE     { course.EmailBeforeErrorMessage__c = coursesWithErrors.get( course.Id ); }
		// 			when MANUAL     { course.EmailManualErrorMessage__c = coursesWithErrors.get( course.Id ); }
		// 			when REMINDER   { course.EmailReminderErrorMessage__c = coursesWithErrors.get( course.Id ); }
		// 		}
		// 	} else {
		// 		switch on checkEmailType( course ) {
		// 			when AFTER      { course.EmailAfterSent__c = true; }
		// 			when BEFORE     { course.EmailBeforeSent__c = true; }
		// 			when MANUAL     { course.EmailManualSent__c = true; }
		// 			when REMINDER   { course.EmailReminderSent__c = true; }
		// 		}
		// 	}
		// }

		// update courses;
	}

	public static List<Task> createTasks( List<Course__c> courses ) {
		// List<Task> tasks = new List<Task>();
		// for ( Course__c c : courses ) {

		// 	Task task = new Task();
		// 	switch on checkEmailType( c ) {
		// 		when AFTER      { task.Subject = 'Epost om evaluering sendt'; }
		// 		when BEFORE     { task.Subject = 'Epost med informasjon før kurs sendt'; }
		// 		when MANUAL     { task.Subject = 'Manuell epost sendt'; }
		// 		when REMINDER   { task.Subject = 'Påminnelse om kurs er sendt på epost'; }
		// 	}
		// 	task.WhatId = c.Id;
		// 	task.Status = 'Completed';
		// 	tasks.add( task );
		// }

		// return tasks;

		return null;

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
}