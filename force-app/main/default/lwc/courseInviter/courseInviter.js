import { LightningElement, track } from 'lwc';

export default class Basic extends LightningElement {

    @track items = [];
    emails = []; //Array for

    // add pills
    addEmail(event) {

        let email = event.target.value;

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

    //test send button
    sendEmail() {
        alert(JSON.stringify(this.items));
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

    }

}