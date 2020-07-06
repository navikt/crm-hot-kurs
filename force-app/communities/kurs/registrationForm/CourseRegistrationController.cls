public with sharing class CourseRegistrationController {
    public List<Course__c> getCourses(Id courseId) {
        return [SELECT Id, Name FROM Course__c WHERE Id =:courseId ];
    }

    public static List<Contact> findOrCreateContact() {
        List<Contact> contacts = [SELECT Id, Name FROM Contact];
        //finn potensiell arbeidsgiver
        return null;
    }

    public List<Account> findAccount() {
        return null;
    }

    public static Course_Registration__c createRegistration() {
        //opprett påmelding. courseId, contactId og status = påmeldt
        //sjekk om personen allerede er påmeldt ?
        return null;
    }

}
