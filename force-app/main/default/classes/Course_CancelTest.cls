@isTest
private with sharing class Course_CancelTest {
    @TestSetup
    static void setup() {
        List<Course__c> courses = new List<Course__c>();

        for (Integer i = 0; i < 2; i++) {
            Course__c course = new Course__c();
            course.Name = 'Test ' + i;
            course.DescriptionFormatted__c = 'Testkurs';
            course.DescriptionShort__c = 'Kort beskrivelse';
            course.Region__c = 'Oslo';
            course.Active__c = true;
            course.MaxNumberOfParticipants__c = 10;

            DateTime dt = DateTime.now();
            dt = dt.addHours(4);
            course.RegistrationFromDateTime__c = datetime.now();
            course.RegistrationToDateTime__c = dt;
            Datetime st = dt.addDays(-1);
            course.RegistrationDeadline__c = st;

            courses.add(course);
        }
        insert courses;
    }

    @isTest
    private static void changeCanceledCourseTitleTest_onBeforeUpdate() {
        Course__c course = [SELECT Id, Name, Cancel__c FROM Course__c LIMIT 1];
        course.Cancel__c = true;
        update course;

        course = [SELECT Id, Name, Cancel__c FROM Course__c WHERE Id = :course.Id];
        System.assertEquals(true, course.Cancel__c);
        System.assertEquals(true, course.Name.contains('AVLYST'));
    }

    @isTest
    private static void previouslyCanceledCoursesTest_onBeforeUpdate() {
        Course__c course = [SELECT Id, Name, Cancel__c FROM Course__c LIMIT 1];
        course.Cancel__c = true;
        update course;

        course = [SELECT Id, Name, Cancel__c FROM Course__c WHERE Id = :course.Id];
        System.assertEquals(true, course.Cancel__c);
        System.assertEquals(true, course.Name.contains('AVLYST'));

        course.Cancel__c = false;
        update course;

        course = [SELECT Id, Name, Cancel__c FROM Course__c WHERE Id = :course.Id];
        System.assertEquals(false, course.Cancel__c);
        System.assertEquals(false, course.Name.contains('AVLYST'));
    }
}
