@isTest
public without sharing class CourseRegistrationEmailModelTest {

	public static String jsonData = '[' +

	                                '    {' +
	                                '        "fullName": "Ola Nordmann",' +
	                                '        "email": "ola.nordmann@test.com"' +
	                                '    },' +

	                                '    {' +
	                                '        "fullName": "Kari Nordmann",' +
	                                '        "email": "kari.nordmann@test.com"' +
	                                '    },' +

	                                '    {' +
	                                '        "fullName": "Per Nordmann",' +
	                                '        "email": "per.nordmann@test.com"' +
	                                '    }' +
	                                ']';

	@isTest
	private static void testModel() {

		Test.StartTest();
		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( jsonData, List<CourseRegistrationEmailModel>.class );
		Test.StopTest();

		System.assertEquals( 3, recipients.size(), 'three persons in json' );

		System.assertEquals( 'Ola Nordmann', recipients[0].fullName, 'fullName is Ola Nordmann' );
		System.assertEquals( 'ola.nordmann@test.com', recipients[0].email, 'email is ola.nordmann@test.com' );

		System.assertEquals( 'Kari Nordmann', recipients[1].fullName, 'fullName is Kari Nordmann' );
		System.assertEquals( 'kari.nordmann@test.com', recipients[1].email, 'email is kari.nordmann@test.com' );

		System.assertEquals( 'Per Nordmann', recipients[2].fullName, 'fullName is Per Nordmann' );
		System.assertEquals( 'per.nordmann@test.com', recipients[2].email, 'email is per.nordmann@test.com' );
	}
}
