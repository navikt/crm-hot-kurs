import { LightningElement, api, wire, track } from 'lwc';

import getEmailPreview from '@salesforce/apex/EmailConfirmationModalController.getEmailPreview';
import getEmailSubject from '@salesforce/apex/EmailConfirmationModalController.getEmailSubject';
import sendEmail from '@salesforce/apex/EmailConfirmationModalController.sendEmail';

import labels from './labels';

export default class EmailConfirmationModal extends LightningElement {
    // parameters
    @api recordId;
    @api templateName;
    @api recipients = [];
    @api isPreview;

    @track recipientBadges = [];

    @track htmlEmail;
    @track subject = labels.subjectField;

    @track loading = true;
    @track sendingEmail = true;
    @track error = false;
    @track errorMsg;
    @track labels = labels;

    @track amountToLoad;
    amountToView = 3;

    connectedCallback() {
        getEmailPreview({
            recordId: this.recordId,
            emailTemplate: this.templateName
        })
            .then((data) => {
                this.htmlEmail = data;
                this.loading = false;
                this.sendingEmail = false;
            })
            .catch((error) => {
                this.setError(error);
            });

        getEmailSubject({ emailTemplate: this.templateName }).then((data) => {
            this.subject = data;
        });

        // recipient badges
        let amount =
            this.recipients.length < this.amountToView
                ? this.recipients.length
                : this.amountToView; // if recipient length is less than viewable recipients, use recipient length
        this.loadRecipientsToBadges(amount);
        if (this.recipients.length > this.amountToView) {
            this.amountToLoad =
                '+' + (this.recipients.length - this.amountToView).toString();
        }
    }

    cancel(event) {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    send(event) {
        this.loading = true;
        this.sendingEmail = true;
        sendEmail({
            recordId: this.recordId,
            recipientsJson: JSON.stringify(this.recipients),
            template: this.templateName
        })
            .then((result) => {
                this.dispatchEvent(
                    new CustomEvent('success', { detail: result })
                );
                this.sendingEmail = false;
            })
            .catch((error) => {
                this.loading = false;
                this.sendingEmail = false;
                this.htmlEmail = '';
                this.error = true;
                this.setError(error);
                this.dispatchEvent(new CustomEvent('error', { detail: error }));
            });
    }

    loadRecipientsToBadges(amount) {
        this.recipientBadges = [];
        for (var i = 0; i < amount; i++) {
            let recipient = this.recipients[i];
            this.recipientBadges.push({
                id: recipient.email,
                label: recipient.fullName
            });
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
        if (
            error.body &&
            error.body.message &&
            typeof error.body.message === 'object' &&
            error.body.message !== null
        ) {
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
