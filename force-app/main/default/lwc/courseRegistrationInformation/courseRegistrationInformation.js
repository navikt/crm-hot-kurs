import { LightningElement, api, track } from 'lwc';
import getCourseFields from '@salesforce/apex/CourseRegistrationController.getCourseFields';
import icons from '@salesforce/resourceUrl/icons';
import { loadScript } from 'lightning/platformResourceLoader';
import MOMENT_JS from '@salesforce/resourceUrl/moment';

export default class courseRegistrationInformation extends LightningElement {
    @api courseId;

    //icons
    calendaricon = icons + '/calendaricon.svg';
    flagicon = icons + '/flagicon.svg';
    mapicon = icons + '/mapicon.svg';
    staricon = icons + '/staricon.svg';

    @track registrationDeadline;
    @track place;
    @track type;
    @track seats;
    @track courseStart;

    connectedCallback() {
        Promise.all([loadScript(this, MOMENT_JS)]).then(() => {
            moment.locale('nb-no');
        });

        getCourseFields({ courseId: this.courseId }).then((result) => {
            if (result) {
                let courseEnd = moment(result.RegistrationToDateTime__c).format('LT');
                this.courseStart =
                    moment(result.RegistrationFromDateTime__c).format('DD. MMM') +
                    ' kl. ' +
                    moment(result.RegistrationFromDateTime__c).format('LT') +
                    ' - ' +
                    courseEnd;
                this.registrationDeadline =
                    moment(result.RegistrationDeadline__c).format('DD. MMM') +
                    ' kl. ' +
                    moment(result.RegistrationDeadline__c).format('LT');
                this.place = result.RegistrationPlaceName__c;
                this.type = result.Type__c;
                const currentSignups = result.RegistrationSignupsCount__c || 0;
                this.seats = result.MaxNumberOfParticipants__c - currentSignups;
            } else {
            }
        });
    }
}
