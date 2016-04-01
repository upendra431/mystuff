/*
@Name               : C62GenerateBatchStatementController
@Author             : customersuccess@cloud62.com
@Date               : Dec 18, 2014
@Description        : call generate invoice batch class to generate statement
*/
public with sharing class C62GenerateBatchStatementController{
    //variables
    public club62__Payment__c tmpPayFrom{get;set;}
    public club62__Payment__c tmpPayTo{get;set;}
    //Constructor
    public C62GenerateBatchStatementController(){
        tmpPayFrom = new club62__Payment__c();
        tmpPayTo = new club62__Payment__c();
        date lastmonth = System.today().toStartOfMonth().adddays(-10);
        date firstDate = date.newInstance(lastmonth.year(), lastmonth.month(), 1);
        tmpPayFrom.club62__Payment_Date__c = firstDate;
        tmpPayTo.club62__Payment_Date__c = System.today().toStartOfMonth().addDays(-1);
        //tmpPayTo.club62__Payment_Date__c = System.today().addDays(1);
    }
    //Run the batch
    public void runStatementBatch(){
        if(tmpPayFrom.club62__Payment_Date__c!=null && tmpPayTo.club62__Payment_Date__c!=null){
            C62BatchGenerateInvoicesBatch batch = new C62BatchGenerateInvoicesBatch(tmpPayFrom.club62__Payment_Date__c,tmpPayTo.club62__Payment_Date__c);
            Database.executeBatch(batch); 
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'The statement batch has been started.'));
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Error,'Please enter the From Date and To Date.'));    
        }    
    }
}