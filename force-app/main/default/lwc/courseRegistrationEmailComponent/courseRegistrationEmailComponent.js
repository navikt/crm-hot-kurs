import { LightningElement, track } from 'lwc';
import sendCourseEmail from "@salesforce/apex/CourseRegistrationEmailController.sendCourseEmail";
import EmailSenderAddress from '@salesforce/schema/Network.EmailSenderAddress';

export default class CourseRegistrationEmailComponent extends LightningElement {

    @track items = []; //Tracks if new items are added
    emails = []; //Array for storing email addresses

    // add pills
    addEmail(event) {

        let email = event.target.value; // variable to hold the registered email address

        let emailIsValid = this.validateEmail(email); // variable to hold value of format-validation check result
        let emailIsUnique = !this.emails.includes(email); // variable to hold value of unique-validation check result


        if (emailIsValid && emailIsUnique) {

            // create new pill
            let pill = {};
            pill.type = 'avatar';
            pill.label = email;
            pill.name = email;
            pill.fallbackIconName = 'standard:user';
            pill.variant = 'circle';

            // add pill to container
            let items = this.items.push(pill);

            // reset input field
            this.template.querySelector('form').reset();

            //push email to array (emails)
            this.emails.push(email);

        }

    }

    //send emails method
    sendEmail() {
        sendCourseEmail({
            jsonStr: JSON.stringify(this.emails) //converting emails array to a string and sending it to Apex class CourseRegistrationEmailController
        }).catch(error => {
            console.log(JSON.stringify(error));
        });
        this.items = [];
        this.emails = [];
    }

    //Check if the email address has a valid format
    validateEmail(email) {
        const re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        return re.test(String(email).toLowerCase());
    }

    // remove pills
    handleItemRemove(event) {

        const index = event.detail.index;
        this.items.splice(index, 1);
        this.emails.splice(index, 1);
    }

}
