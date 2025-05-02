import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createRegistration from '@salesforce/apex/CourseRegistrationController.createRegistration';
import getOrganizationInfo from '@salesforce/apex/CourseRegistrationController.getOrganizationInfo';
import getCourseFields from '@salesforce/apex/CourseRegistrationController.getCourseFields';
import icons from '@salesforce/resourceUrl/icons';
import houseIconNew from '@salesforce/resourceUrl/houseicon2';

export default class CourseRegistrationForm extends NavigationMixin(LightningElement) {
    @track courseId;

    @track theRecord = {};
    @track output;

    @track showForm = false;
    @track showConfirmation = false;
    @track showError = false;
    @track displayErrorMessage = false;
    @track errorMessage;
    @track message;

    @track inputValCode = '';
    @track code;

    @track dueDate;
    @track title;
    @track canceled = false;
    @track allergies = false;
    @track invoiceAdress = false;
    @track invoiceReference = false;
    @track workplace = false;
    @track organization = false;

    @track courseIsFullWarning = false;
    @track numberOnWaitinglist;

    @track showValidationInput = false;
    parameters = {};

    @track url;

    @track county = false;
    @track companyName = false;
    @track role = false;

    //icons
    warningicon = icons + '/warningicon.svg';
    informationicon = icons + '/informationicon.svg';
    successicon = icons + '/successicon.svg';
    erroricon = icons + '/erroricon.svg';
    chevrondown = icons + '/chevrondown.svg';
    houseicon = houseIconNew;

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.courseId = this.parameters.id;

        getCourseFields({ courseId: this.courseId }).then((result) => {
            if (result) {
                this.code = result.InvitationCode__c;
                this.title = result.Name;
                this.companyName = result.ShowCompany__c;
                this.county = result.ShowCounty__c;
                this.role = result.ShowRole__c;
                this.canceled = result.Cancel__c;
                this.allergies = result.ShowAllergies__c;
                this.invoiceAdress = result.ShowInvoiceAdress__c;
                this.invoiceReference = result.ShowInvoiceReference__c;
                this.workplace = result.ShowWorkplace__c;
                this.additionalInformation = result.ShowAdditionalInformation__c;
                this.organization = result.ShowOrganizationNumber__c;

                this.dueDate = result.RegistrationDeadline__c;
                let registrationDeadline = new Date(this.dueDate);
                let dateNow = new Date(Date.now());
                this.url = 'https://arbeidsgiver.nav.no/kursoversikt/' + this.courseId;

                if (registrationDeadline > dateNow && this.canceled == false) {
                    this.showForm = true;
                } else {
                    if (!this.canceled) {
                        this.errorMessage = 'Påmeldingsfristen er passert, det er ikke lenger mulig å melde seg på';
                        this.displayErrorMessage = true;
                    } else {
                        this.errorMessage = 'Kurset er avlyst, det er ikke lenger mulig å melde seg på';
                        this.displayErrorMessage = true;
                    }
                }

                let maxNumberOfParticipants = result.MaxNumberOfParticipants__c;
                let numberOfParticipants = result.NumberOfParticipants__c;
                this.numberOnWaitinglist = result.Waitinglist__c + 1;

                if (numberOfParticipants >= maxNumberOfParticipants) {
                    this.courseIsFullWarning = true;
                }

                if (this.code != undefined) {
                    this.showForm = false;
                    this.showValidationInput = true;
                }
            } else {
            }
        });
    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === '' ? value : decodeURIComponent(value);
            });
        }
        return params;
    }

    handleChange(event) {
        this.theRecord[event.target.name] = event.target.value;
        this.showError = false;
    }

    handleChange2(event) {
        this.inputValCode = event.target.value;
    }

    handleSubmit(event) {
        event.preventDefault();

        const requiredFields = [
            'firstName',
            'lastName',
            'email',
            'phone',
            'companyName',
            'county',
            'role',
            'invoiceAdress',
            'invoiceReference',
            'workplace',
            'organization'
        ]; // List of required fields
        const nonRequiredFields = ['allergies', 'additionalInformation']; // List of non required fields

        const fieldLabels = {
            firstName: 'Fornavn',
            lastName: 'Etternavn',
            email: 'E-post',
            phone: 'Telefon',
            companyName: 'Firma',
            county: 'Fylke',
            role: 'Rolle',
            invoiceAdress: 'Faktura adresse',
            invoiceReference: 'Faktura referanse',
            workplace: 'Arbeidsplass',
            allergies: 'Matallergi',
            additionalInformation: 'Tilleggsinformasjon (f.eks behov for tolk)',
            organization: 'Bedriftsnummer/Organisasjonsnummer'
        };
        for (const field of requiredFields) {
            if (this[field] && !this.theRecord[field]) {
                this.showError = true;
                this.errorMessage = `Vennligst fyll ut alle feltene.`;
                return;
            }

            // Validate field lengths (less than 255 characters)
            if (this.theRecord[field] && this.theRecord[field].length > 255) {
                this.showError = true;
                this.errorMessage = `${fieldLabels[field]} kan ikke være lengre enn 255 tegn.`;
                return;
            }
        }
        // Validate field lengths (less than 255 characters)
        for (const field of nonRequiredFields) {
            if (this.theRecord[field] && this.theRecord[field].length > 255) {
                this.showError = true;
                this.errorMessage = `${fieldLabels[field]} kan ikke være lengre enn 255 tegn.`;
                return;
            }
        }
        // Validate phone number (example: phone should be a number and not empty)
        const phoneRegex = /^[0-9]{8,}$/; // Example: Validates 8 digits or more
        if (this.theRecord.phone && !phoneRegex.test(this.theRecord.phone)) {
            this.showError = true;
            this.errorMessage = 'Vennligst oppgi et gyldig telefonnummer (minst 8 sifre).';
            return;
        }
        // Validate email
        const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if (this.theRecord.email && !emailRegex.test(this.theRecord.email)) {
            this.showError = true;
            this.errorMessage = 'Vennligst oppgi en gyldig e-postadresse.';
            return;
        }

        // Alle sjekker er passert om vi kommer hit
        let output = JSON.stringify(this.theRecord, null);
        createRegistration({
            fields: output,
            courseId: this.courseId
        }).then((result) => {
            this.showForm = false;
            this.showConfirmation = true;
            this.message = result;
        });
    }

    validateCode(event) {
        event.preventDefault();
        if (this.inputValCode === this.code) {
            this.showValidationInput = false;
            this.showForm = true;
            this.displayErrorMessage = false;
        } else {
            this.displayErrorMessage = true;
            this.errorMessage = 'Koden er ikke gyldig. Vennligst prøv igjen';
        }
    }
    @track organizationNumberSearch;
    @track organizationName = 'Feltet fylles automatisk';
    handleOrganizationNumberInput(event) {
        this.organizationNumberSearch = event.target.value;
        if (this.organizationNumberSearch.length == 9) {
            this.organizationName = 'Henter organisasjon...';
            try {
                getOrganizationInfo({
                    organizationNumber: this.organizationNumberSearch
                }).then((result) => {
                    if (result.length == 1) {
                        //this.theRecord.organization = result[0].Id;
                        this.organizationName = result[0].Name;
                        this.theRecord.organization = result[0].Id;
                    } else {
                        this.organizationName = 'Kunne ikke finne organisasjon';
                        this.theRecord.organization = null;
                    }
                });
            } catch (error) {
                this.organizationName = error;
                this.theRecord.organization = null;
            }
        } else {
            this.organizationName = 'Feltet fylles automatisk';
            this.theRecord.organization = null;
        }
    }
}
