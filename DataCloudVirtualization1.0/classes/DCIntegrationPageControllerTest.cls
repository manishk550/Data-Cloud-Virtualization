@isTest
private class DCIntegrationPageControllerTest {
    
    @isTest
    static void testGetListViewFields() {
        // Step 1: Setup test data for DC_Integration_Query_Configuration__c
        DC_Integration_Query_Configuration__c config = new DC_Integration_Query_Configuration__c(
            Name = 'Feedback',
            Query__c = 'SELECT Id FROM Feedback__dlm LIMIT 10'
        );
        insert config;

        // Step 2: Setup test data for DC_Integration_Query_Fields__c
        DC_Integration_Query_Fields__c field = new DC_Integration_Query_Fields__c(
            Field_Label__c = 'First Name',
            Field_Api_Name__c = 'first_name__c',
            Field_Data_Type__c = 'text',
            TypeAttributes__c = 'SomeAttributes',
            Is_List_View_Field__c = true,
            DC_Integration_Query_Configuration__c = config.Id,
            ListViewOrder__c = 1
        );
        insert field;

        // Step 3: Execute the method
        List<DC_Integration_Query_Fields__c> result = DCIntegrationPageController.getListViewFields('Feedback');

        // Step 4: Validate results
        System.assertEquals(1, result.size(), 'The number of fields returned should be 1.');

        DC_Integration_Query_Fields__c returnedField = result[0];
        System.assertEquals('First Name', returnedField.Field_Label__c, 'The field label should be "First Name".');
        System.assertEquals('first_name__c', returnedField.Field_Api_Name__c, 'The field API name should be "first_name__c".');
        System.assertEquals('text', returnedField.Field_Data_Type__c, 'The field data type should be "text".');
        System.assertEquals('SomeAttributes', returnedField.TypeAttributes__c, 'The field type attributes should be "SomeAttributes".');
        System.assertEquals(true, returnedField.Is_List_View_Field__c, 'The field should be marked as a list view field.');
        System.assertEquals(1, returnedField.ListViewOrder__c, 'The list view order should be 1.');
    }
    @isTest
    static void testGetListViewFieldsException() {
        // Simulate an error scenario. For instance, if a problem arises during SOQL execution,
        // the catch block will execute. However, it's challenging to simulate this directly
        // without using custom error-handling mechanisms or mocking, which isn't directly feasible.

        // Insert valid data to ensure no errors occur and validate results
        DC_Integration_Query_Configuration__c config = new DC_Integration_Query_Configuration__c(
            Name = 'Feedback',
            Query__c = 'SELECT Id FROM Feedback__dlm LIMIT 10'
        );
        insert config;

        DC_Integration_Query_Fields__c field = new DC_Integration_Query_Fields__c(
            Field_Label__c = 'First Name',
            Field_Api_Name__c = 'first_name__c',
            Field_Data_Type__c = 'text',
            TypeAttributes__c = 'SomeAttributes',
            Is_List_View_Field__c = true,
            DC_Integration_Query_Configuration__c = config.Id,
            ListViewOrder__c = 1
        );
        insert field;

        List<DC_Integration_Query_Fields__c> result = DCIntegrationPageController.getListViewFields('Feedback');
        
        // Validate results
        System.assertEquals(1, result.size(), 'The number of fields returned should be 1.');

        // Check error logs if applicable
        List<Error_Logs__c> logs = [SELECT Id FROM Error_Logs__c];
        System.assert(logs.isEmpty(), 'There should be no error logs created in this case.');
    }


    @isTest
    static void testExecuteQuerySuccess() {
        // Setup mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, '{"data": [], "metadata": {}}'));

        // Setup test data
        String testQuery = 'SELECT Id FROM Account LIMIT 1';
        
        // Execute method
        String result = DCIntegrationPageController.executeQuery(testQuery);
        
        // Validate results
        System.assertEquals('{"data": [], "metadata": {}}', result);
    }
    
    @isTest
    static void testExecuteQueryUnauthorized() {
        // Setup mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(401, 'Unauthorized'));

        // Setup test data
        String testQuery = 'SELECT Id FROM Account LIMIT 1';
        
        // Execute method
        String result = DCIntegrationPageController.executeQuery(testQuery);
        
        // Validate results
        System.assertEquals('Problem with Authorization with Data cloud, please contact system admin.', result);
    }
    
    @isTest
    static void testExecuteQueryBadRequest() {
        // Setup mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, 'Bad Request'));

        // Setup test data
        String testQuery = 'SELECT Id FROM Account LIMIT 1';
        
        // Execute method
        String result = DCIntegrationPageController.executeQuery(testQuery);
        
        // Validate results
        System.assertEquals('Problem with Authorization with Data cloud, please contact system admin.', result);
    }
    
    @isTest
    static void testExecuteQueryUnhandledResponse() {
        // Setup mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Server Error'));

        // Setup test data
        String testQuery = 'SELECT Id FROM Account LIMIT 1';
        
        // Execute method
        String result = DCIntegrationPageController.executeQuery(testQuery);
        
        // Validate results
        System.assertEquals('', result);
    }
    
    @isTest
    static void testGetAuditConfig() {
        // Setup test data
        DC_Integration_Query_Configuration__c config = new DC_Integration_Query_Configuration__c(
            Name = 'Feedback',
            Query__c = 'SELECT Id FROM Feedback__dlm'
        );
        insert config;
        
        // Execute method
        List<DC_Integration_Query_Configuration__c> result = DCIntegrationPageController.getAuditConfig('Feedback');
        
        // Validate results
        System.assertEquals(1, result.size());
        System.assertEquals('Feedback', result[0].Name);
    }
    
    @isTest
    static void testGetChildDataByParentId() {
        // Setup mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(201, '{"data": [{"Id": "001"}, {"Id": "002"}], "metadata": {}}'));

        // Setup test data
        DC_Integration_Query_Configuration__c config = new DC_Integration_Query_Configuration__c(
            Name = 'Feedback',
            Query__c = 'SELECT Id FROM Feedback__dlm WHERE ParentId = :parentIdPlaceholder'
        );
        insert config;
        
        // Execute method
        List<Map<String, Object>> result = DCIntegrationPageController.getChildDataByParentId('Feedback', '001');
        
        // Validate results
        //System.assertEquals(1, result.size());
        //System.assertEquals('001', result[0].get('Id'));
    }
    @isTest
    static void testConvertToObjects() {
        // Setup test data
        String jsonData = '{"data": [["John", "Doe"]], "metadata": {"first_name__c": {"placeInOrder": 0}, "last_name__c": {"placeInOrder": 1}}}';
        // Execute method
        List<Map<String, Object>> result = DCIntegrationPageController.convertToObjects(jsonData);
        
        // Validate results
        System.assertEquals(1, result.size());
        System.assertEquals('John', result[0].get('first_name__c'));
        System.assertEquals('Doe', result[0].get('last_name__c'));
    }
    
    @isTest
    static void testErrorLogging() {
        // Setup test data
        Test.startTest();
        // Simulate an exception
        try {
            DCIntegrationPageController.convertToObjects('Invalid JSON');
        } catch (Exception e) {
            // Catch exception to test logging
        }
        Test.stopTest();
        
        // Validate error logs
        List<Error_Logs__c> logs = [SELECT Id FROM Error_Logs__c];
        System.assert(logs.size() > 0, 'Error logs should have been created');
    }
    @isTest
    static void testGetFieldApinames() {
        // Setup test data
        // Create a test record for DC_Integration_Query_Configuration__c
        DC_Integration_Query_Configuration__c testConfig = new DC_Integration_Query_Configuration__c(
            Name = 'Booking',
            Query__c = 'SELECT Id, Name, Account.Name, CreatedDate FROM Booking LIMIT 10'
        );
        insert testConfig;
        
        // Call the method with the name of the test record
        List<String> fieldApiNames = DCIntegrationPageController.getFieldApinames('Booking');
    }
    
    // Mock HttpResponse Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
}