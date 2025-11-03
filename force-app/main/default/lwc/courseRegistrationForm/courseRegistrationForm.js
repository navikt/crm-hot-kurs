import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import createRegistration from '@salesforce/apex/CourseRegistrationController.createRegistration';
import getCourseFields from '@salesforce/apex/CourseRegistrationController.getCourseFields';
import getOrganizationInfo from '@salesforce/apex/CourseRegistrationController.getOrganizationInfo';
import icons from '@salesforce/resourceUrl/icons';
import houseIconNew from '@salesforce/resourceUrl/houseicon2';

export default class CourseRegistrationForm extends NavigationMixin(LightningElement) {
    @track courseId;

    @track theRecord = {
        subscribeEmail: false
    };

    @track output;

    @track showForm = false;
    @track showConfirmation = false;
    @track showError = false;
    @track displayErrorMessage = false;
    @track errorMessage;
    @track message;

    @track inputValCode = '';
    @track code;

    @track dueDate;
    @track title;
    @track canceled = false;
    @track allergies = false;
    @track invoiceAdress = false;
    @track invoiceReference = false;
    @track workplace = false;
    @track addMultipleParticipants = false;
    @track showNumberInput = false;
    @track maxNumberOfParticipants;
    @track numberOfParticipants;
    @track typeOfAttendance = false;
    targetGroup = '';
    showGroupTargetAlert = false;

    @track courseIsFullWarning = false;
    @track numberOnWaitinglist;

    @track showValidationInput = false;
    parameters = {};

    @track url;

    @track county = false;
    @track companyName = false;
    @track role = false;

    organizationNumberSearch;
    organizationName = 'Feltet fylles automatisk';
    showOrganizationNumber;

    @track subscribeEmailText;
    @track showEmailSubscribeContainer = false;

    @track subCategoryNames = [
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

    //icons
    warningicon = icons + '/warningicon.svg';
    informationicon = icons + '/informationicon.svg';
    successicon = icons + '/successicon.svg';
    erroricon = icons + '/erroricon.svg';
    chevrondown = icons + '/chevrondown.svg';
    houseicon = houseIconNew;

    generateSubscribeEmailText(theme, category) {
        const preText = 'Jeg ønsker å få e-post når Nav legger ut nye kurs om lignende tema: ';
        if (theme && !category) {
            if (theme !== 'Annet') {
                return `${preText}${theme}.`;
            }
        } else if (theme && category) {
            const formattedCategory = category.replace(/;/g, ', ');
            return `${preText} ${formattedCategory}.`;
        }
        return '';
    }

    connectedCallback() {
        this.parameters = this.getQueryParameters();
        this.courseId = this.parameters.id;

        getCourseFields({ courseId: this.courseId }).then((result) => {
            if (result) {
                this.code = result.InvitationCode__c;
                this.title = result.Name;
                this.companyName = result.ShowCompany__c;
                this.county = result.ShowCounty__c;
                this.role = result.ShowRole__c;
                this.canceled = result.Cancel__c;
                this.allergies = result.ShowAllergies__c;
                this.invoiceAdress = result.ShowInvoiceAdress__c;
                this.invoiceReference = result.ShowInvoiceReference__c;
                this.workplace = result.ShowWorkplace__c;
                this.addMultipleParticipants = result.ShowAddMultipleParticipants__c;
                this.additionalInformation = result.ShowAdditionalInformation__c;
                this.subscribeEmailText = this.generateSubscribeEmailText(result.Theme__c, result.Sub_category__c);
                this.showEmailSubscribeContainer = this.shouldShowEmailSubscribe(result.Sub_category__c);
                this.typeOfAttendance = result.ShowTypeOfAttendance__c;
                this.dueDate = result.RegistrationDeadline__c;
                this.showOrganizationNumber = result.ShowOrganizationNumber__c;
                this.targetGroup = result.TargetGroup__c || '';
                let registrationDeadline = new Date(this.dueDate);
                let dateNow = new Date(Date.now());
                this.url = 'https://arbeidsgiver.nav.no/kursoversikt/' + this.courseId;

                if (registrationDeadline > dateNow && this.canceled === false) {
                    this.showForm = true;
                } else {
                    if (!this.canceled) {
                        this.errorMessage = 'Påmeldingsfristen er passert, det er ikke lenger mulig å melde seg på';
                        this.displayErrorMessage = true;
                    } else {
                        this.errorMessage = 'Kurset er avlyst, det er ikke lenger mulig å melde seg på';
                        this.displayErrorMessage = true;
                    }
                }

                this.maxNumberOfParticipants = result.MaxNumberOfParticipants__c;
                this.numberOfParticipants = result.Registration_Signups_Count__c || 0;
                const waitlistedCount = result.Registration_Waitlisted_Count__c || 0;
                this.numberOnWaitinglist = waitlistedCount + 1;

                if (this.numberOfParticipants >= this.maxNumberOfParticipants) {
                    this.courseIsFullWarning = true;
                }

                if (this.code !== undefined) {
                    this.showForm = false;
                    this.showValidationInput = true;
                }
            }
        });
    }

    handleOrganizationNumberInput(event) {
        this.organizationNumberSearch = event.target.value;
        if (this.organizationNumberSearch.length == 9) {
            this.organizationName = 'Henter organisasjon...';
            try {
                getOrganizationInfo({
                    organizationNumber: this.organizationNumberSearch
                }).then((result) => {
                    if (result.length == 1) {
                        this.organizationName = result[0].Name;
                        this.theRecord.organizationName = result[0].Name;
                        this.theRecord.organizationNumber = this.organizationNumberSearch;
                    } else {
                        this.organizationName = 'Kunne ikke finne organisasjon';
                        this.theRecord.organizationName = null;
                        this.theRecord.organizationNumber = null;
                    }
                });
            } catch (error) {
                this.organizationName = error;
                this.theRecord.organizationName = null;
                this.theRecord.organizationNumber = null;
            }
        } else {
            this.organizationName = 'Feltet fylles automatisk';
            this.theRecord.organizationName = null;
            this.theRecord.organizationNumber = null;
        }
    }

    shouldShowEmailSubscribe(categoryField) {
        /* Bare vise mulighet for å abbonere på subcategories foreløpig */
        if (!categoryField) return false;

        const categories = categoryField.split(';').map((s) => s.trim());
        return categories.some((cat) => this.subCategoryNames.includes(cat));
    }

    getQueryParameters() {
        var params = {};
        var search = window.location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === '' ? value : decodeURIComponent(value);
            });
        }
        return params;
    }

    handleChange(event) {
        this.theRecord[event.target.name] = event.target.value;
        this.showError = false;
    }
    handleCheckboxClick(event) {
        this.theRecord[event.target.name] = event.detail;
        console.log('name ' + event.target.name);
        console.log('value ' + event.detail);
    }

    handleChange2(event) {
        this.inputValCode = event.target.value;
    }

    handleSubmit(event) {
        event.preventDefault();

        const requiredFields = [
            'firstName',
            'lastName',
            'email',
            'phone',
            'companyName',
            'county',
            'role',
            'invoiceAdress',
            'invoiceReference',
            'workplace',
            'typeOfAttendance',
            'organizationNumber'
        ]; // List of required fields
        const nonRequiredFields = ['allergies', 'additionalInformation']; // List of non required fields

        const fieldLabels = {
            firstName: 'Fornavn',
            lastName: 'Etternavn',
            email: 'E-post',
            phone: 'Telefon',
            companyName: 'Firma',
            county: 'Fylke',
            role: 'Rolle',
            invoiceAdress: 'Faktura adresse',
            invoiceReference: 'Faktura referanse',
            workplace: 'Arbeidsplass',
            allergies: 'Matallergi',
            additionalInformation: 'Tilleggsinformasjon (f.eks behov for tolk)',
            typeOfAttendance: 'Deltakelse',
            organizationNumber: 'Organisasjonsnummer'
        };

        for (const field of requiredFields) {
            const value = this.theRecord[field] ? this.theRecord[field].trim() : '';

            if (this[field] && !this.theRecord[field]) {
                this.showError = true;
                this.errorMessage = `Vennligst fyll ut alle feltene.`;
                return;
            }

            // Validate firstname, lastname and phone
            if (['firstName', 'lastName', 'phone', 'email'].includes(field)) {
                if (!value || value.length < 2) {
                    this.showError = true;
                    this.errorMessage = `Vennligst fyll ut ${fieldLabels[field]}.`;
                    return;
                }
            }

            // Validate field lengths (less than 255 characters)
            if (this.theRecord[field] && this.theRecord[field].length > 255) {
                this.showError = true;
                this.errorMessage = `${fieldLabels[field]} kan ikke være lengre enn 255 tegn.`;
                return;
            }
        }

        if (this.showNumberInput) {
            const n = Number(this.theRecord.numberOfParticipants);
            if (!n || !Number.isInteger(n) || n < 1) {
                this.showError = true;
                this.errorMessage = 'Oppgi et gyldig heltall ≥ 1 for antall deltakere.';
                return;
            }
            const availableSlots = this.maxNumberOfParticipants - this.numberOfParticipants;
            if (n > availableSlots && !(availableSlots === 0 && n === 1)) {
                this.showError = true;
                this.errorMessage =
                    'Det er ikke nok ledige plasser på kurset for ' +
                    n +
                    ' deltaker(e). Det er for øyeblikket ' +
                    availableSlots +
                    ' ledige plasser. ' +
                    'Vennligst reduser antall deltakere for å sikre en plass. For påmelding til venteliste, må kurset først være fullt og kun én deltaker kan meldes på om gangen til ventelisten.';
                return;
            }
        }

        // Organization number validation
        if (this.showOrganizationNumber) {
            const orgNum = this.theRecord.organizationNumber ? this.theRecord.organizationNumber.trim() : '';
            const orgRegex = /^[0-9]{9}$/;

            if (!orgRegex.test(orgNum)) {
                this.showError = true;
                this.errorMessage = 'Vennligst oppgi et gyldig organisasjonsnummer (9 sifre).';
                return;
            }

            if (
                this.organizationName === 'Kunne ikke finne organisasjon' ||
                this.organizationName === 'Feltet fylles automatisk'
            ) {
                this.showError = true;
                this.errorMessage = 'Vennligst oppgi et gyldig organisasjonsnummer (9 sifre).';
                return;
            }
        }

        // Validate company field
        if (this.companyName) {
            const value = this.theRecord.companyName ? this.theRecord.companyName.trim() : '';
            if (!value || value.length < 2) {
                this.showError = true;
                this.errorMessage = 'Vennligst oppgi firmanavn.';
                return;
            }
        }

        // Validate role field 
        if (this.role) {
            const value = this.theRecord.role ? this.theRecord.role.trim() : '';
            if (!value || value.length < 2) {
                this.showError = true;
                this.errorMessage = 'Vennligst oppgi rolle.';
                return;
            }
        }

        // Validate field lengths (less than 255 characters)
        for (const field of nonRequiredFields) {
            if (this.theRecord[field] && this.theRecord[field].length > 255) {
                this.showError = true;
                this.errorMessage = `${fieldLabels[field]} kan ikke være lengre enn 255 tegn.`;
                return;
            }
        }
        // Validate phone number (example: phone should be a number and not empty)
        const phoneRegex = /^[0-9]{8,}$/; // Example: Validates 8 digits or more
        if (this.theRecord.phone && !phoneRegex.test(this.theRecord.phone)) {
            this.showError = true;
            this.errorMessage = 'Vennligst oppgi et gyldig telefonnummer (minst 8 sifre).';
            return;
        }
        // Validate email
        const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if (!this.theRecord.email || !emailRegex.test(this.theRecord.email)) {
            this.showError = true;
            this.errorMessage = 'Vennligst oppgi en gyldig e-postadresse.';
            return;
        }

        // Alle sjekker er passert om vi kommer hit
        let output = JSON.stringify(this.theRecord, null);
        createRegistration({
            fields: output,
            courseId: this.courseId
        })
            .then((result) => {
                if (result && result.success === false) {
                    this.showForm = true;
                    this.showError = true;
                    this.errorMessage = result.message;
                    this.showConfirmation = false;
                } else if (result && result.success === true) {
                    this.showForm = false;
                    this.showConfirmation = true;
                    this.message = result.message;
                    this.showError = false;
                } else {
                    this.showForm = true;
                    this.showError = true;
                    this.errorMessage = 'Uventet svar fra server. Prøv igjen senere.';
                    this.showConfirmation = false;
                }
            })
            .catch((error) => {
                this.showForm = true;
                this.showError = true;
                this.errorMessage = 'Teknisk feil ved innsending. Prøv igjen senere.';
                this.showConfirmation = false;
            });
    }

    toggleMultipleParticipants = (event) => {
        this.showNumberInput = event.detail;
    };

    validateCode(event) {
        event.preventDefault();
        if (this.inputValCode === this.code) {
            this.showValidationInput = false;
            this.showForm = true;
            this.displayErrorMessage = false;
        } else {
            this.displayErrorMessage = true;
            this.errorMessage = 'Koden er ikke gyldig. Vennligst prøv igjen';
        }
    }
}
