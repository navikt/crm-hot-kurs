public with sharing class EmailSchedulingHelper {

	public enum EmailTypes { AFTER, REMINDER, BEFORE, MANUAL }

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

			if ( !courseMap.containsKey( reg.Course__c ) ) { continue; } // skip if course is not in map, but it should always be

			Course__c course = courseMap.get( reg.Course__c );

			switch on checkEmailType( course ) {
				when AFTER      { recipient.emailTemplate = 'courseScheduledEmailAfter'; }
				when BEFORE     { recipient.emailTemplate = 'courseScheduledEmailBefore'; }
				when MANUAL     { recipient.emailTemplate = 'courseScheduledEmailManual'; }
				when REMINDER   { recipient.emailTemplate = 'courseScheduledEmailReminder'; }
			}

			if ( recipient.emailTemplate != null ) {
				recipients.add( recipient );
			}
		}

		return recipients;
	}

	public static List<Messaging.SendEmailResult> sendEmailToCourseRecipients( List<ScheduleModel> recipients ) {

		List<Process_SendEmail.Request> requests = new List<Process_SendEmail.Request>();
		for ( ScheduleModel recipient : recipients ) {

			Process_SendEmail.Request request = new Process_SendEmail.Request();
			request.emailTemplateName = recipient.emailTemplate;
			request.recipientContactId = recipient.contactId;
			request.useDoNotReply = true;
			request.relatedToId = recipient.courseId;
			request.saveAsActivity = false;
			requests.add( request );
		}

		return Process_SendEmail.sendEmailWithLogs( requests );
	}

	public static Map<Id, String> getCoursesWithEmailErrors( List<CourseRegistration__c> courseRegistrations, List<Messaging.SendEmailResult> emailResults ) {

		Map<Id, List<String> > mapOfCoursesWithEmailErrors = new Map<Id, List<String> >();
		Map<Id, List<CourseRegistration__c> > mapOfCourseRegistrations = getMapOfCourseRegistrations( courseRegistrations );

		for ( Messaging.SendEmailResult emails : emailResults ) {

			if ( !emails.isSuccess() ) {

				for ( Messaging.SendEmailError error : emails.getErrors() ) {

					Id contactId = error.getTargetObjectId();
					if ( mapOfCourseRegistrations.containsKey( contactId ) ) {

						for ( CourseRegistration__c courseRegistration : mapOfCourseRegistrations.get( contactId ) ) {

							Id courseId = courseRegistration.Course__c;
							String message = contactId + ': ' + error.getMessage();

							if ( mapOfCoursesWithEmailErrors.containsKey( courseId ) ) {
								mapOfCoursesWithEmailErrors.get( courseId ).add( message );
							} else {
								mapOfCoursesWithEmailErrors.put( courseId, new List<String> { message } );
							}
						}
					}
				}
			}
		}

		Map<Id, String> mapOfCoursesWithEmailErrorsAsString = new Map<Id, String>();
		for ( Id key : mapOfCoursesWithEmailErrors.keySet() ) {
			List<String> errors = mapOfCoursesWithEmailErrors.get( key );
			mapOfCoursesWithEmailErrorsAsString.put( key, String.join( errors, '\n' ) );
		}

		return mapOfCoursesWithEmailErrorsAsString;
	}

	public static void updateCoursesWithEmailStatus( List<Course__c> courses, Map<Id, String> coursesWithErrors ) {

		for ( Course__c course : courses ) {
			if ( coursesWithErrors.containsKey( course.Id ) ) {
				switch on checkEmailType( course ) {
					when AFTER      { course.EmailAfterErrorMessage__c = coursesWithErrors.get( course.Id ); }
					when BEFORE     { course.EmailBeforeErrorMessage__c = coursesWithErrors.get( course.Id ); }
					when MANUAL     { course.EmailManualErrorMessage__c = coursesWithErrors.get( course.Id ); }
					when REMINDER   { course.EmailReminderErrorMessage__c = coursesWithErrors.get( course.Id ); }
				}
			} else {
				switch on checkEmailType( course ) {
					when AFTER      { course.EmailAfterSent__c = true; }
					when BEFORE     { course.EmailBeforeSent__c = true; }
					when MANUAL     { course.EmailManualSent__c = true; }
					when REMINDER   { course.EmailReminderSent__c = true; }
				}
			}
		}

		update courses;
	}

	public static List<Task> createTasks( List<Course__c> courses ) {
		List<Task> tasks = new List<Task>();
		for ( Course__c c : courses ) {

			Task task = new Task();
			switch on checkEmailType( c ) {
				when AFTER      { task.Subject = 'Epost om evaluering sendt'; }
				when BEFORE     { task.Subject = 'Epost med informasjon før kurs sendt'; }
				when MANUAL     { task.Subject = 'Manuell epost sendt'; }
				when REMINDER   { task.Subject = 'Påminnelse om kurs er sendt på epost'; }
			}
			task.WhatId = c.Id;
			task.Status = 'Completed';
			tasks.add( task );
		}

		return tasks;

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

	// public static EmailTypes checkEmailType( CourseParticipant__c courseParticipant ) {
	// 	if      ( Date.today() == courseParticipant.Course__r.EmailAfterDate__c )    { return EmailTypes.AFTER; }
	// 	else if ( Date.today() == courseParticipant.Course__r.EmailBeforeDate__c )   { return EmailTypes.BEFORE; }
	// 	else if ( Date.today() == courseParticipant.Course__r.EmailManualDate__c )   { return EmailTypes.MANUAL; }
	// 	else if ( Date.today() == courseParticipant.Course__r.EmailReminderDate__c ) { return EmailTypes.REMINDER; }

	// 	return null;
	// }
}