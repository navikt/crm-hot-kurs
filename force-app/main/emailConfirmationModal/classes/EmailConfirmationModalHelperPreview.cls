public with sharing class EmailConfirmationModalHelperPreview {
	public static List<String> getSObjectFields( String sObjectType, String html ) {

		// find merge fields {{{field}}}
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

		String query = ' SELECT ' + String.join( sObjectFields, ', ' ) +
		               ' FROM ' + sObjectType +
		               ' WHERE Id = : recordId' +
		               ' LIMIT 1';
		List<SObject> data = Database.query( query );

		if ( data.size() != 1 ) {
			throw new AuraException( Label.EmailPreview_queryNoResults );
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