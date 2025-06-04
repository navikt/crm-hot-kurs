@isTest
public with sharing class CourseRegistrationHelperTest {
    @TestSetup
    static void makeData() {
        TestDataFactory.insertEncryptionKey();
    }

    private static CourseRegistration__c newReg(String status, Id courseId, Integer participants) {
        CourseRegistration__c cr = CourseRegistrationHandlerTest.getCourseRegistration(status, courseId);
        if (participants != null) {
            cr.NumberOfParticipants__c = participants;
            update cr;
        }
        return cr;
    }
    /* ---------- capacity validation ---------- */
    @isTest
    static void testValidateRegistrationsAgainstCourseCapacity() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');
        c.MaxNumberOfParticipants__c = 2;
        update c;

        CourseRegistration__c regOk = new CourseRegistration__c(
            Course__c = c.Id,
            Status__c = 'Invitert',
            NumberOfParticipants__c = 2
        );
        CourseRegistration__c regOver = new CourseRegistration__c(
            Course__c = c.Id,
            Status__c = 'Invitert',
            NumberOfParticipants__c = 3
        );

        List<CourseRegistration__c> regs = new List<CourseRegistration__c>{ regOk, regOver };

        Test.startTest();
        CourseRegistrationHelper.validateRegistrationsAgainstCourseCapacity(regs, null);
        Test.stopTest();

        System.assertEquals(0, regOk.getErrors().size(), 'Registration at or below capacity should pass validation');
        System.assertEquals(1, regOver.getErrors().size(), 'Registration exceeding capacity should be blocked');
        System.assert(
            regOver.getErrors()[0].getMessage().contains('overstiger'),
            'Error message should mention capacity exceeded'
        );
    }

    /* ---------- ATTENDING counters ---------- */

    @isTest
    static void testCountCourseIdsToReduceAttending() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');
        c.NumberOfParticipants__c = 5;
        update c;

        List<CourseRegistration__c> regs = new List<CourseRegistration__c>{
            newReg('Invitert', c.Id, 1),
            newReg('Invitert', c.Id, 1)
        };

        Test.startTest();
        CourseRegistrationHelper.countCourseIdsToReduceAttending(regs);
        Test.stopTest();

        System.assertEquals(
            3,
            Integer.valueOf(CourseRegistrationHandlerTest.fetchCourse('Testkurs').NumberOfParticipants__c)
        );
    }

    @isTest
    static void testCountCourseIdsToIncreaseAttending() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');

        List<CourseRegistration__c> regs = new List<CourseRegistration__c>{
            newReg('Invitert', c.Id, 1),
            newReg('Invitert', c.Id, 1)
        };

        Test.startTest();
        CourseRegistrationHelper.countCourseIdsToIncreaseAttending(regs);
        Test.stopTest();

        System.assertEquals(
            2,
            Integer.valueOf(CourseRegistrationHandlerTest.fetchCourse('Testkurs').NumberOfParticipants__c)
        );
    }

    /* ---------- WAITLIST counters ---------- */

    @isTest
    static void testCountCourseIdsToReduceWaiting() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');
        c.Waitinglist__c = 5;
        update c;

        List<CourseRegistration__c> regs = new List<CourseRegistration__c>{
            newReg('Invitert', c.Id, 1),
            newReg('Invitert', c.Id, 1)
        };

        Test.startTest();
        CourseRegistrationHelper.countCourseIdsToReduceWaiting(regs);
        Test.stopTest();

        System.assertEquals(3, Integer.valueOf(CourseRegistrationHandlerTest.fetchCourse('Testkurs').Waitinglist__c));
    }

    @isTest
    static void testCountCourseIdsToIncreaseWaiting() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');

        List<CourseRegistration__c> regs = new List<CourseRegistration__c>{
            newReg('Invitert', c.Id, 1),
            newReg('Invitert', c.Id, 1)
        };

        Test.startTest();
        CourseRegistrationHelper.countCourseIdsToIncreaseWaiting(regs);
        Test.stopTest();

        System.assertEquals(2, Integer.valueOf(CourseRegistrationHandlerTest.fetchCourse('Testkurs').Waitinglist__c));
    }

    /* ---------- direct update helpers ---------- */

    @isTest
    static void testUpdateCoursesParticipants() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');

        Test.startTest();
        CourseRegistrationHelper.updateCoursesParticipants(new Map<Id, Integer>{ c.Id => 5 });
        Test.stopTest();

        System.assertEquals(
            5,
            Integer.valueOf(CourseRegistrationHandlerTest.fetchCourse('Testkurs').NumberOfParticipants__c)
        );
    }

    @isTest
    static void testUpdateCourseWaiting() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');
        c.Waitinglist__c = 5;
        update c;

        Test.startTest();
        CourseRegistrationHelper.updateCourseWaiting(new Map<Id, Integer>{ c.Id => -2 });
        Test.stopTest();

        System.assertEquals(3, Integer.valueOf(CourseRegistrationHandlerTest.fetchCourse('Testkurs').Waitinglist__c));
    }

    /* ---------- wait-list promotion end-to-end ---------- */

    @isTest
    static void testWaitingListFunction() {
        Course__c c = CourseRegistrationHandlerTest.getCourse('Testkurs');

        // 2 attending, 2 wait-listed
        CourseRegistration__c r1 = newReg('Påmeldt', c.Id, 1);
        CourseRegistration__c r2 = newReg('Påmeldt', c.Id, 1);
        CourseRegistration__c r3 = newReg('Venteliste', c.Id, 1);
        CourseRegistration__c r4 = newReg('Venteliste', c.Id, 1);

        Course__c before = CourseRegistrationHandlerTest.fetchCourse('Testkurs');
        System.assertEquals(2, before.NumberOfParticipants__c);
        System.assertEquals(2, before.Waitinglist__c);

        Test.startTest();
        CourseRegistrationHelper.countCourseIdsToCheckWaiting(new Set<Id>{ c.Id });
        Test.stopTest();

        Map<Id, CourseRegistration__c> afterRegs = new Map<Id, CourseRegistration__c>(
            [SELECT Status__c FROM CourseRegistration__c WHERE Id IN :new List<Id>{ r3.Id, r4.Id }]
        );
        System.assertEquals('Påmeldt', afterRegs.get(r3.Id).Status__c);
        System.assertEquals('Påmeldt', afterRegs.get(r4.Id).Status__c);
    }
}
