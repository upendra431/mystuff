public with sharing class C62VoidVendorInvoiceCheckCtr {
    Id recID;
    public club62__Financial_Journal_Entry__c fe{get;set;}
    public C62VoidVendorInvoiceCheckCtr(ApexPages.StandardController controller){
        recId = controller.getId();
        fe = new club62__Financial_Journal_Entry__c();
        fe.club62__Post_Date__c = Date.today();
        if(recId!=null){
            club62__Vendor_Invoice_Check__c vic = [select Id,club62__void__c from club62__Vendor_Invoice_Check__c where id =:recId];
            //Check was already Voided Return
            if(vic.club62__void__c == true){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL,'This Check has already been voided.'));
            }
        }
    }
    
    public PageReference voidCheck(){
        PageReference pr;
        if(recId!=null){
            club62__Vendor_Invoice_Check__c vic = [select Id,(Select Id from club62__Vendor_Invoice_Payments__r),Name, club62__Amount__c,club62__void__c,club62__Vendor_Invoice_Check_Batch__c,club62__Vendor_Invoice_Check_Batch__r.club62__Cash_Financial_Journal_Line__c,club62__Vendor_Invoice_Check_Batch__r.club62__A_P_Trade_Journal_Line__c from club62__Vendor_Invoice_Check__c where id =:recId];
            //Check was already Voided Return
            if(vic.club62__void__c == true){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL,'This Check has already been voided.'));
                return null;
            }else{
                if(fe.club62__Post_Date__c==null){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL,'Post Date cannot be blank'));
                    return null;
                }
                SavePoint sp = Database.setSavepoint();
                /**
                *Create Reversing Entry
                *Create two Journal Lines to cancel out cash and A/P Trade
                *Clear out the Amount Paid on the Invoice Payment Objects
                *Move Id from Vendor Invoice Check to Voided Check on Payment Objects
                *Set Check Voided Checkbox
                */
                try{
                    Map<Id,club62__Financial_Journal_Line__c> fjlMap = new Map<Id,club62__Financial_Journal_Line__c>([Select Id,club62__Description__c,club62__Financial_Account__c, club62__Amount__c, club62__Location__c from club62__Financial_Journal_Line__c where Id=:vic.club62__Vendor_INvoice_Check_Batch__r.club62__Cash_Financial_Journal_Line__c or Id=:vic.club62__Vendor_Invoice_Check_Batch__r.club62__A_P_Trade_Journal_Line__c]);
                    //Make a new Entry for this void
                    //club62__Financial_Journal_Entry__c fe = new club62__Financial_Journal_Entry__c();
                    fe.club62__Entry_Date__c = fe.club62__Post_Date__c;
                    fe.club62__Posted__c = true;
                    //fe.club62__Post_Date__c = Date.today();
                    fe.club62__Description__c = vic.Name+ ' Check Void';
                    if(Schema.SObjectType.club62__Financial_Journal_Entry__c.isCreateable()){
                        insert fe;
                    }
                    //Create the two FJL's to reverse
                    List<club62__Financial_Journal_Line__c> fjlsToInsert = new List<club62__Financial_Journal_Line__c>();
                    if(fjlMap.containsKey(vic.club62__Vendor_Invoice_Check_Batch__r.club62__Cash_Financial_Journal_Line__c)){
                        club62__Financial_Journal_Line__c cashFJL = fjlMap.get(vic.club62__Vendor_Invoice_Check_Batch__r.club62__Cash_Financial_Journal_Line__c).clone(false,true,false,false);
                        cashFJL.club62__Transaction_Date__c = fe.club62__Post_Date__c;//Date.today();
                        cashFJL.club62__Posted__c = true;
                        cashFJL.club62__Post_Date__c = fe.club62__Post_Date__c;//Date.today();
                        cashFJL.club62__Financial_Journal_Entry__c = fe.Id;
                        Decimal amt = Math.abs(vic.club62__Amount__c);
                        if(cashFJL.club62__Amount__c>=0){
                            amt*=-1;
                        }
                        cashFJL.club62__Amount__c = amt;
                        fjlsToInsert.add(cashFJL);
                    }
                    if(fjlMap.containsKey(vic.club62__Vendor_Invoice_Check_Batch__r.club62__A_P_Trade_Journal_Line__c)){
                        club62__Financial_Journal_Line__c tradeFJL = fjlMap.get(vic.club62__Vendor_Invoice_Check_Batch__r.club62__A_P_Trade_Journal_Line__c).clone(false,true,false,false);
                        tradeFJL.club62__Transaction_Date__c = fe.club62__Post_Date__c;//Date.today();
                        tradeFJL.club62__Posted__c = true;
                        tradeFJL.club62__Post_Date__c = fe.club62__Post_Date__c;//Date.today();
                        tradeFJL.club62__Financial_Journal_Entry__c = fe.Id;
                        Decimal amt = Math.abs(vic.club62__Amount__c);
                        if(tradeFJL.club62__Amount__c>=0){
                            amt*=-1;
                        }
                        tradeFJL.club62__Amount__c = amt;
                        fjlsToInsert.add(tradeFJL);
                    }
                    if(Schema.SObjectType.club62__Financial_Journal_Line__c.isCreateable()){
                        insert fjlsToInsert;
                    }
                    //Clear out the Amount Paid on the Invoice Payment Objects
                    //Move Id from Vendor Invoice Check to Voided Check on Payment Objects
                    if(vic.club62__Vendor_Invoice_Payments__r!=null){
                        for(club62__Vendor_Invoice_Payment__c vip : vic.club62__Vendor_Invoice_Payments__r){
                            vip.club62__Amount_Paid__c = 0;
                            vip.club62__Vendor_Invoice_Check__c = null;
                            vip.club62__Voided_Vendor_Invoice_Check__c = vic.Id;
                        }
                    }
                    if(Schema.SObjectType.club62__Vendor_Invoice_Payment__c.isUpdateable()){
                        update vic.club62__Vendor_Invoice_Payments__r;
                    }
                    //Set Check status to void
                    vic.club62__Void__c = true;
                    vic.club62__Voided_Financial_Journal_Entry__c = fe.id;
                    if(Schema.SObjectType.club62__Vendor_Invoice_Check__c.isUpdateable()){
                        update vic;
                    }
                    return new PageReference('/'+recId);
                }catch(Exception ex){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.FATAL,'This Check has already been voided.'));
                    Database.rollback(sp);
                }
            }
        }
        return pr;
    }
    
    public void doNothing(){}

}