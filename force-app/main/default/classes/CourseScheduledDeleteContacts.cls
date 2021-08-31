public with sharing class CourseScheduledDeleteContacts {
    private static final Date date12WeeksInPast = date.today().addDays(-84);
    public static final Id COURSE_ACCOUNT = [SELECT Id FROM Account WHERE Name = 'Kontakter uten konto'].Id;
    public static void courseScheduledDeleteContacts() {
        List<CourseRegistration__c> courseRegistrationsToClean = fetchCourseRegistrationsToClean();
        Set<Id> contactsToDelete = fetchContactsToDelete(courseRegistrationsToClean);

        removePersonalDataFromCr(courseRegistrationsToClean);

        deleteContacts(contactsToDelete);
    }

    // ---------------------------------------------------------------------------------------------- //
    // -------------------------------------------- FETCH ------------------------------------------- //
    // ---------------------------------------------------------------------------------------------- //

    public static List<CourseRegistration__c> fetchCourseRegistrationsToClean() {
        return [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE CourseParticipant__c != NULL AND DAY_ONLY(Course__r.RegistrationToDateTime__c) <= :date12WeeksInPast
        ];
    }

    public static Set<Id> fetchContactsToDelete(List<CourseRegistration__c> courseRegistrationsToClean) {
        Set<Id> contactsToDelete = fetchContactIds(courseRegistrationsToClean);

        Set<Id> contactsThatShouldNotBeDeleted = findContactsWithDefaultAccount(contactsToDelete);
        Set<Id> sameContactsOnSoonerCourse = checkIfSameContactsSoonerCourses(contactsToDelete);

        contactsThatShouldNotBeDeleted.addAll(sameContactsOnSoonerCourse);
        contactsToDelete.removeAll(contactsThatShouldNotBeDeleted);

        return contactsToDelete;
    }

    public static Set<Id> fetchContactIds(List<CourseRegistration__c> courseRegistrationsToClean) {
        Set<Id> contactsFromRegistrations = new Set<Id>();
        for (CourseRegistration__c cr : courseRegistrationsToClean) {
            contactsFromRegistrations.add(cr.CourseParticipant__c);
        }
        return contactsFromRegistrations;
    }

    // ---------------------------------------------------------------------------------------------- //
    // ---------------------------------------- DELETE/CLEAN ---------------------------------------- //
    // ---------------------------------------------------------------------------------------------- //

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

    // ---------------------------------------------------------------------------------------------- //
    // ----------------------------------------HELPER------------------------------------------------ //
    // ---------------------------------------------------------------------------------------------- //

    public static Set<Id> findContactsWithDefaultAccount(Set<Id> contactIds) {
        //Check if contacts listed for deletion are not registered as contacts for other companies than COURSE_ACCOUNT

        Set<Id> contactsOtherThanCourseParticipants = new Set<Id>();
        for (AccountContactRelation acr : [
            SELECT Id, ContactId
            FROM AccountContactRelation
            WHERE ContactId IN :contactIds AND AccountId != :COURSE_ACCOUNT
        ]) {
            contactsOtherThanCourseParticipants.add(acr.ContactId);
        }
        return contactsOtherThanCourseParticipants;
    }

    public static Set<Id> checkIfSameContactsSoonerCourses(Set<Id> contactsToDelete) {
        List<CourseRegistration__c> registrationsSoonerThan12Weeks = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE CourseParticipant__c != NULL AND DAY_ONLY(Course__r.RegistrationToDateTime__c) > :date12WeeksInPast
        ]) {
            registrationsSoonerThan12Weeks.add(cr);
        }

        Set<Id> contactsSoonerThan12Weeks = fetchContactIds(registrationsSoonerThan12Weeks);

        Set<Id> sameContactsOnSoonerCourse = new Set<Id>();
        for (Id contactId : contactsSoonerThan12Weeks) {
            if (contactsToDelete.contains(contactId)) {
                sameContactsOnSoonerCourse.add(contactId);
            }
        }
        return sameContactsOnSoonerCourse;
    }
}
