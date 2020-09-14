import { LightningElement, api, track } from 'lwc';
import loadMoreRecipients from "@salesforce/label/c.EmailPreview_loadMoreRecipients";

export default class EmailConfirmationViewMore extends LightningElement {

    @api amountToLoad = '+10';
    @api recipients;

    @track showPopover = false;
    loadMoreRecipients = loadMoreRecipients;

    viewPopover() {
        this.showPopover = true;
    }
    hidePopover() {
        this.showPopover = false;
    }

}