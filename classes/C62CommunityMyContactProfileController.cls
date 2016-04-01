/*
@Name               : C62CommunityMyContactProfileController
@Author             : customersuccess@cloud62.com
@Date               : Mar 23, 2014
@Description        : Controller for CommunityMyContactProfile page
*/
public with sharing class C62CommunityMyContactProfileController{
    //Class variables
    public Contact cMember {get;set;}
    public club62__Address__c cAddress {get;set;}
    public Boolean cHouse{get;set;}
    public Boolean cDues{get;set;}
    public Boolean cCIF{get;set;}

    /*
    @Name   :C62CommunityMyContactProfileController
    @Description :Constructor to initalize the page
    */
    public C62CommunityMyContactProfileController(){
        try{
            User user = [SELECT Id,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if(user.ContactId==null){return;}
            String memId = user.ContactId;
            cHouse = false;
            cDues = false;
            cCIF = false;
            //Get contact 
            List<Contact> lstCon = Database.query('SELECT ' + C62Utilities.getFields('Contact') 
                        +',(SELECT '+C62Utilities.getFields('club62__Recurring_Payment__c')+' FROM club62__Recurring_Billing__r WHERE club62__Active__c=TRUE)'
                        +' FROM Contact WHERE Id = :memId');
            //Get address of associated contact
            List<club62__Address__c> addList = Database.query('SELECT ' + C62Utilities.getFields('club62__Address__c')
                                    +' FROM club62__Address__c WHERE club62__Customer__c =:memId and club62__Customer__c!=null and club62__Primary__c = true');
            if(addList!=null && addList.size()>0){
              cAddress = addList[0];
            }else{
              cAddress = new club62__Address__c();
              cAddress.club62__Primary__c = true;
            }
            if(lstCon!=null && lstCon.size()>0){
                cMember = lstCon.get(0);
                cAddress.club62__Customer__c = cMember.Id;
                if(lstCon.get(0).club62__Recurring_Billing__r!=null && lstCon.get(0).club62__Recurring_Billing__r.size()>0){
                    for(club62__Recurring_Payment__c rp : cMember.club62__Recurring_Billing__r){
                        if(rp.club62__Pay_Entire_Invoice__c){
                            if(!rp.club62__Auto_Apply_To_Oldest_Statements__c){
                                if(rp.club62__Pay_Entire_Invoice_Type__c==null || rp.club62__Pay_Entire_Invoice_Type__c==''){
                                    cHouse = true;
                                    cDues = true;
                                    cCIF = true;
                                    break;
                                }else{
                                    List<String> applyLst = rp.club62__Pay_Entire_Invoice_Type__c.split(';');
                                    for(String str : applyLst){
                                        List<String> autoApplyStr = str.split(' = ');
                                        if(autoApplyStr.size()==2){
                                            if(autoApplyStr.get(0)=='House'){cHouse = true;}
                                            if(autoApplyStr.get(0)=='Dues'){cDues = true;}
                                            if(autoApplyStr.get(0)=='Capital Improvement Fee'){cCIF = true;}
                                        }
                                    }
                                }
                            }
                        }else{
                            if(rp.club62__Auto_Applied_Amount__c!=null && rp.club62__Auto_Applied_Amount__c!=''){
                                List<String> applyLst = rp.club62__Auto_Applied_Amount__c.split(';');
                                for(String str : applyLst){
                                    List<String> autoApplyStr = str.split(' = ');
                                    System.debug('autoApplyStr>'+autoApplyStr);
                                    if(autoApplyStr.size()==2){
                                        if(autoApplyStr.get(0)=='House'){cHouse = true;}
                                        if(autoApplyStr.get(0)=='Dues'){cDues = true;}
                                        if(autoApplyStr.get(0)=='Capital Improvement Fee'){cCIF = true;}
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }
    
    /*
    @Name   :updateContact
    @Description :update the contact
    */
    public void updateContact(){
        try{
            if(cMember.Phone==null || cMember.Phone=='' || cMember.Email==null || cMember.Email==''){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Phone and Email are required fields.'));
                return;
            }
            if((cAddress.club62__Street_1__c!=null || cAddress.club62__Street_2__c!=null || cAddress.club62__Street_3__c!=null ||
                cAddress.club62__City__c!=null || cAddress.club62__State_Province__c!=null || cAddress.club62__Zip_Postal_Code__c!=null) &&
                cAddress.Name==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Address Name is a required field.'));
                return;
            }
            if(Schema.sObjectType.Contact.isCreateable() && Schema.sObjectType.Contact.isUpdateable()){upsert cMember;}
            if(cAddress.Name!=null && cAddress.Name!='' && Schema.sObjectType.club62__Address__c.isCreateable() && Schema.sObjectType.club62__Address__c.isUpdateable()){upsert cAddress;}
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
            return;
        }
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM,'Your information updated successfully.'));
    }
}