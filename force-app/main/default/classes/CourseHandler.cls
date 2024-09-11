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
                Theme__c,
                AvailableSeats__c,
                MaxNumberOfParticipants__c,
                NumberOfParticipants__c
            FROM Course__c
            WHERE Active__c = TRUE
        ];

        List<CourseApiModel> wrapperList = new List<CourseApiModel>();

        for (Course__c course : courses) {
            CourseApiModel wrapper = new CourseApiModel();

            wrapper.RegistrationID = course.Id;
            wrapper.Title = course.Name;
            wrapper.RegistrationUrl = course.RegistrationUrl2__c;

            wrapper.RegistrationFromDateTime = toOsloTimeZone(course.RegistrationFromDateTime__c);
            wrapper.RegistrationToDateTime = toOsloTimeZone(course.RegistrationToDateTime__c);
            wrapper.RegistrationDeadline = toOsloTimeZone(course.RegistrationDeadline__c);
            // --------------------------------------------- //
            wrapper.RegistrationPlaceName = course.RegistrationPlaceName__c;
            wrapper.FrontPageDescription = course.DescriptionFormatted__c;
            wrapper.Description = course.DescriptionShort2__c;
            wrapper.ShowInActivityList = course.Active__c ? 1 : 0;
            wrapper.AvailableSeats = course.AvailableSeats__c;
            wrapper.MaxNumberOfParticipants = course.MaxNumberOfParticipants__c;
            wrapper.NumberOfParticipants = course.NumberOfParticipants__c;

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

    private static Datetime toOsloTimeZone(Datetime local) {
        TimeZone osloTimeZone = TimeZone.getTimeZone('Europe/Oslo');
        return local.addMinutes(osloTimeZone.getOffset(local) / 60000);
    }
}
