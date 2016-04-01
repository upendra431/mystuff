/*
@Name            : C62VendorCheckRunController
@Author          : customersuccess@cloud62.com
@Date            : March 11 2014
@Description     : Controller for Vendor Check Run Page
*/
public with sharing class C62VendorCheckRunController {

    // The Start and End date that are used for filtering the invoices
    //public club62__Vendor__c cStartDate {get;set;} // of type club62__Vendor__c so binding in VF page works
    public club62__Vendor__c cEndDate {get;set;}   // of type club62__Vendor__c so binding in VF page works
    public club62__Vendor__c cPurchaseCategory {get;set;}
    //public Boolean isFilter {get;set;} // Specifies if the checkBatchDate method is called via the filter fields or not
    public Boolean paidManually{get;set;}
    public Boolean checkPreview{get;set;}


    //Batch that ties all checks generated this run together
    public club62__Vendor_Invoice_Check_Batch__c vicb{get;set;}
    public Boolean validCheckBatchDate{get;set;}

    //Final Print list
    //public Set<Id> vendorCheckIds{get;set;}

    //Closed Month Variables
    private Set<Date> closedFCMap{get;set;}
    public String closedMonthWarning{get;set;}

    //public Map<Id,club62__Vendor_Invoice__c> viCheckMap{get;set;}

    //Selected Number of checks
    public Integer numOfSelChecks{get;set;}
    public Integer numOfSelHoldChecks{get;set;}

    //Holds all of our Invoice Wrapper <Index,Wrapper>
    public Map<Id,VendorInvoiceWrapper> viwMap{get;set;}
    public Map<Id,VendorInvoiceWrapper> viwHoldMap{get;set;}
    public Map<Id,List<Id>> viwVendorMap{get;set;}
    public Map<Id,List<Id>> viwHoldVendorMap{get;set;}

    // CheckAsPDF Page Variable
    //public Map<club62__Vendor_Invoice_Check__c, List<club62__Vendor_Invoice__c>> vicMap{get;set;}

    public Boolean selectAll{get;set;}

    public Decimal grandTotal{get;set;}
    public Decimal grandHoldTotal{get;set;}
    public Decimal payingAmount{get;set;}
    public Decimal payingHoldAmount{get;set;}

    public Integer nextCheckNumber{get;set;}
    //public Integer checkDigits{get;set;}
    public club62__Check_Run__c checkRun{get;set;}
    //Location for Check Run and Operating Checks Account - Defaults to Operating Check check box
    public Club62__Vendor_Invoice__c locationSelection{get;set;}
    public club62__Financial_Account__c operatingChecks{get;set;}


    public String selectAllOnHold{get;set;}
    //for selectvendor action function
    public String selectedVendor{get;set;}
    public String selectedInvoice{get;set;}

    //Check Print Page
    public Map<Id,List<club62__Vendor_Invoice__c>> printedCheckVIMap{get;set;}
    public List<club62__Vendor_Invoice_Check__c> printedCheckVCList{get;set;}
    public Map<Id,Map<Id,FinancialJournalLineWrapper>> printedCheckFJLMap{get;set;}
    public Map<Id,Decimal> printedCheckAmountSentMap{get;set;}
    public Map<Id,String> printedCheckAmountWordsMap{get;set;}
    public Map<Id,Integer> printedCheckNumberOfInvoicesMap{get;set;}
    public Map<Id,List<club62__Vendor_Invoice_Payment__c>> vipPreviewMap{get;set;}
    public Map<Id,club62__Vendor_Invoice_Check__c> vicPreviewMap{get;set;}
    public Map<Id,club62__Vendor__c> venPreviewMap{get;set;}
    //Constructor to initalize the page
    public C62VendorCheckRunController(ApexPages.StandardController stdController) {
        club62__C62BillingSettings__c billSettings = club62__C62BillingSettings__c.getOrgDefaults();
        locationSelection = new Club62__Vendor_Invoice__c();
        if(billSettings!=null && billSettings.club62__Default_CheckRun_Location__c!= null){
            locationSelection.Location__c = [SELECT Id FROM Location__c WHERE Name = :billSettings.club62__Default_CheckRun_Location__c LIMIT 1].Id;
            setOperatingChecksForLocation();
        }
        checkRun = [Select id,club62__Next_Check_Number__c,club62__Printed_Check_Digits__c from club62__Check_Run__c limit 1];
        //checkDigits = (Integer)checkRun.club62__Printed_Check_Digits__c;
        nextCheckNumber = (Integer)checkRun.club62__Next_Check_Number__c;
        paidManually = false;
        vicb = new club62__Vendor_Invoice_Check_Batch__c();
        vicb.club62__Batch_Date__c = Date.Today();
        cPurchaseCategory  = new club62__Vendor__c();
        //cStartDate = new club62__Vendor__c(club62__Cert_of_Liability_Expiration_Date__c = Date.today());
        cEndDate = new club62__Vendor__c(club62__Cert_of_Liability_Expiration_Date__c = Date.today());
        validCheckBatchDate = false;
        regenerateClosedMonths();
        numOfSelChecks = 0;
        checkPreview = false;
        //isFilter = false;
    }
    //Return a list of all of the invoices wrappers for pageblocktable
    public List<VendorInvoiceWrapper> getPostedInvoices(){
        List<VendorInvoiceWrapper> tempWrap = viwMap.values();
        tempWrap.sort();
        return tempWrap;
    }
    //Return a list of all of the invoices wrappers for pageblocktable with Hold Status
    public List<VendorInvoiceWrapper> getNotPostedInvoices(){
        List<VendorInvoiceWrapper> tempWrap = viwHoldMap.values();
        tempWrap.sort();
        return tempWrap;
    }
    //Get list of posted invoices that don't have checks
    // if isFilterCall == true, was called from via the filter fields in VF page
    public void loadPostedInvoices(){
        viwMap = new Map<Id,VendorInvoiceWrapper>();
        viwVendorMap = new Map<Id,List<Id>>();
        grandTotal = 0.00;
        payingAmount = 0.00;
        Map<Id, Decimal> vendorIdToTotal = new Map<Id,Decimal>();
        Map<Id,String> vendorIdToName = new Map<Id,String>();
        //Only Load Vendor Invoice Lines that have been booked but were not previously included on a check.
        List<club62__Vendor_Invoice_Payment__c> vipList;
        if (cPurchaseCategory.club62__Purchase_Category__c == null || cPurchaseCategory.club62__Purchase_Category__c  == ''){
            vipList = [Select Id,club62__Amount__c,club62__Refund__c,club62__Vendor_Invoice__r.club62__Amount_Remaining__c,club62__Amount_Paid__c,club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c,club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__r.club62__Amount__c
                      FROM club62__Vendor_Invoice_Payment__c
                      WHERE club62__Check_Generated__c = false AND club62__Payment_Type__c= 'Check' AND club62__vendor_invoice__r.club62__Hold_Status__c = false
                      //AND club62__Vendor_Invoice__r.club62__Due_Date__c >=:cStartDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Due_Date__c <=:cEndDate.club62__Cert_of_Liability_Expiration_Date__c and Club62__Vendor_Invoice__r.Club62__Location__c=:locationSelection.Club62__Location__c and
                      club62__Vendor_Invoice__r.club62__Amount_Remaining__c!=0];
        }else {
            vipList = [Select Id,club62__Amount__c,club62__Refund__c,club62__Vendor_Invoice__r.club62__Amount_Remaining__c,club62__Amount_Paid__c,club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c,club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__r.club62__Amount__c
                      FROM club62__Vendor_Invoice_Payment__c
                      WHERE club62__Check_Generated__c = false AND club62__Payment_Type__c= 'Check' AND club62__vendor_invoice__r.club62__Hold_Status__c = false
                      //AND club62__Vendor_Invoice__r.club62__Due_Date__c >=:cStartDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Due_Date__c <=:cEndDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Vendor__r.club62__Purchase_Category__c  =:cPurchaseCategory.club62__Purchase_Category__c and Club62__Vendor_Invoice__r.Club62__Location__c=:locationSelection.Club62__Location__c and
                      club62__Vendor_Invoice__r.club62__Amount_Remaining__c!=0];
        }
        Set<Id> viIdSet = new Set<Id>();
        for(club62__Vendor_Invoice_Payment__c vip : vipList){
            viIdSet.add(vip.club62__Vendor_Invoice__c);
        }


        Map<Id,club62__Vendor_Invoice__c> viMap = new Map<Id,club62__Vendor_Invoice__c>([SELECT id,club62__Notes__c,club62__Include_Notes_on_Check__c,Name,club62__Amount__c,club62__Due_Date__c,club62__Invoice_Number__c,club62__Vendor__c,club62__Vendor__r.Name,
                                                                             club62__Vendor_Invoice_Check__c,club62__Vendor_Invoice_Check__r.club62__Total_Amount__c
                                                                             FROM club62__Vendor_Invoice__c
                                                                             WHERE id in :viIdSet ]);
        Set<Id> vendorInvoiceIds = new Set<Id>();
        for(club62__Vendor_Invoice_Payment__c vip : vipList){
            if(!viwVendorMap.containsKey(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)){
                viwVendorMap.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,new List<Id>());
            }
            if(!viwMap.containsKey(vip.club62__Vendor_Invoice__c)){
                VendorInvoiceWrapper viw = new VendorInvoiceWrapper(viMap.get(vip.club62__Vendor_Invoice__c));
                viwMap.put(vip.club62__Vendor_Invoice__c,viw);
                viwVendorMap.get(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c).add(vip.club62__Vendor_Invoice__c);
            }


            viwMap.get(vip.club62__Vendor_Invoice__c).vipList.add(vip);
            if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                viwMap.get(vip.club62__Vendor_Invoice__c).amount+=vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c;
                grandTotal+=(vip.club62__Amount__c-vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c);
            }

            if(!vendorIdToName.containsKey(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)){
                vendorIdToName.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__r.Name);
                if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                    vendorIdToTotal.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c);
                }

            }else{
                if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                    vendorIdToTotal.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,vendorIdToTotal.get(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)+vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c);
                }
            }
            vendorInvoiceIds.add(vip.club62__Vendor_Invoice__c);
        }
        for(Id ven : vendorIdToTotal.keySet()){
            VendorInvoiceWrapper viw = new VendorInvoiceWrapper(vendorIdtoName.get(ven),vendorIdToTotal.get(ven),ven);
            viwMap.put(ven,viw);
            viwVendorMap.get(ven).add(ven);
        }
    }
    //Load all invoices to display on Page
    @RemoteAction
    public static List<VendorInvoiceWrapper> loadPostedInvoicesRA(Date dueDate,String location,String purchaseCategory){
        Map<Id,VendorInvoiceWrapper> viwMap = new Map<Id,VendorInvoiceWrapper>();
        Map<Id,List<Id>> viwVendorMap = new Map<Id,List<Id>>();
        //grandTotal = 0.00;
        //payingAmount = 0.00;
        Map<Id, Decimal> vendorIdToTotal = new Map<Id,Decimal>();
        Map<Id,String> vendorIdToName = new Map<Id,String>();
        //Only Load Vendor Invoice Lines that have been booked but were not previously included on a check.
        List<club62__Vendor_Invoice_Payment__c> vipList;
        if (purchaseCategory == null || purchaseCategory  == ''){
            vipList = [Select Id,club62__Amount__c,club62__Refund__c,club62__Vendor_Invoice__r.club62__Amount_Remaining__c,club62__Amount_Paid__c,club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c,club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__r.club62__Amount__c
                      FROM club62__Vendor_Invoice_Payment__c
                      WHERE club62__Check_Generated__c = false AND club62__Payment_Type__c= 'Check' AND club62__vendor_invoice__r.club62__Hold_Status__c = false
                      //AND club62__Vendor_Invoice__r.club62__Due_Date__c >=:cStartDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Due_Date__c <=:dueDate and Club62__Vendor_Invoice__r.Club62__Location__c=:location and
                      club62__Vendor_Invoice__r.club62__Amount_Remaining__c!=0];
        }else {
            vipList = [Select Id,club62__Amount__c,club62__Refund__c,club62__Vendor_Invoice__r.club62__Amount_Remaining__c,club62__Amount_Paid__c,club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c,club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__r.club62__Amount__c
                      FROM club62__Vendor_Invoice_Payment__c
                      WHERE club62__Check_Generated__c = false AND club62__Payment_Type__c= 'Check' AND club62__vendor_invoice__r.club62__Hold_Status__c = false
                      //AND club62__Vendor_Invoice__r.club62__Due_Date__c >=:cStartDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Due_Date__c <=:dueDate
                      AND club62__Vendor_Invoice__r.club62__Vendor__r.club62__Purchase_Category__c  =:purchaseCategory and Club62__Vendor_Invoice__r.Club62__Location__c=:location and
                      club62__Vendor_Invoice__r.club62__Amount_Remaining__c!=0];
        }
        Set<Id> viIdSet = new Set<Id>();
        for(club62__Vendor_Invoice_Payment__c vip : vipList){
            viIdSet.add(vip.club62__Vendor_Invoice__c);
        }


        Map<Id,club62__Vendor_Invoice__c> viMap = new Map<Id,club62__Vendor_Invoice__c>([SELECT id,club62__Notes__c,club62__Include_Notes_on_Check__c,Name,club62__Amount__c,club62__Due_Date__c,club62__Invoice_Number__c,club62__Vendor__c,club62__Vendor__r.Name,
                                                                             club62__Vendor_Invoice_Check__c,club62__Vendor_Invoice_Check__r.club62__Total_Amount__c
                                                                             FROM club62__Vendor_Invoice__c
                                                                             WHERE id in :viIdSet ]);
        Set<Id> vendorInvoiceIds = new Set<Id>();
        for(club62__Vendor_Invoice_Payment__c vip : vipList){
            if(!viwVendorMap.containsKey(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)){
                viwVendorMap.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,new List<Id>());
            }
            if(!viwMap.containsKey(vip.club62__Vendor_Invoice__c)){
                VendorInvoiceWrapper viw = new VendorInvoiceWrapper(viMap.get(vip.club62__Vendor_Invoice__c));
                viwMap.put(vip.club62__Vendor_Invoice__c,viw);
                viwVendorMap.get(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c).add(vip.club62__Vendor_Invoice__c);
            }


            viwMap.get(vip.club62__Vendor_Invoice__c).vipList.add(vip);
            if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                viwMap.get(vip.club62__Vendor_Invoice__c).amount+=vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c;
                //grandTotal+=(vip.club62__Amount__c-vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c);
            }

            if(!vendorIdToName.containsKey(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)){
                vendorIdToName.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__r.Name);
                if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                    vendorIdToTotal.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c);
                }

            }else{
                if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                    vendorIdToTotal.put(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,vendorIdToTotal.get(viMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)+vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c);
                }
            }
            vendorInvoiceIds.add(vip.club62__Vendor_Invoice__c);
        }
        for(Id ven : vendorIdToTotal.keySet()){
            VendorInvoiceWrapper viw = new VendorInvoiceWrapper(vendorIdtoName.get(ven),vendorIdToTotal.get(ven),ven);
            viwMap.put(ven,viw);
        }
        List<VendorInvoiceWrapper> viwMapreturn = viwMap.values();
        viwMapreturn.sort();
        return viwMapReturn;
    }
    //Load invoices that are on hold and display them at the bottom of the page
    public void loadNotPostedInvoices(){
        viwHoldMap = new Map<Id,VendorInvoiceWrapper>();
        viwHoldVendorMap = new Map<Id,List<Id>>();
        grandHoldTotal = 0.00;
        payingHoldAmount = 0.00;
        Map<Id, Decimal> vendorIdToTotal = new Map<Id,Decimal>();
        Map<Id,String> vendorIdToName = new Map<Id,String>();
        //Only Load Vendor Invoice Lines that have been booked but were not previously included on a check.
        List<club62__Vendor_Invoice_Payment__c> vipHoldList;
        if (cPurchaseCategory.club62__Purchase_Category__c == null || cPurchaseCategory.club62__Purchase_Category__c  == ''){
            vipHoldList = [Select Id,club62__Amount__c,club62__Refund__c,club62__Vendor_Invoice__r.club62__Amount_Remaining__c,club62__Amount_Paid__c,club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c,club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__r.club62__Amount__c
                      FROM club62__Vendor_Invoice_Payment__c
                      WHERE club62__Check_Generated__c = false AND club62__Payment_Type__c= 'Check' AND club62__vendor_invoice__r.club62__Hold_Status__c = true
                      //AND club62__Vendor_Invoice__r.club62__Due_Date__c >=:cStartDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Due_Date__c <=:cEndDate.club62__Cert_of_Liability_Expiration_Date__c and Club62__Vendor_Invoice__r.Club62__Location__c=:locationSelection.Club62__Location__c and
                      club62__Vendor_Invoice__r.club62__Amount_Remaining__c>0];
        }else {
            vipHoldList = [Select Id,club62__Amount__c,club62__Refund__c,club62__Vendor_Invoice__r.club62__Amount_Remaining__c,club62__Amount_Paid__c,club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c,club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__r.club62__Amount__c
                      FROM club62__Vendor_Invoice_Payment__c
                      WHERE club62__Check_Generated__c = false AND club62__Payment_Type__c= 'Check' AND club62__vendor_invoice__r.club62__Hold_Status__c = true
                      //AND club62__Vendor_Invoice__r.club62__Due_Date__c >=:cStartDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Due_Date__c <=:cEndDate.club62__Cert_of_Liability_Expiration_Date__c
                      AND club62__Vendor_Invoice__r.club62__Vendor__r.club62__Purchase_Category__c  =:cPurchaseCategory.club62__Purchase_Category__c and Club62__Vendor_Invoice__r.Club62__Location__c=:locationSelection.Club62__Location__c and
                      club62__Vendor_Invoice__r.club62__Amount_Remaining__c>0];
        }
        Set<Id> viIdSet = new Set<Id>();
        for(club62__Vendor_Invoice_Payment__c vip : vipHoldList){
            viIdSet.add(vip.club62__Vendor_Invoice__c);
        }


        Map<Id,club62__Vendor_Invoice__c> viHoldMap = new Map<Id,club62__Vendor_Invoice__c>([SELECT id,club62__Notes__c,club62__Include_Notes_on_Check__c,Name,club62__Amount__c,club62__Due_Date__c,club62__Invoice_Number__c,club62__Vendor__c,club62__Vendor__r.Name,
                                                                             club62__Vendor_Invoice_Check__c,club62__Vendor_Invoice_Check__r.club62__Total_Amount__c
                                                                             FROM club62__Vendor_Invoice__c
                                                                             WHERE id in :viIdSet ]);
        Set<Id> vendorInvoiceIds = new Set<Id>();
        for(club62__Vendor_Invoice_Payment__c vip : vipHoldList){
            if(!viwHoldVendorMap.containsKey(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)){
                viwHoldVendorMap.put(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,new List<Id>());
            }
            if(!viwHoldMap.containsKey(vip.club62__Vendor_Invoice__c)){
                VendorInvoiceWrapper viw = new VendorInvoiceWrapper(viHoldMap.get(vip.club62__Vendor_Invoice__c));
                viwHoldMap.put(vip.club62__Vendor_Invoice__c,viw);
                viwHoldVendorMap.get(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c).add(vip.club62__Vendor_Invoice__c);
            }


            viwHoldMap.get(vip.club62__Vendor_Invoice__c).vipList.add(vip);
            if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                viwHoldMap.get(vip.club62__Vendor_Invoice__c).amount+=vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c;
                grandHoldTotal+=(vip.club62__Amount__c-vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c);
            }

            if(!vendorIdToName.containsKey(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)){
                vendorIdToName.put(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__r.Name);
                if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                    vendorIdToTotal.put(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c);
                }

            }else{
                if(!vendorInvoiceIds.contains(vip.club62__Vendor_Invoice__c)){
                    vendorIdToTotal.put(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c,vendorIdToTotal.get(viHoldMap.get(vip.club62__Vendor_Invoice__c).club62__Vendor__c)+vip.club62__Vendor_Invoice__r.club62__Amount_Remaining__c);
                }
            }
            vendorInvoiceIds.add(vip.club62__Vendor_Invoice__c);
        }
        for(Id ven : vendorIdToTotal.keySet()){
            VendorInvoiceWrapper viw = new VendorInvoiceWrapper(vendorIdtoName.get(ven),vendorIdToTotal.get(ven),ven);
            viwHoldMap.put(ven,viw);
            viwHoldVendorMap.get(ven).add(ven);
        }
    }
    public void getOperatingChecksFA(){
        if(locationSelection.club62__Payment_FInancial_Account__c!=null){
            operatingChecks = [Select id,Name,club62__Account_Number__c from club62__Financial_Account__c where id =:locationSelection.club62__Payment_Financial_Account__c];
        }else{
            operatingChecks = null;
        }
    }
    public void setOperatingChecksForLocation(){
        if(locationSelection!=null && locationSelection.club62__Location__c!=null){
            try{
                locationSelection.club62__Payment_Financial_Account__c = [Select id from club62__Financial_Account__c where club62__Operating_Checks__c = true and club62__Location__c=:locationSelection.club62__Location__c limit 1].Id;
                getOperatingCHecksFA();
            }catch (Exception e){
                locationSelection.club62__Payment_Financial_Account__c = null;
                operatingChecks = null;
            }
        }else{
            locationSelection.club62__Payment_Financial_Account__c = null;
        }
    }
    public PageReference generateChecks(){
        return generateChecks(true);
    }
    public PageReference previewChecks(){
        return generateChecks(false);
    }
    public String errorLevel {get; set;}
    public String messageName {get; set;}
    public void showMessage() {
      List<remotingReturnResponse> rRRLst = (List<remotingReturnResponse>)JSON.deserialize(messageName.unescapeHtml4(),List<remotingReturnResponse>.class);
      system.debug(rrrlst);
      for(remotingReturnResponse rrr : rrrLst){
          if(rrr.severityCode == 'WARNING') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, rrr.messageStr));
          }else if(rrr.severityCode == 'ERROR'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, rrr.messageStr));
          }else if(rrr.severityCode == 'CONFIRM'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, rrr.messageStr));
          }
      }
    }
    /*
    @Name : remotingSaveRequest
    @Description : Wrapper class
    */
    public class remotingSaveRequest{
        public String invId;
        public Id vid;
        public Boolean selected;
        public Decimal amtToPay;
        public String memo;
    }
    public class remotingReturnResponse{
        public String severityCode;
        public String messageStr;
        public String redirectURL;

    }
    //Prepare the page to display a preview of the finished checks.
    @RemoteAction
    public static List<remotingReturnResponse> testPreviewCheckRA(List<remotingSaveRequest> checkList,Boolean doInsert,String location,Id operatingChecks,Date batchDate,String batchDescription,Integer nextCheckNumber,Boolean paidManually){
        system.debug(checkList);
        //doInsert = false;
        for(remotingSaveRequest rsr : checkList){
            if(rsr.selected!=null){
                system.debug(rsr);
            }
        }
        Set<Id> venInvoiceIds = new Set<Id>();
        Map<Id,club62__Vendor_Invoice_Check__c> vicList = new Map<Id,club62__Vendor_Invoice_Check__c>();
        List<club62__Vendor_Invoice_Payment__c> invoicePaymentsToUpdate = new List<club62__Vendor_Invoice_Payment__c>();
        Set<club62__Vendor_Invoice__c> invoicesToUpdate = new Set<club62__Vendor_Invoice__c>();
        Set<club62__Vendor_Invoice_Line__c> invoiceLinesToUpdate = new Set<club62__Vendor_Invoice_Line__c>();
        Set<club62__Refund__c> refToUpdate = new Set<club62__Refund__c>();
        Map<Id,List<club62__Vendor_Invoice_Payment__c>> vipPreviewMap = new Map<Id,List<club62__Vendor_Invoice_Payment__c>>();
        Map<Id,club62__Vendor_Invoice_Check__c> vicPreviewMap = new Map<Id,club62__Vendor_Invoice_Check__c>();
        club62__Vendor_Invoice_Check_Batch__c vicb = new club62__Vendor_Invoice_Check_Batch__c();
        vicb.club62__Batch_Date__c = batchDate;
        vicb.Club62__Location__c = location;
        if(doInsert == true){
            if(Schema.sObjectType.club62__Vendor_Invoice_Check_Batch__c.isCreateable()){insert vicb;}
        }
        club62__Check_Run__c checkRun = [Select id,club62__Next_Check_Number__c,club62__Printed_Check_Digits__c from club62__Check_Run__c limit 1];
        Decimal totalCheckAmount = 0;
        List<club62__Financial_Journal_Line__c> fjsToInsert = new List<club62__Financial_Journal_Line__c>();
        Map<Id,Decimal> vendTotalMap = new Map<Id,Decimal>();
        for(remotingSaveRequest viw : checkList){
            if(viw.vid!=null && viw.invId!=null && !viw.invId.contains('Total')){
                if(viw.selected == true){
                    venInvoiceIds.add(viw.invId);
                    if(!vicList.containsKey(viw.vid)){
                        club62__Vendor_Invoice_Check__c vic = new club62__Vendor_Invoice_Check__c();
                        vic.club62__Amount__c = viw.amtToPay;
                        vic.club62__Check_Date__c = vicb.club62__Batch_Date__c;
                        vic.club62__Check_Number__c = (nextCheckNumber+'').replaceAll(',','');
                        vic.club62__Paid_Manually__c = paidManually;
                        String tempCheck = '';
                        for(Integer i = vic.club62__Check_Number__c.length();i<checkRun.club62__Printed_Check_Digits__c;i++){
                            tempCheck +='0';
                        }
                        vic.club62__Check_Number__c=tempCheck+vic.club62__Check_Number__c;
                        vic.club62__Vendor_Invoice_Check_Batch__c = vicb.id;
                        vic.club62__Vendor__c = viw.vid;
                        nextCheckNumber++;
                        vicList.put(viw.vid,vic);
                    }else{
                        vicList.get(viw.vid).club62__amount__c+=viw.amtToPay;
                    }
                    if(!vendTotalMap.containsKey(viw.vid)){
                        vendTotalMap.put(viw.vid,0);
                    }
                    if(viw.amtToPay!=null){
                       vendTotalMap.put(viw.vid,vendTotalMap.get(viw.vid)+viw.amtToPay);
                       totalCheckAmount+=viw.amtToPay;
                   }

                }
            }
        }

        for(remotingSaveRequest viw : checkList){
            if(viw.invId!=null && viw.invId.contains('Total')){
                if(vicList.containsKey(viw.vid)){
                    if(vicList.get(viw.vid).club62__Memo__c==null || vicList.get(viw.vid).club62__Memo__c==''){
                        vicList.get(viw.vid).club62__Memo__c=viw.memo;
                    }
                    vicList.get(viw.vid).club62__Total_Amount__c = vendTotalMap.get(viw.vid) +'';
                }
            }
        }

        if(doInsert==true){
            if(Schema.sObjectType.club62__Vendor_Invoice_Check__c.isCreateable()){insert vicList.values();}
        }

        checkRun.club62__Next_Check_Number__c = nextCheckNumber;
        if(doInsert == true && Schema.sObjectType.club62__Check_Run__c.isUpdateable()){update checkRun;}
        Map<Id,List<club62__Vendor_Invoice_Payment__c>> vipMap = new Map<Id,List<club62__Vendor_Invoice_Payment__c>>();
        for(club62__Vendor_Invoice_Payment__c vip : [select Id,club62__Vendor_Invoice__c,club62__Amount__c,club62__Refund__c,club62__Amount_Paid__c,club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c from club62__Vendor_Invoice_Payment__c where club62__Vendor_Invoice__c in :venInvoiceIds and club62__Check_Generated__c = false AND club62__Payment_Type__c= 'Check' AND club62__vendor_invoice__r.club62__Hold_Status__c = false ]){
            if(!vipMap.containsKey(vip.club62__Vendor_Invoice__c)){
                vipMap.put(vip.club62__Vendor_Invoice__c,new List<club62__Vendor_Invoice_Payment__c>());
            }
            vipMap.get(vip.club62__vendor_Invoice__c).add(vip);
        }
        for(remotingSaveRequest viw : checkList){
            Decimal viAmountAvailable = viw.amtToPay;
            //Map<Id,Decimal> VILRemaining = new Map<Id,Decimal>();
            if(viw.selected==true){
                if(viw.vid!=null && viw.invId!=null && !viw.invId.contains('Total') && viAmountAvailable!=null){
                    for(club62__Vendor_Invoice_Payment__c vip : vipMap.get(viw.invId)){
                        Decimal amt = vip.club62__Amount__c-vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c;

                        boolean assignCheck = false;
                        //We have plenty of money to cover this VIP
                        if(viAmountAvailable>=amt){
                            viAmountAvailable -= amt;
                            vip.club62__Amount_Paid__c = amt;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vid).id;
                            invoicePaymentsToUpdate.add(vip);
                            assignCheck = true;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vid).id;
                        }else{
                            //We didn't have enough money to cover the whole thing
                            vip.club62__Amount_Paid__c = viAmountAvailable;
                            viAmountAvailable -= amt;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vid).id;
                            //Create a new line so we can pay off the remaining balance
                            invoicePaymentsToUpdate.add(new club62__Vendor_Invoice_Payment__c(club62__Vendor_Invoice__c=vip.club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__c=vip.club62__Vendor_Invoice_Line__c,club62__Amount_Paid__c=0));
                            invoicePaymentsToUpdate.add(vip);
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vid).id;
                        }
                        if(assignCheck){
                            club62__Vendor_Invoice__c vi = new club62__Vendor_Invoice__c(id=vip.club62__Vendor_Invoice__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vid).id);
                            invoicesToUpdate.add(vi);
                            club62__Vendor_Invoice_Line__c vil = new club62__Vendor_Invoice_Line__c(id=vip.club62__Vendor_Invoice_Line__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vid).id);
                            invoiceLinesToUpdate.add(vil);
                            if(vip.club62__Refund__c!=null){
                                club62__Refund__c ref = new club62__Refund__c(id=vip.club62__Refund__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vid).id);
                                refToUpdate.add(ref);
                            }
                        }
                        if(!vipPreviewMap.containsKey(viw.vid)){
                            vipPreviewMap.put(viw.vid,new List<club62__Vendor_Invoice_Payment__c>());
                        }
                        vipPreviewMap.get(viw.vid).add(vip);
                        if(viAmountAvailable<=0){
                            break;
                        }
                    }
                }
            }
        }
        if(doInsert == true && Schema.sObjectType.club62__Vendor_Invoice_Payment__c.isUpdateable() && Schema.sObjectType.club62__Vendor_Invoice_Payment__c.isCreateable()){upsert invoicePaymentsToUpdate;}
        if(doInsert == true && Schema.sObjectType.club62__Vendor_Invoice__c.isUpdateable()){update new List<club62__Vendor_Invoice__c>(invoicesToUpdate);}
        if(doInsert == true && Schema.sObjectType.club62__Refund__c.isUpdateable()){update new List<club62__Refund__c>(refToUpdate);}
        if(doInsert == true && Schema.sObjectType.club62__Vendor_Invoice_Line__c.isUpdateable()){update new List<club62__Vendor_Invoice_Line__c>(invoiceLinesToUpdate);}
        remotingReturnResponse p = new remotingReturnResponse();
        if(doInsert == true){
            club62__Financial_Account__c tradeAccount = [Select id from club62__Financial_Account__c where club62__A_P_Trade__c = true and club62__Location__c=:location limit 1];
            club62__Financial_Journal_Entry__c fjEntry = new club62__Financial_Journal_Entry__c();
            vicb = [Select Name,club62__Batch_Date__c from club62__Vendor_Invoice_Check_Batch__c where Id=:vicb.Id limit 1];
            fjEntry.club62__Description__c = 'Invoice Check Batch '+vicb.Name;
            fjEntry.club62__Entry_Date__c = vicb.club62__Batch_Date__c;
            fjEntry.club62__Posted__c = true;
            fjEntry.club62__Post_Date__c = vicb.club62__Batch_Date__c;
            if(Schema.sObjectType.club62__Financial_Journal_Entry__c.isCreateable()){insert fjEntry;}
            club62__Financial_Journal_Line__c tradeJournal = new club62__Financial_Journal_Line__c();
            tradeJournal.club62__Amount__c = -totalCheckAmount;
            tradeJournal.club62__Description__c = 'Invoice Check Batch '+vicb.Name;
            tradeJournal.club62__Financial_Account__c=tradeAccount.Id;
            tradeJournal.club62__Financial_Journal_Entry__c = fjEntry.Id;
            tradeJournal.club62__Post_Date__c = vicb.club62__Batch_Date__c;
            tradeJournal.club62__Posted__c = true;
            tradeJournal.club62__Transaction_Date__c = vicb.club62__Batch_Date__c;
            club62__Financial_Journal_Line__c cashJournal = new club62__Financial_Journal_Line__c();
            cashJournal.club62__Amount__c = -totalCheckAmount;
            cashJournal.club62__Description__c = 'Invoice Check Batch '+vicb.Name;
            cashJournal.club62__Financial_Account__c=operatingChecks;
            cashJournal.club62__Financial_Journal_Entry__c = fjEntry.Id;
            cashJournal.club62__Post_Date__c = vicb.club62__Batch_Date__c;
            cashJournal.club62__Posted__c = true;
            cashJournal.club62__Transaction_Date__c = vicb.club62__Batch_Date__c;
            fjsToInsert.add(tradeJournal);
            fjsToInsert.add(cashJournal);
            if(Schema.sObjectType.club62__Financial_Journal_Line__c.isCreateable()){insert fjsToInsert;}
            p.redirectURL ='/apex/club62__C62CheckAsPDF?bid='+vicb.id;
            p.severityCode = 'CONFIRM';
            p.messageStr = '';
            vicb.club62__A_P_Trade_Journal_Line__c = tradeJournal.Id;
            vicb.club62__Cash_Financial_Journal_Line__c = cashJournal.Id;
            if(Schema.sObjectType.club62__Vendor_Invoice_Check_Batch__c.isUpdateable()){update vicb;}
            vicb = new club62__Vendor_Invoice_Check_Batch__c();
            vicb.club62__Batch_Date__c = Date.Today();
            //cancelBatch();
            //checkPreview = false;
        }else{
            //p = new PageReference('/apex/club62__C62CheckAsPDF');
            //checkPreview = true;
            //p.setRedirect(false);
            //vicPreviewMap.putAll(vicList);
            p.severityCode = 'CONFIRM';
            p.messageStr = '';
        }
        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Confirm,'Checks Created'));

        /*return p;*/
        List<remotingReturnResponse> rrrLst = new List<remotingReturnResponse>();
        rrrLst.add(p);
        return rrrLst;
    }
    //Generate the checks from the selected Invoices
    public PageReference generateChecks(Boolean doInsert){
        Map<Id,club62__Vendor_Invoice_Check__c> vicList = new Map<Id,club62__Vendor_Invoice_Check__c>();
        List<club62__Vendor_Invoice_Payment__c> invoicePaymentsToUpdate = new List<club62__Vendor_Invoice_Payment__c>();
        Set<club62__Vendor_Invoice__c> invoicesToUpdate = new Set<club62__Vendor_Invoice__c>();
        Set<club62__Refund__c> refToUpdate = new Set<club62__Refund__c>();
        Set<club62__Vendor_Invoice_Line__c> invoiceLinesToUpdate = new Set<club62__Vendor_Invoice_Line__c>();
        vipPreviewMap = new Map<Id,List<club62__Vendor_Invoice_Payment__c>>();
        vicPreviewMap = new Map<Id,club62__Vendor_Invoice_Check__c>();
        vicb.Club62__Location__c = locationSelection.Club62__Location__c;
        if(doInsert == true){
            if(Schema.sObjectType.club62__Vendor_Invoice_Check_Batch__c.isCreateable()){insert vicb;}
        }

        Decimal totalCheckAmount = 0;
        List<club62__Financial_Journal_Line__c> fjsToInsert = new List<club62__Financial_Journal_Line__c>();
        for(VendorInvoiceWrapper viw : viwMap.values()){
            if(viw.selected == true && viw.vi!=null){

                if(!vicList.containsKey(viw.vi.club62__Vendor__c)){
                    club62__Vendor_Invoice_Check__c vic = new club62__Vendor_Invoice_Check__c();
                    vic.club62__Amount__c = viw.amounttopay;
                    vic.club62__Check_Date__c = vicb.club62__Batch_Date__c;
                    vic.club62__Check_Number__c = (nextCheckNumber+'').replaceAll(',','');
                    vic.club62__Paid_Manually__c = paidManually;
                    String tempCheck = '';
                    for(Integer i = vic.club62__Check_Number__c.length();i<checkRun.club62__Printed_Check_Digits__c;i++){
                        tempCheck +='0';
                    }
                    vic.club62__Check_Number__c=tempCheck+vic.club62__Check_Number__c;
                    vic.club62__Vendor_Invoice_Check_Batch__c = vicb.id;
                    vic.club62__Vendor__c = viw.vi.club62__Vendor__c;
                    nextCheckNumber++;
                    vicList.put(viw.vi.club62__Vendor__c,vic);
                }else{
                    vicList.get(viw.vi.club62__Vendor__c).club62__amount__c+=viw.amounttopay;
                }
                totalCheckAmount+=viw.amounttopay;
            }
        }
        //On Hold Checks
        for(VendorInvoiceWrapper viw : viwHoldMap.values()){
            if(viw.selected == true && viw.vi!=null){

                if(!vicList.containsKey(viw.vi.club62__Vendor__c)){
                    club62__Vendor_Invoice_Check__c vic = new club62__Vendor_Invoice_Check__c();
                    vic.club62__Amount__c = viw.amounttopay;
                    vic.club62__Check_Date__c = vicb.club62__Batch_Date__c;
                    vic.club62__Check_Number__c = (nextCheckNumber+'').replaceAll(',','');
                    vic.club62__Paid_Manually__c = paidManually;
                    String tempCheck = '';
                    for(Integer i = vic.club62__Check_Number__c.length();i<checkRun.club62__Printed_Check_Digits__c;i++){
                        tempCheck +='0';
                    }
                    vic.club62__Check_Number__c=tempCheck+vic.club62__Check_Number__c;
                    vic.club62__Vendor_Invoice_Check_Batch__c = vicb.id;
                    vic.club62__Vendor__c = viw.vi.club62__Vendor__c;
                    nextCheckNumber++;
                    vicList.put(viw.vi.club62__Vendor__c,vic);
                }else{
                    vicList.get(viw.vi.club62__Vendor__c).club62__amount__c+=viw.amounttopay;
                }
                totalCheckAmount+=viw.amounttopay;
            }
        }
        for(VendorInvoiceWrapper viw : viwMap.values()){
            if(viw.vi==null){
                if(vicList.containsKey(viw.vendor)){
                    if(vicList.get(viw.vendor).club62__Memo__c==null || vicList.get(viw.vendor).club62__Memo__c==''){
                        vicList.get(viw.vendor).club62__Memo__c=viw.memo;
                    }
                    if(vicList.get(viw.vendor).club62__Total_Amount__c==null){
                        vicList.get(viw.vendor).club62__Total_Amount__c = '0';
                    }
                    if(viw.TotalAmount==null || viw.totalAmount==''){
                        viw.totalAmount='0';
                    }
                    vicList.get(viw.vendor).club62__Total_Amount__c = Integer.valueOf(viw.totalAmount) + Integer.valueOf(vicList.get(viw.vendor).club62__Total_Amount__c) +'';
                }
            }
        }
        for(VendorInvoiceWrapper viw : viwHoldMap.values()){
            if(viw.vi==null){
                if(vicList.containsKey(viw.vendor)){
                    if(vicList.get(viw.vendor).club62__Memo__c==null || vicList.get(viw.vendor).club62__Memo__c==''){
                        vicList.get(viw.vendor).club62__Memo__c=viw.memo;
                    }
                    if(vicList.get(viw.vendor).club62__Total_Amount__c==null){
                        vicList.get(viw.vendor).club62__Total_Amount__c = '0';
                    }
                    if(viw.TotalAmount==null || viw.totalAmount==''){
                        viw.totalAmount='0';
                    }
                    vicList.get(viw.vendor).club62__Total_Amount__c = Integer.valueOf(viw.totalAmount) + Integer.valueOf(vicList.get(viw.vendor).club62__Total_Amount__c)+ '';
                }
            }
        }
        if(doInsert==true){
            if(Schema.sObjectType.club62__Vendor_Invoice_Check__c.isCreateable()){insert vicList.values();}
        }
        /*vendorCheckIds = new Set<Id>();
        for(club62__Vendor_Invoice_Check__c vic : vicList.values()){
            vendorCheckIds.add(vic.id);
        }*/

        checkRun.club62__Next_Check_Number__c = nextCheckNumber;
        if(doInsert == true && Schema.sObjectType.club62__Check_Run__c.isUpdateable()){update checkRun;}

        for(VendorInvoiceWrapper viw : viwMap.values()){
            Decimal viAmountAvailable = viw.amountToPay;
            //Map<Id,Decimal> VILRemaining = new Map<Id,Decimal>();
            if(viw.selected==true){
                if(viw.vi!=null){
                    for(club62__Vendor_Invoice_Payment__c vip : viw.vipList){
                        Decimal amt = vip.club62__Amount__c-vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c;
                        /*if(!VILRemaining.containsKey(vip.club62__Vendor_Invoice_Line__c)){
                            VILRemaining.put(vip.club62__Vendor_Invoice_Line__c,vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c);
                        }
                        if(VILRemaining.get(vip.club62__Vendor_Invoice_Line__c)>=amt){
                            continue;
                        }*/
                        boolean assignCheck = false;
                        //We have plenty of money to cover this VIP
                        if(viAmountAvailable>=amt){
                            viAmountAvailable -= amt;
                            vip.club62__Amount_Paid__c = amt;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                            invoicePaymentsToUpdate.add(vip);
                            assignCheck = true;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                        }else{
                            //We didn't have enough money to cover the whole thing
                            vip.club62__Amount_Paid__c = viAmountAvailable;
                            viAmountAvailable -= amt;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                            //Create a new line so we can pay off the remaining balance
                            invoicePaymentsToUpdate.add(new club62__Vendor_Invoice_Payment__c(club62__Vendor_Invoice__c=vip.club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__c=vip.club62__Vendor_Invoice_Line__c,club62__Amount_Paid__c=0));
                            invoicePaymentsToUpdate.add(vip);
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                        }
                        if(assignCheck){

                            club62__Vendor_Invoice__c vi = new club62__Vendor_Invoice__c(id=vip.club62__Vendor_Invoice__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vi.club62__Vendor__c).id);
                            invoicesToUpdate.add(vi);
                            club62__Vendor_Invoice_Line__c vil = new club62__Vendor_Invoice_Line__c(id=vip.club62__Vendor_Invoice_Line__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vi.club62__Vendor__c).id);
                            invoiceLinesToUpdate.add(vil);
                            if(vip.club62__Refund__c!=null){
                                club62__Refund__c ref = new club62__Refund__c(id=vip.club62__Refund__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vi.club62__Vendor__c).id);
                                refToUpdate.add(ref);
                            }
                        }
                        if(!vipPreviewMap.containsKey(viw.vi.club62__Vendor__c)){
                            vipPreviewMap.put(viw.vi.club62__Vendor__c,new List<club62__Vendor_Invoice_Payment__c>());
                        }
                        vipPreviewMap.get(viw.vi.club62__Vendor__c).add(vip);
                        if(viAmountAvailable<=0){
                            break;
                        }
                    }
                }
            }
        }
        //Hold List
        for(VendorInvoiceWrapper viw : viwHoldMap.values()){
            Decimal viAmountAvailable = viw.amountToPay;
            //Map<Id,Decimal> VILRemaining = new Map<Id,Decimal>();
            if(viw.selected==true){
                if(viw.vi!=null){
                    for(club62__Vendor_Invoice_Payment__c vip : viw.vipList){
                        Decimal amt = vip.club62__Amount__c-vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c;
                        /*if(!VILRemaining.containsKey(vip.club62__Vendor_Invoice_Line__c)){
                            VILRemaining.put(vip.club62__Vendor_Invoice_Line__c,vip.club62__Vendor_Invoice_Line__r.club62__Amount_Sent__c);
                        }
                        if(VILRemaining.get(vip.club62__Vendor_Invoice_Line__c)>=amt){
                            continue;
                        }*/
                        boolean assignCheck = false;
                        //We have plenty of money to cover this VIP
                        if(viAmountAvailable>=amt){
                            viAmountAvailable -= amt;
                            vip.club62__Amount_Paid__c = amt;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                            invoicePaymentsToUpdate.add(vip);
                            assignCheck = true;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                        }else{
                            //We didn't have enough money to cover the whole thing
                            vip.club62__Amount_Paid__c = viAmountAvailable;
                            viAmountAvailable -= amt;
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                            //Create a new line so we can pay off the remaining balance
                            invoicePaymentsToUpdate.add(new club62__Vendor_Invoice_Payment__c(club62__Vendor_Invoice__c=vip.club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__c=vip.club62__Vendor_Invoice_Line__c,club62__Amount_Paid__c=0));
                            invoicePaymentsToUpdate.add(vip);
                            vip.club62__Vendor_Invoice_Check__c = vicList.get(viw.vi.club62__Vendor__c).id;
                        }
                        if(assignCheck){

                            club62__Vendor_Invoice__c vi = new club62__Vendor_Invoice__c(id=vip.club62__Vendor_Invoice__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vi.club62__Vendor__c).id);
                            invoicesToUpdate.add(vi);
                            club62__Vendor_Invoice_Line__c vil = new club62__Vendor_Invoice_Line__c(id=vip.club62__Vendor_Invoice_Line__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vi.club62__Vendor__c).id);
                            invoiceLinesToUpdate.add(vil);
                            if(vip.club62__Refund__c!=null){
                                club62__Refund__c ref = new club62__Refund__c(id=vip.club62__Refund__c,club62__Vendor_Invoice_Check__c=vicList.get(viw.vi.club62__Vendor__c).id);
                                refToUpdate.add(ref);
                            }
                        }


                        if(viAmountAvailable<=0){
                            break;
                        }
                    }
                }
            }
        }

        if(doInsert == true && Schema.sObjectType.club62__Vendor_Invoice_Payment__c.isUpdateable() && Schema.sObjectType.club62__Vendor_Invoice_Payment__c.isCreateable()){upsert invoicePaymentsToUpdate;}
        if(doInsert == true && Schema.sObjectType.club62__Vendor_Invoice__c.isUpdateable()){update new List<club62__Vendor_Invoice__c>(invoicesToUpdate);}
        if(doInsert == true && Schema.sObjectType.club62__Refund__c.isUpdateable()){update new List<club62__Refund__c>(refToUpdate);}
        if(doInsert == true && Schema.sObjectType.club62__Vendor_Invoice_Line__c.isUpdateable()){update new List<club62__Vendor_Invoice_Line__c>(invoiceLinesToUpdate);}
        PageReference p = null;
        if(doInsert == true){
            club62__Financial_Account__c tradeAccount = [Select id from club62__Financial_Account__c where club62__A_P_Trade__c = true and club62__Location__c=:locationSelection.Location__c limit 1];
            club62__Financial_Journal_Entry__c fjEntry = new club62__Financial_Journal_Entry__c();
            vicb = [Select Name,club62__Batch_Date__c from club62__Vendor_Invoice_Check_Batch__c where Id=:vicb.Id limit 1];
            fjEntry.club62__Description__c = 'Invoice Check Batch '+vicb.Name;
            fjEntry.club62__Entry_Date__c = vicb.club62__Batch_Date__c;
            fjEntry.club62__Posted__c = true;
            fjEntry.club62__Post_Date__c = vicb.club62__Batch_Date__c;
            if(Schema.sObjectType.club62__Financial_Journal_Entry__c.isCreateable()){insert fjEntry;}
            club62__Financial_Journal_Line__c tradeJournal = new club62__Financial_Journal_Line__c();
            tradeJournal.club62__Amount__c = -totalCheckAmount;
            tradeJournal.club62__Description__c = 'Invoice Check Batch '+vicb.Name;
            tradeJournal.club62__Financial_Account__c=tradeAccount.Id;
            tradeJournal.club62__Financial_Journal_Entry__c = fjEntry.Id;
            tradeJournal.club62__Post_Date__c = vicb.club62__Batch_Date__c;
            tradeJournal.club62__Posted__c = true;
            tradeJournal.club62__Transaction_Date__c = vicb.club62__Batch_Date__c;
            club62__Financial_Journal_Line__c cashJournal = new club62__Financial_Journal_Line__c();
            cashJournal.club62__Amount__c = -totalCheckAmount;
            cashJournal.club62__Description__c = 'Invoice Check Batch '+vicb.Name;
            cashJournal.club62__Financial_Account__c=operatingChecks.Id;
            cashJournal.club62__Financial_Journal_Entry__c = fjEntry.Id;
            cashJournal.club62__Post_Date__c = vicb.club62__Batch_Date__c;
            cashJournal.club62__Posted__c = true;
            cashJournal.club62__Transaction_Date__c = vicb.club62__Batch_Date__c;
            fjsToInsert.add(tradeJournal);
            fjsToInsert.add(cashJournal);
            if(Schema.sObjectType.club62__Financial_Journal_Line__c.isCreateable()){insert fjsToInsert;}
            p = new PageReference('/apex/club62__C62CheckAsPDF?bid='+vicb.id);
            p.setRedirect(false);
            vicb.club62__A_P_Trade_Journal_Line__c = tradeJournal.Id;
            vicb.club62__Cash_Financial_Journal_Line__c = cashJournal.Id;
            if(Schema.sObjectType.club62__Vendor_Invoice_Check_Batch__c.isUpdateable()){update vicb;}
            vicb = new club62__Vendor_Invoice_Check_Batch__c();
            vicb.club62__Batch_Date__c = Date.Today();
            cancelBatch();
            checkPreview = false;
        }else{
            p = new PageReference('/apex/club62__C62CheckAsPDF');
            checkPreview = true;
            p.setRedirect(false);
            vicPreviewMap.putAll(vicList);
        }
        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Confirm,'Checks Created'));

        return p;

    }
    public void getPrintCheckListPreview(){
        printedCheckVIMap = new Map<Id,List<club62__Vendor_Invoice__c>>();
        printedCheckVCList = new List<club62__Vendor_Invoice_Check__c>();
        printedCheckAmountWordsMap = new Map<Id,String>();
        printedCheckAmountSentMap = new Map<Id,Decimal>();
        printedCheckFJLMap = new Map<Id,Map<Id,FinancialJournalLineWrapper>>();
        printedCheckNumberOfInvoicesMap = new Map<Id,Integer>();
        checkPreview = true;

        //Map<club62__Vendor_Invoice_Check__c,List<club62__Vendor_Invoice__c>> vicViMap = new Map<club62__Vendor_Invoice_Check__c,List<club62__Vendor_Invoice__c>>();
        Set<Id> viId = new Set<Id>();
        Set<Id> vilIds = new Set<Id>();
        Set<Id> venIds = new Set<Id>();
        for(List<club62__Vendor_Invoice_Payment__c> vipL : vipPreviewMap.values()){
            for(club62__Vendor_Invoice_Payment__c vip : vipL){
                vilIds.add(vip.club62__Vendor_Invoice_Line__c);
            }
        }
        for(club62__Vendor_Invoice_Check__c vic : vicPreviewMap.values()){
            venIds.add(vic.club62__Vendor__c);
        }
        Map<Id,club62__Vendor_Invoice_Line__c> vilPreviewMap= new Map<Id,club62__Vendor_Invoice_Line__c>([Select id,club62__Financial_Account__c,club62__Financial_Account__r.Name,club62__Financial_Account__r.club62__Account_Number__c from club62__Vendor_Invoice_Line__c where Id in :vilIds]);
        venPreviewMap = new Map<Id,club62__Vendor__c>([select id,Name, club62__Payment_Address__c,
                club62__Payment_City__c, club62__Payment_Country__c, club62__Payment_State__c,
                club62__Payment_Postal_Code__c, club62__Physical_Address__c,
                club62__Physical_City__c, club62__Physical_Country__c, club62__Physical_State__c,
                club62__Physical_Postal_Code__c from club62__Vendor__c where id in :venIds]);
        for(club62__Vendor_Invoice_Check__c vic : vicPreviewMap.values()){
            Set<Id> viIdForCheck = new Set<Id>();
            //vicViMap.put(vic,vic.club62__Vendor_Invoices__r);
            //printedCheckVIMap.put(vic.Id,vic.club62__Vendor_Invoices__r);
            printedCheckAmountWordsMap.put(vic.vendor__c,checkAmountToWords(vic.club62__Amount__c));
            printedCheckVCList.add(vic);
            if(!printedCheckFJLMap.containsKey(vic.club62__Vendor__c)){
                printedCheckFJLMap.put(vic.club62__Vendor__c,new Map<Id,FinancialJournalLineWrapper>());
            }
            if(!printedCheckNumberOfInvoicesMap.containsKey(vic.club62__Vendor__c)){
                printedCheckNumberOfInvoicesMap.put(vic.club62__Vendor__c,0);
            }
            for(club62__Vendor_Invoice_Payment__c vi : vipPreviewMap.get(vic.club62__Vendor__c)){
                if(!printedCheckAmountSentMap.containsKey(vi.club62__Vendor_Invoice__c)){
                    printedCheckAmountSentMap.put(vi.club62__Vendor_Invoice__c,0);
                }
                printedCheckAmountSentMap.put(vi.club62__Vendor_Invoice__c,printedCheckAmountSentMap.get(vi.club62__Vendor_Invoice__c)+vi.club62__Amount_Paid__c);
                if(!viIdForCheck.contains(vi.club62__Vendor_Invoice__c)){
                    printedCheckNumberOfInvoicesMap.put(vic.club62__Vendor__c,printedCheckNumberOfInvoicesMap.get(vic.club62__Vendor__c)+1);
                }
                viIdForCheck.add(vi.club62__Vendor_Invoice__c);
                viId.add(vi.club62__Vendor_Invoice__c);

                if(!printedCheckFJLMap.get(vic.Vendor__c).containsKey(vilPreviewMap.get(vi.club62__Vendor_Invoice_Line__c).club62__Financial_Account__c)){
                    printedCheckFJLMap.get(vic.Vendor__c).put(vilPreviewMap.get(vi.club62__Vendor_Invoice_Line__c).club62__Financial_Account__c,new FinancialJournalLineWrapper(vilPreviewMap.get(vi.club62__Vendor_Invoice_Line__c).club62__Financial_Account__r.Name,vilPreviewMap.get(vi.club62__Vendor_Invoice_Line__c).club62__Financial_Account__r.club62__Account_Number__c));
                }

                printedCheckFJLMap.get(vic.Vendor__c).get(vilPreviewMap.get(vi.club62__Vendor_Invoice_Line__c).club62__Financial_Account__c).accTotal += vi.club62__Amount_Paid__c;

            }
        }/**/
        Map<Id,club62__Vendor_Invoice__c> vilMap = new Map<Id,club62__Vendor_Invoice__c>([Select Id, Name, club62__Amount__c, club62__Invoice_Date__c, club62__Invoice_Number__c,
                club62__Include_Notes_on_Check__c, club62__Notes__c, club62__PO_Number__c,club62__Amount_Remaining__c
                from club62__Vendor_Invoice__c where Id in:viId]);
        for(club62__Vendor_Invoice_Check__c vic :vicPreviewMap.values()){
            if(!printedCheckVIMap.containsKey(vic.club62__Vendor__c)){
                printedCheckVIMap.put(vic.club62__Vendor__c,new List<club62__Vendor_Invoice__c>());
            }
            Set<ID> viIds = new Set<Id>();
            for(club62__Vendor_Invoice_Payment__c vil : vipPreviewMap.get(vic.club62__Vendor__c)){
                if(!viIds.contains(vil.club62__Vendor_Invoice__c)){
                    printedcheckvimap.get(vic.club62__Vendor__c).add(vilMap.get(vil.club62__Vendor_Invoice__c));
                    viIds.add(vil.club62__Vendor_Invoice__c);
                }
            }
        }/**/
    }
    public void getprintCheckList(){
        String batchid = ApexPages.currentPage().getparameters().get('bid');
        checkPreview = false;
        if((batchId==null || batchId=='')|| checkPreview==true){
            getprintCheckListPreview();
            return;
        }
        printedCheckVIMap = new Map<Id,List<club62__Vendor_Invoice__c>>();
        printedCheckVCList = new List<club62__Vendor_Invoice_Check__c>();
        printedCheckAmountWordsMap = new Map<Id,String>();
        printedCheckAmountSentMap = new Map<Id,Decimal>();
        printedCheckFJLMap = new Map<Id,Map<Id,FinancialJournalLineWrapper>>();
        printedCheckNumberOfInvoicesMap = new Map<Id,Integer>();
        List<club62__Vendor_Invoice_Check__c> checkVICList = [Select club62__Vendor__c, club62__Vendor__r.Name, club62__Total_Amount__c, club62__Amount__c, club62__Check_Date__c,
                club62__Check_Number__c, club62__Memo__c, club62__Vendor__r.club62__Payment_Address__c,
                club62__Vendor__r.club62__Payment_City__c, club62__Vendor__r.club62__Payment_Country__c, club62__Vendor__r.club62__Payment_State__c,
                club62__Vendor__r.club62__Payment_Postal_Code__c, club62__Vendor__r.club62__Physical_Address__c,
                club62__Vendor__r.club62__Physical_City__c, club62__Vendor__r.club62__Physical_Country__c, club62__Vendor__r.club62__Physical_State__c,
                club62__Vendor__r.club62__Physical_Postal_Code__c,
                (Select Id, club62__Amount_Paid__c,club62__Refund__c,club62__Vendor_Invoice__c,club62__Vendor_Invoice_Line__r.club62__Financial_Account__c,club62__Vendor_Invoice_Line__r.club62__Financial_Account__r.Name,club62__Vendor_Invoice_Line__r.club62__Financial_Account__r.club62__Account_Number__c
                from club62__Vendor_Invoice_Payments__r)
                from club62__Vendor_Invoice_Check__c where club62__Vendor_Invoice_Check_Batch__c=:batchid order by club62__Check_Number__c ASC];

        //Map<club62__Vendor_Invoice_Check__c,List<club62__Vendor_Invoice__c>> vicViMap = new Map<club62__Vendor_Invoice_Check__c,List<club62__Vendor_Invoice__c>>();
        Set<Id> viId = new Set<Id>();
        Integer i=0;
        for(club62__Vendor_Invoice_Check__c vic : checkVICList){
            Set<Id> viIdForCheck = new Set<Id>();
            //vicViMap.put(vic,vic.club62__Vendor_Invoices__r);
            //printedCheckVIMap.put(vic.Id,vic.club62__Vendor_Invoices__r);
            printedCheckAmountWordsMap.put(vic.Id,checkAmountToWords(vic.club62__Amount__c));
            if(i==0){
                System.debug(vic.club62__Amount__c);
                System.debug(checkAmountToWords(vic.club62__Amount__c));
            }
            i++;
            printedCheckVCList.add(vic);
            if(!printedCheckFJLMap.containsKey(vic.Id)){
                printedCheckFJLMap.put(vic.Id,new Map<Id,FinancialJournalLineWrapper>());
            }
            if(!printedCheckNumberOfInvoicesMap.containsKey(vic.Id)){
                printedCheckNumberOfInvoicesMap.put(vic.Id,0);
            }
            for(club62__Vendor_Invoice_Payment__c vi : vic.club62__Vendor_Invoice_Payments__r){
                if(!printedCheckAmountSentMap.containsKey(vi.club62__Vendor_Invoice__c)){
                    printedCheckAmountSentMap.put(vi.club62__Vendor_Invoice__c,0);
                }
                if (vi.club62__Amount_Paid__c != null) {
                	printedCheckAmountSentMap.put(vi.club62__Vendor_Invoice__c,printedCheckAmountSentMap.get(vi.club62__Vendor_Invoice__c)+vi.club62__Amount_Paid__c);
                }
                if(!viIdForCheck.contains(vi.club62__Vendor_Invoice__c)){
                    printedCheckNumberOfInvoicesMap.put(vic.Id,printedCheckNumberOfInvoicesMap.get(vic.Id)+1);
                }
                viIdForCheck.add(vi.club62__Vendor_Invoice__c);
                viId.add(vi.club62__Vendor_Invoice__c);

                if(!printedCheckFJLMap.get(vic.Id).containsKey(vi.club62__Vendor_Invoice_Line__r.club62__Financial_Account__c)){
                    printedCheckFJLMap.get(vic.Id).put(vi.club62__Vendor_Invoice_Line__r.club62__Financial_Account__c,new FinancialJournalLineWrapper(vi.club62__Vendor_Invoice_Line__r.club62__Financial_Account__r.Name,vi.club62__Vendor_Invoice_Line__r.club62__Financial_Account__r.club62__Account_Number__c));
                }

                if (vi.club62__Amount_Paid__c != null) {
                	printedCheckFJLMap.get(vic.Id).get(vi.club62__Vendor_Invoice_Line__r.club62__Financial_Account__c).accTotal += vi.club62__Amount_Paid__c;
                }
            }
        }
        Map<Id,club62__Vendor_Invoice__c> vilMap = new Map<Id,club62__Vendor_Invoice__c>([Select Id, Name, club62__Amount__c, club62__Invoice_Date__c, club62__Invoice_Number__c,
                club62__Include_Notes_on_Check__c, club62__Notes__c, club62__PO_Number__c,club62__Amount_Remaining__c
                from club62__Vendor_Invoice__c where Id in:viId]);
        for(club62__Vendor_Invoice_Check__c vic :checkVICList){
            printedCheckVIMap.put(vic.Id,new List<club62__Vendor_Invoice__c>());
            Set<ID> viIds = new Set<Id>();
            for(club62__Vendor_Invoice_Payment__c vil : vic.club62__Vendor_Invoice_Payments__r){
                if(!viIds.contains(vil.club62__Vendor_Invoice__c)){
                    printedcheckvimap.get(vic.Id).add(vilMap.get(vil.club62__Vendor_Invoice__c));
                    viIds.add(vil.club62__Vendor_Invoice__c);
                }
            }
        }
        /*viCheckMap = new Map<Id,club62__Vendor_Invoice__c>([Select id,(Select id, club62__Financial_Account__c,
                        club62__Financial_Account__r.Name, club62__Financial_Account__r.club62__Account_Number__c,
                        club62__Description__c, club62__Amount__c,club62__Amount_Sent__c
                        from club62__Vendor_Invoice_Lines__r) from club62__Vendor_Invoice__c where id in:viId]);
        */
        //return vicViMap;
    }
    public String checkAmountToWords(Decimal amount){
        List<String> th = new List<String>{'','Thousand','Million', 'Billion','Trillion'};
        List<String> dg = new List<String>{'Zero','One','Two','Three','Four', 'Five','Six','Seven','Eight','Nine'};
        List<String> tn = new List<String>{'Ten','Eleven','Twelve','Thirteen', 'Fourteen','Fifteen','Sixteen', 'Seventeen','Eighteen','Nineteen'};
        List<String> tw = new List<String>{'Twenty','Thirty','Forty','Fifty', 'Sixty','Seventy','Eighty','Ninety'};
      // Converts Numbers, given as a String, into Words
        String amtString = amount+'';
        amtString = amtString.replace(',','').replace(' ','');
        system.debug(amtString);
        Integer x = amtString.indexOf('.');
        if (x == -1) x = amtString.length();
        if (x > 15) return 'too big';
        List<String> n = amtString.split('');
        n.remove(0);
        system.debug(n);
        String str = '';
        Integer sk = 0;
        for (Integer i=0; i < x; i++)
        {
            system.debug('1');
            if (Math.Mod((x-i),3)==2)
            {
                if (n[i] == '1')
                {
                    str += tn[Integer.valueOf(n[i+1])] + ' ';
                    i++;
                    sk=1;
                    }
                    else if (Integer.valueOf(n[i])!=0)
                    {
                        str += tw[Integer.valueOf(n[i])-2] + ' ';
                        sk=1;
                    }
                }
                else if (Integer.valueOf(n[i])!=0)
                {
                    str += dg[Integer.valueOf(n[i])] +' ';
                    if (Math.mod((x-i),3)==0) str += 'Hundred ';
                    sk=1;
                }

                if (Math.mod((x-i),3)==1)
                {
                    if (sk == 1) str += th[(x-i-1)/3] + ' ';
                    sk=0;
                }
            }
            if (x != amtString.length())
            {
                str += '& ';
                if(Integer.valueOf(amtString.substring( ( amtString.length() - 1 ) ))<=9){
                    //str += '0';
                }
                str += amtString.substring( ( amtString.length() - 2 ) ) + ' Cents ';
            }
        return str;
    }
    public void selectInvoice(){
        if(selectedVendor!=null){
            if(viwVendorMap.containsKey(selectedVendor)){
                if(selectedInvoice!=null){
                    if(viwMap.containsKey(selectedInvoice)){
                        viwMap.get(selectedInvoice).amountToPay = viwMap.get(selectedInvoice).amount;
                    }else if(viwHoldMap.containsKey(selectedInvoice)){
                        viwHoldMap.get(selectedInvoice).amountToPay = viwHoldMap.get(selectedInvoice).amount;
                    }
                }
            }else if(viwHoldVendorMap.containsKey(selectedVendor)){
                if(selectedInvoice!=null){
                    if(viwHoldMap.containsKey(selectedInvoice)){
                        viwHoldMap.get(selectedInvoice).amountToPay = viwHoldMap.get(selectedInvoice).amount;
                    }
                }
            }
        }
        reCalcTotal();
    }

    //Recalc total amount
    public void reCalcTotal(){
        payingAmount = 0.00;
        payingHoldAmount = 0.00;
        numOfSelChecks = 0;
        numOfSelHoldChecks = 0;
        Set<Id> venId = new Set<Id>();
        Set<Id> venHoldId = new Set<Id>();
        Map<Id,Decimal> venSumAmount = new Map<Id,Decimal>();
        Map<Id,Decimal> venHoldSumAmount = new Map<Id,Decimal>();
        for(VendorInvoiceWrapper viw : viwMap.values()){
            viw.checkRunAmount = 0.00;
        }
        for(VendorInvoiceWrapper viw : viwHoldMap.values()){
            viw.checkRunAmount = 0.00;
        }
        for(VendorInvoiceWrapper viw : viwMap.values()){
            if(viw.selected==true && viw.vi!=null){
                if((viw.amount>0 && (viw.amountToPay>viw.amount || viw.amountToPay<0))|| (viw.amount<0 && (viw.amountToPay<viw.amount || viw.amountToPay>0))){
                    viw.amountToPay = viw.amount;
                }
                if(viw.amountToPay == 0){
                    viw.amountToPay = viw.amount;
                }
                payingAmount+=viw.amountToPay;
                venId.add(viw.vi.club62__Vendor__c);
                if(!venSumAmount.containsKey(viw.vi.club62__Vendor__c)){
                    venSumAmount.put(viw.vi.club62__Vendor__c,viw.amounttopay);
                }else{
                    venSumAmount.put(viw.vi.club62__Vendor__c,venSumAmount.get(viw.vi.club62__Vendor__c)+viw.amounttopay);
                }
            }
        }

        //Checks On Hold
        for(VendorInvoiceWrapper viw : viwHoldMap.values()){
            if(viw.selected==true && viw.vi!=null){
                if(viw.amountToPay>viw.amount){
                    viw.amountToPay = viw.amount;
                }
                if(viw.amountToPay == 0){
                    viw.amountToPay = viw.amount;
                }
                payingHoldAmount+=viw.amountToPay;
                venHoldId.add(viw.vi.club62__Vendor__c);
                if(!venHoldSumAmount.containsKey(viw.vi.club62__Vendor__c)){
                    venHoldSumAmount.put(viw.vi.club62__Vendor__c,viw.amounttopay);
                }else{
                    venHoldSumAmount.put(viw.vi.club62__Vendor__c,venHoldSumAmount.get(viw.vi.club62__Vendor__c)+viw.amounttopay);
                }
            }
        }
        for(Id vid : venSumAmount.keySet()){
            viwMap.get(vid).checkRunAmount=venSumAmount.get(vid);
        }
        for(Id vid : venHoldSumAmount.keySet()){
            viwHoldMap.get(vid).checkRunAmount=venHoldSumAmount.get(vid);
        }
        numOfSelChecks = venId.size();
        numOfSelHoldChecks = venHoldId.size();
    }
    //Select all invoices for vendor
    public void selectAllVendor(){
        if(selectedVendor!=null){
            if(selectAllOnHold=='false'){
                if(viwVendorMap.containsKey(selectedVendor)){
                    Boolean selectedValue = viwMap.get(selectedVendor).selected;
                    for(Id viId : viwVendorMap.get(selectedVendor)){
                        viwMap.get(viId).selected = selectedValue;
                    }

                    reCalcTotal();
                }
            }else if(selectAllOnHold=='true'){
                if(viwHoldVendorMap.containsKey(selectedVendor)){
                    Boolean selectedValue = viwHoldMap.get(selectedVendor).selected;
                    for(Id viId : viwHoldVendorMap.get(selectedVendor)){
                        viwHoldMap.get(viId).selected = selectedValue;
                    }

                    reCalcTotal();
                }
            }
        }
    }
    //Select all vendor invoices
    public void selectAll(){
        if(selectAllOnHold=='false'){
            for(VendorInvoiceWrapper viw : viwMap.values()){
                viw.selected = selectAll;
            }
        }else if(selectAllOnHold == 'true'){
            for(VendorInvoiceWrapper viw : viwHoldMap.values()){
                viw.selected = selectAll;
            }
        }
        reCalcTotal();
    }
    //Get a list of all closed Months within a range
    //Reload which months are open/closed
    public void regenerateClosedMonths(){
        //Calculate which months have closed
        Date startFCDate = Date.newInstance(vicb.club62__Batch_Date__c.year(),vicb.club62__Batch_Date__c.month(),1);
        Date endFCDate = Date.newInstance(vicb.club62__Batch_Date__c.year(), vicb.club62__Batch_Date__c.month(), 1).addMonths(1).addDays(-1);
        List<club62__Financial_Closing__c> fcLst = [Select Id,club62__Month__c,club62__Year__c,club62__Date__c,club62__Closed__c from club62__Financial_Closing__c where club62__Date__c>=:startFCDate and club62__Date__c<=:endFCDate and club62__Closed__c=true];

        closedFCMap = new Set<Date>();
        for(club62__Financial_Closing__c fc : fcLst){
            closedFCMap.add(fc.club62__Date__c);
        }
        //Let user know which months are closed ahead of time.
        closedMonthWarning = '';
        for(Date d : closedFCMap){
            closedMonthWarning+=','+d.month()+'/'+d.year();
        }
        if(closedMonthWarning.length()>0){
            closedMonthWarning = closedMonthWarning.substring(1);
        }
    }
    public Boolean checkClosedMonth(Date d){
        Boolean check = false;
        if(closedFCMap.contains(Date.newInstance(d.year(), 1, d.day()))){
            check = true;
        }
        return check;
    }
    //Check to make sure Batch Date is not in the past or for a closed month
    public void checkBatchDate(){
        if(locationSelection.Club62__Location__c!=null){
            if(locationSelection.club62__Payment_Financial_Account__c!=null){
                regenerateClosedMonths();
                validCheckBatchDate = !checkClosedMonth(vicb.club62__Batch_Date__c);
                if(validCheckBatchDate==false){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal,'Batch Date is within a closed month.'));
                }else{
                    loadPostedInvoices();
                    loadNotPostedInvoices();
                }
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal,'Cash Account is required for check run'));
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal,'Location is required for check run'));
        }
    }
    // Call loadPostedInvoices from the filter fields
    public void filterInvoices(){
        loadPostedInvoices();
        loadNotPostedInvoices();
    }
    //Cancel the current Batch/Start over
    public void cancelBatch(){
        validCheckBatchDate = false;
        vicb.club62__Description__c = '';
        numOfSelChecks = 0;
        numOfSelHoldChecks = 0;
        regenerateClosedMonths();
        selectAll = false;
        viwMap.clear();
        viwHoldMap.clear();
    }

    public class FinancialJournalLineWrapper{
        public String accName{get;set;}
        public String accNum{get;set;}
        public Decimal accTotal{get;set;}
        public FinancialJournalLineWrapper(String accName, String accNum){
            this.accName = accName;
            this.accNum = accNum;
            accTotal = 0;
        }
    }
    //Wrapper class for VendorInvoices
    public class VendorInvoiceWrapper implements Comparable{
        public club62__Vendor_Invoice__c vi{get;set;}
        public List<club62__Vendor_Invoice_Payment__c> vipList{get;set;}
        public Boolean selected{get;set;}
        public String name{get;set;}
        public Decimal amount{get;set;}
        public Decimal amountToPay{get;set;}
        public Decimal checkRunAmount{get;set;}
        public Integer index{get;set;}
        public String memo{get;set;}
        public String vendor{get;set;}
        public String totalAmount{get;set;}

        public VendorInvoiceWrapper(club62__Vendor_Invoice__c vi){
            this.vi = vi;
            vipList = new List<club62__Vendor_Invoice_Payment__c>();
            amount = 0.00;
            amountToPay = 0.00;
            checkRunAmount=0.00;
            name = '';
        }
        public VendorInvoiceWrapper(String n, Decimal a,String v){
            name = n+' Total';
            amount = a;
            checkRunAmount = 0.00;
            amountToPay = 0.00;
            vendor = v;
        }
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            VendorInvoiceWrapper compareToVIW = (VendorInvoiceWrapper)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if(vi!=null && compareToVIW.vi!=null){
                if(vi.club62__Vendor__r.Name<compareToVIW.vi.club62__Vendor__r.Name){
                    returnValue = -1;
                }else{
                    returnValue = 1;
                }
            }else if(vi!=null){
                if(vi.club62__Vendor__r.Name<compareToVIW.name){
                    returnValue = -1;
                }else{
                    returnValue = 1;
                }
            }else if(compareToVIW.vi!=null){
                if(name<compareToVIW.vi.club62__Vendor__r.Name){
                    returnValue = -1;
                }else{
                    returnValue = 1;
                }
            }else{
                if(name<compareToVIW.name){
                    returnValue = -1;
                }else{
                    returnValue = 1;
                }
            }

            return returnValue;
        }
    }
}