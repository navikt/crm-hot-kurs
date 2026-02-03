public class HOT_CourseSharingHandler extends MyTriggers {
    public override void onAfterInsert() {
        shareWithOwnersDepartmentQueue((List<Course__c>) records);
    }

    private static void shareWithOwnersDepartmentQueue(List<Course__c> courses) {
        if (courses == null || courses.isEmpty()) {
            return;
        }

        /* Hent eier-id-er */
        Set<Id> ownerIds = new Set<Id>();
        for (Course__c c : courses) {
            if (c.OwnerId != null) {
                ownerIds.add(c.OwnerId);
            }
        }

        if (ownerIds.isEmpty()) {
            return;
        }

        /* Hent avdeling fra eiere av kurs */
        Map<Id, User> ownersById = new Map<Id, User>(
            [
                SELECT Id, Department
                FROM User
                WHERE Id IN :ownerIds
            ]
        );

        /* Finn kø-navn per kurs */
        Map<Id, String> courseIdToQueueName = new Map<Id, String>();

        for (Course__c c : courses) {
            User u = ownersById.get(c.OwnerId);
            if (u == null || String.isBlank(u.Department)) {
                continue;
            }

            /* Fjern nuller i avdeling */
            String dep = u.Department.replaceFirst('^0+', '');
            courseIdToQueueName.put(c.Id, 'queue_' + dep);
        }

        if (courseIdToQueueName.isEmpty()) {
            return;
        }

        /* Hent alle relevante køer */
        Map<String, Group> queuesByName = new Map<String, Group>();
        for (Group g : [
            SELECT Id, DeveloperName
            FROM Group
            WHERE Type = 'Queue' AND DeveloperName IN :courseIdToQueueName.values()
        ]) {
            queuesByName.put(g.DeveloperName, g);
        }

        if (queuesByName.isEmpty()) {
            return;
        }

        /* Lag Course__Share mot kø */
        List<Course__Share> sharesToInsert = new List<Course__Share>();

        for (Course__c c : courses) {
            String queueName = courseIdToQueueName.get(c.Id);
            if (queueName == null) {
                continue;
            }

            Group q = queuesByName.get(queueName);
            if (q == null) {
                continue;
            }

            sharesToInsert.add(
                new Course__Share(
                    ParentId = c.Id,
                    UserOrGroupId = q.Id,
                    AccessLevel = 'Edit',
                    RowCause = Schema.Course__Share.RowCause.Manual
                )
            );
        }

        if (!sharesToInsert.isEmpty()) {
            insert sharesToInsert;
        }
    }
}
