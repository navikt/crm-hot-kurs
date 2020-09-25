import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import createRegistration from "@salesforce/apex/CourseRegistrationController.createRegistration";
import getCourseFields from "@salesforce/apex/CourseRegistrationController.getCourseFields";
import icons from '@salesforce/resourceUrl/icons';

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

    @track showValidationInput = false;
    parameters = {};

    //icons
    warningicon = icons + '/warningicon.svg';
    informationicon = icons + '/informationicon.svg';
    successicon = icons + '/successicon.svg';
    erroricon = icons + '/erroricon.svg';
    chevrondown = icons + '/chevrondown.svg';

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.courseId = this.parameters.id;


        getCourseFields({ courseId: this.courseId }).then(
            result => {
                if (result) {
                    this.code = result.InvitationCode__c;
                    this.title = result.Name;

                    this.dueDate = result.RegistrationDeadline__c;
                    var registrationDeadline = new Date(this.dueDate);
                    var dateNow = new Date(Date.now());

                    if (registrationDeadline > dateNow) {
                        this.showForm = true;
                    } else {
                        this.errorMessage = "Påmeldingsfristen er passert, det er ikke lenger mulig å melde seg på"
                        this.displayErrorMessage = true;
                    }

                    if (this.code != undefined) {
                        this.showForm = false;
                        this.showValidationInput = true;

                    }

                } else {

                }
            }
        );

    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse(
                '{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}',
                (key, value) => {
                    return key === "" ? value : decodeURIComponent(value);
                }
            );
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
        if (
            this.theRecord.firstName &&
            this.theRecord.lastName &&
            this.theRecord.email &&
            this.theRecord.phone
        ) {
            let output = JSON.stringify(this.theRecord, null);
            createRegistration({ fields: output, courseId: this.courseId }).then(
                result => {
                    this.showForm = false;
                    this.showConfirmation = true;
                    this.message = result;
                }
            );
        } else {
            this.showError = true;
        }
    }

    validateCode(event) {
        event.preventDefault();
        console.log('codes', this.inputValCode, this.code);
        if (this.inputValCode === this.code) {
            this.showValidationInput = false;
            this.showForm = true;
            this.displayErrorMessage = false;
        } else {
            this.displayErrorMessage = true;
            this.errorMessage = "Koden er ikke gyldig. Vennligst prøv igjen";
        }
    }
}
