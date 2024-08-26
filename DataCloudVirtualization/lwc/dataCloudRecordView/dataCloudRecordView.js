import { LightningElement,track,wire} from 'lwc';
//import getDetailViewFields from '@salesforce/apex/DCIntegrationPageController.getDetailViewFields';
import getDetailViewFields from '@salesforce/apex/DCIntegrationPageController.getFieldApinames';
import { CurrentPageReference } from "lightning/navigation"
export default class DataCloudRecordView extends LightningElement {
@track objectName;
@track recordDetails;
@track recordFieldsToDisplay;
@wire(getDetailViewFields, { recordDetails: '$recordDetails',queryConfigName: '$objectName' })
wiredDetailViewFields({ error, data }) 
{
  if(data)
  {
         let FieldAPinames=data;
         let detailViewFields=FieldAPinames.map(row=>{
          const fieldLabel = this.getFieldLabel(row);
          return{
            fieldAPiName: row,
            fieldLabel:fieldLabel
          }
         });
         this.recordFieldsToDisplay=this.groupFields(detailViewFields);
  }
  else if (error) {
    console.error(error);
}
}
//beautify the Field label from the Api name
   getFieldLabel(fieldName) {
  // Remove '__c'
  let updatedName = fieldName.replace(/__c/g, '');
  // Remove '_c'
  updatedName = updatedName.replace(/_c/g, '');
  // Remove '_'
  updatedName = updatedName.replace(/_/g, ' ');
  return updatedName;
}

groupFields(fields)
{
  const groupedRecordFields = [];
  for (let i = 0; i < fields.length; i += 2) {
      const field1 = fields[i];
      const field2 = fields[i + 1];
      groupedRecordFields.push({
          field1Label: field1.fieldLabel,
          field1Value: this.recordDetails[field1.fieldAPiName],
          field2Label: field2 ? field2.fieldLabel : null,
          field2Value: field2 ? this.recordDetails[field2.fieldAPiName] : null,
          
      });
  }
  return groupedRecordFields;
}

//working code backup

/*@wire(getDetailViewFields, { recordDetails: '$recordDetails',queryConfigName: '$objectName' })
    wiredrecordFields({ error, data }) {
        if (data) {
            const groupedRecordFields = this.grouprecordFields(data);
            this.recordFieldsToDisplay = groupedRecordFields;
            console.log('recordFieldsToDisplay',this.recordFieldsToDisplay[0]);
        } else if (error) {
            console.error(error);
        }
    }
    // Function to group booking fields
    grouprecordFields(fields) {
        const groupedRecordFields = [];
        for (let i = 0; i < fields.length; i += 2) {
            const field1 = fields[i];
            const field2 = fields[i + 1];
            groupedRecordFields.push({
                field1Label: field1.Field_Label__c,
                field1Value: this.recordDetails[field1.Field_Api_Name__c],
                field2Label: field2 ? field2.Field_Label__c : null,
                field2Value: field2 ? this.recordDetails[field2.Field_Api_Name__c] : null,
                
            });
        }
        return groupedRecordFields;
    }*/
  
  @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
      if (currentPageReference) {
        this.recordDetails = currentPageReference.state.c__recordDetails;
        this.objectName = currentPageReference.state.c__objectName;
        if(this.recordDetails)
        {
          this.recordDetails = JSON.parse(this.recordDetails); 
        }
  
      }
    }
    get accordianName() {
      return `${this.objectName} Details`;
  }
    handleSectionToggle(event) {
      const openSections = event.detail.openSections;
      // Optionally handle when sections are toggled
    }
}