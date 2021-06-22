public with sharing class CourseScheduledDeleteContacts {
    public static void courseScheduledDeleteContacts() {
        Date date12WeeksInPast = date.today().addDays(-84);

        List<String> coursesIdsToRemoveContacts = new List<String>();
        for (Course__c course : [
            SELECT Id
            FROM Course__c
            WHERE DAY_ONLY(RegistrationToDateTime__c) = :date12WeeksInPast
        ]) {
            coursesIdsToRemoveContacts.add(course.Id);
        }
        List<CourseRegistration__c> crList12WeeksOld = fetchCourseRegistrations(coursesIdsToRemoveContacts);
        Set<Id> crContactIds12WeeksOld = fetchCrContactIds(coursesIdsToRemoveContacts);

        Set<Id> contactsOtherThanKursdeltakere = checkAccountContactRelationship(crContactIds12WeeksOld);
        Set<Id> sameContactIdsOnSoonerCourse = checkIfSameContactsSoonerCourses(
            crContactIds12WeeksOld,
            date12WeeksInPast
        );

        removePersonalDataFromCr(crList12WeeksOld);

        contactsOtherThanKursdeltakere.addAll(sameContactIdsOnSoonerCourse); //Add contacts that have relationship to other Accounts than 'Kursdeltakere' or should attend other course sooner than 12 weeks
        crContactIds12WeeksOld.removeAll(contactsOtherThanKursdeltakere); //Remove contact IDs that should not be deleted (described in line over)

        deleteContacts12WeeksOld(crContactIds12WeeksOld);
    }

    public static void deleteContacts12WeeksOld(Set<Id> contactIdsForDeletion) {
        List<Contact> contactsForDeletion = [SELECT Id FROM Contact WHERE Id IN :contactIdsForDeletion];
        if (contactsForDeletion.size() > 0) {
            delete contactsForDeletion;
        }
    }

    public static void removePersonalDataFromCr(List<CourseRegistration__c> crList12WeeksOld) {
        List<CourseRegistration__c> crListToUpdate = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : crList12WeeksOld) {
            cr.CourseParticipant__c = null;
            crListToUpdate.add(cr);
        }
        update crListToUpdate;
    }

    public static Set<Id> checkAccountContactRelationship(Set<Id> contactsIds) {
        Id courseAccount = [SELECT Id FROM Account WHERE Name = 'Kontakter uten konto'].Id;

        Set<Id> contactsOtherThanKursdeltakere = new Set<Id>();
        for (AccountContactRelation acr : [
            SELECT Id, ContactId
            FROM AccountContactRelation
            WHERE ContactId IN :contactsIds AND AccountId != :courseAccount
        ]) {
            contactsOtherThanKursdeltakere.add(acr.ContactId);
        }
        return contactsOtherThanKursdeltakere;
    }

    public static Set<Id> checkIfSameContactsSoonerCourses(Set<Id> contactsIds12WeeksOld, Date date12WeeksInPast) {
        List<String> coursesIdsSoonerThan12Weeks = new List<String>();
        for (Course__c course : [
            SELECT Id
            FROM Course__c
            WHERE DAY_ONLY(RegistrationToDateTime__c) > :date12WeeksInPast
        ]) {
            coursesIdsSoonerThan12Weeks.add(course.Id);
        }
        Set<Id> crContactIdsSoonerThan12Weeks = fetchCrContactIds(coursesIdsSoonerThan12Weeks);

        Set<Id> sameContactIdsOnSoonerCourse = new Set<Id>();
        for (Id contactId : crContactIdsSoonerThan12Weeks) {
            if (contactsIds12WeeksOld.contains(contactId)) {
                sameContactIdsOnSoonerCourse.add(contactId);
            }
        }
        return sameContactIdsOnSoonerCourse;
    }

    public static List<CourseRegistration__c> fetchCourseRegistrations(List<String> courseIds) {
        List<CourseRegistration__c> crList = new List<CourseRegistration__c>();
        for (CourseRegistration__c cr : [SELECT Id FROM CourseRegistration__c WHERE Course__c IN :courseIds]) {
            crList.add(cr);
        }
        return crList;
    }

    public static Set<Id> fetchCrContactIds(List<String> courseIds) {
        Set<Id> crContactIds = new Set<Id>();
        for (CourseRegistration__c cr : [
            SELECT Id, CourseParticipant__c
            FROM CourseRegistration__c
            WHERE Course__c IN :courseIds
        ]) {
            crContactIds.add(cr.CourseParticipant__c);
        }
        return crContactIds;
    }
}
