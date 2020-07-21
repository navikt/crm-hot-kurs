public with sharing class CourseRegistrationModel {

	public String firstName;
	public String lastName;
	public String email;
	public String phone;
	public String companyNumber;
	public String source;


	public static CourseRegistrationModel parse( String json ) {
		return (CourseRegistrationModel) System.JSON.deserialize( json, CourseRegistrationModel.class );
	}
}
