public without sharing class CourseScheduledDeleteContacts {
    public static final Id COURSE_ACCOUNT = [SELECT Id FROM Account WHERE Name = 'Kontakter uten konto'].Id;
    private static final Date date12WeeksInPast = date.today().addDays(-84);
    private static final LoggerUtility logger = new LoggerUtility();

    public static void courseScheduledDeleteContacts() {
        List<CourseRegistration__c> courseRegistrationsToClean = fetchCourseRegistrationsToClean();
        Set<Id> contactsToDelete = fetchContactsToDelete(courseRegistrationsToClean);
        Set<Id> emailMessagesToDelete = fetchEmaiMessagesToDelete(courseRegistrationsToClean);

        removePersonalDataFromCr(courseRegistrationsToClean);
        deleteContacts(contactsToDelete);
        deleteEmailMessages(emailMessagesToDelete);
    }

    // ---------------------------------------------------------------------------------------------- //
    // -------------------------------------------- FETCH ------------------------------------------- //
    // ---------------------------------------------------------------------------------------------- //

    public static List<CourseRegistration__c> fetchCourseRegistrationsToClean() {
        List<CourseRegistration__c> courseRegistrationsToClean = [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE CourseParticipant__c != NULL AND DAY_ONLY(Course__r.RegistrationToDateTime__c) <= :date12WeeksInPast
            LIMIT 1000
        ];

        return courseRegistrationsToClean;
    }

    public static Set<Id> fetchContactsToDelete(List<CourseRegistration__c> courseRegistrationsToClean) {
        Set<Id> contactIdsToDelete = fetchContactIds(courseRegistrationsToClean);

        Set<Id> contactsThatShouldNotBeDeleted = findContactsWithDefaultAccount(contactIdsToDelete);
        Set<Id> sameContactsOnSoonerCourse = checkIfSameContactsSoonerCourses(contactIdsToDelete);
        Set<Id> sameContactsOnLaterCourse = checkIfSameContactsLaterCourses(
            contactIdsToDelete,
            courseRegistrationsToClean
        );

        contactsThatShouldNotBeDeleted.addAll(sameContactsOnSoonerCourse);
        contactsThatShouldNotBeDeleted.addAll(sameContactsOnLaterCourse);
        contactIdsToDelete.removeAll(contactsThatShouldNotBeDeleted);

        return contactIdsToDelete;
    }
    public static Set<Id> fetchEmaiMessagesToDelete(List<CourseRegistration__c> courseRegistrations) {
        Set<Id> emailMessagesId = new Set<Id>();
        List<EmailMessage> emailMessages = [SELECT Id FROM EmailMessage WHERE RelatedToId IN :courseRegistrations];
        for (EmailMessage emailMessage : emailMessages) {
            emailMessagesId.add(emailMessage.Id);
        }
        return emailMessagesId;
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
        List<Contact> contactsForDeletion = [
            SELECT Id
            FROM Contact
            WHERE Id IN :contactIdsForDeletion AND IsPersonAccount = FALSE
        ];

        try {
            delete contactsForDeletion;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, recordToDelete, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }
    @future
    public static void deleteEmailMessages(Set<Id> emailMessagesIdsForDeletion) {
        List<EmailMessage> emailMessagesForDeletion = [
            SELECT Id
            FROM EmailMessage
            WHERE Id IN :emailMessagesIdsForDeletion
        ];

        try {
            delete emailMessagesForDeletion;
        } catch (Exception e) {
            LoggerUtility logger = new LoggerUtility();
            logger.exception(e, recordToDelete, CRM_ApplicationDomain.Domain.HOT);
            logger.publishSynch();
        }
    }

    public static void removePersonalDataFromCr(List<CourseRegistration__c> courseRegistrationsToClean) {
        List<CourseRegistration__c> crListToUpdate = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : courseRegistrationsToClean) {
            cr.CourseParticipant__c = null;
            cr.AdditionalInformation__c = null;
            cr.Allergies__c = null;

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
            WHERE CourseParticipant__c != NULL AND DAY_ONLY(Course__r.RegistrationToDateTime__c) > :date12WeeksInPast
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
