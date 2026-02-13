@isTest
private with sharing class HOT_CourseCalendarGeneratorTest {
    @TestSetup
    static void setup() {
        List<Course__c> courses = new List<Course__c>();

        for (Integer i = 0; i < 20; i++) {
            Course__c course = new Course__c();
            course.Name = 'Test ' + i;
            course.DescriptionFormatted__c = 'Test course';
            course.DescriptionShort__c = 'Short description for course ' + i;
            course.Region2__c = 'Oslo';
            course.Active__c = true;
            course.MaxNumberOfParticipants__c = 10;

            course.RegistrationFromDateTime__c = DateTime.now();
            course.RegistrationToDateTime__c = DateTime.now().addHours(5);
            course.RegistrationDeadline__c = DateTime.now().addDays(-1);

            if (i == 0) {
                course.Type__c = '';
            } else {
                course.Type__c = 'Informasjonsmøte';
            }

            courses.add(course);
        }
        insert courses;
    }

    @IsTest
    private static void testGenerateCalendarUrls() {
        List<Course__c> courses = [
            SELECT Id, Name, DescriptionFormatted__c, DescriptionShort__c, GoogleCalendar__c, Region2__c
            FROM Course__c
            WHERE Name = 'Test 0'
            LIMIT 1
        ];

        System.Test.startTest();
        HOT_CourseCalendarGenerator.generateCalendarUrls(courses);
        System.Test.stopTest();

        Course__c updatedCourse = [
            SELECT Id, Name, OutlookCalendar__c, OutlookOfficeCalendar__c, GoogleCalendar__c
            FROM Course__c
            WHERE Id = :courses[0].Id
            LIMIT 1
        ];

        System.assertNotEquals(null, updatedCourse.OutlookCalendar__c, 'Outlook calendar URL should be created');
        System.assertNotEquals(
            null,
            updatedCourse.OutlookOfficeCalendar__c,
            'Outlook Office calendar URL should be created'
        );
        System.assertNotEquals(null, updatedCourse.GoogleCalendar__c, 'Google calendar URL should be created');

        // Check that the URLs contain expected parameters
        String encodedName = EncodingUtil.urlEncode(courses[0].Name, 'UTF-8');
        System.assert(updatedCourse.OutlookCalendar__c.contains(encodedName), 'Outlook URL should contain course name');
        System.assert(updatedCourse.GoogleCalendar__c.contains(encodedName), 'Google URL should contain course name');
    }

    @isTest
    private static void testGenerateUrlForAllCourses() {
        List<Course__c> courses = [
            SELECT
                Id,
                Name,
                RegistrationFromDateTime__c,
                RegistrationToDateTime__c,
                Type__c,
                RegistrationPlaceName__c,
                DescriptionFormatted__c,
                DescriptionShort__c,
                GoogleCalendar__c,
                Region2__c
            FROM Course__c
            WHERE Name LIKE 'Test %'
        ];

        System.Test.startTest();
        HOT_CourseCalendarGenerator.generateCalendarUrls(courses);
        System.Test.stopTest();

        List<Course__c> updatedCourses = [
            SELECT
                Id,
                RegistrationFromDateTime__c,
                RegistrationToDateTime__c,
                Type__c,
                RegistrationPlaceName__c,
                OutlookCalendar__c,
                OutlookOfficeCalendar__c,
                GoogleCalendar__c
            FROM Course__c
            WHERE Name LIKE 'Test %'
        ];

        Integer missingUrlsCount = 0;
        for (Course__c c : updatedCourses) {
            if (c.OutlookCalendar__c == null || c.OutlookOfficeCalendar__c == null || c.GoogleCalendar__c == null) {
                missingUrlsCount++;
            }
        }

        System.assertEquals(0, missingUrlsCount, 'All courses should have calendar URLs generated.');
        System.assertEquals(courses.size(), updatedCourses.size(), 'All courses should be processed.');
    }

    @isTest
    private static void testSkipIncompleteCourseInGeneratedCalendar() {
        List<Course__c> incompleteCourses = new List<Course__c>();

        for (Integer i = 0; i < 2; i++) {
            incompleteCourses.add(
                new Course__c(
                    Name = null,
                    Type__c = 'Webinar',
                    Region2__c = 'Oslo',
                    Active__c = true,
                    MaxNumberOfParticipants__c = 20,
                    DescriptionShort__c = 'Short incomplete course ' + i,
                    RegistrationToDateTime__c = null,
                    RegistrationDeadline__c = null,
                    VideoLink__c = 'https://www.nav.no'
                )
            );
        }

        insert incompleteCourses;

        System.Test.startTest();
        HOT_CourseCalendarGenerator.generateCalendarUrls(incompleteCourses);
        System.Test.stopTest();

        List<Course__c> results = [
            SELECT Id, OutlookCalendar__c, OutlookOfficeCalendar__c, GoogleCalendar__c
            FROM Course__c
            WHERE Id IN :incompleteCourses
        ];

        Integer coursesWithUrlsCount = 0;
        for (Course__c c : results) {
            if (c.OutlookCalendar__c != null || c.OutlookOfficeCalendar__c != null || c.GoogleCalendar__c != null) {
                coursesWithUrlsCount++;
            }
        }

        System.assertEquals(incompleteCourses.size(), results.size(), 'All incomplete courses should be processed.');
        System.assertEquals(0, coursesWithUrlsCount, 'No calendar URLs should be generated for incomplete courses.');
    }

    @isTest
    private static void testGenerateCalendarCourseIdsEmpty() {
        List<Course__c> coursesWithoutIds = new List<Course__c>();
        for (Integer i = 0; i < 2; i++) {
            coursesWithoutIds.add(
                new Course__c(
                    Name = 'No ID Course ' + i,
                    Type__c = 'Konferanse',
                    Region2__c = 'Trøndelag',
                    Active__c = true,
                    MaxNumberOfParticipants__c = 25,
                    RegistrationFromDateTime__c = DateTime.now(),
                    RegistrationToDateTime__c = DateTime.now().addHours(4),
                    RegistrationDeadline__c = DateTime.now().addDays(-2)
                )
            );
        }

        System.Test.startTest();
        HOT_CourseCalendarGenerator.generateCalendarUrls(coursesWithoutIds);
        System.Test.stopTest();

        Integer existingUrlsCount = 0;
        for (Course__c c : coursesWithoutIds) {
            if (c.OutlookCalendar__c != null || c.OutlookOfficeCalendar__c != null || c.GoogleCalendar__c != null) {
                existingUrlsCount++;
            }
        }

        System.assertEquals(0, existingUrlsCount, 'No calendar URLs should be generated for courses without IDs.');
    }

    @isTest
    private static void testGenerateUrlCourseEmptyList() {
        List<Course__c> emptyCourseList = new List<Course__c>();

        System.Test.startTest();
        HOT_CourseCalendarGenerator.generateCalendarUrls(emptyCourseList);
        System.Test.stopTest();
    }
}
