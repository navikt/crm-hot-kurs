import { LightningElement, wire, api, track } from 'lwc';
import getLogData from '@salesforce/apex/CourseEmailSchedulingLog.getLogData';
import { NavigationMixin } from 'lightning/navigation';

export default class CourseEmailSchedulingLog extends NavigationMixin(LightningElement) {
    @api recordId;
    @track data;
    @track isLoading = true;

    connectedCallback() {
        this.load();
    }

    load() {
        this.isLoading = true;
        getLogData({ recordId: this.recordId })
            .then((result) => {
                var tempData = JSON.parse(JSON.stringify(result));
                for (var i = 0; i < tempData.length; i++) {
                    tempData[i]._children = tempData[i]['Children'];
                    delete tempData[i].Children;
                }
                this.data = tempData;
                this.isLoading = false;
            })
            .catch((error) => {});
    }

    handleOnselect(event) {
        let selectedItemValue = event.detail.name;

        if (!this.data) {
            return;
        }

        for (var i = 0; i < this.data.length; i++) {
            if (this.data[i].name == selectedItemValue) {
                this.data[i].expanded = !this.data[i].expanded;
                this.template.querySelector('lightning-tree').items[i].expanded = this.data[i].expanded;
            }

            if (this.data[i].items) {
                for (var j = 0; j < this.data[i].items.length; j++) {
                    if (this.data[i].items[j].name == selectedItemValue) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.data[i].items[j].TargetObjectId,
                                objectApiName: 'Contact',
                                actionName: 'view'
                            }
                        });
                    }
                }
            }
        }
    }

    get isEmpty() {
        if (this.data) {
            return this.data.length == 0;
        } else {
            return true;
        }
    }
}
