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
                Region2__c,
                Type__c,
                Sub_category__c,
                Theme__c
            FROM Course__c
        ];

        List<CourseApiModel> wrapperList = new List<CourseApiModel>();

        for (Course__c course : courses) {
            CourseApiModel wrapper = new CourseApiModel();

            wrapper.RegistrationID = course.Id;
            wrapper.Title = course.Name;
            wrapper.RegistrationUrl = course.RegistrationUrl2__c;

            //temp fix for timezone problems
            Datetime summer = DateTime.newInstance(2021, 3, 28, 0, 0, 0);
            Datetime winter = DateTime.newInstance(2021, 10, 31, 0, 0, 0);

            Datetime fromTime = course.RegistrationFromDateTime__c;
            if (fromTime > summer && fromTime < winter) {
                fromTime = fromTime.addHours(2);
            } else {
                fromTime = fromTime.addHours(1);
            }

            wrapper.RegistrationFromDateTime = fromTime;

            Datetime toTime = course.RegistrationToDateTime__c;
            if (toTime > summer && toTime < winter) {
                toTime = toTime.addHours(2);
            } else {
                toTime = toTime.addHours(1);
            }
            wrapper.RegistrationToDateTime = toTime;

            Datetime deadline = course.RegistrationDeadline__c;
            if (deadline > summer && deadline < winter) {
                deadline = deadline.addHours(2);
            } else {
                deadline = deadline.addHours(1);
            }
            wrapper.RegistrationDeadline = deadline;
            // --------------------------------------------- //
            wrapper.RegistrationPlaceName = course.RegistrationPlaceName__c;
            wrapper.FrontPageDescription = course.DescriptionFormatted__c;
            wrapper.Description = course.DescriptionShort2__c;
            wrapper.ShowInActivityList = course.Active__c ? 1 : 0;

            wrapper.configurable_custom = new CourseApiModel.Configurable_custom();

            wrapper.configurable_custom.Fylke = course.Region2__c;
            wrapper.configurable_custom.Type = course.Type__c;
            wrapper.configurable_custom.Tema = course.Theme__c;
            wrapper.configurable_custom.Underkategori = course.Sub_category__c;

            wrapperList.add(wrapper);
        }

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(wrapperList));
    }
}
