@isTest
private with sharing class CourseLoggingCatchTest {
    @TestSetup
    static void setupData() {
        TestDataFactory.insertEncryptionKey();
    }

    @isTest
    static void testContactCreateAddEncryptedStringThrowsForDeletedRegistration() {
        Course__c course = new Course__c(
            Name = 'Catch test course',
            MaxNumberOfParticipants__c = 10,
            DescriptionFormatted__c = 'Test course',
            Active__c = true
        );
        insert course;

        CourseRegistration__c registration = new CourseRegistration__c(
            ContactFirstName__c = 'Catch',
            ContactLastName__c = 'Test',
            ContactEmail__c = 'catch.test@nav.no',
            Course__c = course.Id,
            Status__c = 'Påmeldt'
        );
        insert registration;
        delete registration;

        Test.startTest();
        try {
            Contact_Create.addEncryptedString(new List<CourseRegistration__c>{ registration });
            System.assert(false, 'Expected update on deleted registration to throw');
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'Expected exception to be rethrown');
        }
        Test.stopTest();
    }

    @isTest
    static void testCourseEmailSubscribeHandlerThrowsForDeletedSubscriber() {
        HOT_CourseSubscriber__c subscriber = new HOT_CourseSubscriber__c(
            Email__c = 'deleted.subscriber@test.no',
            SubCategories__c = 'Syn'
        );
        insert subscriber;
        delete subscriber;

        Test.startTest();
        try {
            CourseEmailSubscribeHandler.addEncryptedString(new List<HOT_CourseSubscriber__c>{ subscriber });
            System.assert(false, 'Expected update on deleted subscriber to throw');
        } catch (Exception e) {
            System.assertNotEquals(null, e, 'Expected exception to be rethrown');
        }
        Test.stopTest();
    }
}
