public without sharing class CourseRegistrationController {
    public class RegistrationResult {
        @AuraEnabled
        public Boolean success;
        @AuraEnabled
        public String message;
    }

    @AuraEnabled
    public static RegistrationResult createRegistration(String fields, String courseId) {
        RegistrationResult result = new RegistrationResult();
        try {
            if (String.isBlank(fields) || String.isBlank(courseId)) {
                result.success = false;
                result.message = 'Nødvendig informasjon mangler (kurs-ID eller påmeldingsdata).';
                return result;
            }
            CourseRegistrationModel model = CourseRegistrationModel.parse(fields);
            if (model == null) {
                result.success = false;
                result.message = 'Påmeldingsdata er ugyldige eller kunne ikke behandles.';
                return result;
            }
            if (checkForDuplicates(model, courseId)) {
                result.success = false;
                result.message = 'Du er allerede påmeldt dette kurset med denne e-postadressen.';
                return result;
            }
            Course__c course = getCourseDetailsForRegistration(courseId);
            if (course == null) {
                result.success = false;
                result.message = 'Kunne ikke hente kursdetaljer. Kurset finnes kanskje ikke eller er utilgjengelig.';
                return result;
            }
            if (course.Cancel__c) {
                result.success = false;
                result.message = 'Kurset er avlyst, det er ikke lenger mulig å melde seg på.';
                return result;
            }

            Integer num = (model.numberOfParticipants == null ||
                model.numberOfParticipants < 1)
                ? 1
                : model.numberOfParticipants;

            CourseRegistration__c reg = new CourseRegistration__c(
                ContactFirstName__c = model.firstName,
                ContactLastName__c = model.lastName,
                ContactEmail__c = model.email,
                ContactPhone__c = model.phone,
                County__c = model.county,
                CompanyName__c = model.companyName,
                Role__c = model.role,
                Allergies__c = model.allergies,
                Workplace__c = model.workplace,
                Invoice_address__c = model.invoiceAdress,
                Invoice_reference__c = model.invoiceReference,
                AdditionalInformation__c = model.additionalInformation,
                NumberofParticipants__c = num,
                Course__c = courseId
            );

            Decimal current = (course.NumberOfParticipants__c != null) ? course.NumberOfParticipants__c : 0;
            Decimal maxCap = (course.MaxNumberOfParticipants__c != null) ? course.MaxNumberOfParticipants__c : 0;
            Decimal avail = maxCap - current;

            if (num <= avail) {
                reg.Status__c = 'Påmeldt';
                insert reg;
                result.success = true;
                result.message = 'Påmelding vellykket. Du vil om kort tid motta en bekreftelse på e-post.';
                return result;
            }

            if (current >= maxCap) {
                if (num > 1) {
                    result.success = false;
                    result.message = 'Det er kun mulig å melde på én deltaker om gangen til ventelisten ettersom kurset er fullt. Vennligst registrer én deltaker.';
                    return result;
                }
                reg.Status__c = 'Venteliste';
                insert reg;
                result.success = true;
                result.message = 'Registrering vellykket! Kurset er fullt, så du er nå satt på venteliste med 1 deltaker.';
                return result;
            }

            result.success = false;
            result.message =
                'Det er ikke nok ledige plasser på kurset for ' +
                num +
                ' deltaker(e). Det er for øyeblikket ' +
                String.valueOf(avail.intValue()) +
                ' ledige plasser. Vennligst reduser antall deltakere for å sikre en plass. ' +
                'For påmelding til venteliste, må kurset først være fullt og kun én deltaker kan meldes på om gangen til ventelisten.';
            return result;
        } catch (Exception e) {
            result.success = false;
            if (e instanceof AuraHandledException) {
                result.message = e.getMessage();
                return result;
            }
            result.message = 'En uventet feil oppstod under registrering. Feilmelding: ' + e.getMessage();
            return result;
        }
    }

    public static Boolean checkForDuplicates(CourseRegistrationModel model, Id courseId) {
        if (model == null || String.isBlank(model.email) || courseId == null)
            return false;
        List<CourseRegistration__c> recs = [
            SELECT Id
            FROM CourseRegistration__c
            WHERE Course__c = :courseId AND ContactEmail__c = :model.email AND Status__c = 'Påmeldt'
            LIMIT 1
        ];
        System.debug('recs mathias >>' + recs);
        return !recs.isEmpty();
    }

    private static Course__c getCourseDetailsForRegistration(String courseId) {
        if (String.isBlank(courseId))
            return null;
        try {
            return [
                SELECT Name, NumberOfParticipants__c, MaxNumberOfParticipants__c, Cancel__c
                FROM Course__c
                WHERE Id = :courseId
                LIMIT 1
            ];
        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static Course__c getCourseFields(String courseId) {
        if (String.isBlank(courseId))
            return null;
        try {
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
                    ShowAddMultipleParticipants__c
                FROM Course__c
                WHERE Id = :courseId
                LIMIT 1
            ];
        } catch (Exception e) {
            return null;
        }
    }
}
