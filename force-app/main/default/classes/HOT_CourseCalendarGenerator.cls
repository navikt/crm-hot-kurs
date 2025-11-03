public without sharing class HOT_CourseCalendarGenerator {

    /**
     * Generates outlook calendar URLs for a list of Course__c records.
     * Adds the generated URL to a custom field 'OutlookCalendar__c' on newly created courses.
     * 
     * Outlook url parameter -> Course__c fields used: 
     *  - subject = Type__c + Name
     *  - body = RegistrationUrl2__c added in the end of body as a link to the course
     *  - startdt = RegistrationFromDateTime__c
     *  - enddt = RegistrationToDateTime__c
     *  - location = RegistrationPlaceName__c
     * 
     * Output: 
     * - Stores the generated URL in OutlookCalendar__c field of Course__c records.
     */
    public static void generateCalendarUrlsFromRegistrations(List<CourseRegistration__c> registrations) {
     
        if (registrations == null || registrations.isEmpty()) {
            return;
        }

        Set<Id> courseIds = new Set<Id>();
        for (CourseRegistration__c reg : registrations) {
            if (reg.Course__c != null) {
                courseIds.add(reg.Course__c);
            }
        }

        if (courseIds.isEmpty()) {
            return;
        }

        List<Course__c> courses = [
            SELECT Id, Name, Type__c, RegistrationFromDateTime__c,
                RegistrationToDateTime__c, RegistrationPlaceName__c,
                RegistrationUrl2__c
            FROM Course__c
            WHERE Id IN :courseIds
        ];

        generateOutlookCalendarUrls(courses);
    }

    public static void generateOutlookCalendarUrls(List<Course__c> courses) {
        if (courses == null || courses.isEmpty()) return;

        List<Course__c> coursesToUpdate = new List<Course__c>(); 

        for (Course__c course : courses) {
            if (course.Name == null || 
                course.RegistrationFromDateTime__c == null || 
                course.RegistrationToDateTime__c == null || 
                course.RegistrationPlaceName__c == null || 
                course.RegistrationUrl2__c == null) {
                continue;
            }
        
        String subjectTitle;
        if (String.isNotBlank(course.Type__c)) {
            subjectTitle = course.Type__c + ' - ' + course.Name;
        } else {
            subjectTitle = course.Name;
        }

        String bodyText = 'Lenke til kurset: ' + course.RegistrationUrl2__c; 

        Map<String, String> params = new Map<String, String>{
            'path' => '/calendar/view/Month',
            'rru' => 'addevent',
            'subject' => subjectTitle,
            'body' => bodyText, 
            'startdt'  => formatDatetimeForOutlook(course.RegistrationFromDateTime__c),
            'enddt'    => formatDatetimeForOutlook(course.RegistrationToDateTime__c),
            'location' => course.RegistrationPlaceName__c
        };

        String baseUrl = 'https://outlook.office.com/calendar/0/deeplink/compose';
            coursesToUpdate.add(new Course__c(
                Id = course.Id,
                OutlookCalendar__c = buildOutlookCalendarUrl(baseUrl, params)
            ));

        }

        if (!coursesToUpdate.isEmpty()) {
            update coursesToUpdate;
        }
    }

    private static String buildOutlookCalendarUrl(String baseUrl, Map<String, String> params) {
        List<String> queryParts = new List<String>();
        for (String key : params.keySet()) {
            String value = params.get(key);
            if (value != null) {
                queryParts.add(key + '=' + EncodingUtil.urlEncode(value, 'UTF-8'));
            }
        }
            return baseUrl + '?' + String.join(queryParts, '&');
        }
    
    private static String formatDatetimeForOutlook(Datetime dt) {
        return dt.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
    }
}