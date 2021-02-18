@RestResource(urlMapping='/Course/*')
global with sharing class CourseHandler extends MyTriggers {
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

            Datetime fromTime = course.RegistrationFromDateTime__c;
            fromTime = fromTime.addHours(1);
            wrapper.RegistrationFromDateTime = fromTime;

            Datetime toTime = course.RegistrationToDateTime__c;
            toTime = toTime.addHours(1);
            wrapper.RegistrationToDateTime = toTime;

            Datetime deadline = course.RegistrationDeadline__c;
            deadline = deadline.addHours(1);
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
        RestContext.response.responseBody = Blob.valueOf(
            JSON.serialize(wrapperList)
        );
    }

    public override void onBeforeUpdate(Map<Id, sObject> triggerOldMap) {
        List<Course__c> canceledCourses = new List<Course__c>();
        for (Course__c course : (List<Course__c>) records) {
            if (course.get('Cancel__c') != false) {
                canceledCourses.add(course);
            }
        }
        if (!canceledCourses.isEmpty()) {
            changeCanceledCourseTitle(canceledCourses);
        }
    }

    public static void changeCanceledCourseTitle(
        List<Course__c> canceledCourses
    ) {
        for (Course__c course : canceledCourses) {
            course.Name = 'AVLYST ' + course.Name;
        }
    }
}
