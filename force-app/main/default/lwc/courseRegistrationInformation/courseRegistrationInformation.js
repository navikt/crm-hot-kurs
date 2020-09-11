import { LightningElement, track, api } from 'lwc';
import calendaricon from '@salesforce/resourceUrl/calendaricon';
import flagicon from '@salesforce/resourceUrl/flagicon';
import mapicon from '@salesforce/resourceUrl/mapicon';
import staricon from '@salesforce/resourceUrl/staricon';

export default class courseRegistrationInformation extends LightningElement {

    //icons
    calendaricon = calendaricon;
    flagicon = flagicon;
    mapicon = mapicon;
    staricon = staricon;

    @api courseId;
    parameters = {};

    connectedCallback() {

        this.parameters = this.getQueryParameters();
        this.courseId = this.parameters.id;

    }

    getQueryParameters() {

        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }
}