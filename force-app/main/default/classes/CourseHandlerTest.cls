@isTest
private with sharing class CourseHandlerTest {
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
    private static void CourseHandlerTest() {
        List<Course__c> courses = [SELECT Id FROM Course__c];
        System.assertEquals(2, courses.size(), '2 courses inserted');

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/Course';
        req.httpMethod = 'GET';

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        CourseHandler.doGet();
        Test.stopTest();
        String result = res.responseBody.toString();

        System.assertNotEquals(null, result);
        System.assert(result.contains('Test 0'));
        System.assert(result.contains('Test 1'));
        System.assert(result.contains('Oslo'));
        System.assert(result.contains('Testkurs'));
        System.assert(result.contains('1'));
    }

    @isTest
    private static void changeCanceledCourseTitle() {
        Course__c course = [SELECT Id, Name, Cancel__c FROM Course__c LIMIT 1];
        course.Cancel__c = true;
        update course;

        course = [
            SELECT Id, Name, Cancel__c
            FROM Course__c
            WHERE Id = :course.Id
        ];
        System.assertEquals(true, course.Cancel__c);
        System.assertEquals(true, course.Name.contains('AVLYST'));
    }
}
