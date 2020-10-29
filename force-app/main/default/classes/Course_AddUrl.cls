global class Course_AddUrl extends MyTriggers {

	global override void onBeforeInsert() {
		addUrlToCourse( (List<Course__c>) records );
	}

	public static void addUrlToCourse( List<Course__c> courses ) {

		List<Domain> domains = [SELECT Domain FROM Domain WHERE Domain = 'kurs.nav.no'];

		if ( domains.size() == 0 ) { domains = [SELECT Domain FROM Domain LIMIT 1]; }

		if ( domains.size() == 1 ) {
			String url = 'https://' + domains[0].Domain + '/';
			for ( Course__c c : courses ) {
				c.CommunityUrl__c = url;
			}
		}
	}
}