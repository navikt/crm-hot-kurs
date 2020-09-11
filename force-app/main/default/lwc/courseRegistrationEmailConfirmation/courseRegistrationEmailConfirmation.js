import { LightningElement, api, wire, track } from 'lwc';
import getEmailPreview from '@salesforce/apex/EmailPreviewComponent.getEmailPreview';

export default class CourseRegistrationEmailConfirmation extends LightningElement {

    @api courseId = 'a0A1X00000344NxUAI';
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
    @track recipientBadges = [];

    @track loading = true;
    @track error = false;
    @track errorMsg;

    connectedCallback() {
        console.log('courseId: ' + this.courseId);
        // console.log('recipients: ' + this.recipients);
        // console.log('templateName: ' + this.templateName);
        // console.log('useDoNotReply: ' + this.useDoNotReply);
        this.recipients.forEach(recipient => {
            this.recipientBadges.push({ "id": recipient.name, "label": recipient.label });
        });
    }

    @wire(getEmailPreview, { recordId: '$courseId', emailTemplate: '$templateName' })
    deWire(result) {
        console.log("before");
        console.log('templateName: ' + this.templateName);
        if (result.data) {
            console.log("success");
            this.htmlEmail = result.data;
            this.loading = false;
        } else if (result.error) {
            console.log("error");
            console.log(JSON.stringify(result.error));
            this.setError(result.error);
        }
    }



    setError(error) {
        this.loading = false;
        this.error = true;
        if (error.body && error.body.exceptionType && error.body.message) {
            this.errorMsg = `[ ${error.body.exceptionType} ] : ${error.body.message}`;
        } else if (error.body && error.body.message) {
            this.errorMsg = `${error.body.message}`;
        } else if (typeof error === String) {
            this.errorMsg = error;
        } else {
            this.errorMsg = JSON.stringify(error);
        }
    }

}