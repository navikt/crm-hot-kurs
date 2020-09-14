import { LightningElement, api, track } from 'lwc';
import loadMoreRecipients from "@salesforce/label/c.EmailPreview_loadMoreRecipients";
import hide from "@salesforce/label/c.EmailPreview_hide";
import hideAria from "@salesforce/label/c.EmailPreview_hideAria";

export default class EmailConfirmationViewMore extends LightningElement {

    @api amountToLoad = '+10';
    @api recipients;

    @track showPopover = false;
    @track showPopoverButton = true;
    loadMoreRecipients = loadMoreRecipients;
    hide = hide;
    hideAria = hideAria;

    viewPopover() {
        this.showPopover = true;
    }
    hidePopover() {
        this.showPopover = false;
    }
    expandRecipients() {
        this.showPopoverButton = false;
        this.hidePopover();
        console.log('1');
        const evt = new CustomEvent('expandrecipients');
        this.dispatchEvent(evt);
        console.log('2');
    }
    collapseRecipients() {
        this.showPopoverButton = true;
        const evt = new CustomEvent('collapserecipients');
        this.dispatchEvent(evt);
    }
}