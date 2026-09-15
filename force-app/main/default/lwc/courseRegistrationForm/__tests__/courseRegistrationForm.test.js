import { createElement } from 'lwc';
import CourseRegistrationForm from 'c/courseRegistrationForm';
import getCourseFields from '@salesforce/apex/CourseRegistrationController.getCourseFields';

jest.mock(
    '@salesforce/apex/CourseRegistrationController.getCourseFields',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/CourseRegistrationController.createRegistration',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/CourseRegistrationController.getOrganizationInfo',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

const COURSE_ID = 'a16QC000000nzGrYAI';

const createCourse = (type) => ({
    Name: 'Testaktivitet',
    Type__c: type,
    RegistrationDeadline__c: '2099-01-01T12:00:00.000Z',
    Cancel__c: false,
    MaxNumberOfParticipants__c: 10,
    RegistrationSignupsCount__c: 0,
    RegistrationWaitlistedCount__c: 0
});

const flushPromises = async () => {
    await Promise.resolve();
    await Promise.resolve();
};

describe('c-course-registration-form breadcrumb', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        window.history.replaceState({}, '', '/');
        jest.clearAllMocks();
    });

    it.each([
        ['Webinar', 'Om webinaret'],
        ['Konferanse', 'Om konferansen'],
        ['Seminar', 'Om seminaret'],
        ['Kurs', 'Om kurset']
    ])('shows the correct label for %s', async (type, expectedLabel) => {
        window.history.replaceState({}, '', `/s/pamelding?id=${COURSE_ID}`);
        getCourseFields.mockResolvedValue(createCourse(type));

        const element = createElement('c-course-registration-form', {
            is: CourseRegistrationForm
        });
        document.body.appendChild(element);

        await flushPromises();

        const breadcrumbLinks = element.shadowRoot.querySelectorAll('.brodsmulesti a');
        expect(breadcrumbLinks[3].textContent.trim()).toBe(expectedLabel);
    });
});
