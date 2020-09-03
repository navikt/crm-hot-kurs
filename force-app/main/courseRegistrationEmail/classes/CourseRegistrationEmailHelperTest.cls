@isTest
private without sharing class CourseRegistrationEmailHelperTest {

	@testSetup
	private static void setup() {
		EmailTemplate et = new EmailTemplate( DeveloperName = 'courseRegistrationInvitation', Name = 'courseRegistrationInvitation', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		Database.insert( et, false );
	}

	@isTest
	private static void testFetchOrCreateContacts() {

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( CourseRegistrationEmailModelTest.jsonData, List<CourseRegistrationEmailModel>.class );

		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 0, contacts.size(), 'no contacts before test' );

		Test.StartTest();
		CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );
		Test.StopTest();

		contacts = [SELECT Id FROM Contact];
		System.assertEquals( 3, contacts.size(), 'three contacts after test' );
	}

	@isTest
	private static void testFetchOrCreateContacts_contactsExists() {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
		Contact c3 = new Contact( LastName = 'test', email = 'per.nordmann@test.com', TAG_Informed__c = true );
		insert new List<Contact> { c1, c2, c3 };

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( CourseRegistrationEmailModelTest.jsonData, List<CourseRegistrationEmailModel>.class );

		List<Contact> contacts = [SELECT Id FROM Contact];
		System.assertEquals( 3, contacts.size(), 'three contacts before test' );

		Test.StartTest();
		contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );
		Test.StopTest();

		System.assertEquals( 3, contacts.size(), 'three contacts returned from function' );

		contacts = [SELECT Id FROM Contact];
		System.assertEquals( 3, contacts.size(), 'still three contacts after test' );
	}

	@isTest
	private static void testCreateCourseRegistrations() {

		DateTime d = Date.today().addDays( 1 );
		Course__c course = new Course__c( Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ) );
		insert course;

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( CourseRegistrationEmailModelTest.jsonData, List<CourseRegistrationEmailModel>.class );
		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		System.assertEquals( 3, contacts.size(), 'three contacts should exist' );


		List<CourseRegistration__c> registrations = [SELECT Id FROM CourseRegistration__c];
		System.assertEquals( 0, registrations.size(), 'no registrations before test' );

		Test.StartTest();
		CourseRegistrationEmailHelper.createCourseRegistrations( course.Id, contacts );
		Test.StopTest();

		registrations = [SELECT Id FROM CourseRegistration__c];
		System.assertEquals( 3, registrations.size(), 'three registrations after test' );
	}

	@isTest
	private static void testCreateCourseRegistrations_allRegistrationsExists() {

		Contact c1 = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		Contact c2 = new Contact( LastName = 'test', email = 'kari.nordmann@test.com', TAG_Informed__c = true );
		Contact c3 = new Contact( LastName = 'test', email = 'per.nordmann@test.com', TAG_Informed__c = true );
		insert new List<Contact> { c1, c2, c3 };

		DateTime d = Date.today().addDays( 1 );
		Course__c course = new Course__c( Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ) );
		insert course;
		CourseRegistration__c reg1 = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = c1.Id, Status__c = 'Påmeldt' );
		CourseRegistration__c reg2 = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = c2.Id, Status__c = 'Påmeldt' );
		CourseRegistration__c reg3 = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = c3.Id, Status__c = 'Påmeldt' );
		insert new List<CourseRegistration__c> { reg1, reg2, reg3 };

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( CourseRegistrationEmailModelTest.jsonData, List<CourseRegistrationEmailModel>.class );
		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		System.assertEquals( 3, contacts.size(), 'three contacts should exist' );

		List<CourseRegistration__c> registrations = [SELECT Id FROM CourseRegistration__c];
		System.assertEquals( 3, registrations.size(), 'three registrations before test' );

		Test.StartTest();
		registrations = CourseRegistrationEmailHelper.createCourseRegistrations( course.Id, contacts );
		Test.StopTest();

		System.assertEquals( 3, registrations.size(), 'three registrations return in function' );
	}

	@isTest
	private static void testCreateCourseRegistrations_alreadyExists() {

		Contact con = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		insert con;
		DateTime d = Date.today().addDays( 1 );
		Course__c course = new Course__c( Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ) );
		insert course;
		CourseRegistration__c reg = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = con.Id, Status__c = 'Påmeldt' );
		insert reg;

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( CourseRegistrationEmailModelTest.jsonData, List<CourseRegistrationEmailModel>.class );
		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		System.assertEquals( 3, contacts.size(), 'three contacts should exist' );

		List<CourseRegistration__c> registrations = [SELECT Id FROM CourseRegistration__c];
		System.assertEquals( 1, registrations.size(), 'one registration before test' );

		Test.StartTest();
		CourseRegistrationEmailHelper.createCourseRegistrations( course.Id, contacts );
		Test.StopTest();

		registrations = [SELECT Id FROM CourseRegistration__c WHERE Status__c = 'Invitert'];
		System.assertEquals( 2, registrations.size(), 'two invited registrations after test' );

		registrations = [SELECT Id FROM CourseRegistration__c WHERE Status__c = 'Påmeldt'];
		System.assertEquals( 1, registrations.size(), 'one attending registrations after test' );
	}


	@isTest
	private static void testCreateCourseRegistrations_checkURL() {

		Contact con = new Contact( LastName = 'test', email = 'ola.nordmann@test.com', TAG_Informed__c = true );
		insert con;
		DateTime d = Date.today().addDays( 1 );
		Course__c course = new Course__c( Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ) );
		insert course;
		CourseRegistration__c reg = new CourseRegistration__c( Course__c = course.Id, CourseParticipant__c = con.Id, Status__c = 'Påmeldt' );
		insert reg;

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( CourseRegistrationEmailModelTest.jsonData, List<CourseRegistrationEmailModel>.class );
		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );

		System.assertEquals( 3, contacts.size(), 'three contacts should exist' );


		Test.StartTest();
		CourseRegistrationEmailHelper.createCourseRegistrations( course.Id, contacts );
		Test.StopTest();

		List<Domain> domains = [SELECT Domain FROM Domain];
		String url = 'https://' + domains[0].Domain + 'kurs/s/?id=' + course.Id;

		// List<CourseRegistration__c> registrations = [SELECT Id, CommunityUrl__c FROM CourseRegistration__c WHERE Status__c = 'Invitert'];
		// System.assertEquals( url, registrations[0].CommunityUrl__c, 'should have added registration url' );
		// System.assertEquals( url, registrations[1].CommunityUrl__c, 'should have added registration url' );
		// registrations = [SELECT Id, CommunityUrl__c FROM CourseRegistration__c WHERE Status__c = 'Påmeldt'];
		// System.assertEquals( url, registrations[0].CommunityUrl__c, 'should have updated registration url' );
	}


	@isTest
	private static void testSendEmailToCourseRecipients() {

		DateTime d = Date.today().addDays( 1 );
		Course__c course = new Course__c( Active__c = true, MaxNumberOfParticipants__c = 4, CommunityUrl__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ) );
		insert course;

		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( CourseRegistrationEmailModelTest.jsonData, List<CourseRegistrationEmailModel>.class );
		List<Contact> contacts = CourseRegistrationEmailHelper.fetchOrCreateContacts( recipients );
		List<CourseRegistration__c> registrations = CourseRegistrationEmailHelper.createCourseRegistrations( course.Id, contacts );

		List<EmailMessage> emails = [SELECT HtmlBody, ToAddress FROM EmailMessage];
		System.assertEquals( 0, emails.size(), 'No emails sent before' );

		Test.StartTest();
		CourseRegistrationEmailHelper.sendEmailToCourseRecipients( registrations, contacts );
		Test.StopTest();

		emails = [SELECT Id FROM EmailMessage];
		System.assertEquals( 3, emails.size(), 'three emails sent, three EmailMessage created' );
	}
}