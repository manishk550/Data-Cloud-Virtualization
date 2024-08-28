
# Data-Cloud-Virtualization APP 
Leverage the power of Data Cloud by virtualizing your DMO object data (e.g., Case and Account) within Salesforce using a reusable LWC app. Customize the data display simply by adjusting configuration records.


# Vector Database Integration
Enhance your agents' efficiency by harnessing  search capabilities from a vector database. This feature enables the recommendation of relevant cases to agents, allowing them to learn from archived cases within Data Cloud.

 # Pre Requisite - 

- [ ] Create Connected App
- [ ] Create Named Credential 
- [ ] Setup Auth Provider 

Setup Vector Database for Case Recommendations
Setup Vector Database for Case DMO for Case Recommendations

 # Install the Package 
Installation Instructions
1. Install the Package This package includes the following components:
    * dcIntegrationPageController - Apex class for fetching Data Cloud DMO data.
    * DataCloudVirtualization - LWC for displaying case data.
    * DataCloudCaseRecommendation - LWC for displaying case recommendations.
    * DataCloudRecordView - LWC for displaying record details.
    * dcrecordDetailViewSA - Service component for console navigation to open records in a new tab (required in App Builder).
    * dcrecordDetailViewAW - Wrapper component for holding the LWC record view component.


 # Post-Deployment Steps
1. Assign Object and Field Access Provide the necessary object and field access to the relevant user profiles:
    * Objects: Dc Integration Query Configuration, DC Integration Query Fields
    * Tab Access: Ensure users have access to the Data Cloud Virtualization app.
2. Configure the Case Record Page Using the App Builder, drag the following components onto the Case Record page:
    * DataCloudVirtualization (e.g., with Query Config Name: Case)
    * DataCloudCaseRecommendations
    * dcrecordDetailSA


- [ ] Create the Custom Config Object Records and define your Query

    -  Name - Case(Query Config Name )
    -  Query -  select AccountId__c,CaseNumber__c,Id__c, ContactId__c,Comments__c,ContactEmail__c,ContactMobile__c,ContactPhone__c,ContactId__c,Priority__c, Status__c, Subject__c from Case_00Da5000002yYP8__dll limit 10
    -  Parent_Object__c - Account 
    -  Relationship - Child 


- [ ] Create the Child Custom Config Object and Define the label and order for list view
 -   Field_Api_Name__c - DMO Field Api Name
 -   Field_Label__c - Label Name in LWC 
 -   Field_Data_Type__c - Text, Button, Number, Currency, date , Phone , email 
 -   TypeAttributes__c - { "typeAttributes": { "label": { "fieldName": "CaseNumber__c" }, "name": "viewDetails", "variant": "base" } }  - For id fields , blank for others 

 -   ListViewOrder__c - Order of the field label 
 -   Is_List_View_Field__c - Display on list view 
   
Note: The Detail View component will dynamically retrieve field names from the query defined in the Dc Integration Query Configuration object record.

