global class CourseRegistrationHandler extends MyTriggers {
    global override void onBeforeInsert() {
        CourseRegistrationHelper.validateRegistrationsAgainstCourseCapacity(
            (List<CourseRegistration__c>) records,
            null
        );
    }

    global override void onBeforeUpdate(Map<Id, sObject> triggerOldMap) {
        Map<Id, CourseRegistration__c> typedOldMap = new Map<Id, CourseRegistration__c>();
        if (triggerOldMap != null) {
            for (Id key : triggerOldMap.keySet()) {
                if (triggerOldMap.get(key) instanceof CourseRegistration__c) {
                    typedOldMap.put(key, (CourseRegistration__c) triggerOldMap.get(key));
                } else {
                    System.debug(
                        LoggingLevel.WARN,
                        'CourseRegistrationHandler.onBeforeUpdate: Encountered non-CourseRegistration__c SObject in oldMap for key: ' +
                        key
                    );
                }
            }
        }

        CourseRegistrationHelper.validateRegistrationsAgainstCourseCapacity(
            (List<CourseRegistration__c>) records,
            typedOldMap
        );
    }

    global override void onAfterDelete() {
        List<CourseRegistration__c> deletedRegistrations = (List<CourseRegistration__c>) records;
        if (deletedRegistrations != null && !deletedRegistrations.isEmpty()) {
            CourseRegistrationHelper.getCourseIdToReduce(deletedRegistrations);
        }
        Set<Id> courseIdsToCheckForPromotion = new Set<Id>();
        if (deletedRegistrations != null) {
            for (CourseRegistration__c reg : deletedRegistrations) {
                if (reg.Course__c != null) {
                    courseIdsToCheckForPromotion.add(reg.Course__c);
                }
            }
        }
        if (!courseIdsToCheckForPromotion.isEmpty()) {
            CourseRegistrationHelper.countCourseIdsToCheckWaiting(courseIdsToCheckForPromotion);
        }
    }
    global override void onAfterUndelete() {
        CourseRegistrationHelper.getCourseIdToIncrease((List<CourseRegistration__c>) records);
    }
    global override void onAfterInsert() {
        CourseRegistrationHelper.getCourseIdToIncrease((List<CourseRegistration__c>) records);
    }

    global override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        CourseRegistrationUpdateHelper.UpdateHelper((List<CourseRegistration__c>) records, triggerOldMap);
    }
}
