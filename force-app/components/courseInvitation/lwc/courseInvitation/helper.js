export { getDataFromInputFields, validateData, emptyInputFields };


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