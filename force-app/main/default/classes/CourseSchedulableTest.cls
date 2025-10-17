@isTest
public class CourseSchedulableTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }
    @isTest
    public static void testCourseSchedulable() {
        String cronExpr = '0 0 0 21 12 ?';

        Course__c course1 = CourseRegistrationHandlerTest.getCourse('Testkurs');
        course1.RegistrationToDateTime__c = Datetime.Now().addDays(-85);
        update course1;

        Account accountCourse = new Account(Name = 'Kontakter uten konto');
        insert accountCourse;

        Contact contact1 = CourseScheduledDeleteContactsTest.getContact(accountCourse.Id, 'test1@test.no');

        CourseRegistration__c cr1 = CourseScheduledDeleteContactsTest.getCourseRegistration(course1.Id, contact1.Id);

        List<Contact> contacts = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crList = [SELECT Id FROM CourseRegistration__c];
        System.assertEquals(1, contacts.size(), 'Should be 1 contact');
        System.assertEquals(1, crList.size(), 'Should be 1 registration');

        Test.StartTest();
        String jobId = System.schedule('testCourseSchedulableJob', cronExpr, new CourseSchedulable());
        Test.StopTest();

        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<CourseRegistration__c> crListAfter = [SELECT Id FROM CourseRegistration__c];
        CourseRegistration__c cr1After = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Id = :cr1.Id
        ];
        //System.assertEquals(0, contactsAfter.size(), 'Should be 0 contacts');
        System.assertEquals(1, crListAfter.size(), 'Should be 1 registration');
        System.assertEquals(null, cr1After.CourseParticipant__c, 'Should be no contact for cr1');
    }
}
