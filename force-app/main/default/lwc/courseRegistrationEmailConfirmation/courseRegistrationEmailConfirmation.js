import { LightningElement, api, wire, track } from 'lwc';
import getEmailPreview from '@salesforce/apex/EmailPreviewComponent.getEmailPreview';
import getEmailSubject from '@salesforce/apex/EmailPreviewComponent.getEmailSubject';
import sendCourseEmail from "@salesforce/apex/CourseRegistrationEmailController.sendCourseEmail";
import labels from "./labels";

export default class CourseRegistrationEmailConfirmation extends LightningElement {

    @api courseId;
    @api recipients = [];
    @api templateName;
    @api useDoNotReply;

    @track htmlEmail;
    @track subject = labels.subjectField;
    @track recipientBadges = [];

    @track loading = true;
    @track error = false;
    @track labels = labels;
    @track errorMsg;

    @track amountToLoad;

    amountToView = 3;

    connectedCallback() {
        getEmailPreview({ recordId: this.courseId, emailTemplate: this.templateName }).then(data => {
            this.htmlEmail = data;
            this.loading = false;
        }).catch(error => {
            console.log('JSON.stringify(error): ' + JSON.stringify(error));
            this.setError(error);
        });

        getEmailSubject({ emailTemplate: this.templateName }).then(data => {
            this.subject = data;
        });

        let amount = this.recipients.length < this.amountToView ? this.recipients.length : this.amountToView; // if recipient length is less than viewable recipients, use recipient length

        this.loadRecipientsToBadges(amount);
        if (this.recipients.length > this.amountToView) {
            this.amountToLoad = '+' + (this.recipients.length - this.amountToView).toString();
        }
    }

    cancel(event) {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    send(event) {

    }

    loadRecipientsToBadges(amount) {
        this.recipientBadges = [];
        for (var i = 0; i < amount; i++) {
            let recipient = this.recipients[i];
            this.recipientBadges.push({ "id": recipient.name, "label": recipient.label });
        }
    }

    get hiddenRecipients() {
        let recipientCopy = [...this.recipients];
        return recipientCopy.splice(this.amountToView, this.recipients.length);
    }

    expandRecipients(event) {
        this.loadRecipientsToBadges(this.recipients.length);
    }
    collapseRecipients(event) {
        this.loadRecipientsToBadges(this.amountToView);
    }

    setError(error) {
        this.loading = false;
        this.error = true;
        if (error.body && error.body.message && typeof error.body.message === 'object' && error.body.message !== null) {
            this.errorMsg = JSON.stringify(error.body.message, undefined, 2);
        } else if (error.body && error.body.message) {
            this.errorMsg = error.body.message;
        } else if (typeof error === String) {
            this.errorMsg = error;
        } else {
            this.errorMsg = JSON.stringify(error, undefined, 2);
        }
    }
}