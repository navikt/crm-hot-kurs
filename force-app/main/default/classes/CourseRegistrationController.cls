public with sharing class CourseRegistrationController {
    @AuraEnabled
    public static String createRegistration(String fields, String courseId) {
        try {
            /*  Boolean duplicate = checkForDuplicates( contactId, courseId );
			   if ( duplicate ) { return 'Du er allerede påmeldt dette kurset'; }
			   insertRegistration( contactId, courseId );*/
            Boolean courseIsFull = checkIfCourseIsFull(courseId);

            if (fields != null) {
                insertRegistration(fields, courseId);
            }
            if (courseIsFull) {
                return 'Registrering vellykket! Du er nå satt på venteliste og vil motta bekreftelse på e-post dersom du blir tildelt en plass.';
            }

            return 'Påmelding vellykket. Du vil om kort tid motta en bekreftelse på e-post';
        } catch (Exception e) {
            return 'Det oppsto en feil. Prøv igjen senere.';
        }
    }
    @AuraEnabled
    public static Course__c getCourseFields(String courseId) {
        return [
            SELECT
                Name,
                RegistrationDeadline__c,
                RegistrationFromDateTime__c,
                RegistrationToDateTime__c,
                InvitationCode__c,
                RegistrationPlaceName__c,
                Type__c,
                MaxNumberOfParticipants__c,
                NumberOfParticipants__c,
                Waitinglist__c,
                ShowCompany__c,
                ShowCounty__c,
                ShowRole__c,
                Cancel__c,
                ShowInvoiceAdress__c,
                ShowInvoiceReference__c,
                ShowAllergies__c
            FROM Course__c
            WHERE Id = :courseId
        ];
    }

    public static Boolean checkIfCourseIsFull(String courseId) {
        Course__c c = getCourseFields(courseId);
        Double maxNumber = c.MaxNumberOfParticipants__c;
        Double numberOfParticipants = c.NumberOfParticipants__c;
        Boolean courseIsFull = numberOfParticipants >= maxNumber ? true : false;

        return courseIsFull;
    }

    public static void insertRegistration(String fields, Id courseId) {
        if (fields != null) {
            Boolean courseIsFull = checkIfCourseIsFull(courseId);
            CourseRegistrationModel model = CourseRegistrationModel.parse(fields);
            CourseRegistration__c registration = new CourseRegistration__c();

            registration.ContactFirstName__c = model.firstName;
            registration.ContactLastName__c = model.lastName;
            registration.ContactEmail__c = model.email;
            registration.ContactPhone__c = model.phone;
            registration.Course__c = courseId;
            registration.County__c = model.county;
            registration.CompanyName__c = model.companyName;
            registration.Role__c = model.role;

            registration.Allergies__c=model.allergies;
            registration.Workplace__c=model.workplace;
            registration.Invoice_address__c=model.invoiceAdress;
            registration.Invoice_reference__c=model.invoiceReference;

            if (courseIsFull) {
                registration.Status__c = 'Venteliste';
            } else {
                registration.Status__c = 'Påmeldt';
            }

            insert registration;
        }
    }

    /*
       public static Boolean checkForDuplicates( Id contactId, Id courseId ) {
        List<CourseRegistration__c> existingRecord =
        [SELECT Id, Course__c, CourseParticipant__c
         FROM CourseRegistration__c
         WHERE Course__c =: courseId
                           AND CourseParticipant__c =: contactId LIMIT 1];

        Boolean exists = existingRecord.size() > 0 ? true : false;

        return exists;
       }*/
}
