import { LightningElement, track, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
//import isProdFunction from '@salesforce/apex/GlobalCommunityHeaderFooterController.isProd';

export default class EmployerCommunityFooter extends LightningElement {

    @api NAVarea;

    //@track isProd = window.location.toString().includes("tolkebestilling.nav.no/");
    @track isPrivatPerson = true;
    //@track isProd;
    //@track error;
    //@wire(isProdFunction)
    //wiredIsProd({ error, data }) {
    //	this.isProd = data;
    //console.log("isProd: " + this.isProd);
    //}

    scrollToTop() {
        window.scroll(0, 0, 'smooth');

    }

    @track isDelSkjerm = false;
    onHandleClickDelSkjerm() {
        this.isDelSkjerm = !this.isDelSkjerm;
    }

    @track isSkjermdelingLesMer = false;
    onHandleClickSkjermdelingInfo() {
        this.isSkjermdelingLesMer = !this.isSkjermdelingLesMer;
    }

    functionalityNotSupported() {
        alert("Vi støtter dessverre ikke denne funksjonaliteten i dag.");
    }

    @wire(CurrentPageReference) pageRef;
    connectedCallback() {
        registerListener('clienttypeselected', this.handleClientTypeSelected, this);
        registerListener('menuSelectedEvent', this.handleMenuSelected, this);
        //this.isPrivatPerson= this.NAVarea == 'Privatperson';
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    //@track isPrivatPerson = true;
    @track isArbeidsgiver = false;
    @track isSamarbeidspartner = false;
    handleClientTypeSelected(data) {
        this.isPrivatPerson = data.isPrivatPerson;
        this.isArbeidsgiver = data.isArbeidsgiver;
        this.isSamarbeidspartner = data.isSamarbeidspartner;
    }

    @track menuPressed = false;
    handleMenuSelected(isSelected) {
        this.menuPressed = isSelected;
    }

}