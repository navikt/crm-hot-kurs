import { createElement } from 'lwc';
import CourseRegistrationInformation from 'c/courseRegistrationInformation';

describe('c-course-registration-information', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders course information immediately from the supplied course fields', () => {
        const element = createElement('c-course-registration-information', {
            is: CourseRegistrationInformation
        });
        element.courseFields = {
            RegistrationFromDateTime__c: '2026-08-05T10:00:00',
            RegistrationToDateTime__c: '2026-08-05T12:30:00',
            RegistrationDeadline__c: '2026-08-01',
            RegistrationPlaceName__c: 'Oslo',
            Type__c: 'Webinar',
            MaxNumberOfParticipants__c: 10,
            RegistrationSignupsCount__c: 3
        };
        document.body.appendChild(element);

        const information = Array.from(element.shadowRoot.querySelectorAll('.metainfo__infoTekst')).map((node) =>
            node.textContent.trim()
        );

        expect(information[0]).toContain('05. aug. kl. 10:00 - 12:30');
        expect(information[1]).toContain('01. aug. kl. 00:00');
        expect(information[2]).toBe('Sted: Oslo');
        expect(information[3]).toBe('Type kurs: Webinar');
        expect(information[4]).toBe('Antall ledige plasser: 7');
    });
});
