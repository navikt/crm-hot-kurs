import { LightningElement, api } from 'lwc';
import title from '@salesforce/label/c.GdprConfirmation_title';
import subtitle from '@salesforce/label/c.GdprConfirmation_subtitle';

export default class GdprCheckboxModal extends LightningElement {
    @api title = title;
    @api subtitle = subtitle;

    cancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    accept() {
        this.dispatchEvent(new CustomEvent('accept'));
    }
}
