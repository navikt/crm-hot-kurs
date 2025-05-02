public without sharing class CourseRegistrationController {
    @AuraEnabled
    public static String createRegistration(String fields, String courseId) {
        try {
            Boolean duplicate = checkForDuplicates(fields, courseId);
            if (duplicate) {
                return 'Du er allerede påmeldt dette kurset, vennligst bruk en annen e-postadresse.';
            }
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
                ShowAllergies__c,
                ShowWorkplace__c,
                ShowAdditionalInformation__c,
                ShowOrganizationNumber
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

    private static List<CourseRegistration__c> getAlreadyInvited(CourseRegistrationModel model, String courseId) {
        List<CourseRegistration__c> alreadyInvited = [
            SELECT Id, Course__c, CourseParticipant__r.Email
            FROM CourseRegistration__c
            WHERE Course__c = :courseId AND CourseParticipant__r.Email = :model.email AND Status__c = 'Invitert'
            LIMIT 1
        ];

        return alreadyInvited;
    }

    public static void insertRegistration(String fields, Id courseId) {
        if (fields != null) {
            Boolean courseIsFull = checkIfCourseIsFull(courseId);
            CourseRegistrationModel model = CourseRegistrationModel.parse(fields);
            List<CourseRegistration__c> registrations = getAlreadyInvited(model, courseId);
            if (registrations.size() > 0) {
                delete registrations;
            }

            CourseRegistration__c registration = new CourseRegistration__c();
            registration.ContactFirstName__c = model.firstName;
            registration.ContactLastName__c = model.lastName;
            registration.ContactEmail__c = model.email;
            registration.ContactPhone__c = model.phone;
            registration.Course__c = courseId;
            registration.County__c = model.county;
            registration.CompanyName__c = model.companyName;
            registration.Role__c = model.role;
            registration.Allergies__c = model.allergies;
            registration.Workplace__c = model.workplace;
            registration.Invoice_address__c = model.invoiceAdress;
            registration.Invoice_reference__c = model.invoiceReference;
            registration.AdditionalInformation__c = model.additionalInformation;
            registration.Organization = model.organizationNumber;

            if (courseIsFull) {
                registration.Status__c = 'Venteliste';
            } else {
                registration.Status__c = 'Påmeldt';
            }

            insert registration;
        }
    }

    public static Boolean checkForDuplicates(String fields, Id courseId) {
        CourseRegistrationModel model = CourseRegistrationModel.parse(fields);
        List<CourseRegistration__c> existingRecord = [
            SELECT Id, Course__c, CourseParticipant__r.Email
            FROM CourseRegistration__c
            WHERE Course__c = :courseId AND CourseParticipant__r.Email = :model.email AND Status__c = 'Påmeldt'
            LIMIT 1
        ];

        return existingRecord.size() > 0;
    }
    @AuraEnabled(cacheable=true)
    public static List<Account> getOrganizationInfo(String organizationNumber) {
        List<Account> account = [
            SELECT Id, Name, INT_OrganizationNumber__c
            FROM Account
            WHERE INT_OrganizationNumber__c = :organizationNumber
        ];
        return account;
    }
}
