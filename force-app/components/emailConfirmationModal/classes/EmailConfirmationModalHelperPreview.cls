public with sharing class EmailConfirmationModalHelperPreview {
    public static List<String> getSObjectFields(String sObjectType, String html) {
        // find merge fields {{{field}}}
        Pattern p = Pattern.compile('(\\{\\{\\{' + sObjectType + '\\..*?\\}\\}\\})');
        Matcher m = p.matcher(html);

        List<String> sObjectFields = new List<String>();
        while (m.find()) {
            String sObjectField = m.group(1).replace('{{{' + sObjectType + '.', '').replace('}}}', '');
            sObjectFields.add(sObjectField);
        }

        return sObjectFields;
    }

    public static Map<String, String> replaceMergeFields(
        String recordId,
        String sObjectType,
        List<String> sObjectFields
    ) {
        String query =
            ' SELECT ' +
            String.join(sObjectFields, ', ') +
            ' FROM ' +
            sObjectType +
            ' WHERE Id = : recordId' +
            ' LIMIT 1';
        List<SObject> data = Database.query(query);

        if (data.size() != 1) {
            throw new AuraException(Label.CourseInvitation_queryNoResults);
        }

        Map<String, String> replacingMap = new Map<String, String>();
        for (String sObjectField : sObjectFields) {
            String key = '\\{\\{\\{' + sObjectType + '.' + sObjectField + '\\}\\}\\}';

            if (isDateTimeField(sObjectType, sObjectField)) {
                Datetime dateGMT = Datetime.valueOf(data[0].get(sObjectField));
                String value = dateGMT.format('dd/MM/yyyy HH:mm');
                replacingMap.put(key, value);
            } else {
                String value = String.valueOf(data[0].get(sObjectField));
                replacingMap.put(key, value);
            }
        }

        return replacingMap;
    }

    public static String mergeHtml(String html, Map<String, String> replacedMergeFields) {
        for (String key : replacedMergeFields.keySet()) {
            if (key != null && key != ' ') {
                String value = replacedMergeFields.get(key) != null ? replacedMergeFields.get(key) : '';
                html = html.replaceAll(key, Matcher.quoteReplacement(value));
            }
        }

        return html;
    }

    public static Boolean isDateTimeField(String sObjectType, String sObjectField) {
        Boolean res = false;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(sObjectType);
        Map<String, Schema.SObjectField> M = leadSchema.getDescribe().fields.getMap();
        Schema.SObjectField field = M.get(sObjectField);
        Schema.DisplayType FldType = field.getDescribe().getType();

        if (FldType == Schema.DisplayType.DateTime) {
            res = true;
        }
        return res;
    }
}
