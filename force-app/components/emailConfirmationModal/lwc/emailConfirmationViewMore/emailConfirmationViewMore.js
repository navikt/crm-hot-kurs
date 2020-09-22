import { LightningElement, api, track } from 'lwc';
import labels from "./labels";

export default class EmailConfirmationViewMore extends LightningElement {

    @api amountToLoad = '+10';
    @api recipients;

    @track showPopover = false;
    @track showPopoverButton = true;
    @track labels = labels;

    viewPopover() {
        console.log('viewPopover');
        this.showPopover = true;
    }
    hidePopover() {
        console.log('hidePopover');
        this.showPopover = false;
    }
    expandRecipients() {
        this.showPopoverButton = false;
        this.hidePopover();
        this.dispatchEvent(new CustomEvent('expandrecipients'));
    }
    collapseRecipients() {
        this.showPopoverButton = true;
        this.dispatchEvent(new CustomEvent('collapserecipients'));
    }
}