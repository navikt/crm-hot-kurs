// NATIVE
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// CONTROLLERS
import createCourseRegistrations from '@salesforce/apex/CourseInvitationController.createCourseRegistrations';

// LOCAL IMPORTS
import { getDataFromInputFields, validateData, emptyInputFields, contactToPill } from "./helper";
import labels from "./labels";

export default class CourseInvitation extends NavigationMixin(LightningElement) {

    @api recordId = 'a0A1j000003dIDEEA2';
    emailRegex = '(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';

    // DATA
    @track recipients = []; // pill container
    @track emails = [];
    @track contacts = [];
    labels = labels;

    // STATES
    @track viewConfirmationWindow = false;
    @track showGdpr = false;
    @track showImport = false;
    @track emailSent = false;
    @track error;
    @track errorMsg;
    @track loading;

    // #########################################
    // ################# EVENTS ################
    // #########################################


    addEmail(event) {

        const validInputs = validateData(this.template.querySelectorAll("lightning-input"));
        if (!validInputs) { return; }

        let pill = getDataFromInputFields(this.template.querySelectorAll("lightning-input"));
        let emailIsUnique = !this.emails.includes(pill.email);

        if (emailIsUnique) {
            this.createPill(pill);
            this.template.querySelector('[data-id="fullName"]').focus();
            emptyInputFields(this.template.querySelectorAll("lightning-input"));
        }
    }

    createPill(pill) {
        pill = contactToPill(pill);
        this.recipients.unshift(pill);
        this.emails.unshift(pill.email);
    }

    inputData(event) {
        if (event.keyCode === 13) {
            this.addEmail(undefined);
        }
    }

    makeLowerCase(event) {
        event.target.value = event.target.value.toLowerCase();
    }

    removePill(event) {
        const index = event.detail.index;
        this.recipients.splice(index, 1);
        this.emails.splice(index, 1);
    }

    // #########################################
    // ################ GETTERS ################
    // #########################################

    get hasRecipients() {
        return this.recipients.length > 0;
    }

    get isConfirmDisabled() {
        return this.recipients.length === 0;
    }

    // #########################################
    // ############ CLICK LISTENERS ############
    // #########################################

    // click confirm
    openConfirmation() {
        this.showGdpr = true;

    }

    startImport() {
        this.showImport = true;
    }

    restart() {
        this.emailSent = false;
        this.recipients = [];
        this.emails = [];
        this.contacts = [];
    }

    // #########################################
    // ######## CUSTOM EVENT LISTENERS #########
    // #########################################

    gdprCancel(event) {
        this.showGdpr = false;
    }

    gdprAccept(event) {
        this.showGdpr = false;

        if (this.recipients.length > 0) {
            this.viewConfirmationWindow = true;
        }
    }

    importCancel(event) {
        this.showImport = false;
    }

    importSuccess(event) {
        this.showImport = false;

        event.detail.forEach(con => {
            let emailIsUnique = !this.emails.includes(con.email);
            if (emailIsUnique) {
                this.createPill(con);
            }
        });
    }

    emailCancel(event) {
        this.viewConfirmationWindow = false;
    }

    emailSuccess(event) {
        this.viewConfirmationWindow = false;
        this.loading = true;

        createCourseRegistrations({
            courseId: this.recordId,
            contacts: this.contacts
        }).then(result => {
            this.loading = false;
            this.contacts = event.detail;
            this.emailSent = true;
            this.toast(this.labels.success, undefined, undefined, 'success', 'dismissable');
        }).catch(error => {
            this.loading = false;
            this.error = true;
            this.toast(this.labels.error, this.labels.errorMsg, undefined, 'error', 'sticky');
        });
    }

    // #########################################
    // ################# OTHER #################
    // #########################################

    toast(title, message, messageData, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            messageData: messageData,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    openContact(event) {
        let contactId = event.target.dataset.targetId;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: contactId,
                actionName: 'view'
            },
        });
    }
}
