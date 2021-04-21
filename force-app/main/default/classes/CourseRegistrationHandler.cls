global class CourseRegistrationHandler extends MyTriggers {
    global override void onAfterDelete() {
        getCourseIdToReduce((List<CourseRegistration__c>) records);
    }

    global override void onAfterUndelete() {
        getCourseIdToIncrease((List<CourseRegistration__c>) records);
    }


    public static void getCourseIdToReduce(List<CourseRegistration__c> registrations) {
        Id courseId;
        for (CourseRegistration__c cr : registrations) {
            if(cr.Status__c == 'Påmeldt'){
                courseId = cr.Course__c;
                reduceCourseNumParticipants(courseId);
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
        }
    }

    public static void increaseCourseNumParticipants(Id idToUpdate){
        Course__c course = [SELECT Id, NumberOfParticipants__c FROM Course__c WHERE Id = :idToUpdate];

        Decimal participantCount = course.NumberOfParticipants__c;
        course.NumberOfParticipants__c = participantCount +1; 
        update course;
    }
}
