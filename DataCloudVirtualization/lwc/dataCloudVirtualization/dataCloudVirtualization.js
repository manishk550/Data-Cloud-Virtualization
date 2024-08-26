import { LightningElement, api, track, wire } from 'lwc';
import getChildDataByParentId from '@salesforce/apex/DCIntegrationPageController.getChildDataByParentId';
import getDatabyUserInput from '@salesforce/apex/DCIntegrationPageController.getDatabyUserInput';
import getListViewFields from '@salesforce/apex/DCIntegrationPageController.getListViewFields';
import { EnclosingTabId, openSubtab, IsConsoleNavigation } from 'lightning/platformWorkspaceApi';
import MESSAGE_CHANNEL from '@salesforce/messageChannel/dcObjectMessageChannel__c';
import { publish, MessageContext } from 'lightning/messageService';

export default class DcListViewSearchPOC extends LightningElement {
    @api ObjectName;
    objectName;
    recordId = '';
    @track totalRecs = [];
    @track simpleListViewRecs = [];
    @track extendedListViewRecords = [];
    @track simpleListViewColumns = [];
    @track extendedListViewColumns = [];
    @track error;
    loading = true;
    currentPage = 1;
    totalPages;
    recordSize = 10;
    startRecNumToDisplay = 1;
    endRecNumToDisplay = 10;
    totalRecsNumToDisplay;
    @api showDetailView = false;
    @api viewAll = false;
    searchTerm = '';

    @wire(MessageContext)
    messageContext;
    @wire(IsConsoleNavigation)
    isConsoleNavigation;
    @wire(EnclosingTabId)
    enclosingTabId;

    connectedCallback() {
        this.cloneObjectName();
    }

    cloneObjectName() {
        this.objectName = this.ObjectName;
    }

    @wire(getListViewFields, { queryConfigName: '$ObjectName' })
    wiredListViewFields({ error, data }) {
        if (data) {
            this.simpleListViewColumns = this.processListViewColumns(data);
            this.extendedListViewColumns = this.simpleListViewColumns;
        } else if (error) {
            console.error('Error loading list view columns', error);
            this.error = 'Error loading list view columns. Please try again later.';
            this.loading = false;
        }
    }

    @wire(getChildDataByParentId, { queryConfigName: '$ObjectName', parentId: '$recordId' })
    wiredChildDataByParentId({ error, data }) {
        if (data) {
            this.totalRecs = data;
            this.updateDisplayedRecords();      
        } else if (error) {
            console.error('Error loading child data by parent ID', error);
            this.error = 'Error loading child data. Please try again later.';
            this.loading = false;
        }
    }

    processListViewColumns(columns) {
        return columns.map(col => {
            const additionalInfo = this.getAdditionalColumnInfo(col.TypeAttributes__c);
            return {
                label: col.Field_Label__c,
                fieldName: col.Field_Api_Name__c,
                type: this.getDataType(col.Field_Data_Type__c),
                typeAttributes: additionalInfo.typeAttributes
            };
        });
    }

    updateDisplayedRecords() {
        if (this.searchTerm.length>7) {
            this.loadData();
        } else {
            this.totalRecsNumToDisplay = this.totalRecs.length;
            let n = this.totalRecs.length > 5 ? 5 : this.totalRecs.length;
            this.simpleListViewRecs = this.totalRecs.slice(0, n);
            let m = this.totalRecs.length > 10 ? 10 : this.totalRecs.length;
            this.extendedListViewRecords = this.totalRecs.slice(0, m);
            this.totalPages = Math.ceil(this.totalRecs.length / this.recordSize);
            this.loading = false;
        }
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        console.log('searchTerm',this.searchTerm);
        this.currentPage = 1;
        this.updateDisplayedRecords();
    }

    loadData() {
        getDatabyUserInput({ queryConfigName: 'searchCase', userInput: this.searchTerm })
            .then(data => {
                if (data) {
                    this.simpleListViewRecs = data;
                    
                }
            })
            .catch(error => {
                console.error('Error loading data by user input', error);
                this.error = 'Error loading data. Please try again later.';
                this.loading = false;
            });
    }

    // Other methods...

    getDataType(type) {
        if (!type) return "text";
        return type;
    }

    getAdditionalColumnInfo(json) {
        if (!json) return {};
        try {
            return JSON.parse(json);
        } catch (e) {
            console.error("Error parsing additional column info", e);
            return {};
        }
    }

    previousHandler() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.sliceRecords();
        }
    }

    nextHandler() {
        if (this.currentPage < this.totalPages) {
            this.currentPage = this.currentPage + 1;
            this.sliceRecords();
        }
    }

    sliceRecords() {
        const start = (this.currentPage - 1) * this.recordSize;
        this.startRecNumToDisplay = start + 1;
        const end = this.recordSize * this.currentPage;
        this.endRecNumToDisplay = end > this.totalRecsNumToDisplay ? this.totalRecsNumToDisplay : end;
        this.extendedListViewRecords = this.totalRecs.slice(start, end);
    }

    viewAllHandler() {
        let componentDef = {
            componentDef: "c:dcListViewSearchPOC",
            attributes: {
                showDetailView: true,
                viewAll: true,
                ObjectName: this.objectName
            }
        };
        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        if (this.isConsoleNavigation) {
            openSubtab(this.enclosingTabId, {
                url: '/one/one.app#' + encodedComponentDef,
                label: this.objectName,
                icon: 'utility:work_order_type',
                focus: true
            }).catch(error => {
                console.error("Error opening a tab", error);
                this.error = 'Error opening new tab. Please try again later.';
            });
        }
    }

    detailViewHandler(event) {
        const actionName = event.detail.action.name;
        if (actionName === 'viewDetails') {
            const row = event.detail.row;
            this.handleDetailView(row);
        }
    }

    handleDetailView(recordDetails) {
        const message = {
            recordDetails: JSON.stringify(recordDetails),
            objectName: this.objectName
        };
        publish(this.messageContext, MESSAGE_CHANNEL, message);
    }
}