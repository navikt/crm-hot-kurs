global class Course_AddUrl extends MyTriggers {

	global override void onBeforeInsert() {
		addUrlToCourse( (List<Course__c>) records );
	}

	public static void addUrlToCourse( List<Course__c> courses ) {

		List<Domain> domains = [SELECT Domain FROM Domain WHERE Domain = 'kurs.nav.no']; // production domain
		if ( domains.size() == 0 ) { domains = [SELECT Domain FROM Domain LIMIT 1]; } // sandbox and scratch org domains
		String url = 'https://' + (domains.size() == 1 ? domains[0].Domain : 'arbeidsgiver.nav.no/kursoversikt') + '/'; // apex test domain

		for ( Course__c c : courses ) {
			c.CommunityUrl__c = url;
		}
	}
}