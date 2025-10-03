import { LightningElement, track, wire } from 'lwc';
import getCourseRegistrationFields from '@salesforce/apex/CourseUnsubscribeController.getCourseRegistrationFields';
import updateCourseRegistrationStatusToAvmeldt from '@salesforce/apex/CourseUnsubscribeController.updateCourseRegistrationStatusToAvmeldt';
import updateCourseRegistrationNumberOfParticipants from '@salesforce/apex/CourseUnsubscribeController.updateCourseRegistrationNumberOfParticipants';

export default class CourseUnsubscribe extends LightningElement {
    @track courseRegId;
    @track showButton = true; // keeps outer container logic
    @track showConfirmation = false;
    @track isLoading = true;

    @track name;
    @track course;
    @track status;
    @track numberOfParticipants;
    @track newCount;

    // UI state for multi-attendee flow
    @track reduceMode = false; // toggled when user clicks "Endre antall"

    connectedCallback() {
        const params = this.getQueryParameters();
        this.courseRegId = params.id;
    }

    @wire(getCourseRegistrationFields, { courseRegId: '$courseRegId' })
    wiredCourse({ data, error }) {
        if (data) {
            this.name = data.CourseParticipantName__c;
            this.course = data.Course__r?.Name;
            this.numberOfParticipants = data.NumberOfParticipants__c;
            this.status = data.Status__c;
            this.isLoading = false;
        } else if (error) {
            console.error(error);
            this.template.host.setAttribute('data-msg', 'Noe gikk galt. Prøv igjen senere.');
            this.showButton = false;
            this.showConfirmation = true;
            this.isLoading = false;
        }
    }

    getQueryParameters() {
        let params = {};
        const search = location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (k, v) =>
                k === '' ? v : decodeURIComponent(v)
            );
        }
        return params;
    }

    // --- Event handlers ---
    handleStartReduce() {
        this.reduceMode = true;
        // prefill with current-1 as a sane default
        const cur = Number(this.numberOfParticipants || 0);
        this.newCount = cur > 1 ? cur - 1 : 1;
    }

    handleCountChange(event) {
        this.newCount = Number(event.target.value);
    }

    async handlePartialSubmit() {
        try {
            this.isLoading = true;
            const current = Number(this.numberOfParticipants || 0);
            const desired = Number(this.newCount || 0);

            if (!(current > 1 && desired >= 1 && desired < current)) {
                this.template.host.setAttribute(
                    'data-msg',
                    'Ugyldig antall. Velg mellom 1 og ' + this.maxReduceTo + '.'
                );
                this.showButton = false;
                this.showConfirmation = true;
                return;
            }

            await updateCourseRegistrationNumberOfParticipants({
                courseRegId: this.courseRegId,
                numberOfParticipants: desired
            });

            this.template.host.setAttribute('data-msg', `Antall påmeldte er oppdatert til ${desired}.`);
            this.showButton = false;
            this.showConfirmation = true;
        } catch (e) {
            console.error(e);
            this.template.host.setAttribute('data-msg', 'Noe gikk galt under oppdateringen. Prøv igjen.');
            this.showButton = false;
            this.showConfirmation = true;
        } finally {
            this.isLoading = false;
        }
    }

    async handleFullUnregister() {
        try {
            this.isLoading = true;
            await updateCourseRegistrationStatusToAvmeldt({ courseRegId: this.courseRegId });

            const current = Number(this.numberOfParticipants || 0);
            const msg = current > 1 ? 'Dere er nå meldt av kurset.' : 'Du er nå meldt av kurset.';
            this.template.host.setAttribute('data-msg', msg);

            this.showButton = false;
            this.showConfirmation = true;
        } catch (e) {
            console.error(e);
            this.template.host.setAttribute('data-msg', 'Noe gikk galt under bekreftelsen. Prøv igjen.');
            this.showButton = false;
            this.showConfirmation = true;
        } finally {
            this.isLoading = false;
        }
    }

    // --- Getters for conditional rendering ---
    get showSingleControls() {
        return !this.isStatusAvmeldt && Number(this.numberOfParticipants || 0) === 1 && this.showButton;
    }
    get showMultiControls() {
        return !this.isStatusAvmeldt && Number(this.numberOfParticipants || 0) > 1 && this.showButton;
    }
    get showCountEditor() {
        // kept for compatibility if you reference it in CSS, but not used anymore
        return this.reduceMode;
    }
    get isStatusAvmeldt() {
        return this.status === 'Avmeldt';
    }
    get maxReduceTo() {
        const n = Number(this.numberOfParticipants || 0);
        return n > 1 ? n - 1 : 1;
    }
    get hostMessage() {
        return this.template?.host?.getAttribute('data-msg') || 'Fullført.';
    }
    get ready() {
        return !this.isLoading;
    }
    @track reduceMode = false;

    toggleReduceMode() {
        this.reduceMode = !this.reduceMode;

        if (this.reduceMode) {
            const cur = Number(this.numberOfParticipants || 0);
            this.newCount = cur > 1 ? cur - 1 : 1;
        }
    }

    get reduceBtnClass() {
        return `btn-secondary${this.reduceMode ? ' is-active' : ''}`;
    }
    get reduceBtnLabel() {
        return this.reduceMode ? 'Avbryt' : 'Endre antall påmeldte';
    }
}
