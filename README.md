
# Data-Cloud-Virtualization APP 
Virtualise your data cloud DMO object data like case and account in Salesforce by using the Reusable LWC app by just changing configuration records.

#Vector Data Base 
Use the power of semantic search from vector data base to provide cases recommendation to agents so agents can learn from the closed archived cases in data cloud.

Pre Requisite - 

- [ ] Create Connected App
- [ ] Create Named Credential 
- [ ] Setup Auth Provider 

Setup Vector Database for Case Recommendations
Setup Vector Database for Case DMO for Case Recommendations

Install this Package 
- [ ] Create the Custom Config Object Records and define your Query 
- [ ] Create the Child Custom Config Object and Define the label and order for list view 

Post Deployment Steps-
- Provide the following  Object access and field access to the user profile
        - Dc Integration Query Configuration
        - DC integration Query Fields
- Provide Object/Tab access
- Provide access to Data cloud virtulaization app 
- Go to App Builder and drang the follwoing component to the Case Record page
    -   DataCloudVirtualization - ex - Query Config Name - Case 
    -   DatacloudCaseRecommendations 
    -   dcrecordDetailSA


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
 -   
   Note - Create the Child Custom Config Object and Define the label and order for Detail View 

