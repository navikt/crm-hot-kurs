import { LightningElement, track } from 'lwc';
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class HeaderDropdownMenu extends LightningElement {
    dekoratoren = dekoratoren;
    @track menuPressed = false;

    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    handleOnClickMenu(event) {
        console.log('test');
        this.menuPressed = !this.menuPressed;

        //this.sendMenuSelectedEvent();
    }
}