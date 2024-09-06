({
	handleMessage : function(component, message, helper) {
        // Retrieve the data passed from LWC
        var workspaceAPI = component.find("workspace");
         var messageChannel = component.find('mChannel');
         if (message != null && message.getParam('recordDetails')!=null ) 
         {
                    const recordDetails = message.getParam('recordDetails');
                    const objectName = message.getParam('objectName');
                    console.log('record'+recordDetails);
                    console.log('objectName'+objectName);
                    component.set('v.recordDetails',JSON.parse(recordDetails) );
                    component.set('v.objectName',message.getParam('objectName'));
              workspaceAPI.getEnclosingTabId().then(function(currentTabId) {
                workspaceAPI.openSubtab({
                    parentTabId: currentTabId,
                    pageReference: {
                        type: 'standard__component',
                        attributes: {
                            componentName: 'c__dcRecordDetailViewAW' // Name of your Lightning Component
                        },
                        state: {
                            c__recordDetails: recordDetails,
                            c__objectName:objectName
                        }
                    },
                    focus: true,
                    label: objectName,
                    icon: 'standard:case'
                }).then(function(response) {
                    console.log("New Sub-Tab opened successfully with Tab ID: ", response);
                }).catch(function(error) {
                    console.log("Error opening new sub-tab: ", error);
                });
            }).catch(function(error) {
                console.log("Error getting focused tab info: ", error);
            });  
         
         } 
    }
    
})({
	myAction : function(component, event, helper) {
		
	}
})