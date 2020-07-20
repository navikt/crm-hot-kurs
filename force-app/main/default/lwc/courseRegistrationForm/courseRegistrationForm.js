import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import createRegistration from "@salesforce/apex/CourseRegistrationController.createRegistration";

export default class CourseRegistrationForm extends NavigationMixin(
  LightningElement
) {
  @track theRecord = {};
  @track output;

  @track showForm = true;
  @track showConfirmation = false;
  @track showError = false;
  @track message;

  @track courseId;

  parameters = {};

  connectedCallback() {
    this.parameters = this.getQueryParameters();
    this.courseId = this.parameters.id;
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

  handleChange(event) {
    this.theRecord[event.target.name] = event.target.value;
    this.showError = false;
  }
  handleSubmit() {
    if (
      this.theRecord.firstName &&
      this.theRecord.lastName &&
      this.theRecord.email &&
      this.theRecord.phone
    ) {
      let output = JSON.stringify(this.theRecord, null);
      createRegistration({ fields: output, courseId: this.courseId }).then(
        result => {
          this.showForm = false;
          this.showConfirmation = true;
          this.message = result;
        }
      );
    } else {
      this.showError = true;
    }
  }
}
