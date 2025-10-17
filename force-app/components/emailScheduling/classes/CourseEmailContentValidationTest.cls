@isTest
private without sharing class CourseEmailContentValidationTest {
    // --------------------------------------------------------------------------------------------------------
    // ------------------------------------------------ AFTER ------------------------------------------------
    // --------------------------------------------------------------------------------------------------------

    @isTest
    private static void testInsertAfter() {
        DateTime afterDate = Date.today().addDays(+7);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = afterDate,
            RegistrationFromDateTime__c = afterDate,
            RegistrationToDateTime__c = afterDate.addDays(1),
            EmailAfterContent__c = 'not okay<img></img>',
            EmailAfterConfirmation__c = true,
            EmailAfterURL__c = 'https://nav.no'
        );
        DmlException error;
        Test.StartTest();
        try {
            insert course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailAfterContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailAfterContent__c'
        );
    }

    @isTest
    private static void testUpdateAfter() {
        DateTime afterDate = Date.today().addDays(+7);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = afterDate,
            RegistrationFromDateTime__c = afterDate,
            RegistrationToDateTime__c = afterDate.addDays(1),
            EmailAfterContent__c = 'OK',
            EmailAfterConfirmation__c = true,
            EmailAfterURL__c = 'https://nav.no'
        );
        insert course;

        DmlException error;
        Test.StartTest();
        try {
            course.EmailAfterContent__c = 'not okay<img></img>';
            update course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailAfterContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailAfterContent__c'
        );
    }

    // --------------------------------------------------------------------------------------------------------
    // ------------------------------------------------ BEFORE ------------------------------------------------
    // --------------------------------------------------------------------------------------------------------

    @isTest
    private static void testInsertBefore() {
        DateTime beforeDate = Date.today().addDays(+7);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = beforeDate,
            RegistrationFromDateTime__c = beforeDate,
            RegistrationToDateTime__c = beforeDate.addDays(1),
            EmailBeforeContent__c = 'not okay<img></img>',
            EmailBeforeConfirmation__c = true
        );
        DmlException error;
        Test.StartTest();
        try {
            insert course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailBeforeContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailBeforeContent__c'
        );
    }

    @isTest
    private static void testUpdateBefore() {
        DateTime beforeDate = Date.today().addDays(+7);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = beforeDate,
            RegistrationFromDateTime__c = beforeDate,
            RegistrationToDateTime__c = beforeDate.addDays(1),
            EmailBeforeContent__c = 'OK',
            EmailBeforeConfirmation__c = true
        );
        insert course;

        DmlException error;
        Test.StartTest();
        try {
            course.EmailBeforeContent__c = 'not okay<img></img>';
            update course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailBeforeContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailBeforeContent__c'
        );
    }

    // --------------------------------------------------------------------------------------------------------
    // ------------------------------------------------ MANUAL ------------------------------------------------
    // --------------------------------------------------------------------------------------------------------

    @isTest
    private static void testInsertManual() {
        DateTime manualDate = Date.today().addDays(+17);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = manualDate,
            RegistrationFromDateTime__c = manualDate,
            RegistrationToDateTime__c = manualDate.addDays(20),
            EmailManualDate__c = Date.today(),
            EmailManualContent__c = 'not okay<img></img>',
            EmailManualConfirmation__c = true
        );
        DmlException error;
        Test.StartTest();
        try {
            insert course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailManualContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailManualContent__c'
        );
    }

    @isTest
    private static void testUpdateManual() {
        DateTime manualDate = Date.today().addDays(+17);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = manualDate,
            RegistrationFromDateTime__c = manualDate,
            RegistrationToDateTime__c = manualDate.addDays(20),
            EmailManualDate__c = Date.today(),
            EmailManualContent__c = 'OK',
            EmailManualConfirmation__c = true
        );
        insert course;

        DmlException error;
        Test.StartTest();
        try {
            course.EmailManualContent__c = 'not okay<img></img>';
            update course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailManualContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailManualContent__c'
        );
    }

    // --------------------------------------------------------------------------------------------------------
    // ----------------------------------------------- REMINDER -----------------------------------------------
    // --------------------------------------------------------------------------------------------------------

    @isTest
    private static void testInsertReminder() {
        DateTime reminderDate = Date.today().addDays(+7);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = reminderDate,
            RegistrationFromDateTime__c = reminderDate,
            RegistrationToDateTime__c = reminderDate.addDays(1),
            EmailReminderContent__c = 'not okay<img></img>',
            EmailReminderConfirmation__c = true
        );
        DmlException error;
        Test.StartTest();
        try {
            insert course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailReminderContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailReminderContent__c'
        );
    }

    @isTest
    private static void testUpdateReminder() {
        DateTime reminderDate = Date.today().addDays(+7);
        Course__c course = new Course__c(
            Name = 'course',
            Active__c = true,
            MaxNumberOfParticipants__c = 4,
            CommunityUrl__c = 'test',
            Region2__c = 'Oslo',
            RegistrationDeadline__c = reminderDate,
            RegistrationFromDateTime__c = reminderDate,
            RegistrationToDateTime__c = reminderDate.addDays(1),
            EmailReminderContent__c = 'OK',
            EmailReminderConfirmation__c = true
        );
        insert course;

        DmlException error;
        Test.StartTest();
        try {
            course.EmailReminderContent__c = 'not okay<img></img>';
            update course;
        } catch (DmlException e) {
            error = e;
        }
        Test.StopTest();

        System.assertEquals(
            'FIELD_CUSTOM_VALIDATION_EXCEPTION',
            error.getDmlStatusCode(0),
            'type error should be FIELD_CUSTOM_VALIDATION_EXCEPTION'
        );
        System.assertEquals(
            'EmailReminderContent__c',
            error.getDmlFieldNames(0)[0],
            'field with error should be EmailReminderContent__c'
        );
    }
}
