import { LightningElement, track } from 'lwc';

export default class courseRegistrationInformation extends LightningElement {

    @track courseId;
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