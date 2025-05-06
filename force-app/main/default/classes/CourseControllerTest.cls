@isTest
private class CourseControllerTest {
    @isTest
    static void testIsCourseActive_true() {
        Course__c activeCourse = new Course__c(
            Name = 'Active Course',
            Active__c = true,
            MaxNumberOfParticipants__c = 100
        );
        insert activeCourse;
        System.assertNotEquals(null, activeCourse.Id, 'Inserted course should have an ID');
        Test.startTest();
        Boolean result = CourseController.isCourseActive(activeCourse.Id);
        Test.stopTest();
        System.assertEquals(true, result, 'Expected active course to return true');
    }
    @isTest
    static void testIsCourseActive_false() {
        Course__c inactiveCourse = new Course__c(
            Name = 'Inactive Course',
            Active__c = false,
            MaxNumberOfParticipants__c = 100
        );
        insert inactiveCourse;
        System.assertNotEquals(null, inactiveCourse.Id, 'Inserted course should have an ID');
        Test.startTest();
        Boolean result = CourseController.isCourseActive(inactiveCourse.Id);
        Test.stopTest();
        System.assertEquals(false, result, 'Expected inactive course to return false');
    }
}
