@isTest
private without sharing class Course_AddUrlTest {
    @isTest
    private static void testAddUrlToCourse() {
        Course__c c = new Course__c(
            Name = 'Mitt kurs',
            DescriptionFormatted__c = 'test',
            MaxNumberOfParticipants__c = 10
        );

        Test.StartTest();
        insert c;
        Test.StopTest();

        List<Course__c> courses = [SELECT CommunityUrl__c FROM Course__c WHERE Id = :c.Id LIMIT 1];

        List<Domain> domains = [SELECT Domain FROM Domain WHERE Domain = 'kurs.nav.no'];
        if (domains.size() == 0) {
            domains = [SELECT Domain FROM Domain LIMIT 1];
        }

        String url = 'https://' + (domains.size() == 1 ? domains[0].Domain : 'arbeidsgiver.nav.no/kursoversikt') + '/';

        System.assertEquals(1, courses.size(), 'One course added, one returned');
        System.assertEquals(url, courses[0].CommunityUrl__c, 'should have added url');
    }
}
