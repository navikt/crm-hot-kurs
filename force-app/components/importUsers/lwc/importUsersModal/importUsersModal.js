import { LightningElement, api, track } from 'lwc';
import labels from './labels';

export default class ImportUsersModal extends LightningElement {
    @api columns;

    @track imported = false;
    @track contacts = [];
    labels = labels;

    addUsers() {
        const users = this.template
            .querySelector('[data-id="importTextField"]')
            .value.split(/\r?\n/);

        users.forEach(function (user, index) {
            if (user) {
                let regex = /(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/g;
                let email = user.toLowerCase().match(regex);

                // if email found, use the first from array
                if (email) email = email[0];
                var emailPattern = new RegExp(email, 'gi');
                let fullName = user
                    .replace(emailPattern, '')
                    .replaceAll(',', '')
                    .replaceAll(';', '')
                    .replaceAll('"', '')
                    .trim();
                this.push({ id: index, fullName: fullName, email: email });
            }
        }, this.contacts);

        this.imported = true;
    }

    removeContact(event) {
        if (this.contacts.length == 1) {
            this.contacts = [];
            this.imported = false;
        }

        let targetId = event.target.dataset.targetId;
        this.contacts.splice(targetId, 1);
    }

    // #########################################
    // ############# CUSTOM EVENT ##############
    // #########################################

    cancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    startImport() {
        this.dispatchEvent(
            new CustomEvent('success', { detail: this.contacts })
        );
    }
}
