import { LightningElement, api, track } from 'lwc';
import getCourseFields from "@salesforce/apex/CourseRegistrationController.getCourseFields";
import calendaricon from '@salesforce/resourceUrl/calendaricon';
import flagicon from '@salesforce/resourceUrl/flagicon';
import mapicon from '@salesforce/resourceUrl/mapicon';
import staricon from '@salesforce/resourceUrl/staricon';

export default class courseRegistrationInformation extends LightningElement {
    @api courseId;

    //icons
    calendaricon = calendaricon;
    flagicon = flagicon;
    mapicon = mapicon;
    staricon = staricon;

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