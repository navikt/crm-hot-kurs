import { LightningElement, api, track } from 'lwc';
import getCourseFields from "@salesforce/apex/CourseRegistrationController.getCourseFields";
import icons from '@salesforce/resourceUrl/icons'

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


    connectedCallback() {

        getCourseFields({ courseId: this.courseId }).then(
            result => {
                if (result) {
                    let courseStart = result.RegistrationFromDateTime__c;
                    let courseEnd = result.RegistrationToDateTime__c;
                    this.registrationDeadline = result.RegistrationDeadline__c;
                    this.place = result.RegistrationPlaceName__c;
                    this.type = result.Type__c;


                } else {

                }
            }
        );

    }
}