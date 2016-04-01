/*
@Name               : C62TXNViewPayFolioController
@Author             : customersuccess@cloud62.com
@Date               : May 28, 2015
@Description        : Controller for TXNViewPayFolio page
*/
public with sharing class C62TXNViewPayFolioController{
    //class variables
    public String recID{get;set;}
    public String folId{get;set;}
    public String resType{get;set;}
    public String folioType{get;set;}
    public String folioLink{get;set;}
    public Map<Id, FolioWrapper> foliosMap{get;set;}
    public String selectedFolioId{get;set;}
    public FolioWrapper selectedFolio{get;set;}
    public String rrName{get;set;}
    public club62__Room_Reservation__c rRes{get;set;}
    public club62__TXN__c pay{get;set;}
    public String selectedPayMethod{get;set;}
    public Set<String> folioIds{get;set;}
    public Boolean paymentSucceeded{get;set;}
    public String payDisc;
    public String cObjId{get;set;}
    public String cObjLabel{get;set;}
    public String cObjCat{get;set;}
    public String selectedPaymentType{get;set;}
    public String earlyCheckOutDis{get;set;}
    public club62__TXN__c earlyCheckOutTran{get;set;}
    public club62__C62Taxes__c cTaxes{get;set;}
    public String anotherMemGuestID{get;set;}
    public String anotherMemGuestName{get;set;}
    public String anotherMemGuestCate{get;set;}
    
    /*
    @Name   :C62TXNViewPayFolioController
    @Description :Constructor to initalize the page
    */
    public C62TXNViewPayFolioController(ApexPages.StandardController stdController) {
        folID = Apexpages.currentPage().getParameters().get('id');
        String resID = Apexpages.currentPage().getParameters().get('rid');
        String rrID = Apexpages.currentPage().getParameters().get('rrid');
        payDisc = Apexpages.currentPage().getParameters().get('payDis');
        earlyCheckOutDis = Apexpages.currentPage().getParameters().get('earlyCheckOutDis');
        anotherMemGuestID = '';
        anotherMemGuestName = '';
        anotherMemGuestCate = '';
        cTaxes = club62__C62Taxes__c.getOrgDefaults();
        selectedPaymentType = 'Credit Card/ACH';
        if((resID == null || resID == '')&& (rrId == null || rrId == '') && (folId == null || folId == '')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invaild Reservation or Folio Id.'));
        }else{
            if(resId != null && resId != ''){
                resType = 'evtRes';
                recId = resId;
            }else if(rrId != null && rrId != ''){
                resType = 'rrRes';
                recId = rrId;
            }
            foliosMap = new Map<Id, FolioWrapper>();
            folioIds = new Set<String>();
            if(resType=='rrRes'){
                List<club62__Room_Reservation__c> rResList = [SELECT Id,Name,club62__From__c,club62__To__c,club62__Person__c,club62__Group_Block_Sponsoring_Customer__c,club62__Who_is_Paying__c,club62__Sponsoring_Customer__c,club62__Room__c,
                        club62__Reservation__r.club62__Sponsoring_Customer__c,club62__Customer__c,RecordType.Name, (Select Id,club62__Folio__c,
                        club62__Type__c,club62__Total_Amount__c From club62__Transactions1__r WHERE club62__Reservation_Registration__c=NULL AND club62__Type__c!='Promotion'),club62__Payment_Method__r.Name, club62__Payment_Method__r.Payment_Type__c,
                        club62__Payment_Method__r.club62__Card_Number__c, club62__Payment_Method__r.club62__Card_Type__c,
                        club62__Payment_Method__c,club62__Payment_Method__r.club62__Customer__c,club62__Payment_Method__r.club62__Person__c 
                        FROM club62__Room_Reservation__c
                        WHERE id=:recID limit 1];
                if(rResList.size()>0){
                    rRes = rResList.get(0);
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invaild Reservation or Folio Id.'));
                    rrName = null;
                    resType = null;
                    recId = null;
                    foliosMap = null;
                    folioIds = null;
                    return;
                }
                rrName = rRes.Name;
                for(club62__TXN__c trns : rRes.club62__Transactions1__r){
                    folioIds.add(trns.club62__Folio__c);
                }
                
                if(earlyCheckOutDis!=null && earlyCheckOutDis!=''){
                    earlyCheckOutTran = new club62__TXN__c(club62__Amount__c=club62__C62Room_Reservation__c.getOrgDefaults().club62__Early_Checkout_Fee__c.setScale(2, System.RoundingMode.HALF_UP),
                            club62__Type__c='Room',club62__SubType__c='Early Departure Fee',club62__Description__c='Early Departure Fee',club62__Room_Reservation__c=rRes.Id,
                            club62__Date__c=Date.Today(),RecordTypeID=Schema.SObjectType.club62__TXN__c.getRecordTypeInfosByName().get('Charge').getRecordTypeId());
                    if(earlyCheckOutTran.club62__Amount__c==null || earlyCheckOutTran.club62__Amount__c<=0){
                        earlyCheckOutTran.club62__Overridden_Sales_Tax__c = 0;
                        earlyCheckOutTran.club62__Overridden_Occupancy_Tax__c = 0;
                        earlyCheckOutTran.club62__Overridden_Hotel_Tax__c = 0;
                        earlyCheckOutTran.club62__Overridden_Unit_Tax__c = 0;
                    }
                    if(rRes.club62__Who_is_Paying__c == 'Guest'){ earlyCheckOutTran.club62__Guest__c =rRes.club62__Person__c; }
                    if(rRes.club62__Group_Block_Sponsoring_Customer__c!=null){
                        earlyCheckOutTran.club62__Member__c=rRes.club62__Group_Block_Sponsoring_Customer__c;
                    }else if(rRes.club62__Reservation__c!=null && rRes.club62__Reservation__r.club62__Sponsoring_Customer__c!=null){
                        earlyCheckOutTran.club62__Member__c=rRes.club62__Reservation__r.club62__Sponsoring_Customer__c;
                    }else{
                        earlyCheckOutTran.club62__Member__c=rRes.club62__Customer__c;
                    }
                }
            } else if(resType=='evtRes') {
                List<club62__Reservation__c> eventList = [Select Name from club62__Reservation__c where id=:recID limit 1];
                if(eventList.size()>0){
                    rrName = eventList.get(0).Name;
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invaild Reservation or Folio Id.'));
                    rrName = null;
                    resType = null;
                    recId = null;
                    foliosMap = null;
                    folioIds = null;
                    return;
                }
            } else if(folId!=null && folId!=''){
                List<club62__Folio__c> folioList = [Select Name,club62__Room_Reservation__c,club62__Title__c,club62__Reservation__c,club62__Room_Reservation__r.Name,
                                club62__Reservation__r.Name,club62__Room_Reservation__r.club62__Reservation__c,
                                club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c,
                                club62__Room_Reservation__r.club62__Group_Block_Sponsoring_Customer__c,
                                club62__Room_Reservation__r.club62__Who_Is_Paying__c from club62__Folio__c where id=:folId];
                if(folioList.size()>0){
                    club62__Folio__c fol = folioList.get(0);
                    rrName = fol.Name;
                    if(fol.club62__Room_Reservation__c!=null){
                        recId = fol.club62__Room_Reservation__c;
                        folioType = 'Room Reservation';
                        folioLink = fol.club62__Room_Reservation__r.Name;
                    }
                    else if(fol.club62__Reservation__c!=null){
                        recId = fol.club62__Reservation__c;
                        folioType = 'Event Reservation';
                        folioLink = fol.club62__Reservation__r.Name;
                    }
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invaild Reservation or Folio Id.'));
                    rrName = null;
                    resType = null;
                    recId = null;
                    foliosMap = null;
                    folioIds = null;
                    return;
                }
            }
            loadFoliosMap();
            createNewPayment();
            if(earlyCheckOutDis!=null && earlyCheckOutDis!='' && earlyCheckOutTran!=null && earlyCheckOutTran.club62__Amount__c!=null && selectedFolio!=null 
                && selectedFolio.balance!=null && selectedFolio.fol.Id==earlyCheckOutTran.club62__Folio__c){
                payAllFolioBalance();
            }
        }
    }
    //To Prepare the Folio Map
    public void loadFoliosMap(){
        foliosMap.clear();
        Map<Id,club62__Folio__c> foliosMapTemp;
        if(resType=='rrRes'){
            foliosMapTemp = new Map<Id,club62__Folio__c>([Select id,club62__Type__c,Name, club62__Customer__c, club62__Customer__r.Name, club62__Customer__r.club62__Customer_Id__c,
                            club62__Guest__c, club62__Guest__r.Name,club62__Room_Reservation__r.club62__Reservation__c,club62__Room_Reservation__r.club62__Who_Is_Paying__c,
                            club62__Room_Reservation__r.Name,club62__Room_Reservation__r.club62__Group_Block_Sponsoring_Customer__c,
                            club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c,club62__Title__c,club62__Room_Reservation__c,club62__Reservation__c,
                            club62__Reservation__r.RecordType.Name,club62__Statement_Description__c,(SELECT ID,RecordType.Name,RecordTypeID,Name,club62__Room_Reservation__c,
                            club62__Room_Reservation__r.Name,club62__Room_Reservation__r.club62__Customer__c,club62__Room_Reservation__r.club62__Customer__r.Name,
                            club62__Room_Reservation__r.club62__Person__c,club62__Room_Reservation__r.club62__Person__r.Name,club62__Total_Amount__c,club62__Amount__c,club62__Date__c,
                            club62__Description__c,club62__Status__c,club62__Type__c,club62__Overridden_Hotel_Tax__c,club62__Overridden_Occupancy_Tax__c,club62__Overridden_Sales_Tax__c,
                            club62__Overridden_Unit_Tax__c,club62__Hotel_Tax__c,club62__Occupancy_Tax__c,club62__Sales_Tax__c,club62__Unit_Tax__c, club62__Gratuity_Amount__c,
                            club62__SubType__c,club62__Reservation_Registration__c,club62__Related_To__c,club62__Related_To__r.RecordType.Name,club62__TXN__c.club62__Payment__c,
                            club62__TXN__c.club62__Payment__r.club62__Status__c FROM club62__Transactions1__r) 
                            From club62__Folio__c where club62__Room_Reservation__c = :recId 
                            OR Id IN :folioIds]);
        }else if(resType=='evtRes'){
            foliosMapTemp = new Map<Id,club62__Folio__c>([Select id,club62__Type__c,Name, club62__Customer__c, club62__Customer__r.Name,club62__Customer__r.club62__Customer_Id__c,
                            club62__Guest__c, club62__Guest__r.Name,club62__Room_Reservation__r.club62__Reservation__c,club62__Room_Reservation__r.club62__Who_Is_Paying__c,
                            club62__Room_Reservation__r.Name,club62__Room_Reservation__r.club62__Group_Block_Sponsoring_Customer__c,
                            club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c,club62__Title__c,club62__Room_Reservation__c,club62__Reservation__c,
                            club62__Reservation__r.RecordType.Name,club62__Statement_Description__c,(SELECT ID,RecordType.Name,RecordTypeID,Name,club62__Room_Reservation__c,
                            club62__Room_Reservation__r.Name,club62__Room_Reservation__r.club62__Customer__c,club62__Room_Reservation__r.club62__Customer__r.Name,
                            club62__Room_Reservation__r.club62__Person__c,club62__Room_Reservation__r.club62__Person__r.Name,club62__Total_Amount__c,club62__Amount__c,club62__Date__c,
                            club62__Description__c,club62__Status__c,club62__Type__c,club62__Overridden_Hotel_Tax__c,club62__Overridden_Occupancy_Tax__c,club62__Overridden_Sales_Tax__c,
                            club62__Overridden_Unit_Tax__c,club62__Hotel_Tax__c,club62__Occupancy_Tax__c,club62__Sales_Tax__c,club62__Unit_Tax__c, club62__Gratuity_Amount__c,
                            club62__SubType__c,club62__Reservation_Registration__c,club62__Related_To__c,club62__Related_To__r.RecordType.Name,club62__TXN__c.club62__Payment__c,
                            club62__TXN__c.club62__Payment__r.club62__Status__c FROM club62__Transactions1__r) From club62__Folio__c where club62__Reservation__c = :recID]);
        }else if((resType=='' || resType==null) && (folId!=null && folId!='')){
            foliosMapTemp = new Map<Id,club62__Folio__c> ([Select id,club62__Type__c,Name, club62__Customer__c, club62__Customer__r.Name, club62__Customer__r.club62__Customer_Id__c,
                            club62__Guest__c, club62__Guest__r.Name,club62__Room_Reservation__r.club62__Reservation__c,club62__Room_Reservation__r.club62__Who_Is_Paying__c,
                            club62__Room_Reservation__r.Name,club62__Room_Reservation__r.club62__Group_Block_Sponsoring_Customer__c,
                            club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c,club62__Title__c,club62__Room_Reservation__c,club62__Reservation__c,
                            club62__Reservation__r.RecordType.Name,club62__Statement_Description__c,(SELECT ID,RecordType.Name,RecordTypeID,Name,club62__Room_Reservation__c,
                            club62__Room_Reservation__r.Name,club62__Room_Reservation__r.club62__Customer__c,club62__Room_Reservation__r.club62__Customer__r.Name,
                            club62__Room_Reservation__r.club62__Person__c,club62__Room_Reservation__r.club62__Person__r.Name,club62__Total_Amount__c,club62__Amount__c,club62__Date__c,
                            club62__Description__c,club62__Status__c,club62__Type__c,club62__Overridden_Hotel_Tax__c,club62__Overridden_Occupancy_Tax__c,club62__Overridden_Sales_Tax__c,
                            club62__Overridden_Unit_Tax__c,club62__Hotel_Tax__c,club62__Occupancy_Tax__c,club62__Sales_Tax__c,club62__Unit_Tax__c, club62__Gratuity_Amount__c,
                            club62__SubType__c,club62__Reservation_Registration__c,club62__Related_To__c,club62__Related_To__r.RecordType.Name,club62__TXN__c.club62__Payment__c,
                            club62__TXN__c.club62__Payment__r.club62__Status__c FROM club62__Transactions1__r) From club62__Folio__c where Id = :folId]);
        }
        List<club62__Room_Reservation__c> tempRRLst = new List<club62__Room_Reservation__c>();
        if(earlyCheckOutDis!=null && earlyCheckOutDis!='' && earlyCheckOutTran!=null && earlyCheckOutTran.club62__Amount__c!=null){
            tempRRLst = [SELECT ID,Name,club62__Tax_Exempt__c,club62__Room__c,club62__Room__r.club62__Charge_Occupancy_Tax__c 
                        FROM club62__Room_Reservation__c WHERE ID=:earlyCheckOutTran.club62__Room_Reservation__c LIMIT 1];
        }
        String folioECOID;
        if(foliosMapTemp!=null){
            Integer i = 0;
            for(club62__Folio__c f : foliosMapTemp.values()){
                Decimal amt = 0.00;
                Decimal pay = 0.00;
                Decimal adj = 0.00;
                Decimal ref = 0.00;
                Decimal grat = 0.00;
                Decimal transfer = 0.00;
                if(i==0 && earlyCheckOutDis!=null && earlyCheckOutDis!='' && earlyCheckOutTran!=null && earlyCheckOutTran.club62__Amount__c!=null){
                    amt += earlyCheckOutTran.club62__Amount__c;
                    if(cTaxes!=null && cTaxes.club62__Sales_Tax__c!=null && tempRRLst!=null && tempRRLst.size()>0 && tempRRLst.get(0).club62__Tax_Exempt__c==false){
                        amt +=  (earlyCheckOutTran.club62__Amount__c * (cTaxes.club62__Sales_Tax__c / 100)).setScale(2, System.RoundingMode.HALF_UP);
                    }
                    earlyCheckOutTran.club62__Folio__c = f.Id;
                    folioECOID = f.Id;
                    i++;
                }
                for(club62__TXN__c t : f.club62__Transactions1__r){
                    if((t.RecordType.Name=='Adjustment' || t.RecordType.Name=='Charge') && t.club62__Reservation_Registration__c==null && t.club62__Type__c!='Promotion' 
                        && t.club62__Amount__c!=null){
                        if(t.RecordType.Name!='Adjustment' || (t.RecordType.Name=='Adjustment' && t.club62__Description__c=='Folio balance adjustment') 
                            || (t.RecordType.Name=='Adjustment' && t.club62__Related_To__c!=null && t.club62__Related_To__r.RecordType.Name!='Adjustment')){
                            if(t.club62__Type__c=='Banquet Transfer' && t.club62__Total_Amount__c<0){
                                transfer+=t.club62__Total_Amount__c;
                                if(t.club62__Gratuity_Amount__c!=null){grat += t.club62__Gratuity_Amount__c;}
                            }else{
                                amt += t.club62__Total_Amount__c;
                                if(t.RecordType.Name=='Adjustment'){adj+=t.club62__Total_Amount__c;}
                                if(t.club62__Gratuity_Amount__c!=null){grat += t.club62__Gratuity_Amount__c;}
                            }
                        }
                    }
                    if(t.RecordType.Name=='Payment' && t.club62__Amount__c!=null && (t.club62__Status__c=='Paid' || t.club62__Status__c=='Refunded' 
                        || t.club62__Status__c=='Partially Refunded')){
                        pay+= -t.club62__Total_Amount__c;
                    }
                    if(t.RecordType.Name=='Refund' && t.club62__Payment__c!=null && t.club62__Amount__c!=null && (t.club62__Payment__r.club62__Status__c=='Paid' 
                        || t.club62__Payment__r.club62__Status__c=='Refunded' || t.club62__Payment__r.club62__Status__c=='Partially Refunded')){
                        ref +=t.club62__Total_Amount__c;
                    }
                }
            }
        }
        if(foliosMap.keySet().size()==1 || (foliosMap.size()>1 && folioECOID!=null)){
            if(foliosMap.keySet().size()==1){
                selectedFolio = foliosMap.values().get(0);
                if(selectedFolio!=null && selectedFolio.fol.club62__Room_Reservation__c!=null && selectedFolio.custGuest!=null && selectedFolio.custGuest!='' 
                    && (selectedFolio.fol.club62__Guest__c!=null || selectedFolio.fol.club62__Customer__c!=null)){
                    anotherMemGuestName = selectedFolio.custGuest;
                    if(selectedFolio.fol.club62__Guest__c!=null){
                        anotherMemGuestID = selectedFolio.fol.club62__Guest__c;
                        anotherMemGuestCate = 'Guest';
                    }else if(selectedFolio.fol.club62__Customer__c!=null){
                        anotherMemGuestID = selectedFolio.fol.club62__Customer__c;
                        anotherMemGuestCate = 'Member';
                    }
                }
            }else if(folioECOID!=null){
                selectedFolio=foliosMap.get(folioECOID);
                if(selectedFolio!=null && selectedFolio.fol.club62__Room_Reservation__c!=null && selectedFolio.custGuest!=null && selectedFolio.custGuest!='' 
                    && (selectedFolio.fol.club62__Guest__c!=null || selectedFolio.fol.club62__Customer__c!=null)){
                    anotherMemGuestName = selectedFolio.custGuest;
                    if(selectedFolio.fol.club62__Guest__c!=null){
                        anotherMemGuestID = selectedFolio.fol.club62__Guest__c;
                        anotherMemGuestCate = 'Guest';
                    }else if(selectedFolio.fol.club62__Customer__c!=null){
                        anotherMemGuestID = selectedFolio.fol.club62__Customer__c;
                        anotherMemGuestCate = 'Member';
                    }
                }
            }
        }
    }
    //Create a new Transaction of paymet record type
    public void createNewPayment(){
        pay = new club62__TXN__c(RecordTypeID=Schema.SObjectType.club62__TXN__c.getRecordTypeInfosByName().get('Payment').getRecordTypeId());
        if(resType=='rrRes'){
            pay.club62__Room_Reservation__c = recId;
        }else if(resType=='evtRes'){
            pay.club62__Reservation__c = recId;
        }
        pay.club62__Date__c = Date.Today();
    }
    
    public List<FolioWrapper> getFoliosMapValues(){
        List<FolioWrapper> follist = new List<FolioWrapper>();
        if(foliosMap!=null && foliosMap.size()>0){follist = foliosMap.values();}
        follist.sort();
        return follist;
    }
    
    public void payAllFolioBalance(){
        if(selectedFolio!=null && selectedFolio.balance!=null && pay!=null){
            pay.club62__Amount__c = selectedFolio.balance;
        }
    }
    
    public void setSelFolio(){
        if(foliosMap.containsKey(selectedFolioId)){
            selectedFolio = foliosMap.get(selectedFolioId);
            if(selectedFolio!=null && selectedFolio.fol.club62__Room_Reservation__c!=null && selectedFolio.custGuest!=null && selectedFolio.custGuest!='' 
                && (selectedFolio.fol.club62__Guest__c!=null || selectedFolio.fol.club62__Customer__c!=null)){
                anotherMemGuestName = selectedFolio.custGuest;
                if(selectedFolio.fol.club62__Guest__c!=null){
                    anotherMemGuestID = selectedFolio.fol.club62__Guest__c;
                    anotherMemGuestCate = 'Guest';
                }else if(selectedFolio.fol.club62__Customer__c!=null){
                    anotherMemGuestID = selectedFolio.fol.club62__Customer__c;
                    anotherMemGuestCate = 'Member';
                }
            }
        }
    }
    
    public List<TranWrapper> getTranWrapperLst(){
        List<TranWrapper> tLst = new List<TranWrapper>();
        Map<String,TranWrapper> tMap = new Map<String,TranWrapper>();
        for(club62__TXN__c t : selectedFolio.fol.club62__Transactions1__r){
            if((t.RecordType.Name=='Adjustment' || t.RecordType.Name=='Charge') && t.club62__Reservation_Registration__c==null && t.club62__Type__c!='Promotion' 
                && t.club62__Amount__c!=null){
                if(t.club62__Room_Reservation__c!=null){
                    if(!tMap.containsKey(t.club62__Room_Reservation__c)){
                        TranWrapper tw = new TranWrapper();
                        tw.rrID = t.club62__Room_Reservation__c;
                        tw.rrName = t.club62__Room_Reservation__r.Name;
                        if(t.club62__Room_Reservation__r.club62__Customer__c!=null){
                            tw.custID = t.club62__Room_Reservation__r.club62__Customer__c;
                            tw.custName = t.club62__Room_Reservation__r.club62__Customer__r.Name;
                        }
                        if(t.club62__Room_Reservation__r.club62__Person__c!=null){
                            tw.perID = t.club62__Room_Reservation__r.club62__Person__c;
                            tw.perName = t.club62__Room_Reservation__r.club62__Person__r.Name;
                        }
                        tw.amt = t.club62__Total_Amount__c.setScale(2, System.RoundingMode.HALF_UP);
                        tMap.put(t.club62__Room_Reservation__c,tw);
                    }else{
                        TranWrapper tw = tMap.get(t.club62__Room_Reservation__c);
                        tw.amt += t.club62__Total_Amount__c.setScale(2, System.RoundingMode.HALF_UP);
                        tMap.put(t.club62__Room_Reservation__c,tw);
                    }
                }
            }
        }
        if(tMap.Size()>0){tLst = new List<TranWrapper>(tMap.values());}
        return tLst;
    }
    
    public List<club62__TXN__c> getTransFolio(){
        List<club62__TXN__c> txnLst =  new List<club62__TXN__c>();
        for(club62__TXN__c t : selectedFolio.fol.club62__Transactions1__r){
            if((t.RecordType.Name=='Adjustment' || t.RecordType.Name=='Charge') && t.club62__Reservation_Registration__c==null && t.club62__Type__c!='Promotion' 
                && t.club62__Amount__c!=null){
                txnLst.add(t);
            }
        }
        return txnLst;
    }
    
    public List<club62__TXN__c> getPayFolio(){
        List<club62__TXN__c> txnLst =  new List<club62__TXN__c>();
        for(club62__TXN__c t : selectedFolio.fol.club62__Transactions1__r){
            if(t.RecordType.Name=='Payment' && t.club62__Amount__c!=null && (t.club62__Status__c=='Paid' || t.club62__Status__c=='Refunded' 
                || t.club62__Status__c=='Partially Refunded')){
                txnLst.add(t);
            }
        }
        return txnLst;
    }
    
    public List<club62__TXN__c> getRefFolio(){
        List<club62__TXN__c> txnLst =  new List<club62__TXN__c>();
        for(club62__TXN__c t : selectedFolio.fol.club62__Transactions1__r){
            if(t.RecordType.Name=='Refund' && t.club62__Payment__c!=null && t.club62__Amount__c!=null && (t.club62__Payment__r.club62__Status__c=='Paid' 
                || t.club62__Payment__r.club62__Status__c=='Refunded' || t.club62__Payment__r.club62__Status__c=='Partially Refunded')){
                txnLst.add(t);
            }
        }
        return txnLst;
    }
    
    public void submitPayment(){
        paymentSucceeded = false;
        SavePoint sp;
        try{
            if(selectedPaymentType=='Check' && (pay.club62__Check_Date__c==null || pay.club62__Check_Number__c==null)){
                throw new C62Utilities.CustomException('Check Date and Check Number are required.');
            }
            if(selectedPaymentType=='External Credit Card' && (pay.club62__External_Payment_Method__c==null || pay.club62__External_Payment_Method__c=='')){
                throw new C62Utilities.CustomException('External Payment Method is required.');
            }
            if(selectedPaymentType=='External Credit Card' && (pay.club62__External_Payment_Method_Last_4_Digits__c==null || pay.club62__External_Payment_Method_Last_4_Digits__c=='')){
                throw new C62Utilities.CustomException('External Payment Method Last 4 Digits are required.');
            }
            if(selectedPaymentType=='External Credit Card' && (pay.club62__External_Payment_Transaction_Code__c==null || pay.club62__External_Payment_Transaction_Code__c=='')){
                throw new C62Utilities.CustomException('External Payment Transaction Code is required.');
            }
            if(pay!=null && pay.club62__Amount__c!=null && pay.club62__Amount__c>0){
                if((selectedPayMethod!=null && selectedPayMethod!='') || (selectedPaymentType=='Cash' || selectedPaymentType=='Check' || selectedPaymentType=='External Credit Card')){
                    pay.Id = null;
                    if(selectedFolio!=null && selectedFolio.fol!=null && selectedFolio.fol.club62__Guest__c!=null){
                        pay.club62__Guest__c = selectedFolio.fol.club62__Guest__c;
                    }else if(selectedFolio!=null && selectedFolio.fol!=null){
                        pay.club62__Member__c = selectedFolio.fol.club62__Customer__c;
                    }
                    if((selectedFolio==null || selectedFolio.fol==null) && resType!='evtRes'){
                        if(rRes!=null && rRes.club62__Person__c!=null){
                            pay.club62__Guest__c = rRes.club62__Person__c;
                        } else if(rRes!=null && rRes.club62__Customer__c!=null){
                            pay.club62__Member__c = rRes.club62__Customer__c;
                        }
                    }
                    if(selectedFolio!=null && selectedFolio.fol!=null){
                        pay.club62__Folio__c = selectedFolio.fol.Id;
                        pay.club62__Description__c = selectedFolio.fol.Name+' - Payment';
                    } else if((selectedFolio==null || selectedFolio.fol==null) && resType!='evtRes'){
                        pay.club62__Description__c = rRes.Name+' - Payment';
                    }
                    pay.club62__Status__c = 'Queued';
                    if(selectedPayMethod!=null && selectedPayMethod!='' && selectedPaymentType == 'Credit Card/ACH'){
                        pay.club62__Payment_Method__c = selectedPayMethod;
                    }
                    club62__Payment_Gateway__c pg = C62PaymentGatewayHandler.getGatewayByType('Room');
                    if(pg != null) pay.club62__Payment_Gateway__c = pg.Id;
                    if(Schema.sObjectType.club62__Payment__c.isCreateable()){
                        club62__TXN__c eventChangeTransaction;
                        if(pay.club62__Reservation__c!=null){
                            String query = 'Select '+C62Utilities.getFields('club62__Reservation__c')+',RecordType.Name FROM club62__Reservation__c where Id=\''
                                            +String.escapeSingleQuotes(pay.club62__Reservation__c)+'\' limit 1';
                            List<club62__Reservation__c> reservation = Database.query(query);
                            if(reservation!=null && reservation.size()>0 && (reservation.get(0).RecordType.Name=='Event' || reservation.get(0).RecordType.Name=='Events - Child')){
                                eventChangeTransaction = new club62__TXN__c(club62__Date__c=Date.Today(),club62__Type__c='Event Payment',club62__Category__c='Event',
                                    club62__SubType__c='Event Payment',club62__Overridden_Sales_Tax__c=0,club62__Amount__c=pay.club62__Amount__c,
                                    club62__Reservation__c=reservation.get(0).Id,club62__Description__c='Manual Event Payment Transaction',
                                    club62__Member__c=pay.club62__Member__c,RecordTypeID=Schema.SObjectType.club62__TXN__c.getRecordTypeInfosByName().get('Charge').getRecordTypeId());
                            }
                        }
                        sp = Database.setSavePoint();
                        if(selectedFolio.fol!=null && selectedFolio.fol.Id!=null && selectedFolio.fol.club62__Room_Reservation__c!=null && selectedPaymentType == 'Credit Card/ACH' 
                            && anotherMemGuestCate!=null && anotherMemGuestCate!=''){
                            pay.club62__Guest__c = null;
                            pay.club62__Member__c = null;
                            pay.club62__Folio__c = null;
                            Boolean createFolioFlag = TRUE;
                            if(anotherMemGuestCate=='Member'){
                                pay.club62__Member__c = anotherMemGuestID;
                                if(anotherMemGuestID==selectedFolio.fol.club62__Customer__c){
                                    createFolioFlag=false;
                                    pay.club62__Folio__c = selectedFolio.fol.Id;
                                }else{
                                    List<club62__Folio__c> tempRRFolioList = [SELECT ID,Name,club62__Location__c,club62__Paid_Date__c,club62__Room_Reservation__c,club62__Status__c,
                                                    club62__Title__c,club62__Type__c FROM club62__Folio__c 
                                                    WHERE club62__Room_Reservation__c=:selectedFolio.fol.club62__Room_Reservation__c AND club62__Customer__c=:anotherMemGuestID];
                                    if(tempRRFolioList.size()>0){
                                        createFolioFlag = false;
                                        pay.club62__Folio__c = tempRRFolioList.get(0).Id; 
                                    }
                                }
                            }else{
                                pay.club62__Guest__c = anotherMemGuestID;
                                if(anotherMemGuestID==selectedFolio.fol.club62__Guest__c){
                                    createFolioFlag=false;
                                    pay.club62__Folio__c = selectedFolio.fol.Id;
                                }else{
                                    List<club62__Folio__c> tempRRFolioList = [SELECT ID,Name,club62__Location__c,club62__Paid_Date__c,club62__Room_Reservation__c,club62__Status__c,
                                                    club62__Title__c,club62__Type__c FROM club62__Folio__c 
                                                    WHERE club62__Room_Reservation__c=:selectedFolio.fol.club62__Room_Reservation__c AND club62__Guest__c=:anotherMemGuestID];
                                    if(tempRRFolioList.size()>0){
                                        createFolioFlag = false;
                                        pay.club62__Folio__c = tempRRFolioList.get(0).Id; 
                                    }
                                }
                            }
                            if(createFolioFlag){
                                List<club62__Folio__c> tempRRFolioList = [SELECT ID,Name,club62__Location__c,club62__Room_Reservation__c,club62__Status__c,
                                                    club62__Title__c,club62__Type__c FROM club62__Folio__c 
                                                    WHERE club62__Room_Reservation__c=:selectedFolio.fol.club62__Room_Reservation__c AND ID=:selectedFolio.fol.Id];
                                if(tempRRFolioList.size()>0){
                                    club62__Folio__c rrFolio = tempRRFolioList.get(0).clone();
                                    if(anotherMemGuestCate=='Member'){rrFolio.club62__Customer__c=anotherMemGuestID;}else{rrFolio.club62__Guest__c=anotherMemGuestID;}
                                    insert rrFolio;
                                    pay.club62__Folio__c = rrFolio.Id;
                                }
                            }
                        }
                        insert pay;
                        if(eventChangeTransaction!=null && Schema.sObjectType.club62__TXN__c.isCreateable()){
                            eventChangeTransaction.club62__Payment__c = pay.Id;
                            insert eventChangeTransaction;
                        }
                        paymentSucceeded = true;
                    }
                }else{
                    throw new C62Utilities.CustomException('Payment Method is Required.');
                }
            }else{
                throw new C62Utilities.CustomException('Payment Amount is Required.');
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            if(sp!=null){Database.rollBack(sp);}
        }
    }
    
    /*
    @Name   :JSONObject
    @Description :Object
    */
    public class JSONObject{
        public String accnum{get;set;}
        public String id {get;set;}
        public String label {get;set;}
        public String cat{get;set;}
    }
    
    //Get all of our members for autocomplete
    @RemoteAction
    public static List<JSONObject> getMemGuest(String strName){
        List<JSONObject> lstReturn = new List<JSONObject>();
        String query = 'SELECT Id,Name,club62__Customer_Id__c,club62__status__c FROM Contact';
        strName = '%'+String.escapeSingleQuotes(strName)+'%';
        strName = strName.replaceAll('\'','\\\'');
        query+=' WHERE Name LIKE \'%'+strName+'%\' ORDER BY Name ASC ';
        query += 'LIMIT 20';
        String queryP = 'SELECT Id,Name,club62__status__c FROM ' + club62__Person__c.class.GetName();
        queryP+=' WHERE Name LIKE \'%'+strName+'%\' ORDER BY Name ASC ';
        queryP += 'LIMIT 20';

        List<Contact> lstCs = Database.Query(query);

        for(Contact v : lstCs){
            JSONObject jso = new JSONObject();
            jso.id = v.id;
            jso.cat='Member';
            jso.label = v.Name +'-'+v.club62__Customer_Id__c+'-'+v.club62__status__c;
            lstReturn.add(jso);
        }
        List<club62__Person__c> lstP = Database.query(queryP);
        for(club62__Person__c p : lstP){
            JSONObject jso = new JSONObject();
            jso.id = p.id;
            jso.label = p.Name +'-'+'-'+p.club62__status__c;
            jso.cat='Guest';
            lstReturn.add(jso);
        }
        return lstReturn;
    }
    
    public void setMemGuest(){
        selectedFolio.fol.club62__Customer__c = null;
        selectedFolio.fol.club62__Guest__c = null;
        if(cObjCat=='Member'){
            selectedFolio.fol.club62__Customer__c=cObjId;
        }else if(cObjCat=='Guest'){
            selectedFolio.fol.club62__Guest__c = cObjId;
        }
        selectedFolio.custGuest = cObjLabel;
    }
    
    public void saveFolio(){
        SavePoint sp = Database.setSavePoint();
        try{
            if(Schema.sObjectType.club62__Folio__c.isUpdateable()){
                update selectedFolio.fol;
                List<club62__TXN__c> tList = [SELECT ID,club62__Member__c,club62__Guest__c,club62__Folio__r.club62__Guest__c,club62__Reservation_Registration__c,
                                            club62__Folio__r.club62__Customer__c,club62__Folio__c,club62__Total_Amount__c FROM club62__TXN__c
                                            WHERE club62__Folio__c=:selectedFolio.fol.Id AND club62__Type__c!='Promotion' AND RecordType.Name IN ('Charge','Adjustment')];
                for(club62__TXN__c t : tList){
                    if(t.club62__Folio__c!=null && t.club62__Folio__r.club62__Customer__c!=null && t.club62__Folio__r.club62__Customer__c!=t.club62__Member__c 
                        && t.club62__Reservation_Registration__c==null){
                        t.club62__Member__c = t.club62__Folio__r.club62__Customer__c;
                    }
                    if(t.club62__Folio__c!=null && t.club62__Folio__r.club62__Guest__c!=t.club62__Guest__c && t.club62__Reservation_Registration__c==null){
                        t.club62__Guest__c = t.club62__Folio__r.club62__Guest__c;
                    }
                }
                if(Schema.sObjectType.club62__TXN__c.isUpdateable() && tList.size()>0){update tList;}
            }
            loadFoliosMap();
            setSelFolio();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
            Database.rollBack(sp);
        }
    }
    
    public void transferToBanquet(){
        if(selectedFolio!=null && selectedFolio.balance!=null && selectedFolio.fol!=null){
            List<club62__TXN__c> transList = new List<club62__TXN__c>();
            SavePoint sp = Database.setSavePoint();
            try{
                if(selectedFolio.balance>0){
                    club62__TXN__c balTrans = new club62__TXN__c(club62__Overridden_Hotel_Tax__c=0,club62__Overridden_Occupancy_Tax__c=0,
                        club62__Overridden_Sales_Tax__c=0,club62__Overridden_Unit_Tax__c=0,club62__Food_Amount__c=0,club62__Drink_Amount__c=0,club62__Gratuity_Amount__c=0,
                        RecordTypeID=Schema.SObjectType.club62__TXN__c.getRecordTypeInfosByName().get('Charge').getRecordTypeId());
                    balTrans.club62__Amount__c = -selectedFolio.balance;
                    balTrans.club62__Description__c = 'Folio balance adjustment';
                    balTrans.club62__Room_Reservation__c = selectedFolio.fol.club62__Room_Reservation__c;
                    balTrans.club62__Date__c = Date.Today();
                    balTrans.club62__Type__c = 'Banquet Transfer';
                    balTrans.club62__Category__c='Room';
                    if(selectedFolio.fol.club62__Customer__c!=null){balTrans.club62__Member__c = selectedFolio.fol.club62__Customer__c;}
                    if(selectedFolio.fol.club62__Guest__c!=null){balTrans.club62__Guest__c = selectedFolio.fol.club62__Guest__c;}
                    transList.add(balTrans);
                    
                    club62__TXN__c newTrans = new club62__TXN__c(club62__Overridden_Hotel_Tax__c=0,club62__Overridden_Occupancy_Tax__c=0,
                        club62__Overridden_Sales_Tax__c=0,club62__Overridden_Unit_Tax__c=0,club62__Food_Amount__c=0,club62__Drink_Amount__c=0,club62__Gratuity_Amount__c=0,
                        RecordTypeID=Schema.SObjectType.club62__TXN__c.getRecordTypeInfosByName().get('Charge').getRecordTypeId());
                    newTrans.club62__Amount__c = selectedFolio.balance;
                    newTrans.club62__Description__c = 'Transferred from '+selectedFolio.fol.Name+' of '+selectedFolio.fol.club62__Room_Reservation__r.Name;
                    newTrans.club62__Reservation__c = selectedFolio.fol.club62__Room_Reservation__r.club62__Reservation__c;
                    newTrans.club62__Category__c = 'Banquet';
                    newTrans.club62__Date__c = Date.Today();
                    newTrans.club62__Type__c = 'Banquet Transfer';
                    if(selectedFolio.fol.club62__Customer__c!=null){newTrans.club62__Member__c = selectedFolio.fol.club62__Customer__c;}
                    if(selectedFolio.fol.club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c!=null){newTrans.club62__Member__c = selectedFolio.fol.club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c;}
                    transList.add(newTrans);
                } else if(selectedFolio.balance<0){
                    club62__TXN__c balTrans = new club62__TXN__c(club62__Overridden_Hotel_Tax__c=0,club62__Overridden_Occupancy_Tax__c=0,
                        club62__Overridden_Sales_Tax__c=0,club62__Overridden_Unit_Tax__c=0,club62__Food_Amount__c=0,club62__Drink_Amount__c=0,club62__Gratuity_Amount__c=0,
                        RecordTypeID=Schema.SObjectType.club62__TXN__c.getRecordTypeInfosByName().get('Charge').getRecordTypeId());
                    balTrans.club62__Amount__c = -selectedFolio.balance;
                    balTrans.club62__Description__c = 'Folio balance adjustment';
                    balTrans.club62__Room_Reservation__c = selectedFolio.fol.club62__Room_Reservation__c;
                    balTrans.club62__Category__c = 'Room';
                    balTrans.club62__Date__c = Date.Today();
                    balTrans.club62__Type__c = 'Banquet Transfer';
                    if(selectedFolio.fol.club62__Customer__c!=null){balTrans.club62__Member__c = selectedFolio.fol.club62__Customer__c;}
                    if(selectedFolio.fol.club62__Guest__c!=null){balTrans.club62__Guest__c = selectedFolio.fol.club62__Guest__c;}
                    transList.add(balTrans);
                    
                    club62__TXN__c newTrans = new club62__TXN__c(club62__Overridden_Hotel_Tax__c=0,club62__Overridden_Occupancy_Tax__c=0,
                        club62__Overridden_Sales_Tax__c=0,club62__Overridden_Unit_Tax__c=0,club62__Food_Amount__c=0,club62__Drink_Amount__c=0,club62__Gratuity_Amount__c=0,
                        RecordTypeID=Schema.SObjectType.club62__TXN__c.getRecordTypeInfosByName().get('Charge').getRecordTypeId());
                    newTrans.club62__Amount__c = selectedFolio.balance;
                    newTrans.club62__Description__c = 'Transferred from '+selectedFolio.fol.Name+' of '+selectedFolio.fol.club62__Room_Reservation__r.Name;
                    newTrans.club62__Reservation__c = selectedFolio.fol.club62__Room_Reservation__r.club62__Reservation__c;
                    newTrans.club62__Category__c = 'Banquet';
                    newTrans.club62__Date__c = Date.Today();
                    newTrans.club62__Type__c = 'Banquet Transfer';
                    if(selectedFolio.fol.club62__Customer__c!=null){newTrans.club62__Member__c = selectedFolio.fol.club62__Customer__c;}
                    if(selectedFolio.fol.club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c!=null){newTrans.club62__Member__c = selectedFolio.fol.club62__Room_Reservation__r.club62__Reservation__r.club62__Sponsoring_Customer__c;}
                    transList.add(newTrans);
                }
                upsert transList;
            }catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
                Database.rollBack(sp);
                return ;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Remaining charges transferred successfully.'));
            createNewPayment();
            loadFoliosMap();
            setSelFolio();
        }
    }
    
    /*
    @Name   :sendToAuthorize
    @Description :Authorize the payment
    */
    public void sendToAuthorize(){
        if(paymentsucceeded){
            if(pay!=null && pay.club62__Amount__c!=null && pay.club62__Amount__c>0){
                if(pay!=null && pay.Id!=null && ((selectedPaymentType == 'Credit Card/ACH' && pay.club62__Payment_Method__c!=null)
                    || selectedPaymentType=='Cash' || selectedPaymentType=='Check' || selectedPaymentType=='External Credit Card')){
                    club62__TXN__c p = [Select Id,club62__Reservation__c,club62__Status__c,Name,club62__Member__c,club62__Member__r.FirstName,club62__Amount__c,
                        club62__Payment_Method__c,club62__Payment_Method__r.Name,club62__Payment_Method__r.club62__Account_Number__c,
                        club62__Payment_Method__r.club62__Card_Holder_Name__c,club62__Member__r.LastName,
                        club62__Payment_Method__r.club62__Card_Number__c,club62__Payment_Method__r.club62__Card_Type__c,club62__Guest__c,club62__Folio__r.Name,
                        club62__Payment_Method__r.club62__CVV_Code__c,club62__Payment_Method__r.club62__Expiration_Date__c,club62__Payment_Method__r.club62__Payment_Type__c,
                        club62__Payment_Method__r.club62__Routing_Number__c,club62__SubType__c ,club62__Folio__c,club62__Guest__r.club62__First_Name__c,
                        club62__Guest__r.club62__Last_Name__c,club62__Number_Of_Authorization_Attempts__c,club62__Room_Reservation__c From club62__TXN__c Where Id =:pay.Id];
                    if(selectedPaymentType == 'Credit Card/ACH'){
                         //FIND ME BEN
                        C62PaymentGatewayController payGateCont = new C62PaymentGatewayController();
                        String firstName, lastName;
                        //Add details about cardholder
                        if(p.club62__Member__c != null){
                            if(p.club62__Member__r.FirstName != null) firstName = p.club62__Member__r.FirstName;
                            if(p.club62__Member__r.LastName != null) lastName = p.club62__Member__r.LastName;
                        } else if(p.club62__Guest__c != null){
                            if(p.club62__Guest__r.club62__First_Name__c != null) firstName = p.club62__Guest__r.club62__First_Name__c;
                            if(p.club62__Guest__r.club62__Last_Name__c != null) lastName = p.club62__Guest__r.club62__Last_Name__c;
                        }
                        
                        try{
                            C62PaymentGatewayClasses.MakePaymentResponse result;
                            if(p.club62__Payment_Method__r.club62__Payment_Type__c=='Credit Card' || p.club62__Payment_Method__r.club62__Payment_Type__c=='ACH/echeck'){
                                result = payGateCont.MakePayment(p.club62__Payment_Method__r,p.club62__Amount__c,firstName,lastName);
                            }
                            if(p.club62__Payment_Method__r.club62__Payment_Type__c=='Direct Bill' || p.club62__Payment_Method__r.club62__Payment_Type__c=='Pass Direct Bill' 
                                || (result != null && result.Effect == C62PaymentGatewayClasses.TransactionEffect.Success)){
                                //If successful mark as Paid
                                p.club62__Status__c='Paid';
                                if(p.club62__Payment_Method__r.club62__Payment_Type__c=='Credit Card' && result != null){
                                    p.club62__Transaction_Id__c = result.TransactionID;
                                    p.club62__Approval_Code__c = result.AuthorizationID;
                                }
                                createNewPayment();
                                loadFoliosMap();
                                setSelFolio();
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payment Charged Successfully!'));
                            } else {
                                //If not successful mark as Rejected
                                p.club62__Status__c='Rejected';
                                Decimal amt = p.club62__Amount__c;
                                createNewPayment();
                                p.club62__Amount__c = amt;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Payment has been Rejected.'));
                            }
                            if(result!=null){p.club62__Processing_Message__c = (result.ErrorDescription != null) ? result.ErrorDescription : 'Payment Succeeded';}
                        }catch(Exception e){
                            p.club62__Status__c = 'Exception';
                            p.club62__Processing_Message__c = e.getMessage();
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
                        }
                    }else{
                        p.club62__Status__c='Paid';
                        createNewPayment();
                        loadFoliosMap();
                        setSelFolio();
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payment Charged Successfully!'));
                    }
                    if(Schema.sObjectType.club62__TXN__c.isUpdateable()){
                        if(payDisc!=null && payDisc!=''){ p.club62__Description__c=payDisc; }
                        if(p.club62__Amount__c!=null && p.club62__Status__c=='Paid' && p.club62__Folio__c!=null && selectedFolio.fol!=null && selectedFolio.fol.Id!=null 
                            && selectedFolio.fol.club62__Room_Reservation__c!=null && selectedPaymentType == 'Credit Card/ACH' && anotherMemGuestCate!=null && anotherMemGuestCate!=''
                            && p.club62__Folio__c!=selectedFolio.fol.Id && resType!='evtRes'){
                            //need to discuss the things.
                        }
                        List<club62__TXN__c> tranLst = new List<club62__TXN__c>();
                        update p;
                        if(earlyCheckOutDis!=null && earlyCheckOutDis!='' && earlyCheckOutTran!=null && earlyCheckOutTran.club62__Amount__c!=null && p.club62__Folio__c!=null 
                            && p.club62__Folio__c==earlyCheckOutTran.club62__Folio__c){
                            tranLst.add(earlyCheckOutTran);
                            if(rRes!=null && rRes.Id!=null){
                                if(rRes.club62__Room__c != null){
                                    club62__Room__c room = [SELECT Id,Name,club62__Status__c,club62__Dirty__c FROM club62__Room__c WHERE Id = :rRes.club62__Room__c];
                                    room.club62__Dirty__c = true;
                                    room.club62__Status__c = 'Vacant';
                                    if(Schema.sObjectType.club62__Room__c.isUpdateable()){update room;}
                                }
                                RecordType rt = [SELECT Id,Name FROM RecordType WHERE Name = 'Checked Out' AND SobjectType = 'club62__Room_Reservation__c'];
                                rRes.RecordTypeId = rt.Id;
                                rRes.club62__Status__c = 'Checked Out';
                                rRes.club62__Check_Out_Date__c = DateTime.NOW();
                                if(Schema.sObjectType.club62__Room_Reservation__c.isUpdateable()){update rRes;}
                            }
                        }
                        upsert tranLst;
                        
                        loadFoliosMap();
                        if(selectedFolio!=null && selectedFolio.fol!=null && selectedFolio.fol.Id!=null){selectedFolioId=selectedFolio.fol.Id;}
                        setSelFolio();
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No Payment Method was Selected'));
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Amount is Required.'));
            }
        }
        paymentSucceeded = false;
    }
    /*
    @Name : TranWrapper
    @Description : Wrapper Class
    */
    public class TranWrapper{
        public String rrID{get;set;}
        public String rrName{get;set;}
        public String custID{get;set;}
        public String custName{get;set;}
        public String perID{get;set;}
        public String perName{get;set;}
        public Decimal amt{get;set;}
    }
    /*
    @Name : FolioWrapper
    @Description : Wrapper Class
    */
    public class FolioWrapper implements Comparable{
        public club62__Folio__c fol{get;set;}
        public Decimal amount{get;set;}
        public Decimal totalPay{get;set;}
        public Decimal adjusted{get;set;}
        public Decimal refunded{get;set;}
        public Decimal transferred{get;set;}
        public Decimal balance{get;set;}
        public Decimal gratuity{get;set;}
        public String custGuest{get;set;}
        public FolioWrapper(club62__Folio__c f, Decimal amt, Decimal p, Decimal adj, Decimal ref, Decimal transfer, Decimal grat){
            fol = f;
            if(fol.club62__Guest__c!=null){
                custGuest = fol.club62__Guest__r.Name;
            }else if(fol.club62__Customer__c!=null){
                custGuest = fol.club62__Customer__r.Name + ' - '+fol.club62__Customer__r.club62__Customer_Id__c;
            }
            amount = amt.setScale(2, System.RoundingMode.HALF_UP);
            totalPay = p.setScale(2, System.RoundingMode.HALF_UP);
            adjusted = adj.setScale(2, System.RoundingMode.HALF_UP);
            refunded = ref.setScale(2, System.RoundingMode.HALF_UP);
            transferred = transfer.setScale(2, System.RoundingMode.HALF_UP);
            gratuity = grat.setScale(2, System.RoundingMode.HALF_UP);
            balance = (amount - totalPay + refunded  + adjusted + transferred).setScale(2, System.RoundingMode.HALF_UP);
        }
        //sorting by Name
        public Integer compareTo(Object compareTo){
            FolioWrapper fw = (FolioWrapper)compareTo;
            if(fol.Name==fw.fol.Name){
                return 0;
            }else if(fol.Name > fw.fol.Name){
                return 1;
            }else{
                return -1;
            }
        }
    }
}