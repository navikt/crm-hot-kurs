import { LightningElement, api, wire, track } from 'lwc';
import getEmailPreview from '@salesforce/apex/EmailPreviewComponent.getEmailPreview';

export default class CourseRegistrationEmailConfirmation extends LightningElement {

    @api recordId = 'a096E00000Bsr13QAB';
    @api recipients = [
        {
            "type": 'avatar',
            "label": "Ola Nordmann",
            "name": "john.foreland@me.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Kari Nordmann",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        }
    ];
    @api templateName = 'courseRegistrationInvitation';
    @api useDoNotReply;

    @track htmlEmail;
    @track loading = true;
    @track recipientBadges = [];

    connectedCallback() {
        this.recipients.forEach(recipient => {
            this.recipientBadges.push({ "id": recipient.name, "label": recipient.label });
        });
    }

    // @wire(getEmailPreview, { recordId: '$recordId', emailTemplate: '$templateName' })
    @wire(getEmailPreview, { recordId: '$recordId', emailTemplate: '$templateName' })
    deWire(result) {
        if (result.data) {

            this.htmlEmail = result.data;
            this.loading = false;

        } else if (result.error) {

            // this.error = true;
            // this.loading = false;
            // this.setError(result.error);
        }
    }

}