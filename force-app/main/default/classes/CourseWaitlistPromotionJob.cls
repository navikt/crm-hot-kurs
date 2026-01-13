public class CourseWaitlistPromotionJob implements Queueable {
    private final List<Id> courseIds;

    public CourseWaitlistPromotionJob(List<Id> courseIds) {
        this.courseIds = courseIds == null ? new List<Id>() : new List<Id>(courseIds);
    }

    public void execute(QueueableContext context) {
        if (courseIds.isEmpty()) {
            return;
        }
        CourseRegistrationHelper.updateCourseWaitlistPromotions(new Set<Id>(courseIds));
    }
}
