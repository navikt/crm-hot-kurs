export { getDataFromInputFields, validateData, emptyInputFields, contactToPill };


const getDataFromInputFields = (array) => {

    let obj = {};
    array.forEach(element => {
        obj[element.name] = element.value;
    });

    return obj;
};

const validateData = (array) => {
    return [...array].reduce((validSoFar, inputCmp) => {
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }, true);
};

const emptyInputFields = (array) => {
    array.forEach(element => {
        element.value = '';
        element.setCustomValidity("");
    });
};

const contactToPill = (pill) => {

    pill.type = 'avatar';
    pill.label = pill.fullName;
    pill.name = pill.email;
    pill.fallbackIconName = 'standard:user';
    pill.variant = 'circle';

    return pill;
};