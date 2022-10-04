public without sharing class CourseDeleteContactBatch {
    public static final Id COURSE_ACCOUNT2 = [SELECT Id FROM Account WHERE Name = 'Kontakter uten konto'].Id;
    private static final LoggerUtility logger = new LoggerUtility();
    
    public static List<Contact> courseDeleteContact(List<Contact> irrContacts) {
        
        List<Contact> contacts = [SELECT id, name from contact WHERE AccountId =: COURSE_ACCOUNT2 AND Id NOT IN (SELECT CourseParticipant__c FROM CourseRegistration__c) AND Id NOT IN (SELECT Contact__c FROM CustomOpportunity__c)];

        Set<Id> contactsMayBeDeleted = fetchContactIds(contacts);
        Set<Id> contactsThatShouldNotBeDeleted = findContactsWithOtherAccount(contactsMayBeDeleted);

        contactsMayBeDeleted.removeAll(contactsThatShouldNotBeDeleted);

        List<Contact> contactsForDeletion = [SELECT Id FROM Contact WHERE Id IN :contactsMayBeDeleted AND IsPersonAccount = false];

        return contactsForDeletion;
    }

    public static Set<Id> findContactsWithOtherAccount(Set<Id> contactIds) {
        
        Set<Id> contactsOtherThanCourseParticipants = new Set<Id>();
        List<AccountContactRelation> accountContactsOtherThanCourseParticipants = [
            SELECT Id, ContactId
            FROM AccountContactRelation
            WHERE ContactId IN :contactIds AND AccountId != :COURSE_ACCOUNT2
        ];

        for (AccountContactRelation acr : accountContactsOtherThanCourseParticipants) {
            contactsOtherThanCourseParticipants.add(acr.ContactId);
        }
        return contactsOtherThanCourseParticipants;
    }

    public static Set<Id> fetchContactIds(List<Contact> contactsToClean) {
        Set<Id> contactsFromRegistrations = new Set<Id>();
        for (Contact cr : contactsToClean) {
            contactsFromRegistrations.add(cr.Id);
        }
        return contactsFromRegistrations;
    }
}
