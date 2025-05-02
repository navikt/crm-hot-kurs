import { LightningElement, api, wire } from 'lwc';
import isCourseActive from '@salesforce/apex/CourseController.isCourseActive';

export default class CourseCopyLinkButton extends LightningElement {
    @api recordId;
    isActive = false;
    copied = false;
    copyNotAllowed = false;

    get generatedLink() {
        return `https://arbeidsgiver.nav.no/kursoversikt/${this.recordId}`;
    }

    async handleCopyClick() {
        // Reset messages
        this.copied = false;
        this.copyNotAllowed = false;

        try {
            const result = await isCourseActive({ courseId: this.recordId });
            this.isActive = result;

            if (!this.isActive) {
                this.copyNotAllowed = true;
                return;
            }

            const textArea = document.createElement('textarea');
            textArea.value = this.generatedLink;
            document.body.appendChild(textArea);
            textArea.select();

            try {
                document.execCommand('copy');
                this.copied = true;
            } catch (err) {
                console.error('Failed to copy: ', err);
            }

            document.body.removeChild(textArea);

            setTimeout(() => {
                this.copied = false;
                this.copyNotAllowed = false;
            }, 20000);
        } catch (error) {
            console.error('Error refreshing course status:', error);
            this.copyNotAllowed = true;
        }
    }
}
