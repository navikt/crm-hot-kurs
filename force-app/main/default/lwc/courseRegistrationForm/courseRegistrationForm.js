import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import createRegistration from "@salesforce/apex/CourseRegistrationController.createRegistration";
import getInvitationCode from "@salesforce/apex/CourseRegistrationController.getInvitationCode";
import getCourseFields from "@salesforce/apex/CourseRegistrationController.getCourseFields";

import warningicon from '@salesforce/resourceUrl/warningicon';
import informationicon from '@salesforce/resourceUrl/informationcircle';
import chevronleft from '@salesforce/resourceUrl/chevronleft';

import { validateData } from "./helper";


export default class CourseRegistrationForm extends NavigationMixin(
    LightningElement
) {
    @track theRecord = {};
    @track output;

    @track showForm = false;
    @track showConfirmation = false;
    @track showError = false;
    @track displayErrorMessage = false;
    @track errorMessage;
    @track message;

    @track inputValCode;
    @track code;

    @track dueDate;

    @track courseId;

    @track showValidationInput = false;
    parameters = {};

    //icons
    warningicon = warningicon;
    informationicon = informationicon;
    chevronleft = chevronleft;

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.courseId = this.parameters.id;


        //this.checkValidationCode();

        getCourseFields({ courseId: this.courseId }).then(
            result => {
                if (result) {
                    this.code = result.InvitationCode__c;

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

    /* checkValidationCode() {
         getInvitationCode({ courseId: this.courseId }).then(
             result => {
                 if (result) {
                     this.showValidationInput = true;
                     this.code = result;
                 } else {
                     //this.showForm = true;
                 }
             }
         );
     }*/

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

        /*  if (event.target.checkValidity()) {
              event.target.reportValidity();
          }*/

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
