/*
@Name               : C62BatchPassess
@Author             : customersuccess@cloud62.com
@Date               : July 18, 2014
@Description        : Void Pass Authorizations, Set pass status to expired, set person's guest pass status
*/
global with sharing class C62BatchPasses implements Database.batchable<sObject>,Database.AllowsCallouts,Schedulable{
    global Integer cSize;
    
    /*
    @Name :start
    @Description :
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT '+Club62.C62Utilities.getFields('club62__Pass__c')+ ' FROM club62__Pass__c where club62__Expiration_Date__c<=TODAY and club62__Status__c=\'Active\'';
        return Database.getQueryLocator(query);
    }
    global void execute(SchedulableContext ctx) {
        C62BatchPasses batch1 = new C62BatchPasses();
        ID batchprocessid = Database.executeBatch(batch1,10);
    }
    /*
    @Name :execute
    @Description :
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        C62Utilities.cSetExecuted.add('BatchRun');
        //Assume batch size is 10 due to callout limit
        if(cSize == null) cSize = scope.size();
        if(cSize <= 10){
            List<club62__Pass__c> lstPasses = (List<Pass__c>)scope;
            List<club62__Payment__c> lstUpdate = new List<club62__Payment__c>();
            
            
            Set<Id> paymentIds = new Set<Id>();
            Set<Id> perIds = new Set<Id>();
            
            for(club62__Pass__c p : lstPasses){
                if(p.club62__Purchasing_Authorization__c!=null){
                    paymentIds.add(p.club62__Purchasing_Authorization__c);
                }
                if(p.club62__Person__c!=null){
                    perIds.add(p.club62__Person__c);
                }
            }
            //Querying all authorized payments
            List<club62__Payment__c> tempPayList = database.query('Select '+club62.C62Utilities.getFields('club62__Payment__c')+' FROM club62__Payment__c where id in :paymentIds and club62__Status__c=\'Authorized\'');
            List<club62__Person__c> perList = [select id, (Select Id from club62__Passes__r where club62__Expiration_Date__c>Today) from club62__Person__c where Id in:perIds and club62__Active_Guest_Pass__c=true];
            List<club62__Person__c> perToUpdate = new List<club62__Person__c>();
            
            
            //Void authorizations for expired passes
            for(club62__Payment__c pay : tempPayList){
                //void the authorization payment
                C62PaymentGatewayController payGateCont = new C62PaymentGatewayController();
                
                C62PaymentGatewayClasses.VoidAuthorizationResponse result = payGateCont.VoidAuthorization(pay);
                if(result.Effect == C62PaymentGatewayClasses.TransactionEffect.Success){
                    //Successful void
                   pay.club62__Status__c = 'Voided';
                   lstUpdate.add(pay);
                } else {
                    //void failed
                    pay.club62__Processing_Message__c = result.ErrorDescription;
                    pay.club62__Status__c = 'Rejected';
                    lstUpdate.add(pay);
                }
            }
            //Set Pass status to Expired
            for(club62__Pass__c pass : lstPasses){
                pass.club62__Status__c = 'Expired';
            }
            if(Schema.sObjectType.club62__Pass__c.isUpdateable()){update lstPasses;}
            //Set Active Guest Pass to false if they no longer have any active guest passes
            for(club62__Person__c per : perList){
                if(!(per.club62__Passes__r.size()>0)){
                    per.club62__Active_Guest_Pass__c = false;
                    perToUpdate.add(per);
                }
            }
            if(Schema.sObjectType.club62__Person__c.isUpdateable()){update perToUpdate;}
            if(Schema.sObjectType.club62__Payment__c.isUpdateable() && lstUpdate.size() > 0) update lstUpdate;
        }
    }

    /*
    @Name :finish
    @Description :finish method
    */
    global void finish(Database.BatchableContext BC) {
        if(cSize != null && cSize > 10){
            Database.executeBatch(new C62BatchPasses(),10);
        }
    }
}