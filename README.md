
Data-Cloud-Virtualization APP
Overview

Leverage the power of Data Cloud by virtualizing your DMO object data (e.g., Case and Account) within Salesforce using a reusable LWC app. Customize the data display simply by adjusting configuration records.

Vector Database Integration

Enhance your agents' efficiency by harnessing semantic search capabilities from a vector database. This feature enables the recommendation of relevant cases to agents, allowing them to learn from archived cases within Data Cloud.

Prerequisites
Before installing and using the app, ensure the following steps are completed:

Create a Connected App
Create a Named Credential
Set Up an Auth Provider
Setup Vector Database for Case DMO Recommendations
Installation Instructions
Install the Package
This package includes the following components:

dcIntegrationPageController - Apex class for fetching Data Cloud DMO data.
DataCloudVirtualization - LWC for displaying case data.
DataCloudCaseRecommendation - LWC for displaying case recommendations.
DataCloudRecordView - LWC for displaying record details.
dcrecordDetailViewSA - Service component for console navigation to open records in a new tab (required in App Builder).
dcrecordDetailViewAW - Wrapper component for holding the LWC record view component.
Post-Deployment Steps
Assign Object and Field Access
Provide the necessary object and field access to the relevant user profiles:

Objects: Dc Integration Query Configuration, DC Integration Query Fields
Tab Access: Ensure users have access to the Data Cloud Virtualization app.
Configure the Case Record Page

Using the App Builder, drag the following components onto the Case Record page:

DataCloudVirtualization (e.g., with Query Config Name: Case)
DataCloudCaseRecommendations
dcrecordDetailSA
Create Custom Configuration Records

Set up custom configuration records to define your data queries:

Custom Config Object (Dc Integration Query Configuration):

Name: Case (or your specific Query Config Name)
Query: Define the query to retrieve your data, e.g.:
sql
Copy code
SELECT AccountId__c, CaseNumber__c, Id__c, ContactId__c, Comments__c, ContactEmail__c, ContactMobile__c, ContactPhone__c, ContactId__c, Priority__c, Status__c, Subject__c 
FROM Case_00Da5000002yYP8__dll 
LIMIT 10
Parent_Object__c: Account
Relationship: Child
Child Custom Query Field Object (DC Integration Query Fields):

Field_Api_Name__c: DMO Field API Name
Field_Label__c: Label Name in LWC
Field_Data_Type__c: Specify data type (Text, Button, Number, Currency, Date, Phone, Email)
TypeAttributes__c: (Optional) For ID fields, specify type attributes, e.g.:
json
Copy code
{ "typeAttributes": { "label": { "fieldName": "CaseNumber__c" }, "name": "viewDetails", "variant": "base" } }
ListViewOrder__c: Define the display order in the list view.
Is_List_View_Field__c: Specify whether to display the field in the list view.
Note: The Detail View component will dynamically retrieve field names from the query defined in the Dc Integration Query Configuration object record.

This structured guide should be suitable for use in a professional setting, helping users efficiently set up and deploy the Data-Cloud-Virtualization APP while providing the necessary details to customize and extend the application.
