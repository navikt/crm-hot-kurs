public class CourseSchedulable implements Schedulable {
    public void execute(SchedulableContext sc) {
        CourseScheduledDeleteContacts.courseScheduledDeleteContacts();
    }
}
