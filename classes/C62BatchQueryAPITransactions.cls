global with sharing class C62BatchQueryAPITransactions implements Database.batchable<sObject>, Database.AllowsCallouts, Database.Stateful{


    public string transId;
    global C62BatchQueryAPITransactions () {
    }
    public C62BatchQueryAPITransactions(String transId){
        this.transId = transId;
    }
    /*global Database.QueryLocator start(Database.BatchableContext BC) {
        Map<String, String> inputs = new Map<String, String>();

        inputs.put('condition', 'pendingsettlement,complete');

        C62PaymentGatewayEVO x = new C62PaymentGatewayEVO();
        x.QueryTransactions = true;
        calloutResponse = x.QueryPaymentRecord(inputs);

        integer cnt = Integer.ValueOf(calloutResponse.NonStandardValues.Get('TransactionCount'));

        if(cnt == 0){
            return null;
        }

        List<String> tempIDs = new List<String>();

        for(integer i = 0; i < cnt; i++){
            TransactionRecords.Put(calloutResponse.NonStandardValues.Get(i + '-transaction_id'), i + '');
            tempIDs.Add(calloutResponse.NonStandardValues.Get(i + '-transaction_id'));
        }

        String query = 'SELECT ' + C62Utilities.GetFields(club62__Payment__c.class.GetName());
        query += ' FROM club62__Payment__c';
        query += ' WHERE club62__Payment_Gateway__r.Name = \'EVO\'';
        query += ' AND club62__Transaction_Id__c in :tempIDs';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(club62__Payment__c ind : (List<club62__Payment__c>)scope){
            ind.club62__Batch_ID__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-batch_id');
            ind.club62__Batch_Card_Hash__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-cc_hash');
            ind.club62__Batch_CSC_Response__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-csc_response');
            ind.club62__Batch_CC_Bin__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-cc_bin');
            ind.club62__Batch_Action_Type__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-action_type');

            string dte = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-date');

            string year = dte.substring(0,4);
            string month = dte.substring(4,6);
            string day = dte.substring(6,8);
            string hour = dte.substring(8,10);
            string minute = dte.substring(10,12);
            string second = dte.substring(12,14);
            string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;

            ind.club62__Batch_Date__c = datetime.valueOf(stringDate);
            ind.club62__Batch_IP_Address__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-ip_address');
            ind.club62__Batch_Condition__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-condition');
        }

        update scope;
    }
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select ' + C62Utilities.GetFields(club62__Payment__c.class.GetName()) +' from club62__Payment__c where club62__Payment_Gateway__r.Name = \'EVO\' and  club62__Batch_Date__c = null and club62__Transaction_Id__c!=null';
        /*if(transId!=null){
            query+=' and club62__Transaction_Id__c=:transId';
        }*/
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
       Map<String, String> TransactionRecords = new Map<String, String>();
        List<club62__Payment__c> payList = (List<club62__Payment__c>)scope;

        Map<String, String> inputs = new Map<String, String>();
        String transIds = '';
        for(club62__Payment__c p : payList){
            if(p.club62__Transaction_Id__c!=null){
                if(transIds!=''){
                	transIds+=',';
                }
                transIds += p.club62__Transaction_Id__c;
            }
        }

        inputs.put('transaction_id', transIds);

        C62PaymentGatewayEVO x = new C62PaymentGatewayEVO();
        x.QueryTransactions = true;
        C62PaymentGatewayClasses.QueryRecordResponse calloutResponse = x.QueryPaymentRecord(inputs);

        integer cnt = Integer.ValueOf(calloutResponse.NonStandardValues.Get('TransactionCount'));

        if(cnt != 0){
            for(integer i = 0; i < cnt; i++){
                TransactionRecords.Put(calloutResponse.NonStandardValues.Get(i + '-transaction_id'), i + '');
            }
            Set<String> rejectedStatuses = new Set<String>{'failed','canceled','unknown'};
            Set<String> approvedStatuses = new Set<String>{'complete'};
            for(club62__Payment__c ind : payList){
                if(TransactionRecords.containsKey(ind.club62__Transaction_Id__c)){
                    String payStatus = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-condition');
                    if(payStatus!=null && (rejectedStatuses.contains(payStatus) || approvedStatuses.contains(payStatus))){
                        ind.club62__Batch_ID__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-batch_id');
                        ind.club62__Batch_Card_Hash__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-cc_hash');
                        ind.club62__Batch_CSC_Response__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-csc_response');
                        ind.club62__Batch_CC_Bin__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-cc_bin');
                        ind.club62__Batch_Action_Type__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-action_type');

                        string dte = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-date');

                        string year = dte.substring(0,4);
                        string month = dte.substring(4,6);
                        string day = dte.substring(6,8);
                        string hour = dte.substring(8,10);
                        string minute = dte.substring(10,12);
                        string second = dte.substring(12,14);
                        string stringDate = year + '-' + month + '-' + day + ' ' + hour + ':' + minute + ':' + second;

                        ind.club62__Batch_Date__c = datetime.valueOf(stringDate);
                        ind.club62__Batch_IP_Address__c = calloutResponse.NonStandardValues.Get(TransactionRecords.Get(ind.club62__Transaction_Id__c) + '-ip_address');
                        ind.club62__Batch_Condition__c = payStatus;

                        /*if(approvedStatuses.contains(payStatus)){
                            ind.club62__Status__c = 'Paid';
                        }else if(rejectedStatuses.contains(payStatus)){
                            ind.club62__Status__c = 'Rejected';
                        }*/
                    }
                }
            }
            update scope;
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}