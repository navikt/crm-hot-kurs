@isTest
private with sharing class HOT_CourseCalendarGeneratorTest {
    @TestSetup 
    static void setup() {
        List<Course__c> courses = new List<Course__c>();

        for (Integer i = 0; i < 3; i++) {
            Course__c course = new Course__c();
            course.Name = 'Test ' + i;
            course.DescriptionFormatted__c = 'Testkurs';
            course.DescriptionShort__c = 'Short description for course ' + i;
            course.Region2__c = 'Oslo';
            course.Active__c = true;
            course.MaxNumberOfParticipants__c = 10;

            course.RegistrationFromDateTime__c = DateTime.now();
            course.RegistrationToDateTime__c = DateTime.now().addHours(5);
            course.RegistrationDeadline__c = DateTime.now().addDays(-1);

            courses.add(course);
        }
        insert courses;
    }
    
    @IsTest
    private static void testGenerateCalendarUrls() {
        
        Course__c course = [SELECT Id, Name, DescriptionFormatted__c, DescriptionShort__c, GoogleCalendar__c, Region2__c 
        FROM Course__c 
        WHERE Name = 'Test 0' 
        LIMIT 1];
        
        List<Course__c> courses = new List<Course__c>{course};

        System.Test.startTest();
        HOT_CourseCalendarGenerator.generateCalendarUrls(courses);
        System.Test.stopTest();

        Course__c updatedCourse = [
            SELECT Id, Name, OutlookCalendar__c, OutlookOfficeCalendar__c, GoogleCalendar__c
            FROM Course__c
            WHERE Id = :course.Id
            LIMIT 1
        ];

        System.assertNotEquals(null, updatedCourse.OutlookCalendar__c, 'Outlook calendar URL should be created');
        System.assertNotEquals(null, updatedCourse.OutlookOfficeCalendar__c, 'Outlook Office calendar URL should be created');
        System.assertNotEquals(null, updatedCourse.GoogleCalendar__c, 'Google calendar URL should be created');

        // Check that the URLs contain expected parameters
        String encodedName = EncodingUtil.urlEncode(course.Name, 'UTF-8');
        System.assert(updatedCourse.OutlookCalendar__c.contains(encodedName), 'Outlook URL should contain course name');
        System.assert(updatedCourse.GoogleCalendar__c.contains(encodedName), 'Google URL should contain course name');
    }

    @isTest
    private static void testEmptyCourseList() {
        List<Course__c> notSavedCourse = new List<Course__c>();
         for (Integer i = 0; i < 2; i++) {
            notSavedCourse.add(new Course__c(
            Name = 'Empty course ' + i,
            DescriptionFormatted__c = 'Unsaved test course',
            Region2__c = 'Oslo',
            Active__c = true,
            MaxNumberOfParticipants__c = 5,
            RegistrationFromDateTime__c = DateTime.now(),
            RegistrationToDateTime__c = DateTime.now().addHours(2),
            RegistrationDeadline__c = DateTime.now().addDays(-1)
            ));
        }
        
        System.Test.startTest();
        HOT_CourseCalendarGenerator.generateCalendarUrls(notSavedCourse);
        System.Test.stopTest();

        List<Course__c> updatedCourses = [
            SELECT Id, DescriptionFormatted__c, OutlookCalendar__c, GoogleCalendar__c
            FROM Course__c WHERE Name LIKE 'Empty course'
        ];

        Integer updatedCoursesCount = 0;
        for (Course__c c : updatedCourses) {
            if (c.OutlookCalendar__c != null || c.GoogleCalendar__c != null) {
            updatedCoursesCount++;
            }
        }

        System.assertEquals(0, updatedCoursesCount, 'No calendar URLs should be generated for empty course list.');
    }

    // @isTest 
    // private static void testGeneratedCalenderNoTypeData() {

    // }
}