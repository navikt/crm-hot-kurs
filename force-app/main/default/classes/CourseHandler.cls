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
        ];

        List<CourseApiModel> wrapperList = new List<CourseApiModel>();

        for (Course__c course : courses) {
            CourseApiModel wrapper = new CourseApiModel();

            wrapper.RegistrationID = course.Id;
            wrapper.Title = course.Name;
            wrapper.RegistrationUrl = course.RegistrationUrl2__c;

            //permanent DST fix
            // DateTime currentDateTime = DateTime.now();
            // Timezone userTimeZone = Timezone.getTimeZone('Europe/Oslo');
            // Integer timeZoneOffsetMinutes = userTimeZone.getOffset(DateTime.now());
            // Datetime fromTime = course.RegistrationFromDateTime__c.addMinutes(timeZoneOffsetMinutes);
            // Datetime toTime = course.RegistrationToDateTime__c.addMinutes(timeZoneOffsetMinutes);
            // Datetime deadline = course.RegistrationDeadline__c.addMinutes(timeZoneOffsetMinutes);

            // wrapper.RegistrationFromDateTime = fromTime;
            // wrapper.RegistrationToDateTime = toTime;
            // wrapper.RegistrationDeadline = deadline;

            //temp fix for timezone problems
            Datetime summer25 = DateTime.newInstance(2025, 3, 30, 0, 0, 0);
            Datetime winter25 = DateTime.newInstance(2025, 10, 26, 0, 0, 0);
            Datetime summer24 = DateTime.newInstance(2024, 3, 31, 0, 0, 0);
            Datetime winter24 = DateTime.newInstance(2024, 10, 27, 0, 0, 0);

            Datetime fromTime = course.RegistrationFromDateTime__c;
            if (fromTime > summer24 && fromTime < winter24 || fromTime > summer25 && fromTime < winter25) {
                fromTime = fromTime.addHours(2);
            } else {
                fromTime = fromTime.addHours(1);
            }

            wrapper.RegistrationFromDateTime = fromTime;

            Datetime toTime = course.RegistrationToDateTime__c;
            if (toTime > summer24 && toTime < winter24 || toTime > summer25 && toTime < winter25 ) {
                toTime = toTime.addHours(2);
            } else {
                toTime = toTime.addHours(1);
            }
            wrapper.RegistrationToDateTime = toTime;

            Datetime deadline = course.RegistrationDeadline__c;
            if (deadline > summer24 && deadline < winter24 || deadline > summer25 && deadline < winter25) {
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
}
