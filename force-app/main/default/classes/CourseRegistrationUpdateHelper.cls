public class CourseRegistrationUpdateHelper {
    public static void UpdateHelper(List<CourseRegistration__c> records, Map<Id, sObject> triggerOldMap) {
        List<String> fieldsToCheck = new List<String>{ 'Status__c' };
        List<String> coursesReduceAttending = new List<String>();
        List<String> coursesReduceWaiting = new List<String>();
        List<String> coursesIncreaseAttending = new List<String>();
        List<String> coursesIncreaseWaiting = new List<String>();
        List<String> coursesToUpdateWaitingRegs = new List<String>();

        for (CourseRegistration__c cr : (List<CourseRegistration__c>) records) {
            Boolean statusIsUpdated = MyTriggers.hasChangedFields(fieldsToCheck, cr, triggerOldMap.get(cr.Id));

            if (!statusIsUpdated)
                continue;

            CourseRegistration__c oldCr = (CourseRegistration__c) triggerOldMap.get(cr.Id);
            Boolean newIsAttending = cr.Status__c == 'Påmeldt';
            Boolean newIsNotAttending = cr.Status__c == 'Avmeldt';
            Boolean newIsWaitListed = cr.Status__c == 'Venteliste';
            Boolean oldIsAttending = oldCr.Status__c == 'Påmeldt';
            Boolean oldIsNotAttending = oldCr.Status__c == 'Avmeldt';
            Boolean oldIsWaitListed = oldCr.Status__c == 'Venteliste';

            if (newIsAttending) {
                coursesIncreaseAttending.add(cr.Course__c);
                if (oldIsWaitListed) {
                    coursesReduceWaiting.add(cr.Course__c);
                }
            } else if (oldIsAttending) {
                coursesReduceAttending.add(cr.Course__c);
                if (newIsNotAttending) {
                    coursesToUpdateWaitingRegs.add(cr.Course__c);
                } else if (newIsWaitListed) {
                    coursesIncreaseWaiting.add(cr.Course__c);
                }
            } else if (oldIsWaitListed) {
                coursesReduceWaiting.add(cr.Course__c);
            } else if (newIsWaitListed) {
                coursesIncreaseWaiting.add(cr.Course__c);
            }
        }
        if (!coursesReduceAttending.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToReduceAttending(coursesReduceAttending);
        }
        if (!coursesReduceWaiting.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToReduceWaiting(coursesReduceWaiting);
        }
        if (!coursesIncreaseAttending.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToIncreaseAttending(coursesIncreaseAttending);
        }
        if (!coursesIncreaseWaiting.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToIncreaseWaiting(coursesIncreaseWaiting);
        }
        if (!coursesToUpdateWaitingRegs.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToCheckWaiting(coursesToUpdateWaitingRegs);
        }
    }
}
