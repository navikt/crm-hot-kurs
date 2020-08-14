import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import createRegistration from "@salesforce/apex/CourseRegistrationController.createRegistration";
import getInvitationCode from "@salesforce/apex/CourseRegistrationController.getInvitationCode";


export default class CourseRegistrationForm extends NavigationMixin(
    LightningElement
) {
    @track theRecord = {};
    @track output;

    @track showForm = false;
    @track showConfirmation = false;
    @track showError = false;
    @track message;

    @track inputValCode;
    @track code;


    @track courseId;

    @track showValidationInput = false;
    parameters = {};

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.courseId = this.parameters.id;

        this.checkValidationCode();
    }

    checkValidationCode() {
        getInvitationCode({ courseId: this.courseId }).then(
            result => {
                if (result) {
                    this.showValidationInput = true;
                    this.code = result;
                } else {
                    this.showForm = true;
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

    handleSubmit() {
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

    validateCode() {
        if (this.inputValCode === this.code) {
            this.showValidationInput = false;
            this.showForm = true;
        }
    }
}
