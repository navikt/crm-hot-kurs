import { LightningElement, track, wire } from 'lwc';
import getCourseEmailSubscriber from '@salesforce/apex/CourseEmailSubscriberController.getCourseEmailSubscriber';
import updateCourseEmailSubscriber from '@salesforce/apex/CourseEmailSubscriberController.updateCourseEmailSubscriber';
import activateCourseEmailSubscriber from '@salesforce/apex/CourseEmailSubscriberController.activateCourseEmailSubscriber';
import deleteCourseEmailSubscriber from '@salesforce/apex/CourseEmailSubscriberController.deleteCourseEmailSubscriber';

import { refreshApex } from '@salesforce/apex';

export default class CourseManageEmailSubscription extends LightningElement {
    @track emailSubscriberId;
    parameters = {};

    @track showCheckboxes = false;
    @track showConfirmation = false;
    @track emailSubcriber;
    @track isSubmitButtonDisabled = false;
    @track isNotActive = false;
    @track displayMessage = '';
    @track noRecord = false;

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.emailSubscriberId = this.parameters.id;
    }
    _checkboxesInitialized = false;

    renderedCallback() {
        if (this.showCheckboxes && !this._checkboxesInitialized) {
            const allCheckboxes = this.template.querySelectorAll('c-checkbox');
            if (allCheckboxes.length > 0) {
                const categories = this.emailSubcriber?.Categories__c
                    ? this.emailSubcriber.Categories__c.split(';').map((item) => item.trim())
                    : [];
                const subCategories = this.emailSubcriber?.SubCategories__c
                    ? this.emailSubcriber.SubCategories__c.split(';').map((item) => item.trim())
                    : [];

                this.setCheckboxes(categories, subCategories);
                this._checkboxesInitialized = true;
            }
        }
    }

    wiredSubscriberResult;

    @wire(getCourseEmailSubscriber, { Id: '$emailSubscriberId' })
    wiredSubscriber(result) {
        this.wiredSubscriberResult = result;
        const { data, error } = result;
        if (data) {
            this.emailSubcriber = data;

            if (data.isActive__c === false) {
                this.isNotActive = true;
                this.showCheckboxes = false;
            } else {
                this.showCheckboxes = true;
                this._checkboxesInitialized = false; // reset hvis vi laster på nytt
            }
        } else if (error) {
            this.showCheckboxes = false;
            this.noRecord = true;
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
        this.isNotActive = false;
        activateCourseEmailSubscriber({
            Id: this.emailSubscriberId
        })
            .then(() => {
                this.showCheckboxes = true;
                refreshApex(this.wiredSubscriberResult);
            })
            .catch((error) => {
                alert('feil');
                console.error('Feil ved lagring:', error);
            });
    }
    handleSubmitDelete() {
        deleteCourseEmailSubscriber({
            Id: this.emailSubscriberId
        })
            .then(() => {
                this.showCheckboxes = false;
                this.displayMessage =
                    'Din e-postadresse og valgte kategorier ble slettet. Du vil ikke lenger motta epost om nye kurs.';
                this.showConfirmation = true;
            })
            .catch((error) => {
                this.displayMessage('Feil ved lagring:', error);
            });
    }
    handleSubmit() {
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
            'Service og reparasjon',
            'Tilrettelegging i arbeid',
            'Varsling'
        ];
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
                this.displayMessage = 'Endringene ble lagret';
                this.showConfirmation = true;
                this.isSubmitButtonDisabled = true;
                this.showCheckboxes = false;
            })
            .catch((error) => {
                this.displayMessage('Feil ved lagring:', error);
            });
    }
}
