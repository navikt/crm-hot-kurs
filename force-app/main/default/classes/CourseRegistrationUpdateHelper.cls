public class CourseRegistrationUpdateHelper {
    public static void updateHelper(List<CourseRegistration__c> newRecords, Map<Id, sObject> triggerOldMap) {
        Map<Id, CourseRegistration__c> oldMap = triggerOldMap == null
            ? new Map<Id, CourseRegistration__c>()
            : new Map<Id, CourseRegistration__c>((List<CourseRegistration__c>) triggerOldMap.values());

        List<CourseRegistration__c> crsToRemoveOldContribution = new List<CourseRegistration__c>();
        List<CourseRegistration__c> crsToAddNewContribution = new List<CourseRegistration__c>();

        Set<Id> coursesToCheckWaitlist = new Set<Id>();

        for (CourseRegistration__c newCr : newRecords) {
            CourseRegistration__c oldCr = oldMap.get(newCr.Id);

            boolean relevantChangeOccurred = false;
            if (newCr.Status__c != oldCr.Status__c) {
                relevantChangeOccurred = true;
            }
            if (
                (newCr.Status__c == 'Påmeldt' ||
                newCr.Status__c == 'Venteliste' ||
                oldCr.Status__c == 'Påmeldt' ||
                oldCr.Status__c == 'Venteliste') && (newCr.NumberOfParticipants__c != oldCr.NumberOfParticipants__c)
            ) {
                relevantChangeOccurred = true;
            }

            if (!relevantChangeOccurred) {
                continue; // Skip if no relevant fields changed
            }

            if (oldCr.Status__c == 'Påmeldt' || oldCr.Status__c == 'Venteliste') {
                crsToRemoveOldContribution.add(oldCr);
            }

            if (newCr.Status__c == 'Påmeldt' || newCr.Status__c == 'Venteliste') {
                crsToAddNewContribution.add(newCr);
            }

            if (oldCr.Status__c == 'Påmeldt' && newCr.Status__c != 'Påmeldt') {
                coursesToCheckWaitlist.add(oldCr.Course__c); // Course ID from old record (should be same as new)
            } else if (
                oldCr.Status__c == 'Påmeldt' &&
                newCr.Status__c == 'Påmeldt' &&
                newCr.NumberOfParticipants__c != null &&
                oldCr.NumberOfParticipants__c != null &&
                newCr.NumberOfParticipants__c < oldCr.NumberOfParticipants__c
            ) {
                // Participants decreased while still attending
                coursesToCheckWaitlist.add(oldCr.Course__c);
            }
        }

        if (!crsToRemoveOldContribution.isEmpty()) {
            CourseRegistrationHelper.getCourseIdToReduce(crsToRemoveOldContribution);
        }

        if (!crsToAddNewContribution.isEmpty()) {
            CourseRegistrationHelper.getCourseIdToIncrease(crsToAddNewContribution);
        }

        if (!coursesToCheckWaitlist.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToCheckWaiting(coursesToCheckWaitlist);
        }
    }
}
