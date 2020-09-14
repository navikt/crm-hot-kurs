import { LightningElement, api, wire, track } from 'lwc';
import getEmailPreview from '@salesforce/apex/EmailPreviewComponent.getEmailPreview';
import labels from "./labels";

export default class CourseRegistrationEmailConfirmation extends LightningElement {

    @api courseId = 'a0A1j000003Z3aEEAS';
    @api recipients = [
        {
            "type": 'avatar',
            "label": "Johnnie O'Brien",
            "name": "john.foreland@me.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Rosalie Clayton",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Donte Briggs",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Yasmeen Stout",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Meghan Brown",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Louisa Howells",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Azaan Mac",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Jawad Rubio",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Aarron Carson",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Yasmin Kay",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Andrew Zuniga",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Parker Muir",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Greta Bull",
            "name": "john.foreland@icloud.com",
            "fallbackIconName": 'standard:user',
            "variant": 'circle'
        },
        {
            "type": 'avatar',
            "label": "Alexa Frank",
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
    @track labels = labels;
    @track errorMsg;

    @track amountToLoad;

    connectedCallback() {
        console.log('t');

        for (var i = 0; i < 3; i++) {
            let recipient = this.recipients[i];
            this.recipientBadges.push({ "id": recipient.name, "label": recipient.label });
        }

        if (this.recipients.length > 3) {
            this.amountToLoad = '+' + (this.recipients.length - 3).toString();
        }

    }

    @wire(getEmailPreview, { recordId: '$courseId', emailTemplate: '$templateName' })
    deWire(result) {
        if (result.data) {
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