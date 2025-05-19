@IsTest
public with sharing class CourseEmailSubscriberControllerTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }
    @isTest
    public static void testGetCourseEmailSubscriber() {
        HOT_CourseSubscriber__c courseSubscriber = new HOT_CourseSubscriber__c(
            Email__c = 'fakeemail@nav.no.scratchorg',
            SubCategories__c = 'Bolig;Syn'
        );
        insert courseSubscriber;
        HOT_CourseSubscriber__c insertedCourseSubscriber = [
            SELECT Id, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            LIMIT 1
        ];

        Test.startTest();
        HOT_CourseSubscriber__c result = CourseEmailSubscriberController.getCourseEmailSubscriber(
            insertedCourseSubscriber.EncryptedId__c
        );
        Test.stopTest();
        HOT_CourseSubscriber__c insertedSubscriber = [
            SELECT Id, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseSubscriber.Id
            LIMIT 1
        ];
        Assert.isNotNull(result, 'Should have returned a course');
    }
    @isTest
    public static void testUpdateCourseEmailSubscriber() {
        HOT_CourseSubscriber__c courseSubscriber = new HOT_CourseSubscriber__c(
            Email__c = 'fakeemail@nav.no.scratchorg',
            SubCategories__c = 'Bolig;Syn'
        );
        insert courseSubscriber;
        HOT_CourseSubscriber__c insertedCourseSubscriber = [
            SELECT Id, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            LIMIT 1
        ];

        Test.startTest();
        CourseEmailSubscriberController.updateCourseEmailSubscriber(
            insertedCourseSubscriber.EncryptedId__c,
            '',
            'Hørsel;Syn;Bolig'
        );
        Test.stopTest();
        HOT_CourseSubscriber__c result = [
            SELECT Id, SubCategories__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseSubscriber.Id
            LIMIT 1
        ];
        Assert.areEqual('Hørsel;Syn;Bolig', result.SubCategories__c, 'Should have got the subcategories updated');
    }
    @isTest
    public static void testActivateCourseEmailSubscriber() {
        HOT_CourseSubscriber__c courseSubscriber = new HOT_CourseSubscriber__c(
            Email__c = 'fakeemail@nav.no.scratchorg',
            SubCategories__c = 'Bolig;Syn'
        );
        insert courseSubscriber;
        HOT_CourseSubscriber__c insertedCourseSubscriber = [
            SELECT Id, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            LIMIT 1
        ];

        Test.startTest();
        CourseEmailSubscriberController.activateCourseEmailSubscriber(insertedCourseSubscriber.EncryptedId__c);
        Test.stopTest();
        HOT_CourseSubscriber__c result = [
            SELECT Id, isActive__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseSubscriber.Id
            LIMIT 1
        ];
        Assert.areEqual(true, result.isActive__c, 'Should have got activated');
    }
    @isTest
    public static void testCreateCourseEmailSubscriberExistingSubscriber() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true,
            Sub_category__c = 'Hørsel'
        );
        insert course;
        HOT_CourseSubscriber__c courseSubscriber = new HOT_CourseSubscriber__c(
            Email__c = 'fakeemail@nav.no.scratchorg',
            SubCategories__c = 'Bolig;Syn'
        );
        insert courseSubscriber;
        Test.startTest();
        CourseEmailSubscriberController.createCourseEmailSubscriber(course.Id, 'fakeemail@nav.no.scratchorg');
        Test.stopTest();
        HOT_CourseSubscriber__c result = [
            SELECT Id, Categories__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseSubscriber.Id
            LIMIT 1
        ];
        Assert.areEqual('Bolig;Syn;Hørsel', result.Categories__c, 'Should have added new category to list');
    }
    @isTest
    public static void testCreateCourseEmailSubscriberNewSubscriber() {
        Course__c course = new Course__c(
            Name = 'Testkurs',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Testkurs',
            Active__c = true,
            Sub_category__c = 'Hørsel'
        );
        insert course;
        Test.startTest();
        CourseEmailSubscriberController.createCourseEmailSubscriber(course.Id, 'fakeemail@nav.no.scratchorg');
        Test.stopTest();
        HOT_CourseSubscriber__c result = [
            SELECT Id, Categories__c
            FROM HOT_CourseSubscriber__c
            LIMIT 1
        ];
        Assert.areEqual('Hørsel', result.Categories__c, 'Should have created a new subscriber with only one category');
    }
    @isTest
    public static void testDeleteCourseEmailSubscriber() {
        HOT_CourseSubscriber__c courseSubscriber = new HOT_CourseSubscriber__c(
            Email__c = 'fakeemail@nav.no.scratchorg',
            SubCategories__c = 'Bolig;Syn'
        );
        insert courseSubscriber;
        HOT_CourseSubscriber__c insertedCourseSubscriber = [
            SELECT Id, EncryptedId__c
            FROM HOT_CourseSubscriber__c
            LIMIT 1
        ];
        Test.startTest();
        CourseEmailSubscriberController.deleteCourseEmailSubscriber(insertedCourseSubscriber.EncryptedId__c);
        Test.stopTest();
        List<HOT_CourseSubscriber__c> result = [
            SELECT Id, Categories__c
            FROM HOT_CourseSubscriber__c
            WHERE Id = :courseSubscriber.Id
        ];
        Assert.areEqual(0, result.size(), 'Subscriber should be deleted and list should be empty');
    }
}
