import { LightningElement, track, wire, api } from 'lwc';

/*const screenWidth = screen.width;
const headerHeight = screenWidth > 576 ? 91 : 88;
const headerStartPosition = screenWidth > 576 ? 44 : 0;
var headerPosition = headerStartPosition;
var hovedbannerposition = headerStartPosition + headerHeight;
document.documentElement.style.setProperty('--fixed', "fixed");
document.documentElement.style.setProperty('--margintop', 0);
document.documentElement.style.setProperty('--hovedbannerposition', hovedbannerposition.toString() + "px");
document.documentElement.style.setProperty('--headerPosition', headerPosition.toString() + "px");
var prevScrolled = 0;


window.addEventListener('scroll', () => {
    var scrolled = window.scrollY;
    const difference = scrolled - prevScrolled;
    if (difference >= 0) {
        if (headerPosition > -headerHeight) {
            headerPosition = headerPosition - difference;
            hovedbannerposition = headerPosition + headerHeight;
        }
        else {
            headerPosition = -headerHeight
            hovedbannerposition = 0;
        }
    }
    else {
        if (headerPosition < 0) {
            headerPosition = headerPosition - difference;
            hovedbannerposition = headerPosition + headerHeight;
        }
        else if (scrolled < headerStartPosition) {
            headerPosition = headerStartPosition - scrolled;
            hovedbannerposition = headerPosition + headerHeight;
        }
        else {
            headerPosition = 0;
            hovedbannerposition = headerHeight;
        }

    }
    document.documentElement.style.setProperty('--headerPosition', headerPosition.toString() + "px");
    document.documentElement.style.setProperty('--hovedbannerposition', hovedbannerposition.toString() + "px");

    prevScrolled = scrolled;

});
*/
import dekoratoren from '@salesforce/resourceUrl/dekoratoren';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class EmployerCommunityHeader extends LightningElement {
    dekoratoren = dekoratoren;
    @api NAVarea;
    @track isPrivatPerson = true;
    renderedCallback() {
        loadStyle(this, dekoratoren);
    }

    connectedCallback() {
        //this.isPrivatPerson = this.NAVarea == 'Privatperson';
        //console.log(this.NAVarea);
        //console.log(this.isPrivatPerson);
    }



}