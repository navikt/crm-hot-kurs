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
            LIMIT 1000
        ];
    }

    public static Set<Id> fetchContactsToDelete(List<CourseRegistration__c> courseRegistrationsToClean) {
        Set<Id> contactsToDelete = fetchContactIds(courseRegistrationsToClean);

        Set<Id> contactsThatShouldNotBeDeleted = findContactsWithDefaultAccount(contactsToDelete);
        Set<Id> sameContactsOnSoonerCourse = checkIfSameContactsSoonerCourses(contactsToDelete);
        Set<Id> sameContactsOnLaterCourse = checkIfSameContactsLaterCourses(
            contactsToDelete,
            courseRegistrationsToClean
        );

        contactsThatShouldNotBeDeleted.addAll(sameContactsOnSoonerCourse);
        contactsThatShouldNotBeDeleted.addAll(sameContactsOnLaterCourse);
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

    @future
    public static void deleteContacts(Set<Id> contactIdsForDeletion) {
        List<Contact> contactsForDeletion = [SELECT Id FROM Contact WHERE Id IN :contactIdsForDeletion AND IsPersonAccount = false];
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
        List<AccountContactRelation> accountContactsOtherThanCourseParticipants = [
            SELECT Id, ContactId
            FROM AccountContactRelation
            WHERE ContactId IN :contactIds AND AccountId != :COURSE_ACCOUNT
        ];

        for (AccountContactRelation acr : accountContactsOtherThanCourseParticipants) {
            contactsOtherThanCourseParticipants.add(acr.ContactId);
        }
        return contactsOtherThanCourseParticipants;
    }

    public static Set<Id> checkIfSameContactsSoonerCourses(Set<Id> contactsToDelete) {
        List<CourseRegistration__c> registrationsSoonerThan12Weeks = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE CourseParticipant__c != NULL AND Course__r.RegistrationToDateTime__c > :date12WeeksInPast
        ];

        Set<Id> contactsSoonerThan12Weeks = fetchContactIds(registrationsSoonerThan12Weeks);

        Set<Id> sameContactsOnSoonerCourse = new Set<Id>();
        for (Id contactId : contactsSoonerThan12Weeks) {
            if (contactsToDelete.contains(contactId)) {
                sameContactsOnSoonerCourse.add(contactId);
            }
        }
        return sameContactsOnSoonerCourse;
    }

    public static Set<Id> checkIfSameContactsLaterCourses(
        Set<Id> contactsToDelete,
        List<CourseRegistration__c> courseRegistrationsToBeCleaned
    ) {
        List<CourseRegistration__c> registrationsLaterThan12WeeksForContactsToDelete = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE
                CourseParticipant__c IN :contactsToDelete
                AND Id NOT IN :courseRegistrationsToBeCleaned
                AND DAY_ONLY(Course__r.RegistrationToDateTime__c) <= :date12WeeksInPast
        ];

        Set<Id> contactsToDeleteOnOtherLaterCourses = new Set<Id>();
        if (registrationsLaterThan12WeeksForContactsToDelete.size() > 0) {
            for (CourseRegistration__c cr : registrationsLaterThan12WeeksForContactsToDelete) {
                contactsToDeleteOnOtherLaterCourses.add(cr.CourseParticipant__c);
            }
        }
        return contactsToDeleteOnOtherLaterCourses;
    }
}
