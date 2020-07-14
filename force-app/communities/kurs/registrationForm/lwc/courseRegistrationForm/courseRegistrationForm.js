import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import findOrCreateContact from '@salesforce/apex/CourseRegistrationController.findOrCreateContact';

export default class CourseRegistrationForm extends NavigationMixin(LightningElement) {
    @track theRecord = {};
    @track output;

    @track showForm = true;
    @track showConfirmation = false;
    @track message;


    handleChange(event) {
        this.theRecord[event.target.name] = event.target.value;
    }
    handleSubmit() {
        let output = JSON.stringify(this.theRecord, null);
        findOrCreateContact({ fields: output })
            .then(result => {
                this.showForm = false;
                this.showConfirmation = true;
                this.message = result;
                console.log('result', result);
            });
    }
}