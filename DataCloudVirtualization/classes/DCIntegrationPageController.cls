public with sharing class DCIntegrationPageController {
 
    public static String executeQuery(String query) {
        String errorMessage ='Problem with Authorization with Data cloud, please contact system admin.';
        try
        {
        String responseBody = '';

        // Prepare the request body
        Map<String, String> requestBodyMap = new Map<String, String>();
        System.debug('SQL----->'+ query);
        requestBodyMap.put('sql', query);
        String requestBody = JSON.serialize(requestBodyMap);
        
        
        // Send POST request to the endpoint
        HttpResponse response = sendPostRequest(requestBody);
         if (response.getStatusCode() == 201) {
            return response.getBody();
        } 
        else if(response.getStatusCode() == 401){
            insert (new Error_Logs__c(Name='Problem with Authorization with Data cloud',Exception_From__c='while Fetching the data in LWC from DataCloud',Exception_Message__c=response.getBody(),Exception_Type__c=String.valueof(response.getStatusCode())+'error',Input_Request__c=query));
            return errorMessage;
            
        }
        else if(response.getStatusCode() == 400){
            System.debug('Failed to get data - ' + response.getStatusCode() + ' - ' + response.getBody());
            insert (new Error_Logs__c(Name='Malformed SOQL query',Exception_From__c='while Fetching the data in LWC from DataCloud',Exception_Message__c=response.getBody(),Exception_Type__c=String.valueof(response.getStatusCode())+'error',Input_Request__c=query));
            return errorMessage;
            
        }
        else {
            System.debug('Failed to get data - ' + response.getStatusCode() + ' - ' + response.getBody());
            insert (new Error_Logs__c(Name='unable to fetch the Response',Exception_From__c='while Fetching the data in LWC from DataCloud',Exception_Message__c=response.getBody(),Exception_Type__c=String.valueof(response.getStatusCode())+'error',Input_Request__c=query));
            return responseBody;
        }
        }
        catch(exception e) 
                {
                   insert (new Error_Logs__c(Name=e.getTypeName(),Exception_From__c=String.valueof(e.getLineNumber())+e.getCause(),Exception_Message__c=e.getMessage(),Exception_Type__c=e.getTypeName(),Input_Request__c=e.getStackTraceString()));
                }
        return errorMessage;
    }
    
    public static HttpResponse sendPostRequest(String requestBody) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Data_Cloud_Token_URL/services/data/v57.0/ssot/queryv2');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        request.setTimeout(120000);
        System.debug('Endpoint--->' + request);
        return new Http().send(request);
    }

    @AuraEnabled(cacheable=true)
    public static List<DC_Integration_Query_Configuration__c> getAuditConfig(String queryConfigName){
        System.debug('Fetching DC_Integration_Query_Configuration__c');
        return [SELECT Id, Name,Object_Name__c, Parent_Object__c, Relationship__c, Query__c, OrgId__c FROM DC_Integration_Query_Configuration__c WHERE Name = :queryConfigName];
    }

    // Get SubChild Data
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getChildDataByParentId(String queryConfigName, String parentId ) {
        List<Map<String, Object>> responseData = new List<Map<String, Object>>();
         try
        {
        // get the query from config for given object
        List<DC_Integration_Query_Configuration__c> auditQueryConfigurations = getAuditConfig(queryConfigName);
        if (auditQueryConfigurations.isEmpty()) {
            System.debug('Query not found, so returning empty response');
            return responseData;
        }

       DC_Integration_Query_Configuration__c dcConfig;
        for (DC_Integration_Query_Configuration__c config : auditQueryConfigurations) {
            if (config.Name == queryConfigName) {
                dcConfig = config;
                break;
            }
        }
        string query = '';
        if(dcConfig != null){
            query = dcConfig.Query__c.replace(':parentIdPlaceholder', parentId);
            system.debug('query'+query);
        }

        // Execute the provided query
        String responseBody = executeQuery(query);

        // Parse response body
        if (responseBody != null && !String.isEmpty(responseBody)) {
            responseData = convertToObjects(responseBody);
            return responseData;
        }
        }
        catch(exception e) 
                {
                   insert (new Error_Logs__c(Name=e.getTypeName(),Exception_From__c=String.valueof(e.getLineNumber())+e.getCause(),Exception_Message__c=e.getMessage(),Exception_Type__c=e.getTypeName(),Input_Request__c=e.getStackTraceString()));
                }
        return responseData;
    }
    //Get Fields to be displayed in the ListView
     @AuraEnabled(cacheable=true)
    public static List<DC_Integration_Query_Fields__c>  getListViewFields(string queryConfigName)
    {
        List<DC_Integration_Query_Fields__c> listViewFields = new List<DC_Integration_Query_Fields__c>();
        try
        {
          listViewFields = [select Id,Field_Label__c,Field_Api_Name__c,Field_Data_Type__c,TypeAttributes__c,Is_List_View_Field__c,DC_Integration_Query_Configuration__r.Name,ListViewOrder__c
                from DC_Integration_Query_Fields__c 
                where DC_Integration_Query_Configuration__r.Name = :queryConfigName and Is_List_View_Field__c=true ORDER BY ListViewOrder__c ];
            return listViewFields;
        }
        catch (Exception e) 
        {
          insert (new Error_Logs__c(Name='Error while fetching Fields'));
       }
        return listViewFields;
    }
    //Get the Fields to be displayed in detail view via query in Dc Integration query Configuration
    @AuraEnabled(cacheable=true)
    public static List<String> getFieldApinames(String queryConfigName)
   {
      List<String> fieldApinames = new List<String>();
     DC_Integration_Query_Configuration__c getRecord =[SELECT Id, Name,Object_Name__c, Parent_Object__c, Relationship__c, Query__c, OrgId__c FROM DC_Integration_Query_Configuration__c WHERE Name = :queryConfigName Limit 1];
     String query =getRecord.Query__c;
       system.debug('getRecord'+getRecord);
       system.debug('query'+query);
        String querywithFields = query;
        // Find the positions of 'select' and 'from'
     Integer startPos = querywithFields.indexOf('select') + 'select'.length();
     Integer endPos = querywithFields.indexOf('from'); 
      if (startPos == -1 || endPos == -1 || startPos >= endPos) {
        return fieldApinames; // Return empty list if positions are invalid
    }
      // Extract the substring between select and from
        querywithFields = query.substring(startPos, endPos).trim();
        // Split the cleaned string by commas to get each field API name
        List<String> fields = querywithFields.split(',');
        // Remove extra spaces and quotes, then add to the list
        for (String field : fields) {
            field = field.trim().replace('"', '');
                fieldApiNames.add(field);
             }
     return fieldApinames;
  }
    
    
    //Get Fields to be displayed in record DetailView via Records Related to DC Integration query Fields
    @AuraEnabled(cacheable=true)
    public static List<DC_Integration_Query_Fields__c>  getDetailViewFields(string queryConfigName)
    {
        List<DC_Integration_Query_Fields__c> detailViewFields = new List<DC_Integration_Query_Fields__c>();
        try 
        {
             detailViewFields = [select Id,Field_Label__c,Field_Api_Name__c,DC_Integration_Query_Configuration__r.Name,Detail_View_Order__c
                from DC_Integration_Query_Fields__c 
                where DC_Integration_Query_Configuration__r.Name = :queryConfigName  ORDER BY Detail_View_Order__c ];
       }
        catch (Exception e) 
        {
          insert (new Error_Logs__c(Name='Error while fetching Fields'));
       }
        return detailViewFields;
        
        
    }

  //Get case data by subject
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getDatabyCaseSubject(string queryConfigName,String searchTerm)
    {
        List<Map<String, Object>> responseData = new List<Map<String, Object>>();
        List<DC_Integration_Query_Configuration__c> auditQueryConfigurations = getAuditConfig(queryConfigName);
        DC_Integration_Query_Configuration__c dcConfig;
        for (DC_Integration_Query_Configuration__c config : auditQueryConfigurations) {
            if (config.Name == queryConfigName) {
                dcConfig = config;
                break;
            }
        }
        string query = ''; 
        
        if(dcConfig != null){
            query = dcConfig.Query__c.replace('searchTerm', '\'' + '%' + searchTerm +'%'+ '\'');
            system.debug('query'+query);
        }

        // Execute the provided query
        String responseBody = executeQuery(query);

        // Parse response body
        if (responseBody != null && !String.isEmpty(responseBody)) {
            responseData = convertToObjects(responseBody);
            return responseData;
        }
        return responseData;
    }
    //Get Case data by case Number
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getDatabyUserInput(string queryConfigName,String userInput)
    {
        List<Map<String, Object>> responseData = new List<Map<String, Object>>();
        List<DC_Integration_Query_Configuration__c> auditQueryConfigurations = getAuditConfig(queryConfigName);
        DC_Integration_Query_Configuration__c dcConfig;
        for (DC_Integration_Query_Configuration__c config : auditQueryConfigurations) {
            if (config.Name == queryConfigName) {
                dcConfig = config;
                break;
            }
        }
        String modifiedQuery= '';
        if(dcConfig!=null)
        {   
        if (isAlpha(userInput)) 
        {
            // Replace the placeholder with string filter for LIKE clause
            String subjectFilter =  'WHERE Subject__c LIKE \''  + '%' +userInput +'%'+'\''+' LIMIT 10';
            // Construct the modified query
            modifiedQuery = dcConfig.Query__c+' '+subjectFilter;
            
        } else 
        {
          // Replace the placeholder with actual numeric value
            String caseNumberFilter = 'WHERE CaseNumber__c = \'' + userInput + '\'';
            // Construct the modified query
            modifiedQuery = dcConfig.Query__c+' '+caseNumberFilter;
        }
        }
        // Execute the provided query
        String responseBody = executeQuery(modifiedQuery);

        // Parse response body
        if (responseBody != null && !String.isEmpty(responseBody)) {
            responseData = convertToObjects(responseBody);
            return responseData;
        }
        return responseData;
    }
        
    public static List<Map<String, Object>> convertToObjects(String jsonData) {
        List<Map<String, Object>> objects = new List<Map<String, Object>>();
        try
        {
        // Parse JSON data
        Map<String, Object> data = (Map<String, Object>)JSON.deserializeUntyped(jsonData);
        List<Object> jsonDataList = (List<Object>)data.get('data');
        Map<String, Object> metadata = (Map<String, Object>)data.get('metadata');
        
        // Create a list of maps to store field names and placeInOrder values
        List<Map<String, Object>> metadataList = new List<Map<String, Object>>();
        for (String fieldName : metadata.keySet()) {
            Map<String, Object> fieldInfo = (Map<String, Object>)metadata.get(fieldName);
            Integer placeInOrder = (Integer)fieldInfo.get('placeInOrder');
            Map<String, Object> fieldMap = new Map<String, Object>();
            fieldMap.put('fieldName', fieldName);
            fieldMap.put('placeInOrder', placeInOrder);
            metadataList.add(fieldMap);
        }

        // // Sort the metadataList based on placeInOrder values
        for (Integer i = 0; i < metadataList.size(); i++) {
            for (Integer j = i + 1; j < metadataList.size(); j++) {
                Map<String, Object> metadataA = metadataList[i];
                Map<String, Object> metadataB = metadataList[j];
                Integer orderA = (Integer)metadataA.get('placeInOrder');
                Integer orderB = (Integer)metadataB.get('placeInOrder');
                if (orderA > orderB) {
                    // Swap the elements
                    Map<String, Object> temp = metadataList[i];
                    metadataList[i] = metadataList[j];
                    metadataList[j] = temp;
                }
            }
        }
        
        // Iterate over each entry in the data and create objects
        for (Object entry : jsonDataList) {
            List<Object> entryList = (List<Object>)entry;
            Map<String, Object> obj = new Map<String, Object>();
            
            // Map data based on sorted metadata keys
            for (Map<String, Object> fieldMap : metadataList) {
                String fieldName = (String)fieldMap.get('fieldName');
                Integer placeInOrder = (Integer)fieldMap.get('placeInOrder');
                obj.put(fieldName, entryList[placeInOrder]);
            }
            objects.add(obj);
        }
        return objects;
        }
        catch(exception ex)
        {
           insert (new Error_Logs__c(Name='Error while mapping the data'));
        }
        return objects;
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCaseData(String subject) {
        List<Map<String, Object>> responseData = new List<Map<String, Object>>();
         try
        {
        // get the query from config for given object
        //String subject='TDS Amount';
        String query = 'SELECT c.CRM_Closure_Email__c, c.Subject__c, c.CRM_Query_Type__c, c.Class__c, c.Closure_EmailTextBody__c, c.Description__c, c.Subclass__c ' +
                       'FROM vector_search(table(EMAILGENAIPOC_index__dlm), \'' + 
                       String.escapeSingleQuotes(subject.escapeJava()).replaceAll('\'', '\\u0027') + 
                       '\', \'\', 100) v ' +
                       'JOIN EMAILGENAIPOC_chunk__dlm cc ON v.SourceRecordId__c = cc.RecordId__c ' +
                       'JOIN email_GENAIPOC__dlm c ON cc.SourceRecordId__c = c.Subject__c ' +
                       'WHERE cc.Chunk__c != \'\' AND score__C > 0.6 ' +
                       'ORDER BY score__C DESC LIMIT 5';

        // Execute the provided query
        String responseBody = executeQuery(query);

        // Parse response body
        if (responseBody != null && !String.isEmpty(responseBody)) {
            responseData = convertToObjects(responseBody);
            return responseData;
        }
        }
        catch(exception e) 
                {
                   insert (new Error_Logs__c(Name=e.getTypeName(),Exception_From__c=String.valueof(e.getLineNumber())+e.getCause(),Exception_Message__c=e.getMessage(),Exception_Type__c=e.getTypeName(),Input_Request__c=e.getStackTraceString()));
                }
        return responseData;
    }
    public static Boolean isAlpha(String userInput) {
        Pattern alphaPattern = Pattern.compile('^[a-zA-Z ]*$');
        Matcher matcher = alphaPattern.matcher(userInput);
        return matcher.matches();
    }
    
}
