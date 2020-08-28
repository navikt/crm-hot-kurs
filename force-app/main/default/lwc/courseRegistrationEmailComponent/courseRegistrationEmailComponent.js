import { LightningElement, track } from 'lwc';
import sendCourseEmail from "@salesforce/apex/CourseRegistrationEmailController.sendCourseEmail";
import { getDataFromInputFields, validateData, emptyInputFields } from "./helper";

export default class CourseRegistrationEmailComponent extends LightningElement {

    @track items = []; // pill container
    @track emails = [];
    @track emailSent = false;
    @track checkboxChecked = false;

    emailRegex = '(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';

    // add pills
    addEmail(event) {

        const validInputs = validateData(this.template.querySelectorAll("lightning-input"));
        if (!validInputs) { return; }

        let pill = getDataFromInputFields(this.template.querySelectorAll("lightning-input"));
        let emailIsUnique = !this.emails.includes(pill.email);

        if (emailIsUnique) {

            pill.type = 'avatar';
            pill.label = pill.firstName + ' ' + pill.lastName;
            pill.name = pill.email;
            pill.fallbackIconName = 'standard:user';
            pill.variant = 'circle';

            this.items.push(pill);
            this.emails.push(pill.email);

            emptyInputFields(this.template.querySelectorAll("lightning-input"));
        }
    }

    //send emails method
    confirmation() {
        sendCourseEmail({
            jsonStr: JSON.stringify(this.emails) //converting emails array to a string and sending it to Apex class CourseRegistrationEmailController
        }).catch(error => {
            console.log(JSON.stringify(error));
        });
        this.items = {};
        this.emails = [];
        this.emailSent = true;
    }

    checkbox() {
        this.checkboxChecked = !this.checkboxChecked;
    }

    get hasItems() {
        return this.items.length > 0;
    }

    get canSend() {
        return this.items.length > 0; // TODO and checkbox is checked
    }

    // remove pills
    handleItemRemove(event) {
        const index = event.detail.index;
        this.items.splice(index, 1);
        this.emails.splice(index, 1);
    }

}
