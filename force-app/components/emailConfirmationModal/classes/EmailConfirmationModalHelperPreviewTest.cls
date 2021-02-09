@isTest
private without sharing class EmailConfirmationModalHelperPreviewTest {
    public static String html = 'this is {{{Course__c.Adjective__c}}}. Would you not agree, {{{Course__c.Person__c}}}? However, we don\'t want any {{{Account.BusinessPeople__c}}}';

    @isTest
    private static void testGetSObjectFields() {
        Test.StartTest();
        List<String> result = EmailConfirmationModalHelperPreview.getSObjectFields(
            'Course__c',
            html
        );
        Test.StopTest();

        System.assertEquals(2, result.size(), 'Should contains two fields');
        System.assertEquals(
            'Adjective__c',
            result[0],
            'should be Adjective__c'
        );
        System.assertEquals('Person__c', result[1], 'should be Person__c');
    }

    @isTest
    private static void testReplaceMergeFields() {
        Contact con = new Contact(
            LastName = 'Nordmann',
            Email = 'kari.nordmann@test.no',
            FirstName = 'Kari',
            TAG_Informed__c = true
        );
        insert con;

        List<String> sObjectFields = new List<String>{
            'FirstName',
            'LastName',
            'Email'
        };
        Test.StartTest();
        Map<String, String> replacedMergeFields = EmailConfirmationModalHelperPreview.replaceMergeFields(
            con.Id,
            'Contact',
            sObjectFields
        );
        Test.StopTest();

        System.assertEquals(
            3,
            replacedMergeFields.size(),
            'Three fields, three values'
        );
        System.assertEquals(
            'Kari',
            replacedMergeFields.get('\\{\\{\\{Contact.FirstName\\}\\}\\}'),
            'FirstName should be Kari'
        );
        System.assertEquals(
            'Nordmann',
            replacedMergeFields.get('\\{\\{\\{Contact.LastName\\}\\}\\}'),
            'LastName should be Nordmann'
        );
        System.assertEquals(
            'kari.nordmann@test.no',
            replacedMergeFields.get('\\{\\{\\{Contact.Email\\}\\}\\}'),
            'Email should be kari.nordmann@test.no'
        );
    }

    @isTest
    private static void testReplaceMergeFields_empty() {
        Contact con = new Contact(
            LastName = 'Nordmann',
            FirstName = 'Kari',
            TAG_Informed__c = true
        );
        insert con;

        List<String> sObjectFields = new List<String>{ 'Email' };
        Test.StartTest();
        Map<String, String> replacedMergeFields = EmailConfirmationModalHelperPreview.replaceMergeFields(
            con.Id,
            'Contact',
            sObjectFields
        );
        Test.StopTest();

        System.assertEquals(
            1,
            replacedMergeFields.size(),
            'one field, one value'
        );
        System.assertEquals(
            null,
            replacedMergeFields.get('{{{Contact.Email}}}'),
            'Email should be empty'
        );
    }

    @isTest
    private static void testReplaceMergeFields_date() {
        Date d = Date.today();
        Contact con = new Contact(
            LastName = 'Nordmann',
            Birthdate = d,
            TAG_Informed__c = true
        );
        insert con;

        List<String> sObjectFields = new List<String>{ 'Birthdate' };
        Test.StartTest();
        Map<String, String> replacedMergeFields = EmailConfirmationModalHelperPreview.replaceMergeFields(
            con.Id,
            'Contact',
            sObjectFields
        );
        Test.StopTest();

        System.assertEquals(
            1,
            replacedMergeFields.size(),
            'one field, one value'
        );
        System.assertEquals(
            String.valueOf(d) + ' 00:00:00',
            replacedMergeFields.get('\\{\\{\\{Contact.Birthdate\\}\\}\\}'),
            'Birthday should be ' + d
        );
    }

    @isTest
    private static void testMergeHtml() {
        Map<String, String> replacedMergeFields = new Map<String, String>();
        replacedMergeFields.put(
            '\\{\\{\\{Course__c.Adjective__c\\}\\}\\}',
            'nice'
        );
        replacedMergeFields.put(
            '\\{\\{\\{Course__c.Person__c\\}\\}\\}',
            'Kari'
        );

        Test.StartTest();
        String actual = EmailConfirmationModalHelperPreview.mergeHtml(
            html,
            replacedMergeFields
        );
        Test.StopTest();

        String expected = 'this is nice. Would you not agree, Kari? However, we don\'t want any {{{Account.BusinessPeople__c}}}';
        System.assertEquals(
            expected,
            actual,
            'should have replaced all fields'
        );
    }

    @isTest
    private static void testIsDateTimeField_positive() {
        Test.StartTest();
        Boolean result = EmailConfirmationModalHelperPreview.isDateTimeField(
            'Course__c',
            'RegistrationFromDateTime__c'
        );
        Test.StopTest();

        System.assertEquals(true, result, 'Field expected to be DateTime type');
    }

    @isTest
    private static void testIsDateTimeField_negative() {
        Test.StartTest();
        Boolean result = EmailConfirmationModalHelperPreview.isDateTimeField(
            'Course__c',
            'Name'
        );
        Test.StopTest();

        System.assertEquals(
            false,
            result,
            'Field expected to not be DateTime type'
        );
    }
}
