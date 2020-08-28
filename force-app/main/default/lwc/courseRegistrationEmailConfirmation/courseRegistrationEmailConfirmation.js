import { LightningElement, api } from 'lwc';
import getEmailPreview from '@salesforce/apex/EmailPreviewComponent.getEmailPreview';

export default class CourseRegistrationEmailConfirmation extends LightningElement {

    @api recipients;
    @api templateName;
    @api useDoNotReply;


}