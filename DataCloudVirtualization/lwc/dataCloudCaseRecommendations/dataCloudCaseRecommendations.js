import { LightningElement, api, track, wire } from 'lwc';
import getSimilarCases from '@salesforce/apex/DCIntegrationPageController.getCaseData';
import { getRecord } from 'lightning/uiRecordApi';
import { EnclosingTabId, openSubtab, IsConsoleNavigation } from 'lightning/platformWorkspaceApi';
import MESSAGE_CHANNEL from '@salesforce/messageChannel/dcObjectMessageChannel__c';
import { publish, MessageContext } from 'lightning/messageService';

const FIELDS = [
    'Case.Id',
    'Case.Subject',
];

export default class DcListvIewSerachbySubject extends LightningElement {
    @wire(MessageContext)
    messageContext;
    
    @wire(IsConsoleNavigation)
    isConsoleNavigation;

    @wire(EnclosingTabId)
    enclosingTabId;

    @api recordId;
    @api caseSubject;
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
    endRecNumToDisplay ;
    totalRecsNumToDisplay;
    @api showDetailView = false;
    @api viewAll = false;

    @track columns = [
        { label: 'Query Type', fieldName: 'CRM_Query_Type__c', type: 'button', 
            typeAttributes: { 
                label: { fieldName: 'CRM_Query_Type__c' },
                name: 'viewDetails',
                variant: 'base'
            }
        },
        { label: 'Class', fieldName: 'Class__c', type: 'text' },
        { label: 'Description', fieldName: 'Description__c', type: 'text' },
        { label: 'Subject', fieldName: 'Subject__c', type: 'text' }
    ];

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    handleRecord({ error, data }) {
        if (data) {
            this.caseSubject = data.fields.Subject.value;
            console.log('this.caseSubject', this.caseSubject);
            // Trigger fetch of similar cases by subject
            this.fetchSimilarCases();
        } else if (error) {
            console.error('Error retrieving record:', error);
            this.caseSubject = 'Error retrieving subject';
        }
    }

    @wire(getSimilarCases, { subject: '$caseSubject' })
    wiredCases({ error, data }) {
        if (data) {
            this.totalRecs = data;
            let n = this.totalRecs.length > 5 ? 5 : this.totalRecs.length;
            this.simpleListViewRecs = this.totalRecs.slice(0, n);
            let m = this.totalRecs.length > 10 ? 10 : this.totalRecs.length;
            this.extendedListViewRecords = this.totalRecs.slice(0, m);
            this.totalPages = Math.ceil(this.totalRecs.length / this.recordSize);
            this.totalRecsNumToDisplay = this.totalRecs.length;
            this.endRecNumToDisplay=m;
            this.loading = false;
        } else if (error) {
            console.error('Error fetching similar cases:', error);
            this.error = 'Error fetching similar cases. Please try again later.';
            this.loading = false;
        }
    }

    fetchSimilarCases() {
        if (this.caseSubject && this.caseSubject.length > 3) {
            // The @wire method will automatically handle the call and data binding
        }
    }

    handleSearch(event) {
        this.caseSubject = event.target.value;
        console.log('searchTerm', this.caseSubject);
        this.currentPage = 1;
        this.updateDisplayedRecords();
    }
    
    previousHandler() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
            this.sliceRecords();
        }
    }

    updateDisplayedRecords() {
        if (this.caseSubject.length > 3) {
            // The @wire method will automatically handle the call and data binding
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
            componentDef: "c:DcListvIewSerachbySubject",
            attributes: {
                showDetailView: true,
                viewAll: true,
                caseSubject: this.caseSubject
            }
        };
        let encodedComponentDef = btoa(JSON.stringify(componentDef));
        if (this.isConsoleNavigation) {
            console.log('searchTerm', this.caseSubject);
            openSubtab(this.enclosingTabId, {
                url: '/one/one.app#' + encodedComponentDef,
                label: 'Cases',
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
            objectName: 'cases1'
        };
        publish(this.messageContext, MESSAGE_CHANNEL, message);
    }
}