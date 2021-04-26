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
        Id courseId;
        for (CourseRegistration__c cr : (List<CourseRegistration__c>) records) {
            if(cr.Status__c == 'Påmeldt' && 
               MyTriggers.hasChangedFields(fieldsToCheck, cr, triggerOldMap.get(cr.Id))) 
               {
                courseId = cr.Course__c;
                increaseCourseNumParticipants(courseId);
                if(triggerOldMap.get(cr.Id).get('Status__c') == 'Venteliste'){
                    courseId = cr.Course__c;
                    reduceCourseWaitinglist(courseId);
                    }
               }
            else if(MyTriggers.hasChangedFields(fieldsToCheck, cr, triggerOldMap.get(cr.Id)) &&
                    triggerOldMap.get(cr.Id).get('Status__c') == 'Påmeldt')
                    {
                     courseId = cr.Course__c;
                     reduceCourseNumParticipants(courseId);
                     if(cr.Status__c == 'Avmeldt' &&
                        checkWaitinglist(cr.Course__c) == true)
                        {
                            courseId = cr.Course__c;
                            setNextInLineToRegistered(courseId);
                        }
                     else if(cr.Status__c == 'Venteliste')
                        {
                            courseId = cr.Course__c;
                            increaseCourseWaitinglist(courseId);
                        }
                    }
            else if(MyTriggers.hasChangedFields(fieldsToCheck, cr, triggerOldMap.get(cr.Id)) &&
                    triggerOldMap.get(cr.Id).get('Status__c') == 'Venteliste')
                    {
                     courseId = cr.Course__c;
                     reduceCourseWaitinglist(courseId);
                    }
            else if(MyTriggers.hasChangedFields(fieldsToCheck, cr, triggerOldMap.get(cr.Id)) &&
                    cr.Status__c == 'Venteliste')
                    {
                        courseId = cr.Course__c;
                        increaseCourseWaitinglist(courseId);
                    }
        }
    }

    public static void getCourseIdToReduce(List<CourseRegistration__c> registrations) {
        Id courseId;
        for (CourseRegistration__c cr : registrations) {
            if(cr.Status__c == 'Påmeldt'){
                courseId = cr.Course__c;
                reduceCourseNumParticipants(courseId);
            }
            else if(cr.Status__c == 'Venteliste'){
                courseId = cr.Course__c;
                reduceCourseWaitinglist(courseId);
            }
        }
    }

    public static void reduceCourseNumParticipants(Id idToUpdate){
        Course__c course = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Id = :idToUpdate];

        Decimal participantCount = course.NumberOfParticipants__c;
        course.NumberOfParticipants__c = participantCount -1; 
        update course;
    }

    public static void getCourseIdToIncrease(List<CourseRegistration__c> registrations) {
        Id courseId;
        for (CourseRegistration__c cr : registrations) {
            if(cr.Status__c == 'Påmeldt'){
                courseId = cr.Course__c;
                increaseCourseNumParticipants(courseId);
            }
            else if(cr.Status__c == 'Venteliste'){
                    courseId = cr.Course__c;
                    increaseCourseWaitinglist(courseId);
            }
        }
    }

    public static void increaseCourseNumParticipants(Id idToUpdate){
        Course__c course = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Id = :idToUpdate];

        Decimal participantCount = course.NumberOfParticipants__c;
        course.NumberOfParticipants__c = participantCount +1; 
        update course;
    }

    public static void reduceCourseWaitinglist(Id idToUpdate){
        Course__c course = [SELECT Id, Waitinglist__c FROM Course__c WHERE Id = :idToUpdate];

        Decimal waitinglistCount = course.Waitinglist__c;
        course.Waitinglist__c = waitinglistCount -1; 
        update course;
    }

    public static void increaseCourseWaitinglist(Id idToUpdate){
        Course__c course = [SELECT Id, Waitinglist__c FROM Course__c WHERE Id = :idToUpdate];

        Decimal waitinglistCount = course.Waitinglist__c;
        course.Waitinglist__c = waitinglistCount +1; 
        update course;
    }

    public static Boolean checkWaitinglist(Id IdToCheck){
        List<CourseRegistration__c> waitingList = [SELECT Id, Status__c FROM CourseRegistration__c WHERE Course__c = :IdToCheck AND Status__c = 'Venteliste'];
        Boolean isNotEmpty;
        if(!waitingList.isEmpty()){
            isNotEmpty = true;
        }
        return isNotEmpty;
    }

    public static void setNextInLineToRegistered(Id courseId){
        List<CourseRegistration__c> waitingList = [SELECT Id, Status__c, Course__c, CreatedDate FROM CourseRegistration__c WHERE Course__c = :courseId AND Status__c = 'Venteliste' ORDER BY CreatedDate ASC LIMIT 1];
        CourseRegistration__c participant = waitingList[0];
        participant.Status__c = 'Påmeldt';
        update participant;
    }
}
