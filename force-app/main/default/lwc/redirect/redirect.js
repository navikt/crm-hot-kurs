import { LightningElement } from 'lwc';

export default class Redirect extends LightningElement {
    connectedCallback() {
        window.location.replace('https://arbeidsgiver.nav.no/kursoversikt/');
    }
}
