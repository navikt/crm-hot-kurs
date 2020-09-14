public with sharing class EmailPreviewComponent {

	// TODO rename
	@AuraEnabled(cacheable = true)
	public static String getEmailPreview( String recordId, String emailTemplate ) {

		List<EmailTemplate> templates = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplate LIMIT 1];
		String sObjectType = TAG_ActivityTimelineHelper.getSOjectTypeFromRecordId( recordId );
		List<String> sObjectFields = getSObjectFields( sObjectType, templates[0].HtmlValue );
		Map<String, String> replacedMergeFields = replaceMergeFields( recordId, sObjectType, sObjectFields );
		String mergedHtml = mergeHtml( templates[0].HtmlValue, replacedMergeFields );

		return mergedHtml;
	}

	public static List<String> getSObjectFields( String sObjectType, String html ) {

		Pattern p = Pattern.compile( '(\\{\\{\\{' + sObjectType + '\\..*?\\}\\}\\})' );
		Matcher m = p.matcher( html );

		List<String> sObjectFields = new List<String>();
		while ( m.find() ) {
			String sObjectField = m.group( 1 ).replace( '{{{' + sObjectType + '.', '' ).replace( '}}}', '' );
			sObjectFields.add( sObjectField );
		}

		return sObjectFields;
	}

	public static Map<String, String> replaceMergeFields( String recordId, String sObjectType, List<String> sObjectFields ) {

		System.debug( 'recordId: ' + recordId );
		System.debug( 'sObjectType: ' + sObjectType );
		System.debug( 'sObjectFields: ' + sObjectFields );

		String query = ' SELECT ' + String.join( sObjectFields, ', ' ) +
		               ' FROM ' + sObjectType +
		               ' WHERE Id = : recordId' +
		               ' LIMIT 1';

		System.debug( 'query: ' + query );
		List<SObject> data = Database.query( query );
		System.debug( 'data: ' + data );
		if ( data.size() != 1 ) {
			return null;
		}

		Map<String, String> replacingMap = new Map<String, String>();
		for ( String sObjectField : sObjectFields ) {
			System.debug( 'sObjectField: ' + sObjectField );
			String key = '\\{\\{\\{' + sObjectType + '.' + sObjectField + '\\}\\}\\}';
			System.debug( 'key: ' + key );
			String value = String.valueOf( data[0].get( sObjectField ) );

			System.debug( 'value: ' + value );
			replacingMap.put( key, value );
		}

		return replacingMap;
	}

	public static String mergeHtml( String html, Map<String, String> replacedMergeFields ) {
		for ( String key : replacedMergeFields.keySet() ) {
			if ( key != null && key != ' ' ) {
				String value = replacedMergeFields.get( key ) != null ? replacedMergeFields.get( key ) : '';
				html = html.replaceAll( key, value.stripHtmlTags() );
			}
		}

		return html;
	}
}
