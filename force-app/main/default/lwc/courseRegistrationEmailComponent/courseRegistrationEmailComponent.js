import { LightningElement, track, api } from 'lwc';
import { getDataFromInputFields, validateData, emptyInputFields } from "./helper";
import labels from "./labels";

export default class CourseRegistrationEmailComponent extends LightningElement {

    @api recordId;

    @track recipients = []; // pill container
    @track emails = [];
    @track emailSent = false;
    @track checkboxChecked = false;
    @track viewConfirmationWindow = false;

    labels = labels;
    emailRegex = '(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';
    // add pills
    addEmail(event) {

        const validInputs = validateData(this.template.querySelectorAll("lightning-input"));
        if (!validInputs) { return; }

        let pill = getDataFromInputFields(this.template.querySelectorAll("lightning-input"));
        let emailIsUnique = !this.emails.includes(pill.email);

        if (emailIsUnique) {

            pill.type = 'avatar';
            pill.label = pill.firstName;
            pill.name = pill.email;
            pill.fallbackIconName = 'standard:user';
            pill.variant = 'circle';

            this.recipients.push(pill);
            this.emails.push(pill.email);

            emptyInputFields(this.template.querySelectorAll("lightning-input"));
        }
    }

    inputData(event) {
        if (event.keyCode === 13) {
            this.addEmail(undefined);
        }
    }

    closeConfirmation(event) {
        this.viewConfirmationWindow = false;
    }

    //send emails method
    openConfirmation() {
        if (this.recipients.length > 0) {
            this.viewConfirmationWindow = true;
        }
    }

    makeLowerCase(event) {
        event.target.value = event.target.value.toLowerCase();
    }

    checkbox() {
        this.checkboxChecked = !this.checkboxChecked;
    }

    get hasRecipients() {
        return this.recipients.length > 0;
    }

    get isConfirmDisabled() {
        return this.recipients.length === 0;
    }

    // remove pills
    handleItemRemove(event) {
        const index = event.detail.index;
        this.recipients.splice(index, 1);
        this.emails.splice(index, 1);
    }

}
