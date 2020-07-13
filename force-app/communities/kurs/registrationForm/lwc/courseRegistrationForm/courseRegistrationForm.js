import { LightningElement, track } from 'lwc';
import findOrCreateContact from '@salesforce/apex/CourseRegistrationController.findOrCreateContact';
export default class CourseRegistrationForm extends LightningElement {
    @track theRecord = {};
    @track output;

    handleChange(event) {
        this.theRecord[event.target.name] = event.target.value;
    }
    handleSubmit() {
        let output = JSON.stringify(this.theRecord, null);
        findOrCreateContact({ fields: output });
    }

}