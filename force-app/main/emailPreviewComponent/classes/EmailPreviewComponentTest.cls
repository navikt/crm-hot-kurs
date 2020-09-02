@isTest
private without sharing class EmailPreviewComponentTest {

	public static String html = 'this is {{{Course__c.Adjective__c}}}. Would you not agree, {{{Course__c.Person__c}}}? However, we don\'t want any {{{Account.BusinessPeople__c}}}';

	@testSetup
	private static void setup() {
		EmailTemplate et = new EmailTemplate( DeveloperName = 'MY_UNIQUE_NAME', Name = 'MY_UNIQUE_NAME', IsActive = true, FolderId = UserInfo.getOrganizationId(), UiType = 'sfx', TemplateType = 'custom', Subject = 'Invitasjon til kurs', HtmlValue = '<html><head></head><body><p>Hei {{{Recipient.Name}}}! Velkommen til {{{Course__c.Name}}}.</p></body></html>' );
		Database.insert( et, false );
	}

	@isTest
	private static void testGetEmailPreview() {

		DateTime d = Date.today().addDays( 1 );
		Course__c course = new Course__c( Active__c = true, Name = 'mitt kurs', MaxNumberOfParticipants__c = 4, Description__c = 'test', Region__c = 'Oslo', RegistrationDeadline__c = d, RegistrationFromDateTime__c = d, RegistrationToDateTime__c = d.addDays( 1 ) );
		insert course;

		Test.StartTest();
		String actual = EmailPreviewComponent.getEmailPreview( course.Id, 'MY_UNIQUE_NAME' );
		Test.StopTest();

		String expected = 'Hei {{{Recipient.Name}}}! Velkommen til mitt kurs.';
		System.assertEquals( expected, actual.stripHtmlTags(), 'should have merged fields and given email template' );
	}

	@isTest
	private static void testGetSObjectFields() {

		Test.StartTest();
		List<String> result = EmailPreviewComponent.getSObjectFields( 'Course__c', html );
		Test.StopTest();

		System.assertEquals( 2, result.size(), 'Should contains two fields' );
		System.assertEquals( 'Adjective__c', result[0], 'should be Adjective__c' );
		System.assertEquals( 'Person__c', result[1], 'should be Person__c' );
	}

	@isTest
	private static void testReplaceMergeFields() {

		Contact con = new Contact( LastName = 'Nordmann', Email = 'kari.nordmann@test.no', FirstName = 'Kari', TAG_Informed__c = true );
		insert con;

		List<String> sObjectFields = new List<String> { 'FirstName', 'LastName', 'Email' };
		Test.StartTest();
		Map<String, String> replacedMergeFields = EmailPreviewComponent.replaceMergeFields( con.Id, 'Contact', sObjectFields );
		Test.StopTest();

		System.assertEquals( 3, replacedMergeFields.size(), 'Three fields, three values' );
		System.assertEquals( 'Kari', replacedMergeFields.get( '\\{\\{\\{Contact.FirstName\\}\\}\\}' ), 'FirstName should be Kari' );
		System.assertEquals( 'Nordmann', replacedMergeFields.get( '\\{\\{\\{Contact.LastName\\}\\}\\}' ), 'LastName should be Nordmann' );
		System.assertEquals( 'kari.nordmann@test.no', replacedMergeFields.get( '\\{\\{\\{Contact.Email\\}\\}\\}' ), 'Email should be kari.nordmann@test.no' );
	}

	@isTest
	private static void testReplaceMergeFields_empty() {

		Contact con = new Contact( LastName = 'Nordmann', FirstName = 'Kari', TAG_Informed__c = true );
		insert con;

		List<String> sObjectFields = new List<String> { 'Email' };
		Test.StartTest();
		Map<String, String> replacedMergeFields = EmailPreviewComponent.replaceMergeFields( con.Id, 'Contact', sObjectFields );
		Test.StopTest();

		System.assertEquals( 1, replacedMergeFields.size(), 'one field, one value' );
		System.assertEquals( null, replacedMergeFields.get( '{{{Contact.Email}}}' ), 'Email should be empty' );
	}

	@isTest
	private static void testReplaceMergeFields_date() {

		Date d = Date.today();
		Contact con = new Contact( LastName = 'Nordmann', Birthdate = d, TAG_Informed__c = true );
		insert con;

		List<String> sObjectFields = new List<String> {'Birthdate'};
		Test.StartTest();
		Map<String, String> replacedMergeFields = EmailPreviewComponent.replaceMergeFields( con.Id, 'Contact', sObjectFields );
		Test.StopTest();

		System.assertEquals( 1, replacedMergeFields.size(), 'one field, one value' );
		System.assertEquals( String.valueOf( d ) + ' 00:00:00', replacedMergeFields.get( '\\{\\{\\{Contact.Birthdate\\}\\}\\}' ), 'Birthday should be ' + d );
	}

	@isTest
	private static void testMergeHtml() {

		Map<String, String> replacedMergeFields = new Map<String, String>();
		replacedMergeFields.put( '\\{\\{\\{Course__c.Adjective__c\\}\\}\\}', 'nice' );
		replacedMergeFields.put( '\\{\\{\\{Course__c.Person__c\\}\\}\\}', 'Kari' );

		Test.StartTest();
		String actual = EmailPreviewComponent.mergeHtml( html, replacedMergeFields );
		Test.StopTest();

		String expected = 'this is nice. Would you not agree, Kari? However, we don\'t want any {{{Account.BusinessPeople__c}}}';
		System.assertEquals( expected, actual, 'should have replaced all fields' );
	}
}