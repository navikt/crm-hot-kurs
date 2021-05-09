global class CourseRegistrationHandler extends MyTriggers {
    global override void onAfterDelete() {
        getCourseIdToReduce((List<CourseRegistration__c>) records);
    }

    global override void onAfterUndelete() {
        getCourseIdToIncrease((List<CourseRegistration__c>) records);
    }

    global override void onAfterInsert() {
        getCourseIdToIncrease((List<CourseRegistration__c>) records);
    }

    global override void onAfterUpdate(Map<Id, sObject> triggerOldMap) {
        List<String> fieldsToCheck = new List<String>{'Status__c'};
        List<String> coursesReduceAttending = new List<String>();
        List<String> coursesReduceWaiting = new List<String>();
        List<String> coursesIncreaseAttending = new List<String>();
        List<String> coursesIncreaseWaiting = new List<String>();
        List<String> coursesToUpdateWaitingRegs = new List<String>();

        for (CourseRegistration__c cr : (List<CourseRegistration__c>) records) {
            Boolean statusIsUpdated = MyTriggers.hasChangedFields(fieldsToCheck, cr, triggerOldMap.get(cr.Id));

            if(!statusIsUpdated) continue;

            CourseRegistration__c oldCr = (CourseRegistration__c) triggerOldMap.get(cr.Id);
            Boolean newIsAttending = cr.Status__c == 'Påmeldt';
            Boolean newIsNotAttending = cr.Status__c == 'Avmeldt';
            Boolean newIsWaitListed = cr.Status__c == 'Venteliste';
            Boolean oldIsAttending = oldCr.Status__c == 'Påmeldt';
            Boolean oldIsNotAttending = oldCr.Status__c == 'Avmeldt';
            Boolean oldIsWaitListed = oldCr.Status__c == 'Venteliste';

            if(newIsAttending) {
                coursesIncreaseAttending.add(cr.Course__c);
                if(oldIsWaitListed) {
                    coursesReduceWaiting.add(cr.Course__c);
                }
            }
            else if(oldIsAttending) {
                coursesReduceAttending.add(cr.Course__c);
                if(newIsNotAttending){
                    coursesToUpdateWaitingRegs.add(cr.Course__c);
                }
                else if(newIsWaitListed) {
                    coursesIncreaseWaiting.add(cr.Course__c);
                }
            }
            else if(oldIsWaitListed) {
                coursesReduceWaiting.add(cr.Course__c);
                }
            else if(newIsWaitListed) {
                coursesIncreaseWaiting.add(cr.Course__c);
                }
        }
        if(!coursesReduceAttending.isEmpty()){
            countCourseIdsToReduceAttending(coursesReduceAttending);
        }
        if(!coursesReduceWaiting.isEmpty()){
            countCourseIdsToReduceWaiting(coursesReduceWaiting);
        }
        if(!coursesIncreaseAttending.isEmpty()){
            countCourseIdsToIncreaseAttending(coursesIncreaseAttending);
        }
        if(!coursesIncreaseWaiting.isEmpty()){
            countCourseIdsToIncreaseWaiting(coursesIncreaseWaiting);
        }
        if(!coursesToUpdateWaitingRegs.isEmpty()){
            countCourseIdsToCheckWaiting(coursesToUpdateWaitingRegs);
        }
    }

    public static void getCourseIdToReduce(List<CourseRegistration__c> registrations) {
        List<String> coursesReduceAttending = new List<String>();
        List<String> coursesReduceWaiting = new List<String>();

        for (CourseRegistration__c cr : registrations) {
            Boolean reducedAttending = cr.Status__c == 'Påmeldt';
            Boolean reducedWaiting = cr.Status__c == 'Venteliste';

            if(reducedAttending){
                coursesReduceAttending.add(cr.Course__c);
            }
            else if(reducedWaiting){
                coursesReduceWaiting.add(cr.Course__c);
            }
        }
        if(!coursesReduceAttending.isEmpty()){
            countCourseIdsToReduceAttending(coursesReduceAttending);
        }    
        if(!coursesReduceWaiting.isEmpty()){
            countCourseIdsToReduceWaiting(coursesReduceWaiting);
        }
    }

    public static void getCourseIdToIncrease(List<CourseRegistration__c> registrations) {

        List<String> coursesIncreaseAttending = new List<String>();
        List<String> coursesIncreaseWaiting = new List<String>();

        for (CourseRegistration__c cr : registrations) {
            Boolean increasedAttending = cr.Status__c == 'Påmeldt';
            Boolean increasedWaiting = cr.Status__c == 'Venteliste';
            if(increasedAttending){
                coursesIncreaseAttending.add(cr.Course__c);
            }
            else if(increasedWaiting){
                coursesIncreaseWaiting.add(cr.Course__c);
            }
        }   
        if(!coursesIncreaseAttending.isEmpty()){
            countCourseIdsToIncreaseAttending(coursesIncreaseAttending);
        }
        if(!coursesIncreaseWaiting.isEmpty()){
            countCourseIdsToIncreaseWaiting(coursesIncreaseWaiting);
        }
    }

    public static void updateCoursesParticipants(Map<String,Integer> coursesCount){
        List<Course__c> coursesToUpdate = new List<Course__c>();
        for(Course__c course : [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Id IN :coursesCount.keyset()]) {
            course.NumberOfParticipants__c = course.NumberOfParticipants__c + coursesCount.get(course.Id);
            coursesToUpdate.add(course);
        }
        update coursesToUpdate;
    }

    public static void updateCourseWaiting(Map<String,Integer> coursesCountWait){
        List<Course__c> coursesToUpdateWait = new List<Course__c>();
        for(Course__c course : [SELECT Id, Waitinglist__c FROM Course__c WHERE Id IN :coursesCountWait.keyset()]) {
            course.Waitinglist__c = course.Waitinglist__c + coursesCountWait.get(course.Id);
            coursesToUpdateWait.add(course);
        }
        update coursesToUpdateWait;
    }

    public static void countCourseIdsToReduceAttending(List<String> reduceAttending) {
        Map<String,Integer> reduceCountIds = new Map<String,Integer>();
        for(String id : reduceAttending) {
            if(!reduceCountIds.containsKey(id)) {
                reduceCountIds.put(id,0);
            }
            Integer currentCountAtt = reduceCountIds.get(id)-1;
            reduceCountIds.put(id,currentCountAtt);
        }
        updateCoursesParticipants(reduceCountIds);
    }

    public static void countCourseIdsToReduceWaiting(List<String> reduceWaiting) {
        Map<String,Integer> reduceWaitCountIds = new Map<String,Integer>();
        for(String id : reduceWaiting) {
            if(!reduceWaitCountIds.containsKey(id)) {
                reduceWaitCountIds.put(id,0);
            }
            Integer currentCountWait = reduceWaitCountIds.get(id)-1;
            reduceWaitCountIds.put(id,currentCountWait);
        }
        updateCourseWaiting(reduceWaitCountIds);
    }

    public static void countCourseIdsToIncreaseAttending(List<String> increaseAttending) {
        Map<String,Integer> increaseCountIds = new Map<String,Integer>();
        for(String id : increaseAttending) {
            if(!increaseCountIds.containsKey(id)) {
                increaseCountIds.put(id,0);
            }
            Integer currentCountAtt = increaseCountIds.get(id)+1;
            increaseCountIds.put(id,currentCountAtt);
        }
        updateCoursesParticipants(increaseCountIds);
    }

    public static void countCourseIdsToIncreaseWaiting(List<String> increaseWaiting) {
        Map<String,Integer> increaseWaitCountIds = new Map<String,Integer>();
        for(String id : increaseWaiting) {
            if(!increaseWaitCountIds.containsKey(id)) {
                increaseWaitCountIds.put(id,0);
            }
            Integer currentCountWait = increaseWaitCountIds.get(id)+1;
            increaseWaitCountIds.put(id,currentCountWait);
        }
        updateCourseWaiting(increaseWaitCountIds);
    }

    public static void countCourseIdsToCheckWaiting(List<String> updateWaiting) {
        Map<String,Integer> updateWaitCountIds = new Map<String,Integer>();
        for(String id : updateWaiting) {
            if(!updateWaitCountIds.containsKey(id)) {
                updateWaitCountIds.put(id,0);
            }
            Integer currentCountWait = updateWaitCountIds.get(id)+1;
            updateWaitCountIds.put(id,currentCountWait);
        }
        checkAndUpdateWaitingList(updateWaitCountIds);
    }

    public static void checkAndUpdateWaitingList(Map<String,Integer> checkUpdateWaiting) {
        List<CourseRegistration__c> crToUpdateWait = new List<CourseRegistration__c>();
        for(Course__c course : [SELECT Id, Waitinglist__c FROM Course__c WHERE Id IN :checkUpdateWaiting.keyset()]) {
            String courseId = course.Id;
            Integer crIds = checkUpdateWaiting.get(course.Id);
            Integer courseWaiting = integer.valueof(course.Waitinglist__c);
            if(courseWaiting > 0 && courseWaiting < crIds) {
                for(CourseRegistration__c cr : [SELECT Id, Status__c, Course__c, CreatedDate FROM CourseRegistration__c WHERE Course__c = :courseId AND Status__c = 'Venteliste' ORDER BY CreatedDate ASC LIMIT :courseWaiting]) {
                    cr.Status__c = 'Påmeldt';
                    crToUpdateWait.add(cr);
                }
            }
            if(courseWaiting >= crIds){
                for(CourseRegistration__c cr : [SELECT Id, Status__c, Course__c, CreatedDate FROM CourseRegistration__c WHERE Course__c = :courseId AND Status__c = 'Venteliste' ORDER BY CreatedDate ASC LIMIT :crIds]) {
                    cr.Status__c = 'Påmeldt';
                    crToUpdateWait.add(cr);
                }
            }
        }
        update crToUpdateWait;
    }
}
