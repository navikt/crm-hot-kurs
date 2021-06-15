public class CourseRegistrationHelper {
    public static void getCourseIdToReduce(List<CourseRegistration__c> registrations) {
        List<String> coursesReduceAttending = new List<String>();
        List<String> coursesReduceWaiting = new List<String>();

        for (CourseRegistration__c cr : registrations) {
            Boolean reducedAttending = cr.Status__c == 'Påmeldt';
            Boolean reducedWaiting = cr.Status__c == 'Venteliste';

            if (reducedAttending) {
                coursesReduceAttending.add(cr.Course__c);
            } else if (reducedWaiting) {
                coursesReduceWaiting.add(cr.Course__c);
            }
        }
        if (!coursesReduceAttending.isEmpty()) {
            countCourseIdsToReduceAttending(coursesReduceAttending);
        }
        if (!coursesReduceWaiting.isEmpty()) {
            countCourseIdsToReduceWaiting(coursesReduceWaiting);
        }
    }

    public static void getCourseIdToIncrease(List<CourseRegistration__c> registrations) {
        List<String> coursesIncreaseAttending = new List<String>();
        List<String> coursesIncreaseWaiting = new List<String>();

        for (CourseRegistration__c cr : registrations) {
            Boolean increasedAttending = cr.Status__c == 'Påmeldt';
            Boolean increasedWaiting = cr.Status__c == 'Venteliste';
            if (increasedAttending) {
                coursesIncreaseAttending.add(cr.Course__c);
            } else if (increasedWaiting) {
                coursesIncreaseWaiting.add(cr.Course__c);
            }
        }
        if (!coursesIncreaseAttending.isEmpty()) {
            countCourseIdsToIncreaseAttending(coursesIncreaseAttending);
        }
        if (!coursesIncreaseWaiting.isEmpty()) {
            countCourseIdsToIncreaseWaiting(coursesIncreaseWaiting);
        }
    }

    public static void countCourseIdsToReduceAttending(List<String> reduceAttending) {
        Map<String, Integer> reduceCountIds = new Map<String, Integer>();
        for (String id : reduceAttending) {
            if (!reduceCountIds.containsKey(id)) {
                reduceCountIds.put(id, 0);
            }
            Integer currentCountAtt = reduceCountIds.get(id) - 1;
            reduceCountIds.put(id, currentCountAtt);
        }
        updateCoursesParticipants(reduceCountIds);
    }

    public static void countCourseIdsToIncreaseAttending(List<String> increaseAttending) {
        Map<String, Integer> increaseCountIds = new Map<String, Integer>();
        for (String id : increaseAttending) {
            if (!increaseCountIds.containsKey(id)) {
                increaseCountIds.put(id, 0);
            }
            Integer currentCountAtt = increaseCountIds.get(id) + 1;
            increaseCountIds.put(id, currentCountAtt);
        }
        updateCoursesParticipants(increaseCountIds);
    }

    public static void updateCoursesParticipants(Map<String, Integer> coursesCount) {
        List<Course__c> coursesToUpdate = new List<Course__c>();
        for (Course__c course : [
            SELECT Id, NumberOfParticipants__c
            FROM Course__c
            WHERE Id IN :coursesCount.keyset()
        ]) {
            course.NumberOfParticipants__c = course.NumberOfParticipants__c + coursesCount.get(course.Id);
            coursesToUpdate.add(course);
        }
        update coursesToUpdate;
    }

    public static void countCourseIdsToReduceWaiting(List<String> reduceWaiting) {
        Map<String, Integer> reduceWaitCountIds = new Map<String, Integer>();
        for (String id : reduceWaiting) {
            if (!reduceWaitCountIds.containsKey(id)) {
                reduceWaitCountIds.put(id, 0);
            }
            Integer currentCountWait = reduceWaitCountIds.get(id) - 1;
            reduceWaitCountIds.put(id, currentCountWait);
        }
        updateCourseWaiting(reduceWaitCountIds);
    }

    public static void countCourseIdsToIncreaseWaiting(List<String> increaseWaiting) {
        Map<String, Integer> increaseWaitCountIds = new Map<String, Integer>();
        for (String id : increaseWaiting) {
            if (!increaseWaitCountIds.containsKey(id)) {
                increaseWaitCountIds.put(id, 0);
            }
            Integer currentCountWait = increaseWaitCountIds.get(id) + 1;
            increaseWaitCountIds.put(id, currentCountWait);
        }
        updateCourseWaiting(increaseWaitCountIds);
    }

    public static void updateCourseWaiting(Map<String, Integer> coursesCountWait) {
        List<Course__c> coursesToUpdateWait = new List<Course__c>();
        for (Course__c course : [SELECT Id, Waitinglist__c FROM Course__c WHERE Id IN :coursesCountWait.keyset()]) {
            course.Waitinglist__c = course.Waitinglist__c + coursesCountWait.get(course.Id);
            coursesToUpdateWait.add(course);
        }
        update coursesToUpdateWait;
    }

    public static void countCourseIdsToCheckWaiting(List<String> updateWaiting) {
        Map<String, Integer> updateWaitCountIds = new Map<String, Integer>();
        for (String id : updateWaiting) {
            if (!updateWaitCountIds.containsKey(id)) {
                updateWaitCountIds.put(id, 0);
            }
            Integer currentCountWait = updateWaitCountIds.get(id) + 1;
            updateWaitCountIds.put(id, currentCountWait);
        }
        updateCourseWaitingListMembers(updateWaitCountIds);
    }

    public static void updateCourseWaitingListMembers(Map<String, Integer> checkUpdateWaiting) {
        //Create a List of Course Regaistrations where the status should be updated from 'Venteliste' to 'Påmeldt'
        List<CourseRegistration__c> crToUpdateWait = new List<CourseRegistration__c>();
        //Loop through courses received in Map from update trigger (potentially to change status for Course registrations from 'Venteliste' to 'Påmeldt')
        for (Course__c course : [SELECT Id, Waitinglist__c FROM Course__c WHERE Id IN :checkUpdateWaiting.keyset()]) {
            String courseId = course.Id;
            Integer waitingListQuantityFromUpdate = checkUpdateWaiting.get(course.Id);
            Integer courseWaitingList = integer.valueof(course.Waitinglist__c);

            if (courseWaitingList > 0 && courseWaitingList < waitingListQuantityFromUpdate) {
                //Loop through registrations on waiting list for course with LIMIT set by course waiting list regsitrations
                for (CourseRegistration__c cr : [
                    SELECT Id, Status__c, Course__c, CreatedDate
                    FROM CourseRegistration__c
                    WHERE Course__c = :courseId AND Status__c = 'Venteliste'
                    ORDER BY CreatedDate ASC
                    LIMIT :courseWaitingList
                ]) {
                    cr.Status__c = 'Påmeldt'; //change cr status from 'Venteliste' to 'Påmeldt'
                    crToUpdateWait.add(cr);
                }
            }
            if (courseWaitingList >= waitingListQuantityFromUpdate) {
                //Loop through registrations on waiting list for course with LIMIT set by number of updated registrations
                for (CourseRegistration__c cr : [
                    SELECT Id, Status__c, Course__c, CreatedDate
                    FROM CourseRegistration__c
                    WHERE Course__c = :courseId AND Status__c = 'Venteliste'
                    ORDER BY CreatedDate ASC
                    LIMIT :waitingListQuantityFromUpdate
                ]) {
                    cr.Status__c = 'Påmeldt'; //change cr status from 'Venteliste' to 'Påmeldt'
                    crToUpdateWait.add(cr);
                }
            }
        }
        update crToUpdateWait;
    }
}
