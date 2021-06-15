global class CourseRegistrationHandler extends MyTriggers {
    global override void onAfterDelete() {
        CourseRegistrationHelper.getCourseIdToReduce((List<CourseRegistration__c>) records);
    }

    global override void onAfterUndelete() {
        CourseRegistrationHelper.getCourseIdToIncrease((List<CourseRegistration__c>) records);
    }

    global override void onAfterInsert() {
        CourseRegistrationHelper.getCourseIdToIncrease((List<CourseRegistration__c>) records);
    }

    global override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        CourseRegistrationUpdateHelper.UpdateHelper(records, triggerOldMap);
    }
}
