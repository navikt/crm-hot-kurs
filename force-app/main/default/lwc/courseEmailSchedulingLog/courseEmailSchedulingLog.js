import { LightningElement, api, track } from 'lwc';
import getLogData from '@salesforce/apex/CourseEmailSchedulingLog.getLogDataWithCanceledEmails';
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
                const tempData = JSON.parse(JSON.stringify(result));
                tempData.forEach((item) => {
                    item._children = item.Children;
                    delete item.Children;
                });
                this.data = tempData;
                this.isLoading = false;
            })
            .catch((error) => {
                console.error('Error:', error);
            });
    }

    handleOnselect(event) {
        const selectedItemValue = event.detail.name;

        if (!this.data) {
            return;
        }

        this.data.forEach((item, i) => {
            if (item.name === selectedItemValue) {
                item.expanded = !item.expanded;
                this.template.querySelector('lightning-tree').items[i].expanded = item.expanded;
            }

            if (item.items) {
                item.items.forEach((subItem) => {
                    if (subItem.name === selectedItemValue) {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: subItem.TargetObjectId,
                                objectApiName: 'Contact',
                                actionName: 'view'
                            }
                        });
                    }
                });
            }
        });
    }

    get isEmpty() {
        return !this.data || this.data.length === 0;
    }
}
