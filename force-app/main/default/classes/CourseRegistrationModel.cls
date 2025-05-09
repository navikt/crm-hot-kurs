public with sharing class CourseRegistrationModel {
    public String firstName;
    public String lastName;
    public String email;
    public String phone;
    public String companyNumber;
    public String source;
    public String status;
    public String county;
    public String companyName;
    public String role;
    public String workplace;
    public String invoiceAdress;
    public String invoiceReference;
    public String allergies;
    public String additionalInformation;
    public String subscribeEmail;

    public static CourseRegistrationModel parse(String json) {
        return (CourseRegistrationModel) System.JSON.deserialize(json, CourseRegistrationModel.class);
    }
}
