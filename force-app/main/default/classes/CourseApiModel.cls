public class CourseApiModel {
    public Id RegistrationID;
    public String Title;
    public String RegistrationUrl;
    public Datetime RegistrationFromDateTime;
    public Datetime RegistrationToDateTime;
    public Datetime RegistrationDeadline;
    public String RegistrationPlaceName;
    public String Description;
    public Decimal AvailableSeats;
    public Decimal MaxNumberOfParticipants;
    public Decimal NumberOfParticipants;
    public String FrontPageDescription;
    public Integer ShowInActivityList;
    public Configurable_custom configurable_custom;
    public Boolean PublishWithoutRegistrationForm;

    public class Configurable_custom {
        public String Fylke;
        public String Type;
        public String Tema;
        public String Underkategori;
    }
}
