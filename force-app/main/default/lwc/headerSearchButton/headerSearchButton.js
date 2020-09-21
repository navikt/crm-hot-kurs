import { LightningElement, track } from 'lwc';

export default class HeaderSearchButton extends LightningElement {
    @track searchPressed = false;
    handleOnClickSearch(event) {
        this.searchPressed = !this.searchPressed;
    }
}