public class CourseRegistrationUpdateHelper {
    public static void updateHelper(List<CourseRegistration__c> newRecords, Map<Id, sObject> triggerOldMap) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }

        Map<Id, CourseRegistration__c> oldMap = triggerOldMap == null
            ? new Map<Id, CourseRegistration__c>()
            : new Map<Id, CourseRegistration__c>((List<CourseRegistration__c>) triggerOldMap.values());

        Set<Id> coursesToCheckWaitlist = new Set<Id>();

        for (CourseRegistration__c newCr : newRecords) {
            if (newCr == null) {
                continue;
            }

            CourseRegistration__c oldCr = oldMap.get(newCr.Id);
            if (oldCr == null) {
                continue;
            }

            Boolean oldWasAttending = oldCr.Status__c == 'Påmeldt';
            Boolean newIsAttending = newCr.Status__c == 'Påmeldt';

            if (oldWasAttending && !newIsAttending && oldCr.Course__c != null) {
                coursesToCheckWaitlist.add(oldCr.Course__c);
                continue;
            }

            if (!oldWasAttending || !newIsAttending) {
                continue;
            }

            Id oldCourseId = oldCr.Course__c;
            if (oldCourseId == null) {
                continue;
            }

            if (newCr.Course__c != null && newCr.Course__c != oldCourseId) {
                coursesToCheckWaitlist.add(oldCourseId);
                continue;
            }

            Integer oldParticipants = oldCr.NumberOfParticipants__c == null || oldCr.NumberOfParticipants__c < 1
                ? 1
                : oldCr.NumberOfParticipants__c.intValue();
            Integer newParticipants = newCr.NumberOfParticipants__c == null || newCr.NumberOfParticipants__c < 1
                ? 1
                : newCr.NumberOfParticipants__c.intValue();

            if (newParticipants < oldParticipants) {
                coursesToCheckWaitlist.add(oldCourseId);
            }
        }

        if (!coursesToCheckWaitlist.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToCheckWaiting(coursesToCheckWaitlist);
        }
    }
}
