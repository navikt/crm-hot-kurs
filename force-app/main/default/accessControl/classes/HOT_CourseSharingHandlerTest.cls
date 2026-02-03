@IsTest
private class HOT_CourseSharingHandlerTest {
    @TestSetup
    static void setupData() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String unique = String.valueOf(System.now().getTime());

        PermissionSet courseAdminPs = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Course_Admin'
            LIMIT 1
        ];

        User u1 = new User(
            Alias = 'u1',
            Email = 'u1@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test U1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            Username = 'u1+' + unique + '@example.test',
            Department = '04700'
        );

        User u2 = new User(
            Alias = 'u2',
            Email = 'u2@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test U2',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            Username = 'u2+' + unique + '@example.test',
            Department = '04700'
        );

        // Ekstra bruker med annen avdeling
        User u3 = new User(
            Alias = 'u3',
            Email = 'u3@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test U3',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            Username = 'u3+' + unique + '@example.test',
            Department = '04800'
        );

        insert new List<User>{ u1, u2, u3 };

        insert new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = courseAdminPs.Id),
            new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = courseAdminPs.Id),
            new PermissionSetAssignment(AssigneeId = u3.Id, PermissionSetId = courseAdminPs.Id)
        };

        Group q = new Group(Name = 'queue_4700', DeveloperName = 'queue_4700', Type = 'Queue');
        insert q;

        insert new QueueSobject(QueueId = q.Id, SobjectType = 'Course__c');

        // NB: u3 skal IKKE være medlem av queue_4700
        insert new List<GroupMember>{
            new GroupMember(GroupId = q.Id, UserOrGroupId = u1.Id),
            new GroupMember(GroupId = q.Id, UserOrGroupId = u2.Id)
        };
    }

    @IsTest
    static void user2_has_access_to_course_created_by_user1() {
        User u1 = [SELECT Id FROM User WHERE Alias = 'u1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE Alias = 'u2' LIMIT 1];
        Group q = [SELECT Id FROM Group WHERE DeveloperName = 'queue_4700' LIMIT 1];

        Course__c course;

        Test.startTest();
        System.runAs(u1) {
            DateTime dt = DateTime.now().addHours(4);
            DateTime st = DateTime.now().addDays(-1);

            course = new Course__c(
                Name = 'Kurs 1',
                DescriptionFormatted__c = 'Testkurs',
                DescriptionShort__c = 'Kort beskrivelse',
                Region2__c = 'Oslo',
                Active__c = true,
                MaxNumberOfParticipants__c = 10,
                RegistrationFromDateTime__c = DateTime.now(),
                RegistrationToDateTime__c = dt,
                RegistrationDeadline__c = st
            );
            insert course;
        }
        Test.stopTest();

        Course__Share share = [
            SELECT ParentId, UserOrGroupId, AccessLevel, RowCause
            FROM Course__Share
            WHERE ParentId = :course.Id AND UserOrGroupId = :q.Id
            LIMIT 1
        ];
        System.assertEquals('Edit', share.AccessLevel);
        System.assertEquals(Schema.Course__Share.RowCause.Manual, share.RowCause);

        System.runAs(u2) {
            UserRecordAccess ura = [
                SELECT RecordId, HasReadAccess, HasEditAccess
                FROM UserRecordAccess
                WHERE UserId = :u2.Id AND RecordId = :course.Id
                LIMIT 1
            ];
            System.assertEquals(true, ura.HasReadAccess, 'User2 should have read access');
            System.assertEquals(true, ura.HasEditAccess, 'User2 should have edit access');

            Course__c visible = [
                SELECT Id, Name
                FROM Course__c
                WHERE Id = :course.Id
                LIMIT 1
            ];
            System.assertEquals(course.Id, visible.Id);
        }
    }

    @IsTest
    static void user3_with_other_department_should_not_have_access() {
        User u1 = [SELECT Id FROM User WHERE Alias = 'u1' LIMIT 1];
        User u3 = [SELECT Id FROM User WHERE Alias = 'u3' LIMIT 1];

        Course__c course;

        Test.startTest();
        System.runAs(u1) {
            DateTime dt = DateTime.now().addHours(4);
            DateTime st = DateTime.now().addDays(-1);

            course = new Course__c(
                Name = 'Kurs 2',
                DescriptionFormatted__c = 'Testkurs',
                DescriptionShort__c = 'Kort beskrivelse',
                Region2__c = 'Oslo',
                Active__c = true,
                MaxNumberOfParticipants__c = 10,
                RegistrationFromDateTime__c = DateTime.now(),
                RegistrationToDateTime__c = dt,
                RegistrationDeadline__c = st
            );
            insert course;
        }
        Test.stopTest();

        System.runAs(u3) {
            // 1) Sjekk via UserRecordAccess
            UserRecordAccess ura = [
                SELECT RecordId, HasReadAccess, HasEditAccess
                FROM UserRecordAccess
                WHERE UserId = :u3.Id AND RecordId = :course.Id
                LIMIT 1
            ];
            System.assertEquals(false, ura.HasReadAccess, 'User3 should NOT have read access');
            System.assertEquals(false, ura.HasEditAccess, 'User3 should NOT have edit access');

            List<Course__c> rows = [
                SELECT Id
                FROM Course__c
                WHERE Id = :course.Id
                LIMIT 1
            ];
            System.assertEquals(0, rows.size(), 'User3 should not be able to query the course');
        }
    }
}
