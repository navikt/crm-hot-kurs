import { LightningElement, api } from 'lwc';
import icons from '@salesforce/resourceUrl/icons';

export default class CourseRegistrationInformation extends LightningElement {
    @api courseFields;

    //icons
    calendaricon = icons + '/calendaricon.svg';
    flagicon = icons + '/flagicon.svg';
    mapicon = icons + '/mapicon.svg';
    staricon = icons + '/staricon.svg';

    get courseStart() {
        const courseStart = this.parseDate(this.courseFields?.RegistrationFromDateTime__c);
        const courseEnd = this.parseDate(this.courseFields?.RegistrationToDateTime__c);
        return `${this.formatDate(courseStart)} kl. ${this.formatTime(courseStart)} - ${this.formatTime(courseEnd)}`;
    }

    get registrationDeadline() {
        const deadline = this.parseDate(this.courseFields?.RegistrationDeadline__c);
        return `${this.formatDate(deadline)} kl. ${this.formatTime(deadline)}`;
    }

    get place() {
        return this.courseFields?.RegistrationPlaceName__c;
    }

    get type() {
        return this.courseFields?.Type__c;
    }

    get seats() {
        const currentSignups = this.courseFields?.RegistrationSignupsCount__c || 0;
        return this.courseFields?.MaxNumberOfParticipants__c - currentSignups;
    }

    parseDate(value) {
        if (!value) {
            return undefined;
        }

        const localDateValue = /^\d{4}-\d{2}-\d{2}$/.test(value) ? `${value}T00:00:00` : value;
        return new Date(localDateValue);
    }

    formatDate(date) {
        if (!date) {
            return '';
        }

        return new Intl.DateTimeFormat('nb-NO', {
            day: '2-digit',
            month: 'short'
        }).format(date);
    }

    formatTime(date) {
        if (!date) {
            return '';
        }

        return new Intl.DateTimeFormat('nb-NO', {
            hour: '2-digit',
            minute: '2-digit'
        }).format(date);
    }
}
