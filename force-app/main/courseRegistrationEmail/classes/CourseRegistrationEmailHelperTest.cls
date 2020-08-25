@isTest
private without sharing class CourseRegistrationEmailHelperTest {
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

		Test.StartTest();
		// CourseRegistrationEmailHelper.createCourseRegistrations();
		Test.StopTest();
	}

	@isTest
	private static void testSendEmailToCourseRecipients() {

		Test.StartTest();
		// CourseRegistrationEmailHelper.sendEmailToCourseRecipients();
		Test.StopTest();
	}
}