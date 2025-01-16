import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createRegistration from '@salesforce/apex/CourseRegistrationController.createRegistration';
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

        // Basis felter som alltid vises
        if (!this.theRecord.firstName || !this.theRecord.lastName || !this.theRecord.email || !this.theRecord.phone) {
            this.showError = true;
            return;
        }

        // Tillegs felter sjekk om de er satt
        if (this.companyName && !this.theRecord.companyName) {
            this.showError = true;
            return;
        }
        if (this.county && !this.theRecord.county) {
            this.showError = true;
            return;
        }
        if (this.role && !this.theRecord.role) {
            this.showError = true;
            return;
        }
        if (this.invoiceAdress && !this.theRecord.invoiceAdress) {
            this.showError = true;
            return;
        }
        if (this.invoiceReference && !this.theRecord.invoiceReference) {
            this.showError = true;
            return;
        }
        if (this.workplace && !this.theRecord.workplace) {
            this.showError = true;
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
}
