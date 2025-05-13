import { LightningElement, track, wire } from 'lwc';
import getCourseEmailSubscriber from '@salesforce/apex/CourseEmailSubscriberController.getCourseEmailSubscriber';
import updateCourseEmailSubscriber from '@salesforce/apex/CourseEmailSubscriberController.updateCourseEmailSubscriber';
import activateCourseEmailSubscriber from '@salesforce/apex/CourseEmailSubscriberController.activateCourseEmailSubscriber';
import { refreshApex } from '@salesforce/apex';

export default class CourseManageEmailSubscription extends LightningElement {
    @track emailSubscriberId;
    parameters = {};

    @track isActive = true;
    @track showConfirmation = false;
    @track emailSubcriber;

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.emailSubscriberId = this.parameters.id;

        // getCourseEmailSubscriber({ Id: this.emailSubscriberId }).then((result) => {
        //     this.emailSubcriber = result;
        //     if (this.emailSubcriber.isActive__c == false) {
        //         this.isActive = false;
        //     } else {
        //         const categories = result.Categories__c
        //             ? result.Categories__c.split(';').map((item) => item.trim())
        //             : [];

        //         const subCategories = result.SubCategories__c
        //             ? result.SubCategories__c.split(';').map((item) => item.trim())
        //             : [];

        //         this.setCheckboxes(categories, subCategories);
        //     }
        // });
    }

    wiredSubscriberResult;

    @wire(getCourseEmailSubscriber, { Id: '$emailSubscriberId' })
    wiredSubscriber(result) {
        this.wiredSubscriberResult = result; // store for refresh
        const { data, error } = result;
        if (data) {
            this.emailSubcriber = data;
            if (data.isActive__c === false) {
                this.isActive = false;
            } else {
                this.isActive = true;
                const categories = data.Categories__c ? data.Categories__c.split(';').map((item) => item.trim()) : [];
                const subCategories = data.SubCategories__c
                    ? data.SubCategories__c.split(';').map((item) => item.trim())
                    : [];

                this.setCheckboxes(categories, subCategories);
            }
        } else if (error) {
            console.error('Error fetching subscriber:', error);
        }
    }
    setCheckboxes(categories, subCategories) {
        const allCheckboxes = this.template.querySelectorAll('c-checkbox');
        allCheckboxes.forEach((checkbox) => {
            const name = checkbox.name;
            if (categories.includes(name) || subCategories.includes(name)) {
                checkbox.setCheckboxValue(true);
            } else {
                checkbox.setCheckboxValue(false);
            }
        });
    }

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === '' ? value : decodeURIComponent(value);
            });
        }
        return params;
    }
    handleActivaEmailSubscription() {
        activateCourseEmailSubscriber({
            Id: this.emailSubscriberId
        })
            .then(() => {
                //this.showConfirmation = true;
                this.isActive = true;
                refreshApex(this.wiredSubscriberResult);
            })
            .catch((error) => {
                alert('feil');
                console.error('Feil ved lagring:', error);
            });
    }
    handleSubmit() {
        alert('går inn her' + this.emailSubscriberId);
        const allCheckboxes = this.template.querySelectorAll('c-checkbox');
        const selectedCategories = [];
        const selectedSubCategories = [];

        const categoryNames = [
            'Hjelpemidler og tilrettelegging',
            'Inkluderende arbeidsliv (IA)',
            'Arbeidssøkeraktivitet'
        ];

        const subCategoryNames = [
            'Bevegelse',
            'Bolig',
            'Hørsel',
            'Kognisjon',
            'Kommunikasjon (ASK)',
            'Syn',
            'Service og reperasjon',
            'Tilrettelegging i arbeid',
            'Varsling'
        ];
        console.log('hei');
        allCheckboxes.forEach((checkbox) => {
            if (checkbox.getValue()) {
                const name = checkbox.name;

                if (categoryNames.includes(name)) {
                    selectedCategories.push(name);
                } else if (subCategoryNames.includes(name)) {
                    selectedSubCategories.push(name);
                }
            }
        });
        const categoriesStr = selectedCategories.join(';');
        const subCategoriesStr = selectedSubCategories.join(';');
        // Kall Apex for å lagre
        updateCourseEmailSubscriber({
            Id: this.emailSubscriberId,
            categories: categoriesStr,
            subCategories: subCategoriesStr
        })
            .then(() => {
                console.log('Lagret!');
                //this.showConfirmation = true;
            })
            .catch((error) => {
                alert('feil');
                console.error('Feil ved lagring:', error);
            });
    }
}
