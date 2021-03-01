@RestResource(urlMapping='/Course/*')
global with sharing class CourseHandler {
    @HttpGet
    global static void doGet() {
        List<Course__c> courses = [
            SELECT
                Id,
                Name,
                RegistrationUrl2__c,
                RegistrationFromDateTime__c,
                RegistrationToDateTime__c,
                RegistrationDeadline__c,
                RegistrationPlaceName__c,
                DescriptionFormatted__c,
                DescriptionShort2__c,
                Active__c,
                Region__c,
                Type__c,
                Theme__c
            FROM Course__c
        ];

        List<CourseApiModel> wrapperList = new List<CourseApiModel>();

        for (Course__c course : courses) {
            CourseApiModel wrapper = new CourseApiModel();

            wrapper.RegistrationID = course.Id;
            wrapper.Title = course.Name;
            wrapper.RegistrationUrl = course.RegistrationUrl2__c;

            TimeZone tz = UserInfo.getTimeZone();
            Datetime nowDate = Datetime.now();
            Datetime fromTime = course.RegistrationFromDateTime__c;
            Integer summerOffsetTime = tz.getOffset(fromTime) - tz.getOffset(nowDate);
            Integer os = tz.getOffset(fromTime);
            fromTime = fromTime.addHours(1 - os / 3600000 + summerOffsetTime / 3600000);
            wrapper.RegistrationFromDateTime = fromTime;

            Datetime toTime = course.RegistrationToDateTime__c;
            summerOffsetTime = tz.getOffset(toTime) - tz.getOffset(nowDate);
            os = tz.getOffset(toTime);
            toTime = toTime.addHours(1 - os / 3600000 + summerOffsetTime / 3600000);
            wrapper.RegistrationToDateTime = toTime;

            Datetime deadline = course.RegistrationDeadline__c;
            summerOffsetTime = tz.getOffset(deadline) - tz.getOffset(nowDate);
            os = tz.getOffset(deadline);
            deadline = deadline.addHours(1 - os / 3600000 + summerOffsetTime / 3600000);
            wrapper.RegistrationDeadline = deadline;

            wrapper.RegistrationPlaceName = course.RegistrationPlaceName__c;
            wrapper.FrontPageDescription = course.DescriptionFormatted__c;
            wrapper.Description = course.DescriptionShort2__c;
            wrapper.ShowInActivityList = course.Active__c ? 1 : 0;

            wrapper.configurable_custom = new CourseApiModel.Configurable_custom();

            wrapper.configurable_custom.Fylke = course.Region__c;
            wrapper.configurable_custom.Type = course.Type__c;
            wrapper.configurable_custom.Tema = course.Theme__c;

            wrapperList.add(wrapper);
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(wrapperList));
    }
}
