import { LightningElement, api } from 'lwc';
import getEmailPreview from '@salesforce/apex/CourseRegistrationEmailPreview.getEmailPreview';

export default class CourseRegistrationEmailConfirmation extends LightningElement {

    @api recipients;
    @api templateName;
    @api useDoNotReply;


}