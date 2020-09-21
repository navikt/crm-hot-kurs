import { LightningElement, track } from 'lwc';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class HeaderSearchButton extends LightningElement {
    @track searchPressed = false;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    handleOnClickSearch(event) {
        this.searchPressed = !this.searchPressed;
    }
}