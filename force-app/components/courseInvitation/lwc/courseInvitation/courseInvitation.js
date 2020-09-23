// native
import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// controllers
import createCourseRegistrations from '@salesforce/apex/CourseInvitationController.createCourseRegistrations';

// local files
import { getDataFromInputFields, validateData, emptyInputFields } from "./helper";
import labels from "./labels";

export default class CourseInvitation extends NavigationMixin(LightningElement) {

    @api recordId = 'a0A1j000003dIDEEA2';

    @track recipients = []; // pill container
    @track emails = [];

    @track contacts = [];
    @track viewConfirmationWindow = false;

    @track showGdpr = false;
    @track emailSent = false;
    @track error;
    @track errorMsg;
    @track loading;

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
            pill.label = pill.fullName;
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



    restart() {
        this.emailSent = false;
        this.recipients = [];
        this.emails = [];
        this.contacts = [];
    }

    makeLowerCase(event) {
        event.target.value = event.target.value.toLowerCase();
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

    // remove pills
    handleItemRemove(event) {
        const index = event.detail.index;
        this.recipients.splice(index, 1);
        this.emails.splice(index, 1);
    }

    // #########################################
    // ############ CLICK LISTENERS ############
    // #########################################

    // click confirm
    openConfirmation() {
        this.showGdpr = true;
    }

    // #########################################
    // ############ EVENT LISTENERS ############
    // #########################################

    // cancelled gdpr
    gdprCancel(event) {
        this.showGdpr = false;
    }

    // accepted gdpr
    gdprAccept(event) {
        this.showGdpr = false;

        if (this.recipients.length > 0) {
            this.viewConfirmationWindow = true;
        }
    }

    emailCancel(event) {
        this.viewConfirmationWindow = false;
    }

    emailSuccess(event) {
        this.contacts = event.detail;
        this.emailSent = true;
        this.viewConfirmationWindow = false;
        this.loading = true;

        createCourseRegistrations({
            courseId: this.recordId,
            contacts: this.contacts
        }).then(result => {
            this.loading = false;
            this.toast(this.labels.success, undefined, undefined, 'success', 'dismissable');
        }).catch(error => {
            this.loading = false;
            this.error = true;
            this.toast(this.labels.error, this.labels.errorMsg, undefined, 'error', 'sticky');
        });
    }

}
