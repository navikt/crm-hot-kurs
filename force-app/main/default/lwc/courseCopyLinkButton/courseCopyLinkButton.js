import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isCourseActive from '@salesforce/apex/CourseController.isCourseActive';

export default class CourseCopyLinkButton extends LightningElement {
    @api recordId;

    get generatedLink() {
        return `https://arbeidsgiver.nav.no/kursoversikt/${this.recordId}`;
    }

    async handleCopyClick() {
        try {
            const isActive = await isCourseActive({ courseId: this.recordId });

            if (!isActive) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Ikke mulig å kopiere',
                        message: 'Kurset er ikke aktivt og kan ikke kopieres.',
                        variant: 'warning'
                    })
                );
                return;
            }

            const textArea = document.createElement('textarea');
            textArea.value = this.generatedLink;
            document.body.appendChild(textArea);
            textArea.select();

            try {
                document.execCommand('copy');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Lenke kopiert',
                        message: 'Kurslenken ble kopiert til utklippstavlen.',
                        variant: 'success'
                    })
                );
            } catch (err) {
                console.error('Failed to copy: ', err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Feil',
                        message: 'Klarte ikke å kopiere lenken.',
                        variant: 'error'
                    })
                );
            }

            document.body.removeChild(textArea);
        } catch (error) {
            console.error('Error checking course status:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Feil',
                    message: 'Kunne ikke hente kursstatus.',
                    variant: 'error'
                })
            );
        }
    }
}
