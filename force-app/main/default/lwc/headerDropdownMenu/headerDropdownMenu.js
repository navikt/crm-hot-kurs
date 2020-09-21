import { LightningElement, track } from 'lwc';

export default class HeaderDropdownMenu extends LightningElement {

    @track menuPressed = false;

    handleOnClickMenu(event) {
        console.log('test');
        this.menuPressed = !this.menuPressed;

        //this.sendMenuSelectedEvent();
    }
}