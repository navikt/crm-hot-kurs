@isTest
private without sharing class CourseRegistrationEmailControllerTest {
	@isTest
	private static void testSendCourseEmail() {

		String jsonData = '[' +

		                  '    {' +
		                  '        "firstName": "Ola",' +
		                  '        "lastName": "Nordmann",' +
		                  '        "email": "ola.nordmann@test.com"' +
		                  '    },' +

		                  '    {' +
		                  '        "firstName": "Kari",' +
		                  '        "lastName": "Nordmann",' +
		                  '        "email": "kari.nordmann@test.com"' +
		                  '    },' +

		                  '    {' +
		                  '        "firstName": "Per",' +
		                  '        "lastName": "Nordmann",' +
		                  '        "email": "per.nordmann@test.com"' +
		                  '    }' +
		                  ']';

		DateTime d = Date.today().addDays( 1 );

		Course__c course = new Course__c( Active__c = true, MaxNumberOfParticipants__c = 4, Description__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ) );
		insert course;

		List<CourseRegistration__c> registrations = [SELECT Id FROM CourseRegistration__c];
		System.assertEquals( 0, registrations.size(), 'no registrations before test' );

		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 0, contacts.size(), 'no contacts before test' );

		List<EmailMessage> emails = [SELECT HtmlBody, ToAddress FROM EmailMessage];
		System.assertEquals( 0, emails.size(), 'No emails sent before' );

		Test.StartTest();
		CourseRegistrationEmailController.sendCourseEmail( course.Id, jsonData );
		Test.StopTest();

		registrations = [SELECT Id FROM CourseRegistration__c];
		System.assertEquals( 3, registrations.size(), 'three registrations after test' );

		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 3, contacts.size(), 'three contacts after test' );

		emails = [SELECT Id FROM EmailMessage];
		System.assertEquals( 3, emails.size(), 'three emails sent, only one EmailMessage created' );
	}
}