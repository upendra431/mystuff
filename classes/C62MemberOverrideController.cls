/*
@Name               : C62MemberOverrideController 
@Author             : customersuccess@cloud62.com
@Date               : December 12, 2013
@Description        : Controller for Member Detail Override
*/
public with sharing class C62MemberOverrideController {
    Contact mem;
    public C62MemberOverrideController(ApexPages.StandardController controller) {
        mem = (Contact)controller.getRecord();
        mem = [select id,club62__Master_Duplicate_Customer__c,club62__Master_Duplicate_Person__c from Contact where id=:mem.id];
    }
    //Merge using C62DupeMerge
    public PageReference startMerge(){
        PageReference ref;
        ref = Page.C62DupeMerge;
        ref.getParameters().put('mid',mem.id);
        ref.setRedirect(true);
        return ref;
    }
    /*
    @Name    :dontCreate
    @Description    :delete new Duplicate
    */
    public PageReference dontCreate(){
        PageReference ref;
        if(mem.club62__Master_Duplicate_Customer__c!=null){
            ref = new PageReference('/'+mem.club62__Master_Duplicate_Customer__c);
               
        }else if(mem.club62__Master_Duplicate_Person__c!=null){
            ref = new PageReference('/'+mem.club62__Master_Duplicate_Person__c);
        }else{
            ref = new PageReference('/');
        }
        ref.setRedirect(true);
        if(Schema.sObjectType.Contact.isDeletable()){delete mem;}
        return ref;   
    }
    
    /*
    @Name    :NotADupe
    @Description    :Mark this as overridden and refresh the page
    */
    public PageReference NotADupe(){
        mem.club62__Possible_Duplicate_Override__c = true;
        if(Schema.sObjectType.Contact.isUpdateable()){update mem;}
        PageReference ref = new PageReference('/'+mem.id);
        ref.setRedirect(true);
        return ref;
    }
    
    /*
    @Name    :goToExisting
    @Description    :Go to existing Master member or Person
    */
    public PageReference goToExisting(){
        PageReference ref;
        if(mem.club62__Master_Duplicate_Customer__c!=null){
            ref = new PageReference('/'+mem.club62__Master_Duplicate_Customer__c);
        }else if(mem.club62__Master_Duplicate_Person__c!=null){
            ref = new PageReference('/'+mem.club62__Master_Duplicate_Person__c);
        }
        return ref;
    }
}