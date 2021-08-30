public with sharing class CourseScheduledDeleteContacts {
    private static final Date date12WeeksInPast = date.today().addDays(-84);
    public static void courseScheduledDeleteContacts() {
        List<CourseRegistration__c> courseRegistrationsToClean = fetchCourseRegistrationsToClean();
        Set<Id> contactsToDelete = fetchContactsToDelete(courseRegistrationsToClean);

        removePersonalDataFromCr(courseRegistrationsToClean);

        deleteContacts(contactsToDelete);
    }

    public static void deleteContacts(Set<Id> contactIdsForDeletion) {
        List<Contact> contactsForDeletion = [SELECT Id FROM Contact WHERE Id IN :contactIdsForDeletion];
        if (contactsForDeletion.size() > 0) {
            delete contactsForDeletion;
        }
    }

    public static void removePersonalDataFromCr(List<CourseRegistration__c> courseRegistrationsToClean) {
        List<CourseRegistration__c> crListToUpdate = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : courseRegistrationsToClean) {
            cr.CourseParticipant__c = null;
            crListToUpdate.add(cr);
        }
        update crListToUpdate;
    }

    public static Set<Id> checkAccountContactRelationship(Set<Id> contactIds) {
        Id courseAccount = [SELECT Id FROM Account WHERE Name = 'Kontakter uten konto'].Id;

        Set<Id> contactsOtherThanCourseParticipants = new Set<Id>();
        for (AccountContactRelation acr : [
            SELECT Id, ContactId
            FROM AccountContactRelation
            WHERE ContactId IN :contactIds AND AccountId != :courseAccount
        ]) {
            contactsOtherThanCourseParticipants.add(acr.ContactId);
        }
        return contactsOtherThanCourseParticipants;
    }

    public static Set<Id> checkIfSameContactsSoonerCourses(Set<Id> contactsToDelete) {
        
        List<CourseRegistration__c> registrationsSoonerThan12Weeks = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id, CourseParticipant__c FROM CourseRegistration__c WHERE CourseParticipant__c != null AND DAY_ONLY(Course__r.RegistrationToDateTime__c) > :date12WeeksInPast]) {
            registrationsSoonerThan12Weeks.add(cr);
        }

        Set<Id> contactsSoonerThan12Weeks = fetchContacts(registrationsSoonerThan12Weeks);

        Set<Id> sameContactsOnSoonerCourse = new Set<Id>();
        for (Id contactId : contactsSoonerThan12Weeks) {
            if (contactsToDelete.contains(contactId)) {
                sameContactsOnSoonerCourse.add(contactId);
            }
        }
        return sameContactsOnSoonerCourse;
    }

    public static List<CourseRegistration__c> fetchCourseRegistrationsToClean() {
        List<CourseRegistration__c> registrationsToClean = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id, CourseParticipant__c FROM CourseRegistration__c WHERE CourseParticipant__c != null AND DAY_ONLY(Course__r.RegistrationToDateTime__c) <= :date12WeeksInPast]) {
            registrationsToClean.add(cr);
        }
        return registrationsToClean;
    }

    public static Set<Id> fetchContactsToDelete(List<CourseRegistration__c> courseRegistrationsToClean) {
        Set<Id> contactsToDelete = fetchContacts(courseRegistrationsToClean);

        Set<Id> contactsThatShouldNotBeDeleted = checkAccountContactRelationship(contactsToDelete);
        Set<Id> sameContactsOnSoonerCourse = checkIfSameContactsSoonerCourses(
            contactsToDelete
        );

        contactsThatShouldNotBeDeleted.addAll(sameContactsOnSoonerCourse);
        contactsToDelete.removeAll(contactsThatShouldNotBeDeleted);

        return contactsToDelete;

    }

    public static Set<Id> fetchContacts(List<CourseRegistration__c> courseRegistrationsToClean) {
        Set<Id> contactsFromRegistrations = new Set<Id>();
        for (CourseRegistration__c cr : courseRegistrationsToClean) {
            contactsFromRegistrations.add(cr.CourseParticipant__c);
        }
        return contactsFromRegistrations;
    }
}
