/*
@Name               : C62BatchGenerateNewSubscriptionLines
@Author             : customersuccess@cloud62.com
@Date               : December 30, 2013
@Description        : Batch to new subscription lines for subscriptions with no end date
*/
global with sharing class C62BatchGenerateNewSubscriptionLines implements Database.Batchable<sObject>,Schedulable{
    //public List<Database.SaveResult> srLst;
    
    String qry;
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query All Members who are active and have subscriptions with no end dates that are going to expire soon
        //Using C62BillingSettings Custom setting for the invoice generation threshold. 
        club62__C62BillingSettings__c billSettings = club62__C62BillingSettings__c.getOrgDefaults();
        Date effectiveDate = Date.Today();
        if(billSettings!=null && billSettings.club62__Invoice_Generation_Threshold__c != null){
          effectiveDate.addDays(Integer.valueOf(billSettings.club62__Invoice_Generation_Threshold__c));
        }
        String query = 'SELECT (Select '+C62Utilities.getFields('club62__Subscription_Line__c')+' FROM club62__Subscription_Lines__r ORDER BY CreatedDate DESC), ' + C62Utilities.getFields('club62__Subscription__c') + ' FROM club62__Subscription__c WHERE club62__Customer__r.club62__Status__c in (\'Active\',\'Reinstated\',\'Suspended\') and club62__Start_Date__c<=:effectiveDate and (club62__End_Date__c=null or club62__End_Date__c>:effectiveDate)and (club62__Last_Subscription_Line_End_Date__c = null or club62__Last_Subscription_Line_End_Date__c<=Next_N_Days:30 or club62__Last_Subscription_Line_End_Date__c<=TODAY) and RecordType.Name != \'Legacy\'';
        
        if(qry!=null && qry!=''){
          query = 'SELECT (Select '+C62Utilities.getFields('club62__Subscription_Line__c')+' FROM club62__Subscription_Lines__r where club62__Type__c in (\'Dues\') ORDER BY CreatedDate DESC), ' + C62Utilities.getFields('club62__Subscription__c') + ' FROM club62__Subscription__c '+qry;
        }

        return Database.getQueryLocator(query);
   }
   global C62BatchGenerateNewSubscriptionLines(String str){
    this.qry = str;
   }
   global C62BatchGenerateNewSubscriptionLines(){}
   global void execute(SchedulableContext ctx) {
        C62BatchGenerateNewSubscriptionLines batch1 = new C62BatchGenerateNewSubscriptionLines();
        ID batchprocessid = Database.executeBatch(batch1);
   }
  
   global void execute(Database.BatchableContext BC, List<sObject> scope){
       C62Utilities.cSetExecuted.add('BatchRun');
       List<club62__Subscription__c> msLst = (List<club62__Subscription__c>)scope;
       C62MemberSubscriptionCalculationsHandler.afterInsertAfterUpdate(msLst,true);
   }
   global void finish(Database.BatchableContext BC){
       //String cronId = System.ScheduleBatch(new C62BatchGenerateMemberDues(),'C62BatchGenerateMemberDues'+Date.today().year()+'-'+Date.today().month()+'-'+Date.today().day(),1);             
   }
}