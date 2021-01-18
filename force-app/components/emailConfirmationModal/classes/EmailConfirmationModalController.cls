public with sharing class EmailConfirmationModalController {

	@AuraEnabled
	public static List<Contact> sendEmail( String recordId, String recipientsJson, String template, Boolean useDoNotReply ) {

		List<EmailTemplate> templates = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :template LIMIT 1];
		if ( templates.size() != 1 ) { throw new AuraException( Label.EmailConfirmation_missingTemplate ); }

		List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize( recipientsJson, List<EmailConfirmationModalModel>.class );
		List<Contact> contacts = EmailConfirmationModalHelper.fetchOrCreateContacts( recipients );
		EmailConfirmationModalHelper.sendEmailToCourseRecipients( recordId, contacts, templates[0].Id );

		return contacts;
	}

	@AuraEnabled(cacheable = true)
	public static String getEmailPreview( String recordId, String emailTemplate ) {

		List<EmailTemplate> templates = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplate LIMIT 1];
		if ( templates.size() != 1 ) { throw new AuraException( Label.EmailConfirmation_missingTemplate ); }
		String sObjectType = ActivityTimelineHelper.getSOjectTypeFromRecordId( recordId );
		List<String> sObjectFields = EmailConfirmationModalHelperPreview.getSObjectFields( sObjectType, templates[0].HtmlValue );
		Map<String, String> replacedMergeFields = EmailConfirmationModalHelperPreview.replaceMergeFields( recordId, sObjectType, sObjectFields );
		String mergedHtml = EmailConfirmationModalHelperPreview.mergeHtml( templates[0].HtmlValue, replacedMergeFields );

		return mergedHtml;
	}

	@AuraEnabled(cacheable = true)
	public static String getEmailSubject( String emailTemplate ) {

		List<EmailTemplate> templates = [SELECT Subject FROM EmailTemplate WHERE DeveloperName = :emailTemplate LIMIT 1];

		return templates[0].Subject;
	}


}
