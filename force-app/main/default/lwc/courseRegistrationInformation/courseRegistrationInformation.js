import { LightningElement, api } from 'lwc';

import calendaricon from '@salesforce/resourceUrl/calendaricon';
import flagicon from '@salesforce/resourceUrl/flagicon';
import mapicon from '@salesforce/resourceUrl/mapicon';
import staricon from '@salesforce/resourceUrl/staricon';

export default class courseRegistrationInformation extends LightningElement {
    @api courseId;

    //icons
    calendaricon = calendaricon;
    flagicon = flagicon;
    mapicon = mapicon;
    staricon = staricon;
}