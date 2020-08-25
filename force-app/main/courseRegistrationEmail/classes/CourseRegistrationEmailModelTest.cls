@isTest
public without sharing class CourseRegistrationEmailModelTest {

	public static String jsonData = '[' +

	                                '    {' +
	                                '        "firstName": "Ola",' +
	                                '        "lastName": "Nordmann",' +
	                                '        "email": "ola.nordmann@test.com"' +
	                                '    },' +

	                                '    {' +
	                                '        "firstName": "Kari",' +
	                                '        "lastName": "Nordmann",' +
	                                '        "email": "kari.nordmann@test.com"' +
	                                '    },' +

	                                '    {' +
	                                '        "firstName": "Per",' +
	                                '        "lastName": "Nordmann",' +
	                                '        "email": "per.nordmann@test.com"' +
	                                '    }' +
	                                ']';

	@isTest
	private static void testModel() {

		Test.StartTest();
		List<CourseRegistrationEmailModel> recipients = (List<CourseRegistrationEmailModel>) System.JSON.deserialize( jsonData, List<CourseRegistrationEmailModel>.class );
		Test.StopTest();

		System.assertEquals( 3, recipients.size(), 'three persons in json' );

		System.assertEquals( 'Ola', recipients[0].firstName, 'firstName is Ola' );
		System.assertEquals( 'Nordmann', recipients[0].lastName, 'lastName is Nordmann' );
		System.assertEquals( 'ola.nordmann@test.com', recipients[0].email, 'email is ola.nordmann@test.com' );

		System.assertEquals( 'Kari', recipients[1].firstName, 'firstName is Kari' );
		System.assertEquals( 'Nordmann', recipients[1].lastName, 'lastName is Nordmann' );
		System.assertEquals( 'kari.nordmann@test.com', recipients[1].email, 'email is kari.nordmann@test.com' );

		System.assertEquals( 'Per', recipients[2].firstName, 'firstName is Per' );
		System.assertEquals( 'Nordmann', recipients[2].lastName, 'lastName is Nordmann' );
		System.assertEquals( 'per.nordmann@test.com', recipients[2].email, 'email is per.nordmann@test.com' );
	}
}