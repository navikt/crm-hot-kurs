public with sharing class EmailConfirmationModalController {

	// TODO rename
	@AuraEnabled
	public static List<Contact> sendCourseEmail( Id courseId, String recipientsJson ) {

		List<EmailConfirmationModalModel> recipients = (List<EmailConfirmationModalModel>) System.JSON.deserialize( recipientsJson, List<EmailConfirmationModalModel>.class );

		List<Contact> contacts = EmailConfirmationModalHelper.fetchOrCreateContacts( recipients );

		List<CourseRegistration__c> registrations = EmailConfirmationModalHelper.createCourseRegistrations( courseId, contacts );

		EmailConfirmationModalHelper.sendEmailToCourseRecipients( registrations, contacts );

		return contacts;
	}

	@AuraEnabled(cacheable = true)
	public static String getEmailPreview( String recordId, String emailTemplate ) {

		List<EmailTemplate> templates = [SELECT Id, HtmlValue FROM EmailTemplate WHERE DeveloperName = :emailTemplate LIMIT 1];
		String sObjectType = TAG_ActivityTimelineHelper.getSOjectTypeFromRecordId( recordId );
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