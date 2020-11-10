import { LightningElement, api, track } from 'lwc';
import navlogo from '@salesforce/resourceUrl/nylogo';

export default class EmployerCommunityMenuItems extends LightningElement {
    navlogo = navlogo;
    @api NAVarea;
    @track isArbeidsgiver;
    @track isPrivatperson;
    @track isSamarbeidspartner;

    connectedCallback() {
        this.isPrivatperson = this.NAVarea == 'Privatperson';
        this.isArbeidsgiver = this.NAVarea == 'Arbeidsgiver';
        this.isSamarbeidspartner = this.NAVarea == 'Samarbeidspartner';
    }
}