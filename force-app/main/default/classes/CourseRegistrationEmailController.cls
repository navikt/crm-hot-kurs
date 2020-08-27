public with sharing class CourseRegistrationEmailController {
    @AuraEnabled()
    public static void sendCourseEmail(String jsonStr) {
        List<String> emailAddresses = (List<String>) System.JSON.deserialize(jsonStr, List<String>.class);
        system.debug(jsonStr);
    }
}
