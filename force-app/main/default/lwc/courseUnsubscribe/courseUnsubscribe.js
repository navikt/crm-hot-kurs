import { LightningElement, track } from 'lwc';
import updateCourseRegistration from "@salesforce/apex/CourseUnsubscribeController.updateCourseRegistration";
import getCourseRegistrationFields from "@salesforce/apex/CourseUnsubscribeController.getCourseRegistrationFields";

export default class CourseUnsubscribe extends LightningElement {
    @track courseRegId;
    parameters = {};
    @track showButton = true;
    @track showConfirmation = false;
    @track name;
    @track course;

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.courseRegId = this.parameters.id;

        getCourseRegistrationFields({ courseRegId: this.courseRegId }).then(
            result => {
                this.name = result.CourseParticipantName__c;
                this.course = result.Course__r.Name;
            }
        );

        console.log('id' + this.courseRegId);
    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse(
                '{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}',
                (key, value) => {
                    return key === "" ? value : decodeURIComponent(value);
                }
            );
        }
        return params;
    }

    handleSubmit(event) {
        updateCourseRegistration({ courseRegId: this.courseRegId }).then(
            result => {
                this.showButton = false;
                this.showConfirmation = true;
            }
        );
    }

}