@isTest
public with sharing class C62TxnFinancialUtilities {

    public static FinancialUtilityWrapper calculateFinancialAccount(List<SObject> sobjToMap, String objType){
        return calculateFinancialAccount(sobjToMap,objType,false);
    }
    public static FinancialUtilityWrapper calculateFinancialAccount(List<SObject> sobjToMap, String objType, Boolean isBatch){
        return calculateFinancialAccount(sobjToMap,objType,false, Datetime.now(),Datetime.now());
    }
    public static FinancialUtilityWrapper calculateFinancialAccount(List<SObject> sobjToMap, String objType, Boolean isBatch, Datetime startDate, Datetime endDate){
        if(endDate==null){
            endDate = Datetime.now();
        }
        String currentBatchRun='';
        if(currentBatchRun!='Transaction'){
            currentBatchRun = objType;
        }
        //Get all Financial Accounts
        List<club62__Financial_Account__c> faList = database.query('SELECT '+C62Utilities.getFields('club62__Financial_Account__c')+' from club62__Financial_Account__c ORDER BY club62__Account_Number__c ASC');
        Map<Id,club62__Financial_Account__c> faMap = new Map<Id,club62__Financial_Account__c>(faList);
        Map<String,List<sObjectWrapper>> faTosObj = new Map<String,List<sObjectWrapper>>();
        Map<Schema.SObjectType,String> objToString = new Map<Schema.SObjectType,String>();
        Map<String,Set<String>> objFieldMap = new Map<String,Set<String>>();
        objFieldMap.put('club62__Transaction__c',Schema.SObjectType.club62__Txn__c.fields.getMap().keySet());
        objFieldMap.put('club62__Redemption__c',Schema.SObjectType.club62__Redemption__c.fields.getMap().keySet());
        objFieldMap.put('club62__Folio__c',Schema.SObjectType.club62__Folio__c.fields.getMap().keySet());

        objToString.put(club62__Txn__c.getsObjectType(),'club62__transaction__c');
        objToString.put(club62__Redemption__c.getsObjectType(),'club62__redemption__c');
        objToString.put(club62__Folio__c.getsObjectType(),'club62__folio__c');

        //Get all Financial Account Mappings for current Scope
        List<club62__Financial_Account_Mapping__c> famLst = [Select Id,club62__Category__c,club62__Location__c,club62__Amount_Type__c,club62__Financial_Account_Debit_Credit__c,club62__Child_Object_Record_Type__c,club62__Contra__c,club62__Current_Future__c,club62__Paid_Unpaid__c,club62__House_Financial_Account__c,club62__Payment_Financial_Account__c,club62__Payment_Type__c,club62__Payment_SubType__c,club62__Financial_Account__c, club62__Child_Object__c,club62__Child_Type__c,club62__Child_SubType__c,club62__Parent_Object__c,club62__Parent_Type__c,club62__Parent_SubType__c,Name from club62__Financial_Account_Mapping__c where (club62__Financial_Account__c in :faList or club62__House_Financial_Account__c in:faList) and club62__House_Financial_Account__c=null order by club62__Rank__c ASC NULLS LAST];
        List<club62__Financial_Account_Mapping__c> famLstLAM = [Select Id,club62__Category__c,club62__Location__c,club62__Financial_Account_Debit_Credit__c,club62__Contra__c,club62__Current_Future__c,club62__Paid_Unpaid__c,club62__House_Financial_Account__c,club62__Child_Type__c,club62__Child_Object__c From club62__Financial_Account_Mapping__c where club62__House_Financial_Account__c!=null order by club62__Rank__c ASC NULLS LAST];
        Map<String,List<club62__Financial_Account_Mapping__c>> famObjMap = new Map<String,List<club62__Financial_Account_Mapping__c>>();


        for(club62__Financial_Account_Mapping__c fam : famLst){
            if(!famObjMap.containsKey((fam.club62__Child_Object__c).tolowercase()))
                famObjMap.put((fam.club62__Child_Object__c).toLowerCase(),new List<club62__Financial_Account_Mapping__c>());
            famObjMap.get((fam.club62__Child_Object__c).tolowercase()).add(fam);
        }

        Map<String,RecordType> transactionRTs = new Map<String,RecordType>();
        if(currentBatchRun==null || currentBatchRun==''){
            for (String rtName : Schema.SObjectType.club62__Transaction__c.getRecordTypeInfosByName().keySet()){
                String thisRTId = Schema.SObjectType.club62__Transaction__c.getRecordTypeInfosByName().get(rtName ).getRecordTypeId();
                RecordType thisRT = new RecordType(Name = rtName, Id = thisRTId);
                transactionRTs.put(rtName, thisRT);
            }
        }
        Set<Id> miSet = new Set<Id>();

        Set<Id> folioIdSet = new Set<Id>();
        Set<Id> payids = new Set<Id>();
        for(sObject obj : sobjToMap){
            if(objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('club62__folio__c') || objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('folio__c')){
                folioIdSet.add((Id)obj.get('club62__Folio__c'));
            }
            if(currentBatchRun == 'Transaction'){
                String rtName = ((club62__Txn__c)obj).RecordType.Name;
                if(rtName == 'Refund'){
                    if(((club62__Txn__c)obj).club62__Payment__c!=null){
                        payids.add(((club62__Txn__c)obj).club62__Payment__c);
                    }
                }
            }
        }
        Map<Id,club62__Folio__c> folioMap = new Map<Id,club62__Folio__c>([Select id,club62__Type__c,club62__Room_Reservation__c,club62__Reservation__c from club62__Folio__c where id in:folioIdSet]);
        Set<Id> checkDepositRefundIds = new Set<Id>();


        Map<Id,club62__Txn__c> payMap = new Map<Id,club62__Txn__c>([Select id,club62__Financial_Journal_Line__r.club62__Financial_Account__c,club62__House_Financial_Journal_Line__r.club62__Financial_Account__c,club62__DateTime__c,club62__Bank_Deposit__c,club62__Bank_Deposit__r.Name,club62__Folio__r.club62__Reservation__c,club62__Folio__r.club62__Room_Reservation__c,club62__Date__c,club62__Location__c,RecordTypeId,club62__Amount__c,club62__Type__c,club62__SubType__c,club62__Member__r.club62__Type__c,club62__Member__r.club62__SubType__c,club62__Member__c,club62__Folio__c,club62__Folio__r.club62__Type__c from club62__Txn__c where Id in :payIds]);
        //Relate each object to a Financial Account based on the Financial Account Mapping Rules
        for(sObject obj : sobjToMap){
            Date objDate = Date.today().addDays(-1);
            Datetime tempDate;
            if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c'){
                objDate = ((DateTime)obj.get('club62__DateTime__c')).date();
                tempDate = DateTime.newInstance(objDate,endDate.time());
                if(objDate==tempDate.date() && ((DateTime)obj.get('club62__DateTime__c'))<=tempDate){
                    objDate = objDate.addDays(-1);
                }
            }else if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__redemption__c'){
                objDate =((DateTime)obj.get('club62__Redemption_Date__c')).date();
                tempDate = DateTime.newInstance(objDate,endDate.time());
                if(objDate==tempdate.date() && ((DateTime)obj.get('club62__Redemption_Date__c'))<=tempdate){
                    objDate = objDate.addDays(-1);
                }
            }
            sObject refObj;
            Boolean isRefund = false;
            if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c'){
                String rtName = ((club62__Txn__c)obj).RecordType.Name;
                if(rtName == 'Refund' && ((club62__Refund__c)obj).club62__SubType__c!='Check Request'){
                    if(obj.get('club62__Payment__c')!=null && payMap.containsKey((Id)obj.get('club62__Payment__c'))){
                        club62__Txn__c pay = payMap.get((Id)obj.get('club62__Payment__c'));
                        if(pay.club62__Financial_Journal_Line__c==null || pay.club62__House_Financial_Journal_Line__c ==null){
                            refObj = obj;
                            obj = payMap.get((Id)obj.get('club62__Payment__c'));
                            isRefund = true;
                        }
                    }
                }else{
                    checkDepositRefundIds.add(obj.Id);
                }
            }
            sObject pObj;
            List<club62__Financial_Account_Mapping__c> sObjfamLst = new List<club62__Financial_Account_Mapping__c>();
            if(famObjMap.containsKey((objToString.get(obj.getsObjectType())).tolowercase())){
                sObjFamLst.addAll(famObjMap.get((objToString.get(obj.getsObjectType())).tolowercase()));
            }
            Integer maxRunNumber = 1;
            if(isBatch==true){
                if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c' && ((String)obj.get('club62__Category__c'))=='Dining'){
                    maxRunNumber = 4;
                }else if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c' && ((String)obj.get('club62__Category__c'))=='Room'){
                    maxRunNumber = 5;
                }else{
                    if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c' && ((Decimal)obj.get('club62__Sales_Tax__c'))!=0){
                        maxRunNumber = 2;
                    }
                    if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c' && ((Decimal)obj.get('club62__Gratuity_Amount__c'))!=0){
                        maxRunNumber = 3;
                    }
                }
            }
            Boolean forceRun = false;
            Boolean isRevenueSplit = false;

            //If Manual Financial Account Filled in ignore mapping rules
            //if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__credit__c' && (String)obj.get('club62__Manual_Financial_Account__c')!=null && (String)obj.get('club62__Manual_Financial_Account__c')!=''){
            //    club62__Financial_Account_Mapping__c tempFam = new club62__Financial_Account_Mapping__c();
            //    tempFam.club62__Child_Object__c = 'club62__Credit__c';
            //    tempFam.club62__Financial_Account__c = (String)obj.get('club62__Manual_Financial_Account__c');
            //    if(faMap.containsKey(tempFam.club62__Financial_Account__c) && famap.get(tempFam.club62__Financial_Account__c).club62__Debit_Credit__c == 'Debit'){
            //        tempFam.club62__Contra__c = true;
            //    }
            //    sobjfamlst.clear();
            //    sobjfamlst.add(tempFam);
            //    forceRun = true;
            //}
            //Transaction Revenue Splits
            if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c' && (String)obj.get('club62__Revenue_Split_1_Account__c')!=null && (String)obj.get('club62__Revenue_Split_1_Account__c')!=''){
                club62__Financial_Account_Mapping__c tempFam = new club62__Financial_Account_Mapping__c();
                tempFam.club62__Child_Object__c = 'club62__Transaction__c';
                tempFam.club62__Financial_Account__c = (String)obj.get('club62__Revenue_Split_1_Account__c');
                if(sobjfamlst.size()>0){
                    sobjfamlst.add(0,tempFam);
                }else{
                    sobjfamlst.add(tempFam);
                }
                forceRun = true;
                isRevenueSplit = true;
            }
            //Redemption Revenue Splits
            if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__redemption__c' && (String)obj.get('club62__Revenue_Split_1_Account__c')!=null && (String)obj.get('club62__Revenue_Split_1_Account__c')!=''){
                club62__Financial_Account_Mapping__c tempFam = new club62__Financial_Account_Mapping__c();
                tempFam.club62__Child_Object__c = 'club62__Redemption__c';
                tempFam.club62__Financial_Account__c = (String)obj.get('club62__Revenue_Split_1_Account__c');
                if(sobjfamlst.size()>0){
                    sobjfamlst.add(0,tempFam);
                }else{
                    sobjfamlst.add(tempFam);
                }
                forceRun = true;
                isRevenueSplit = true;
            }

            //Match child,parent and payment if applicable
            if(sobjfamlst!=null){
                for(Integer runNumber = 1; runNumber<= maxRunNumber;runNumber++){
                    for(club62__Financial_Account_Mapping__c fam : sObjfamLst){
                        Boolean childMatch = false;
                        Boolean recordTypeMatch = false;
                        Boolean categoryMatch = true;
                        Boolean parentMatch = true;
                        Boolean paymentMatch = true;
                        Boolean paymentMatchParent = true;
                        Boolean locationMatch = true;
                        Boolean amountTypeMatch = false;
                        club62__Financial_Account_Mapping__c pfam;

                        String location;
                        if(objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('location__c')){
                            location = (String)obj.get('location__c');
                        }else if(objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('club62__location__c')){
                            location = (String)obj.get('club62__location__c');
                        }
                        if(((fam.Location__c!=null && objfieldmap.containsKey(fam.Child_Object__c)&&objFieldMap.get(fam.child_object__c).contains('location__c')))){
                            locationMatch = false;
                            if(fam.Location__c == location){
                                locationMatch = true;
                            }
                        }
                        //Check child Match
                        if(fam.club62__Child_Object_Record_Type__c!=null && fam.club62__Child_Object_Record_Type__c!=''){
                            if(fam.club62__Child_Object_Record_Type__c == obj.get('RecordTypeId')){
                                recordTypeMatch = true;
                            }
                        }else{
                            recordTypeMatch = true;
                        }
                        if(recordTypeMatch == true){
                            categoryMatch = false;
                            if(fam.club62__Category__c!=null && fam.club62__Category__c!=''){
                                if(currentBatchRun == 'Transaction' && ((String)obj.get('club62__Category__c'))==fam.club62__Category__c){
                                    categoryMatch = true;
                                }
                            }else{
                                categoryMatch = true;
                            }
                            if(fam.club62__Child_Type__c!=null&&fam.club62__Child_Type__c!=''){
                                if(obj.get('club62__Type__c')==fam.club62__Child_Type__c&&fam.club62__Child_Object_Record_Type__c!=transactionRTs.get('Payment').Id){
                                    if(fam.club62__Child_SubType__c!=null&&fam.club62__Child_SubType__c!=''){
                                        if(obj.get('club62__SubType__c')==fam.club62__Child_SubType__c){
                                            childmatch = true;
                                        }
                                    }else{
                                        childmatch = true;
                                    }
                                }else if(fam.club62__Child_Object__c=='club62__Transaction__c' && fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Payment').Id){
                                    if(obj.get('RecordTypeId')==fam.club62__Child_Type__c){
                                        if(fam.club62__Child_SubType__c!=null&&fam.club62__Child_SubType__c!=''){
                                            if(obj.get('club62__SubType__c')==fam.club62__Child_SubType__c){
                                                childmatch = true;
                                            }
                                        }else{
                                            childmatch = true;
                                        }
                                    }
                                }
                            }else{
                                childmatch = true;
                            }
                        }
                        //Check if we need parentMatch
                        if(childMatch==true){
                            //Check parent Match
                            if(fam.club62__Parent_Object__c!=''&&fam.club62__Parent_Object__c!=null){
                                parentMatch = false;
                                if(fam.club62__Parent_Object__c=='Contact' && obj.get('club62__Member__c')!=null){
                                    if(fam.club62__Parent_Type__c!=null&&fam.club62__Parent_Type__c!=''){
                                        if(obj.getSObject('club62__Member__r').get('club62__Type__c')==fam.club62__Parent_Type__c){
                                            if(fam.club62__Parent_SubType__c!=null&&fam.club62__Parent_SubType__c!=''){
                                                if(obj.getSObject('club62__Member__r').get('club62__Type__c')==fam.club62__Parent_SubType__c){
                                                    parentMatch = true;
                                                }
                                            }else{
                                                parentMatch = true;
                                            }
                                        }
                                    }else{
                                        parentMatch = true;
                                    }
                                }else if(fam.club62__Parent_Object__c=='club62__Facility__c' && obj.get('club62__Facility__c')!=null){
                                    if(fam.club62__Parent_Type__c!=null&&fam.club62__Parent_Type__c!=''){
                                        if(obj.get('club62__Facility__c')==fam.club62__Parent_Type__c){
                                            if(fam.club62__Parent_SubType__c!=null&&fam.club62__Parent_SubType__c!=''){
                                                if(obj.getSObject('club62__Customer__r').get('club62__SubType__c')==fam.club62__Parent_SubType__c){
                                                    parentMatch = true;
                                                }
                                            }else{
                                                parentMatch = true;
                                            }
                                        }
                                    }else{
                                        parentMatch = true;
                                    }
                                }
                            }
                        }

                        if((objToString.get(obj.getsObjectType())).tolowercase()=='club62__transaction__c' ){
                            if((String)obj.get('club62__Category__c')=='Dining' && ((runNumber==1 && fam.club62__Amount_Type__c=='Food')||(runNumber==2 && fam.club62__Amount_Type__c=='Beverage')||(runNumber==3 && fam.club62__Amount_Type__c=='Sales Tax')||(runNumber==4 && fam.club62__Amount_Type__c=='Gratuity'))){
                                amountTypeMatch = true;
                            }else if((String)obj.get('club62__Category__c')=='Room' && ((runNumber==1 && fam.club62__Amount_Type__c==null)||(runNumber==2 && fam.club62__Amount_Type__c=='Sales Tax')||(runNumber==3 && fam.club62__Amount_Type__c=='Occupancy Tax')||(runNumber==4 && fam.club62__Amount_Type__c=='Hotel Tax')||(runNumber==5 && fam.club62__Amount_Type__c=='Unit Tax'))){
                                amountTypeMatch = true;
                            }else if((Id)obj.get('RecordTypeId')==transactionRTs.get('Dues').Id){
                                if((runNumber==1 && (fam.club62__Amount_Type__c == null || fam.club62__Amount_Type__c == ''))||(runNumber==2 && fam.club62__Amount_Type__c == 'Sales Tax')){
                                    amountTypeMatch = true;
                                }
                            }else if(((String)obj.get('club62__Category__c')!='Dining' && (String)obj.get('club62__Category__c')!='Room') && ((runNumber==1 && fam.club62__Amount_Type__c==null)||(runNumber==2 && fam.club62__Amount_Type__c=='Sales Tax')||(runNumber==3 && fam.club62__Amount_Type__c =='Gratuity'))){
                                amountTypeMatch = true;
                            }
                        }else{
                            amountTypeMatch = true;
                        }

                        List<Id> tbLinestoQuery = new List<Id>();


                        //Match Found
                        if((forceRun==true && runNumber == 1)||(childMatch==true&&parentMatch==true&&categoryMatch==true&&paymentMatch==true&&paymentMatchParent==true&&locationMatch==true&&amountTypeMatch==true)){

                            sObjectWrapper objWrap = null;
                            Id houseFAMId = null;
                            //If not membercharge that was created automatically
                            String additionalDescription;
                            if(pobj==null){
                                if(fam.club62__Financial_Account__c!=null){
                                    String faId = fam.club62__Financial_Account__c;
                                    String revenueSplitfaId = '';
                                    if(refObj==null && (objFieldMap.get(fam.club62__Child_Object__c).contains('club62__bank_deposit__c') || objFieldMap.get(fam.club62__Child_Object__c).contains('bank_deposit__c')) && obj.get('club62__bank_deposit__c')!=null){
                                        if(obj.getsObject('club62__bank_deposit__r')!=null){
                                            additionalDescription = ((String)obj.getsObject('club62__bank_deposit__r').get('name'));
                                        }
                                    }
                                    if(refObj==null && (objFieldMap.get(fam.club62__Child_Object__c).contains('club62__financial_batch__c') || objFieldMap.get(fam.club62__Child_Object__c).contains('financial_batch__c')) && obj.get('club62__financial_batch__c')!=null){
                                        faId+=':'+obj.get('club62__financial_batch__c');
                                        revenueSplitfaId += ':'+obj.get('club62__financial_batch__c');
                                    }else if(refObj==null && fam.club62__Child_Object__c == 'club62__Payment__c'){
                                        faId+='!'+(String)obj.get('club62__Subtype__c');
                                        additionalDescription = (String)obj.get('club62__Subtype__c');
                                    }
                                    faId+='~'+objDate;
                                    revenueSplitfaId+='~'+objDate;
                                    if(!faTosObj.containsKey(faId)){
                                        faTosObj.put(faId,new List<sObjectWrapper>());
                                    }

                                    if(isRevenueSplit == true && runNumber == 1){

                                        if(fam.club62__Child_Object__c == 'club62__Transaction__c'){
                                            objWrap = new sObjectWrapper(null,obj,0,false,11,fam.club62__Contra__c);
                                            faTosObj.get(obj.get('club62__Revenue_Split_1_Account__c')+revenueSplitfaId).add(objWrap);
                                            if(!faTosObj.containsKey(obj.get('club62__Revenue_Split_2_Account__c')+revenueSplitfaId)){
                                                faTosObj.put(obj.get('club62__Revenue_Split_2_Account__c')+revenueSplitfaId,new List<sObjectWrapper>());
                                            }
                                            faTosObj.get(obj.get('club62__Revenue_Split_2_Account__c')+revenueSplitfaId).add(new sObjectWrapper(null,obj,9,false,12,fam.club62__Contra__c));
                                        }else if(fam.club62__Child_Object__c == 'club62__Redemption__c'){
                                            objWrap = new sObjectWrapper(null,obj,10,false,11,fam.club62__Contra__c);
                                            faTosObj.get(obj.get('club62__Revenue_Split_1_Account__c')+revenueSplitfaId).add(objWrap);
                                            if(!faTosObj.containsKey(obj.get('club62__Revenue_Split_2_Account__c')+revenueSplitfaId)){
                                                faTosObj.put(obj.get('club62__Revenue_Split_2_Account__c')+revenueSplitfaId,new List<sObjectWrapper>());
                                            }
                                            faTosObj.get(obj.get('club62__Revenue_Split_2_Account__c')+revenueSplitfaId).add(new sObjectWrapper(null,obj,11,false,12,fam.club62__Contra__c));
                                            if(!faTosObj.containsKey(obj.get('club62__Prepaid_Account__c')+revenueSplitfaId)){
                                                faTosObj.put(obj.get('club62__Prepaid_Account__c')+revenueSplitfaId,new List<sObjectWrapper>());
                                            }
                                            faTosObj.get(obj.get('club62__Prepaid_Account__c')+revenueSplitfaId).add(new sObjectWrapper(null,obj,12,true,0,fam.club62__Contra__c));
                                        }
                                    }else if(isRefund == true){
                                        faTosObj.get(faId).add(new sObjectWrapper(null,refObj,0,true,fam.club62__Contra__c));
                                    }else if((fam.club62__Amount_Type__c==null || fam.club62__Amount_Type__c=='')){
                                        if(fam.club62__Child_Object__c == 'club62__Credit__c' || fam.club62__Child_Object__c == 'club62__Dues_Split__c'){
                                            system.debug(System.loggingLevel.error,fam);
                                            objWrap = new sObjectWrapper(fam,obj,0,true,fam.club62__Contra__c);
                                        }else{
                                            objWrap = new sObjectWrapper(fam,obj,0,false,fam.club62__Contra__c);
                                            if(additionalDescription!=null){
                                                objWrap.additionalDescription = additionalDescription;
                                            }
                                        }
                                        faTosObj.get(faId).add(objWrap);
                                    }else if(fam.club62__Amount_Type__c=='Food'){
                                        objWrap = new sObjectWrapper(fam,obj,0,false,3,fam.club62__Contra__c);
                                        faTosObj.get(faId).add(objWrap);
                                    }else if(fam.club62__Amount_Type__c=='Beverage'){
                                        objWrap = new sObjectWrapper(fam,obj,3,false,4,fam.club62__Contra__c);
                                        faTosObj.get(faId).add(objWrap);
                                    }else if(fam.club62__Amount_Type__c == 'Sales Tax'){
                                        if(fam.club62__Child_Object__c == 'club62__Dues_Split__c'){
                                            objWrap = new sObjectWrapper(fam,obj,4,true,5,fam.club62__Contra__c);
                                        }else{
                                            objWrap = new sObjectWrapper(fam,obj,4,false,5,fam.club62__Contra__c);
                                        }
                                        faTosObj.get(faId).add(objWrap);
                                    }else if(fam.club62__Amount_Type__c=='Gratuity'){
                                        objWrap = new sObjectWrapper(fam,obj,5,false,6,fam.club62__Contra__c);
                                        faTosObj.get(faId).add(objWrap);
                                    }else if(fam.club62__Amount_Type__c=='Occupancy Tax'){
                                        objWrap = new sObjectWrapper(fam,obj,6,false,7,fam.club62__Contra__c);
                                        faTosObj.get(faId).add(objWrap);
                                    }else if(fam.club62__Amount_Type__c=='Hotel Tax'){
                                        objWrap = new sObjectWrapper(fam,obj,7,false,8,fam.club62__Contra__c);
                                        faTosObj.get(faId).add(objWrap);
                                    }else if(fam.club62__Amount_Type__c=='Unit Tax'){
                                        objWrap = new sObjectWrapper(fam,obj,8,false,9,fam.club62__Contra__c);
                                        faTosObj.get(faId).add(objWrap);
                                    }
                                }else if(fam.club62__Payment_Financial_Account__c!=null && fam.club62__Child_Object__c=='club62__Credit__c'){
                                    String faId = fam.club62__Payment_Financial_Account__c;
                                    if((objFieldMap.get(fam.club62__Child_Object__c).contains('club62__financial_batch__c') || objFieldMap.get(fam.club62__Child_Object__c).contains('financial_batch__c')) && obj.get('club62__financial_batch__c')!=null){
                                        faId+=':'+obj.get('club62__financial_batch__c');
                                    }
                                    faId+='~'+objDate;
                                    if(!faTosObj.containsKey(faId)){
                                        faTosObj.put(faId,new List<sObjectWrapper>());
                                    }
                                    objWrap = new sObjectWrapper(fam,obj,0,false,fam.club62__Contra__c);
                                    faTosObj.get(faId).add(objWrap);

                                }
                            }
                            Boolean doSearch = false;
                            if(isBatch==true){
                                doSearch = true;
                            }
                            if(doSearch && fam.club62__House_Financial_Account__c!=null){
                                doSearch = false;
                                String faId = fam.club62__House_Financial_Account__c;
                                if((objFieldMap.get(fam.club62__Child_Object__c).contains('club62__financial_batch__c') || objFieldMap.get(fam.club62__Child_Object__c).contains('club62__financial_batch__c')) && obj.get('club62__financial_batch__c')!=null){
                                    faId+=':'+obj.get('club62__financial_batch__c');
                                }
                                faId+='~'+objDate;
                                if(!faTosObj.containsKey(faId)){
                                    faTosObj.put(faId,new List<sObjectWrapper>());
                                }
                                objWrap = new sObjectWrapper(fam,obj,1,false,fam.club62__Contra__c);
                                faTosObj.get(faId).add(objWrap);
                            }
                            if(fam.club62__Financial_Account__c!=null && (currentBatchRun == '' || currentBatchRun == null || currentBatchRun == 'Payment' || currentBatchRun == 'Dues' || currentBatchRun == 'Refund' || currentBatchRun == 'InvoiceLinePayment')){
                                obj.put('club62__Financial_Account__c',fam.club62__Financial_Account__c);
                            }

                            if(doSearch==true &&(runNumber==1) && (fam.club62__Child_Object__c != 'club62__Transaction__c' || ((fam.club62__Child_Object__c == 'club62__Transaction__c' && fam.club62__Child_Object_Record_Type__c != transactionRTs.get('Refund').Id) || (fam.club62__Child_Object__c == 'club62__Transaction__c' && fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Refund').Id && fam.Child_SubType__c == 'Check Request')))){
                                club62__Financial_Account_Mapping__c cFAM = null;
                                club62__Financial_Account_Mapping__c lFAM = null;
                                club62__Financial_Account_Mapping__c cFAMMem = null;
                                club62__Financial_Account_Mapping__c promoFAM = null;
                                for(club62__Financial_Account_Mapping__c famLAM : famLstLAM){
                                    if(famLAM.club62__Child_Object__c==fam.club62__Child_Object__c){
                                        promoFAM = famLAM;
                                    }
                                    Boolean skipFolio = false;
                                    if(refObj==null && famLAM.club62__Child_Object__c==fam.club62__Child_Object__c && famLAM.club62__Child_Object__c=='club62__Transaction__c' && famLAM.club62__Child_Object_Record_Type__c==transactionRTs.get('Deposit').Id && obj.getSObject('RecordType').get('Name')=='Deposit'){
                                        club62__Txn__c pay = (club62__Txn__c)obj;
                                        if(pay.club62__Reservation__c!= null && pay.club62__Reservation__r.RecordType.Name == 'Sponsored Event'){
                                            skipFolio = true;
                                        }
                                    }
                                    if(famLAM.club62__Child_Object__c==fam.club62__Child_Object__c && (skipFolio || (!(objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('club62__folio__c')) ||  (!(objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('club62__folio__c') && (obj.get('club62__Folio__c')==null || obj.get('club62__Folio__c')!='')))))){
                                        String locationLedg;
                                        if(objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('location__c')){
                                            locationLedg = (String)obj.get('location__c');
                                        }else if(objFieldMap.get(convCase(objToString.get(obj.getsObjectType()))).contains('club62__location__c')){
                                            locationLedg = (String)obj.get('club62__location__c');
                                        }
                                        if(famLAM.Location__c==null||(famLAM.Location__c!=null && locationLedg!=null && locationLedg!='' && famLam.Location__c==locationLedg)){
                                            if(fam.club62__Child_Object__c=='club62__Dues_Split__c'){
                                                if(famlam.club62__Paid_Unpaid__c!=null && famlam.club62__Paid_Unpaid__c!=''){
                                                    Decimal aremain = ((Decimal)obj.get('club62__Amount_Paid__c'));
                                                    if(aremain==null){
                                                        aremain=0;
                                                    }
                                                    String paid = 'Paid';
                                                    if((((Decimal)obj.get('club62__Amount__c'))-aremain)>0){
                                                        paid = 'Unpaid';
                                                    }
                                                    if(paid==famlam.club62__Paid_Unpaid__c && paid=='Unpaid'){
                                                        cFAM=famLAM;
                                                    }else if(paid==famLam.club62__Paid_Unpaid__c && paid=='Paid'){
                                                        lFAM = famLAM;
                                                    }

                                                }else{
                                                    cFAM=famLAM;
                                                }
                                            }
                                            else if(refObj==null && famLAM != null && famLAM.club62__Child_Object__c=='club62__Transaction__c' && famLAM.club62__Child_Object_Record_Type__c==transactionRTs.get('Deposit').Id && obj.getSObject('RecordType').get('Name')=='Deposit' && obj.get('club62__Reservation__c')!= null && obj.getSObject('club62__Reservation__r').getSObject('RecordType').get('Name') == 'Sponsored Event'){
                                                cFAM = famLAM;
                                                break;
                                            }
                                            else if(famLAM.club62__Child_Type__c=='club62__Customer__c' && objFieldMap.get(fam.club62__Child_Object__c).contains('club62__customer__c')){
                                                if(obj.get('club62__customer__c')!=null){
                                                    cFAMMem = famLAM;
                                                }
                                            }
                                            else if(famLAM.club62__Child_Type__c=='club62__Customer__c' && objFieldMap.get(fam.club62__Child_Object__c).contains('club62__member__c')){
                                                if(obj.get('club62__member__c')!=null){
                                                    cFAMMem = famLAM;
                                                }
                                            }
                                            else if(famLAM.club62__Child_Type__c=='club62__Person__c' && objFieldMap.get(fam.club62__Child_Object__c).contains('club62__person__c')){
                                                if(obj.get('club62__person__c')!=null){
                                                    cFAM = famLAM;
                                                }
                                            }else if(famLAM.club62__Child_Type__c=='club62__Person__c' && objFieldMap.get(fam.club62__Child_Object__c).contains('club62__guest__c')){
                                                if(obj.get('club62__guest__c')!=null){
                                                    cFAM = famLAM;
                                                }
                                            }else if(famLAM.club62__Child_Type__c=='' || famLAM.club62__Child_Type__c==null){
                                                cFAM = famLAM;
                                            }
                                            else if(objFieldMap.get(fam.club62__Child_Object__c).contains(famLAM.club62__Child_Type__c.tolowercase())){
                                                if(obj.get(famLAM.club62__Child_Type__c.tolowercase())!=null){
                                                   cFAM = famLAM;
                                                   //break;
                                                }
                                            }
                                        }
                                    }else if(famLAM.club62__Child_Object__c=='club62__Folio__c'){
                                        if(objFieldMap.get(fam.club62__Child_Object__c).contains('club62__folio__c') || objFieldMap.get(fam.club62__Child_Object__c).contains('folio__c')){
                                            if(obj.get('club62__Folio__c')!=null){
                                                System.debug(folioMap);
                                                if((famLam.club62__Child_Type__c=='' || famLam.club62__Child_Type__c==null || folioMap.get((Id)obj.get('club62__Folio__c')).club62__Type__c==famLAM.club62__Child_Type__c)&& folioMap.get((Id)obj.get('club62__Folio__c')).club62__Room_Reservation__c!=null){
                                                    cFAM = famLAM;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                    if(famLAM.club62__Child_Object__c==fam.club62__Child_Object__c){
                                        if(cFAM==null){
                                            cFAM = famLAM;
                                        }
                                    }
                                }
                                if(cFAM==null && cFAMMem!=null){
                                    cFAM = cFAMMem;
                                }

                                if(cFAM!=null){
                                    houseFAMId = cFAM.club62__House_Financial_Account__c;
                                    Boolean generate = true;
                                    if(generate==true/* && pObj==null*/){
                                        String faId = cFAM.club62__House_Financial_Account__c;
                                        if(refObj==null && (objFieldMap.get(cfam.club62__Child_Object__c).contains('club62__financial_batch__c') || objFieldMap.get(cfam.club62__Child_Object__c).contains('financial_batch__c')) && obj.get('club62__financial_batch__c')!=null){
                                            faId+=':'+obj.get('club62__financial_batch__c');
                                        }
                                        faId+='~'+objDate;
                                        if(!faTosObj.containsKey(faId)){
                                            faTosObj.put(faId,new List<sObjectWrapper>());
                                        }
                                        if(promoFAM != null){
                                            if(promoFAM.club62__Child_Object__c=='club62__Transaction__c'){
                                                if((Decimal)obj.get('club62__Amount_Discounted__c')!=null && (Decimal)obj.get('club62__Amount_Discounted__c')!=0 ){
                                                    if(fam.club62__Financial_Account_Debit_Credit__c==promoFAM.club62__Financial_Account_Debit_Credit__c){
                                                        faTosObj.get(faId).add(new sObjectWrapper(promoFAM,obj,13,!objWrap.negAmount,10,cFAM.club62__contra__c));
                                                    }else{
                                                        faTosObj.get(faId).add(new sObjectWrapper(promoFAM,obj,13,objWrap.negAmount,13,cFAM.club62__contra__c));
                                                    }
                                                }
                                            }
                                        }
                                        if(refObj==null && fam.club62__Child_Object__c=='club62__Transaction__c' && (fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Payment').Id||fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Deposit').Id)){
                                            sObjectWrapper payWrap = new sObjectWrapper(cFAM,obj,1,true,cFAM.club62__contra__c);
                                            if(additionalDescription!=null){
                                                payWrap.additionalDescription = additionalDescription;
                                            }
                                            faTosObj.get(faId).add(payWrap);
                                        }else if(refObj!=null && isRefund==true){
                                            Boolean isContra = false;
                                                if((fam.club62__contra__c == true && cfam.club62__contra__c == false) || (fam.club62__Contra__c == false && cfam.club62__Contra__c == true)){
                                                    isContra = true;
                                                }
                                            faTosObj.get(faId).add(new sObjectWrapper(cFAM,refObj,1,false,isContra));
                                        }else if(cFAM.club62__Child_Object__c=='club62__Transaction__c' && cFam.club62__Child_Object_Record_Type__c == transactionRTs.get('Dues').Id){
                                            faTosObj.get(faId).add(new sObjectWrapper(cFAM,obj,1,false,10,cFAM.club62__contra__c));
                                        }else{
                                            if(objWrap!=null){
                                                Boolean isContra = false;
                                                if((fam.club62__contra__c == true && cfam.club62__contra__c == false) || (fam.club62__Contra__c == false && cfam.club62__Contra__c == true)){
                                                    isContra = true;
                                                }
                                                if(fam.club62__Financial_Account_Debit_Credit__c==cFAM.club62__Financial_Account_Debit_Credit__c){
                                                    if(fam.club62__Child_Object__c == 'club62__Transaction__c' && (fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Charge').Id || fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Adjustment').Id || fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Dues').Id)){
                                                        faTosObj.get(faId).add(new sObjectWrapper(cFAM,obj,1,!objWrap.negAmount,10,isContra));
                                                    }else{
                                                        faTosObj.get(faId).add(new sObjectWrapper(cFAM,obj,1,!objWrap.negAmount,0,isContra));
                                                    }
                                                }else{
                                                    if(fam.club62__Child_Object__c == 'club62__Transaction__c' && (fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Charge').Id || fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Adjustment').Id || fam.club62__Child_Object_Record_Type__c == transactionRTs.get('Dues').Id)){
                                                        faTosObj.get(faId).add(new sObjectWrapper(cFAM,obj,1,objWrap.negAmount,10,isContra));
                                                    }else{
                                                        faTosObj.get(faId).add(new sObjectWrapper(cFAM,obj,1,objWrap.negAmount,0,isContra));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                if(lFAM!=null){
                                     Boolean generate = true;
                                    if(generate==true){
                                        String faId = lFAM.club62__House_Financial_Account__c;
                                        if((objFieldMap.get(lFAM.club62__Child_Object__c).contains('club62__financial_batch__c')||objFieldMap.get(lFAM.club62__Child_Object__c).contains('financial_batch__c')) && obj.get('club62__financial_batch__c')!=null){
                                            faId+=':'+obj.get('club62__financial_batch__c');
                                        }
                                        faId+='~'+objDate;
                                        if(!faTosObj.containsKey(faId)){
                                            faTosObj.put(faId,new List<sObjectWrapper>());
                                        }
                                            faTosObj.get(faId).add(new sObjectWrapper(lfam,obj,2,true,lFam.club62__Contra__c));
                                    }
                                }
                            }
                            break;
                        }
                    }
                }
            }
        }
        if(currentBatchRun=='Transaction'){
            for(club62__Txn__c mr : (List<club62__Txn__c>)sobjToMap){
                if(!checkDepositRefundIds.contains(mr.id) && mr.club62__Payment__c!=null && mr.RecordTypeId == transactionRTs.get('Refund').Id){
                    if(mr.club62__Payment__r.club62__Financial_Journal_Line__c!=null && mr.club62__Payment__r.club62__Financial_Journal_Line__r.club62__Financial_Account__c!=null){
                        String faId = mr.club62__Payment__r.club62__Financial_Journal_Line__r.club62__Financial_Account__c;
                        faId+='~'+mr.club62__Date__c;
                        if(!faTosObj.containsKey(faId)){
                            faTosObj.put(faId,new List<sObjectWrapper>());
                        }
                        faTosObj.get(faId).add(new sObjectWrapper(null,(sObject)mr,0,true,false));
                    }
                    if(mr.club62__Payment__r.club62__House_Financial_Journal_Line__c!=null && mr.club62__Payment__r.club62__House_Financial_Journal_Line__r.club62__Financial_Account__c!=null){
                        String faId = mr.club62__Payment__r.club62__House_Financial_Journal_Line__r.club62__Financial_Account__c;
                        faId+='~'+mr.club62__Date__c;
                        if(!faTosObj.containsKey(faId)){
                            faTosObj.put(faId,new List<sObjectWrapper>());
                        }
                        faTosObj.get(faId).add(new sObjectWrapper(null,(sObject)mr,1,false,false));
                    }
                }
            }
        }

        FinancialUtilityWrapper fuw = new FinancialUtilityWrapper();
        fuw.objList = sobjToMap;
        fuw.objWrapperMap = faToSObj;
        return fuw;
    }
    public static String convCase(String input){
        String newString ='';
        Boolean nextTitleCase = false;
        Integer i = 0;
        for(String c : input.split('')){
            if((c.isWhitespace()||c=='_')&& newString.length()>0){
                nextTitleCase = true;
            }else if(nextTitleCase==true && (input.length()-newString.length())!=1){
                c = c.toUpperCase();
                nextTitleCase = false;
            }
            newString+=c;
            i++;
        }
        return newString;
    }
    public class FinancialUtilityWrapper{
        public List<sObject> objList{get;set;}
        public Map<String,List<sObjectWrapper>>objWrapperMap{get;set;}
    }
    public class sObjectWrapper{
        public club62__Financial_Account_Mapping__c fam{get;set;}
        public sObject obj{get;set;}
        public Boolean negAmount{get;set;}
        public Integer housePayment{get;set;} //0=Reg Account,1=House Account,2=Lib Account,3=Beverage Account,4 = Tax Account,5=Gratuity_Account__c,6 = Tax 2, 7 = Tax 3, 8 = Tax 4, 9 = financial account 2, 10 = Revenue Split 1, 11 = Revenue Split 2, 12 = PrePaid, 13 = Promotion Account
        public Integer amountToUse{get;set;} //0=club62__Amount__c;1=club62__Current_Amount__c;2=club62__Future_Amount__c;3=club62__Food_Amount__c;4=club62__Drink_Amount__c;5=club62__Sales_Tax__c;6=club62__Gratuity_Amount__c;7 = Occupancy Tax;8 = Hotel Tax;9= Unit Tax;;10 = Total Amount;11 = Revenue Split 1 Amount;12 = Revenue Split 2 Amount;13 = Amount Discounted
        public Boolean contra{get;set;}
        public String additionalDescription{get;set;}
        public sObjectWrapper(club62__Financial_Account_Mapping__c f ,sObject o, Integer hp,Boolean na,Boolean ca){
            fam = f;
            obj = o;
            housePayment = hp;
            negAmount = na;
            contra = ca;
            amountToUse=0;
        }
        public sObjectWrapper(club62__Financial_Account_Mapping__c f ,SObject o,Integer hp,Boolean na,Integer atu,Boolean ca){
            this(f,o,hp,na,ca);
            amountToUse = atu;
        }
    }
}