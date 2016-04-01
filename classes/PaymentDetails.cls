@RestResource(urlMapping='/PaymentDetails/*')
global without sharing class PaymentDetails{

    @HttpPost
    global static InvoiceWrapper getPaymentDetails(String invID){
        User thisUser = [select ContactId from User where Id = :UserInfo.getUserId()];
        InvoiceWrapper iw = new InvoiceWrapper();
        iw.payLst = [SELECT Id,Name,club62__Customer__r.FirstName, club62__Customer__r.LastName FROM club62__Payment_Method__c WHERE 
                        club62__Customer__c =: thisUser.ContactId AND club62__Customer__c!=null AND club62__Payment_Type__c='Credit Card' 
                        AND club62__Temporary__c = false AND club62__Inactive__c = false AND (club62__Expiration_Date__c=null 
                        OR (club62__Expiration_Date__c!=null AND club62__Expiration_Date__c>=:Date.Today()))];
        iw.hasRecurringPay = false;
        List<club62__Recurring_Payment__c> recPay = [SELECT ID FROM club62__Recurring_Payment__c WHERE club62__Customer__c=:thisUser.ContactId 
                        AND club62__Customer__c!=null AND club62__Active__c=TRUE];
        if(recPay.size()>0){iw.hasRecurringPay = true;}
        iw.applyToWrapperLst = new List<ApplyToWrapper>();
        Schema.DescribeFieldResult fieldResult = club62__Payment__c.club62__Apply_To__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple){
            if(p.getValue()=='House'){
                ApplyToWrapper wrapper = new ApplyToWrapper();
                wrapper.applyToType = p.getValue();
                wrapper.applyToAmt = 0.00;
                wrapper.amtOwed = 0.00;
                wrapper.payAll = false;
                iw.applyToWrapperLst.add(wrapper);
            }
        }
        if(invID!=null && invID!=''){
            List<club62__Invoice__c> stList = [Select Id, (Select Id from club62__Invoice_Lines__r) from club62__Invoice__c where Id =:invID limit 1];
            Set<Id> statLinesSet = new Set<Id>();
            Set<Id> payIdsSet = new Set<Id>();
            for(club62__Invoice_Line__c invL : stList[0].club62__Invoice_Lines__r){
                statLinesSet.add(invL.Id);
            }
            List<club62__Invoice_Line__c> invLines = [Select Id,club62__Amount__c,club62__Type__c,club62__SubType__c,(Select Id,club62__Amount_Due__c from club62__Transactions__r),(Select Id from club62__Payments__r),(Select Id from club62__Credits__r),(SELECT ID,Name,club62__Amount__c,club62__Refund_History__c 
                            from club62__Refunds__r) from club62__Invoice_Line__c where Id IN :statLinesSet];
            Map<String,Decimal> payTypeMap = new map<String,Decimal>();
            for(club62__Invoice_Line__c invL : invLines){
                if(invL.club62__Type__c!='Payment' && invL.club62__Type__c!='Credit'){
                    //including refund in house because we are forcing user to unapply a payment before refunding so all refund should be count towards house
                    if(invL.club62__Type__c=='House'/* || invL.club62__Type__c=='Refund'*/){
                        if(!payTypeMap.containsKey('House')){
                            payTypeMap.put('House',invL.club62__Amount__c);
                        }else{
                            payTypeMap.put('House',payTypeMap.get('House')+invL.club62__Amount__c);
                        }
                    }
                    if(invL.club62__Type__c=='Adjustment'){
                        String dueType = 'House';
                        if(!payTypeMap.containsKey(dueType)){
                            payTypeMap.put(dueType,invL.club62__Amount__c); 
                        }else{
                            payTypeMap.put(dueType,payTypeMap.get(dueType)+invL.club62__Amount__c);
                        }
                    }
                    if(invL.club62__Type__c.contains('Carry Forward')){
                        String payType = invL.club62__Type__c.replace('Carry Forward','').trim();
                        if(!payTypeMap.containsKey(payType)){
                            payTypeMap.put(payType,invL.club62__Amount__c);
                        }else{
                            payTypeMap.put(payType,payTypeMap.get(payType)+invL.club62__Amount__c);
                        }
                    }
                    
                    if(invL.club62__Type__c=='Refund'){
                        Decimal houseAMTRef = invL.club62__Amount__c;
                        if(houseAMTRef!=null && houseAMTRef>0){
                            if(!payTypeMap.containsKey('House')){ payTypeMap.put('House',houseAMTRef); }else{ payTypeMap.put('House',payTypeMap.get('House')+houseAMTRef); }
                        }
                    }
                }else{
                    //this need to be done to deduct amount for carry forward lines if paid
                    for(club62__Payment__c pay : invL.club62__Payments__r){
                        payIdsSet.add(pay.Id);
                    }
                    for(club62__Credit__c cred : invL.club62__Credits__r){
                        payIdsSet.add(cred.Id);
                    }
                }
            }
            if(payIdsSet.size()>0){
                List<club62__Payment__c> payLst = [Select Id,club62__Amount__c,club62__Amount_Remaining__c,(Select Id,club62__Amount_Applied__c,club62__Amount_Refunded__c From club62__AR_Payments__r),(Select Id,club62__Amount_Paid__c From club62__Transactions__r) From club62__Payment__c Where Id IN :payIdsSet];
                List<club62__Credit__c> credLst = [Select Id,club62__Amount__c,club62__Amount_Remaining__c,(Select Id,club62__Amount_Applied__c,club62__Amount_Refunded__c 
                    From club62__AR_Payments__r) From club62__Credit__c Where Id IN :payIdsSet];
                for(club62__Payment__c pay : payLst){
                    Decimal payAppAmount = pay.club62__Amount__c;
                    if(!payTypeMap.containsKey('House')){ payTypeMap.put('House',0.00); }
                    if(payTypeMap.containsKey('House') && payAppAmount>0){ payTypeMap.put('House',payTypeMap.get('House')-payAppAmount); }
                }
                for(club62__Credit__c cred : credLst){
                    Decimal creditAmt = cred.club62__Amount__c;
                    if(!payTypeMap.containsKey('House')){ payTypeMap.put('House',0.00); }
                    if(payTypeMap.containsKey('House') && creditAmt>0){ payTypeMap.put('House',payTypeMap.get('House')-creditAmt); }
                }
            }
            for(ApplyToWrapper wrapper : iw.applyToWrapperLst){
                if(payTypeMap.containsKey(wrapper.applyToType)){
                    wrapper.applyToAmt = payTypeMap.get(wrapper.applyToType);
                    wrapper.amtOwed = payTypeMap.get(wrapper.applyToType);
                    wrapper.amtToPay = wrapper.applyToAmt;
                }
                wrapper.payAll = true;
            }
        }
       return iw;
    }

    global Class InvoiceWrapper{
        public List<club62__Payment_Method__c> payLst{get;set;}
        public List<ApplyToWrapper> applyToWrapperLst{get;set;}
        public Boolean hasRecurringPay{get;set;}
    }
    
    /*
    @Name   :ApplyToWrapper
    @Description :inner class for auto apply
    */
    public class ApplyToWrapper{
        public String applyToType{get;set;}
        public Decimal amtOwed{get;set;}
        public Decimal applyToAmt{get;set;}
        public Decimal amtToPay{get;set;}
        public Boolean payAll{get;set;}
    }
}