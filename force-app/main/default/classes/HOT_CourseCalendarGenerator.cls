public without sharing class HOT_CourseCalendarGenerator {

    /**
     * Generates dynamic calendar event URLs (Outlook live, outlook office and Google) for created Course__c records.
     * 
     * Outlook url parameter -> Course__c fields used: 
     *  - subject = Type__c + Name
     *  - body = Name + link to course record
     *  - startdt = RegistrationFromDateTime__c
     *  - enddt = RegistrationToDateTime__c
     *  - location = RegistrationPlaceName__c
     * 
     * Google url parameter 
     *  - text = Type__c + Name
     *  - details = Name + link to course record
     *  - dates = RegistrationFromDateTime__c '/' RegistrationToDateTime__c
     *  - location = RegistrationPlaceName__c
     * 
     * Output: 
     *  - URLs are stored in OutlookCalendar__c, OutlookOfficeCalendar__c and GoogleCalendar__c fields.
     */
    public static void generateCalendarUrls(List<Course__c> courseList) {
     
        if (courseList == null || courseList.isEmpty()) {
            return;
        }

        Set<Id> courseIds = new Set<Id>();
        for (Course__c course : courseList) {
            if (course.Id != null) {
                courseIds.add(course.Id);
            }
        }

        if (courseIds.isEmpty()) {
            return;
        }

        List<Course__c> courses = [
            SELECT Id, Name, Type__c, RegistrationFromDateTime__c,
                RegistrationToDateTime__c, RegistrationPlaceName__c
            FROM Course__c
            WHERE Id IN :courseIds
        ];

        buildValidCalendarUrls(courses);
    }

    public static void buildValidCalendarUrls(List<Course__c> courses) {
        if (courses == null || courses.isEmpty()) return;

        List<Course__c> coursesToUpdate = new List<Course__c>(); 

        for (Course__c course : courses) {
            if (course.Id == null || course.Name == null || 
                course.RegistrationFromDateTime__c == null || 
                course.RegistrationToDateTime__c == null) {
                continue;
            }
        
            String courseUrl = 'https://arbeidsgiver.nav.no/kursoversikt/' + course.Id;
            String outlookOfficeUrl = 'https://outlook.office.com/calendar/0/deeplink/compose';
            String outlookPrivateUrl = 'https://outlook.live.com/calendar/0/deeplink/compose';
            String googleBaseUrl = 'https://calendar.google.com/calendar/render';

            String bodyText = 'Lenke til kurset:<br/>' + '<a href="' + 
                courseUrl + '" target="_blank">' + course.Name + '</a>';

            String subjectTitle = String.isNotBlank(course.Type__c) 
                    ? course.Type__c + ' - ' + course.Name 
                    : course.Name;

            // Assign parameters for Outlook link
            Map<String, String> params = new Map<String, String>{
                'path' => '/calendar/view/Month',
                'rru' => 'addevent',
                'subject' => subjectTitle,
                'body' => bodyText, 
                'startdt'  => formatDatetimeForOutlook(course.RegistrationFromDateTime__c),
                'enddt'    => formatDatetimeForOutlook(course.RegistrationToDateTime__c),
                'location' => course.RegistrationPlaceName__c
            };

            // Assign parameters for Google link
            Map<String, String> googleParams = new Map<String, String>{
                'action' => 'TEMPLATE',
                'text' => subjectTitle,
                'details' => bodyText,
                'location' => course.RegistrationPlaceName__c,
                'dates' => formatDatetimeForGoogle(course.RegistrationFromDateTime__c, course.RegistrationToDateTime__c)
            };

            // Generate calendar url 
            String outlookOfficeLink = buildCalendarUrl(outlookOfficeUrl, params);
            String outlookPrivateLink = buildCalendarUrl(outlookPrivateUrl, params);
            String googleLink = buildCalendarUrl(googleBaseUrl, googleParams);


            coursesToUpdate.add(new Course__c(
                    Id = course.Id,
                    OutlookOfficeCalendar__c = outlookOfficeLink,
                    OutlookCalendar__c = outlookPrivateLink, 
                    GoogleCalendar__c = googleLink
                ));
            }

        if (!coursesToUpdate.isEmpty()) {
            update coursesToUpdate;
        }
    }

    private static String buildCalendarUrl(String baseUrl, Map<String, String> params) {
        List<String> queryParts = new List<String>();
        for (String key : params.keySet()) {
            String value = params.get(key);
            if (value != null) {
                queryParts.add(key + '=' + EncodingUtil.urlEncode(value, 'UTF-8'));
            }
        }
            return baseUrl + '?' + String.join(queryParts, '&');
        }
    
    private static String formatDatetimeForOutlook(Datetime outlookDate) {
        return outlookDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
    }

    private static String formatDatetimeForGoogle(Datetime googleStartDate, Datetime googleEndDate) {
        String startStr = googleStartDate.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
        String endStr = googleEndDate.formatGMT('yyyyMMdd\'T\'HHmmss\'Z\'');
        return startStr + '/' + endStr;
    }
}