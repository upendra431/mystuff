/*
@Name           : C62ConvertApplicantController
@Author         : customersuccess@cloud62.com
@Date           : October 30th, 2013
@Description    : Controller for ConvertApplicanPage.
*/
public with sharing class C62ConvertApplicantController{
    //variables
    public club62__Person__c applicant{get;set;}
    public Boolean confirmFlag{get;set;}
    public Boolean activePMOnFile{get;set;}
       
    /*
    @Name   :C62ConvertApplicantController
    @Description :Constructor 
    */
    public C62ConvertApplicantController(ApexPages.StandardController controller) {
        applicant = (club62__Person__c)controller.getRecord();
        confirmFlag = true;
        activePMOnFile = false;
        if(applicant != null && applicant.Id != null){
            //query the application record
            String strQry = 'SELECT ' + C62Utilities.getFields('club62__Person__c') 
                            + ',(SELECT ' + C62Utilities.getFields('club62__Address__c')+' FROM club62__Addresses__r)'
                            + ',(SELECT ' + C62Utilities.getFields('club62__Payment__c') + ' FROM club62__Payments__r)'
                            + ',(SELECT ' + C62Utilities.getFields('club62__Payment_Method__c') + ' FROM club62__Billing_Methods__r)'
                            + ',(SELECT ' + C62Utilities.getFields('club62__Transaction__c') + ' FROM club62__Transactions__r)'
                            + ',(SELECT ' + C62Utilities.getFields('club62__Refund__c') + ' FROM club62__Refunds__r)'
                            + ',(SELECT ' + C62Utilities.getFields('club62__Pass__c') + ' FROM club62__Passes__r)'
                            +' FROM club62__Person__c WHERE ID = \'' + String.escapeSingleQuotes(applicant.Id) + '\'';
            applicant = Database.query(strQry);
            //Getting associated payment methods 
            List<club62__Payment_Method__c> pmLst = [Select Id,club62__Payment_Type__c,club62__Expiration_Date__c From club62__Payment_Method__c Where club62__Person__c=:applicant.Id And club62__Inactive__c=false And club62__Temporary__c=false];
            for(club62__Payment_Method__c pm : pmLst){
                if(pm.club62__Payment_Type__c == 'Credit Card' && (pm.club62__Expiration_Date__c==null 
                    || (pm.club62__Expiration_Date__c!=null && pm.club62__Expiration_Date__c>=Date.Today()))){
                    activePMOnFile = true;
                }
            }
            //Checks
            if(applicant.club62__Addresses__r==null){
                confirmFlag = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Before you convert '+applicant.Name+' to a Customer, please add at least 1 address.'));
                return;
            }else if(applicant.club62__Addresses__r.size()<=0){
                confirmFlag = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Before you convert '+applicant.Name+' to a Customer, please add at least 1 address.'));
                return;
            }
            if(applicant.club62__BirthDate__c==null){
                confirmFlag = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An applicant must have a birthday before it can be converted.'));
                return;
            }
        }
    }
    
    /*
    @Name   :applicantConversion
    @Description :Convert the applicant into Customer
    */
    public PageReference applicantConversion(){
        //create a Customer record
        SavePoint sp = Database.setSavepoint();
        Contact member = new Contact(club62__Join_Date__c=System.today(),club62__Status__c='Pending',FirstName=applicant.club62__First_Name__c,
                           LastName=applicant.club62__Last_Name__c,club62__Title__c=applicant.club62__Salutation__c,club62__Billing_Frequency__c=applicant.club62__Billing_Frequency__c,
                           club62__Gender__c=applicant.club62__Gender__c,Birthdate=applicant.club62__Birthdate__c,club62__Graduate_School__c=applicant.club62__Graduate_School__c,
                           club62__SSN__c=applicant.club62__SSN__c,club62__Marital_Status__c=applicant.club62__Marital_Status__c,
                           club62__Maiden_Name__c=applicant.club62__Maiden_Name__c,HomePhone=applicant.club62__Home_Phone__c,club62__Occupation__c=applicant.club62__Occupation__c,
                           MobilePhone=applicant.club62__Mobile_Phone__c,club62__Undergraduate_Year__c=applicant.club62__Undergraduate_Year__c,
                           OtherPhone=applicant.club62__Work_Phone__c,club62__Referred_By__c = applicant.club62__Referrer__c,
                           Email = applicant.club62__Email__c,club62__Other_Email__c = applicant.club62__Other_Email__c,club62__Applicant__c=applicant.Id,
                           club62__Secondary_Email__c = applicant.club62__Secondary_Email__c,club62__Type__c = applicant.club62__Type__c,
                           club62__Primary_Institution__c=applicant.club62__Primary_Institution__c,club62__Undergraduate_School__c=applicant.club62__Undergraduate_School__c,
                           club62__Tour_Date__c=applicant.club62__Tour_Date__c,club62__Tour_By__c=applicant.club62__Tour_By__c,club62__Tour_Comments__c = applicant.club62__Tour_Comments__c,
                           club62__Graduate_Year__c=applicant.club62__Graduate_Year__c,club62__Category__c=applicant.club62__Category__c,
                           club62__Spouse__c=applicant.club62__Spouse__c, club62__VIP_Details__c=applicant.club62__VIP_Details__c,club62__Source__c=applicant.club62__Source__c);
        try{    
            //insert the member record
            //Do any queries before we delete the applicant
            List<Attachment> attachList;
            if(applicant.club62__Photo_Attachment_Id__c!=null){
                attachList = [Select SystemModstamp,ParentId,OwnerId,Name,LastModifiedDate,LastModifiedById,IsPrivate,IsDeleted,Id,Description,CreatedDate,CreatedById,ContentType,BodyLength,Body 
                                                From Attachment Where Id=:applicant.club62__Photo_Attachment_Id__c];
                
            }
            List<club62__Address__c> updateAdd = new List<club62__Address__c>();
            List<Task> tskLst = [Select ID,WhoID,WhatID FROM Task WHERE WhatID=:applicant.ID];
            List<Event> eventLst = [Select ID,WhoID,WhatID FROM Event WHERE WhatID=:applicant.ID];
            List<club62__Relationship__c> delRel = [SELECT ID FROM club62__Relationship__c WHERE club62__Secondary_Person__c=:applicant.ID];
            List<club62__Payment_Method__c> lstPayMethods = applicant.club62__Billing_Methods__r;
            List<club62__Payment__c> lstPay = applicant.club62__Payments__r;
            List<club62__Transaction__c> lstOC = applicant.club62__Transactions__r;
            List<club62__Refund__c> lstRfnd = applicant.club62__Refunds__r;
            List<club62__Pass__c> lstPasses = applicant.club62__Passes__r;
            if(Schema.sObjectType.club62__Relationship__c.isDeletable() && delRel.size()>0) delete delRel;
            Attachment att = new Attachment();
            
            if(applicant.club62__Addresses__r != null && applicant.club62__Addresses__r.size()>0){
                //if address exists
                for(club62__Address__c address : applicant.club62__Addresses__r){
                    updateAdd.add(address);
                }
                
                //update the addresses with new member
                if(Schema.sObjectType.club62__Address__c.isUpdateable() && updateAdd.size()>0){ update updateAdd;}
                
            }
            member.club62__Possible_Duplicate_Override__c = true;
            member.club62__Customer_Account_Enabled__c = true;
            if(Schema.sObjectType.Contact.isCreateable()){
                insert member;
                member = Database.query('SELECT ' + C62Utilities.getFields('Contact')+ ' FROM Contact WHERE ID=\''+member.Id+'\'');
            }
            if(attachList!=null && attachList.size()>0){
                att = attachList[0].clone();
                att.ParentId = member.Id;
                if(Schema.sObjectType.Attachment.isCreateable()){insert att;}
                member.club62__Photo_Attachment_Id__c=att.Id;
                if(Schema.sObjectType.Contact.isUpdateable()){update member;}
            }
            
            //change the status of applicant to approved
            if(member.id!=null){
                // Get all associated Task with Person.
                
                if(tskLst.size()>0){
                    for(Task t : tskLst){
                        t.whoID=member.id;
                        t.WhatID = null;
                    }
                    if(Schema.sObjectType.Task.isUpdateable()){update tskLst;}
                }
                // Get all associated Event with Person.
               
                if(eventLst.size()>0){
                    for(Event e : eventLst){
                        e.whoID=member.id;
                        e.WhatID = null;
                    }
                    if(Schema.sObjectType.Event.isUpdateable()){update eventLst;}
                }
            }
            
            if(updateAdd != null && updateAdd.size()>0){
                //if address exists
                for(club62__Address__c address : updateAdd){
                    address.club62__Customer__c = member.Id;
                }
                
                //update the addresses with new member
                if(Schema.sObjectType.club62__Address__c.isUpdateable() && updateAdd.size()>0){ update updateAdd;}
                
            }
            //Move the payment methods to the member
            for(club62__Payment_Method__c pm : lstPayMethods){
                pm.club62__Customer__c = member.Id;
                pm.club62__Person__c = null;
            }
            //Move over payments to member
            for(club62__Payment__c p : lstPay){
                if(p.club62__Customer__c==null || (p.club62__Customer__c!=null && club62__C62BillingSettings__c.getOrgDefaults()!=null && p.club62__Customer__c==club62__C62BillingSettings__c.getOrgDefaults().club62__Application_Holding_Member__c)){
                    p.club62__Customer__c = member.Id;
                }
                p.club62__Person__c = null;
            }
            //create receivable for application fee if found
            club62__Transaction__c appFee = null;
            String recId = null;
            String dbPayId = null;
            for(club62__Transaction__c oc : lstOC){
                if(oc.club62__Type__c=='Application Fee' && oc.club62__Amount_Due__c>0){
                    appFee = oc;
                }
            }
            if(appFee!=null && appFee.Id!=null){
                List<club62__Payment_Method__c> pmLst = [Select Id From club62__Payment_Method__c Where club62__Customer__c=:member.Id];
                if(pmLst.size()>0){
                    club62__Payment__c dbPay = new club62__Payment__c(club62__Amount__c=appFee.club62__Amount_Due__c,club62__Payment_Date__c=Date.Today(),
                        club62__Payment_Method__c=pmLst[0].Id,club62__Status__c='Paid',club62__Customer__c=member.Id,
                        club62__Type__c='Payment',club62__Description__c='Membership Application Fee');
                    insert dbPay;
                    dbPayId = dbPay.Id;
                    List<club62__Payment__c> dbPayment = [Select Id,(Select Id,club62__Receivable__c From club62__AR_Payments__r) From club62__Payment__c Where Id=:dbPay.Id];    
                    for(club62__AR_Payment__c ar : dbPayment[0].club62__AR_Payments__r){
                        recId = ar.club62__Receivable__c;
                    }
                }
            }
            //Move over other charges to member
            for(club62__Transaction__c oc : lstOC){             
                if(oc.club62__Type__c=='Application Fee' && oc.club62__Payment__c==null && oc.club62__Amount_Due__c>0 && recId!=null && dbPayId!=null){
                    oc.club62__Payment__c=dbPayId;
                    oc.club62__Receivable__c=recId;
                }
                if(oc.club62__Customer__c==null || (oc.club62__Customer__c!=null && club62__C62BillingSettings__c.getOrgDefaults()!=null && oc.club62__Customer__c==club62__C62BillingSettings__c.getOrgDefaults().club62__Application_Holding_Member__c)){
                    oc.club62__Customer__c = member.Id;
                }
                if(oc.club62__Customer_Status_Flag__c==FALSE){            
                    oc.club62__Customer_Status_Flag__c = TRUE;
                }else{                 
                    oc.club62__Customer_Status_Flag__c=FALSE;
                }  
                oc.club62__Person__c = null;             
            }

            //Move over refunds to member
            for(club62__Refund__c r : lstRfnd) {
                r.club62__Customer__c = member.Id;
                r.club62__Person__c = null;
            }

            //Move over passes to member
            for(club62__Pass__c p : lstPasses){
                p.club62__Customer__c = member.Id;
                p.club62__Person__c = null;
            }
            
            if(Schema.sObjectType.club62__Payment_Method__c.isUpdateable()){update lstPayMethods;}
            if(Schema.sObjectType.club62__Payment__c.isUpdateable()){update lstPay;}
            if(Schema.sObjectType.club62__Transaction__c.isUpdateable()){update lstOC;}
            if(Schema.sObjectType.club62__Refund__c.isUpdateable()){update lstRfnd;}
            if(Schema.sObjectType.club62__Pass__c.isUpdateable()){update lstPasses;}
            
            //delete the Converted Person,
            if(Schema.sObjectType.club62__Person__c.isDeletable()){delete applicant;}
            //reupdate the member removing the duplicate override check
            member.club62__Possible_Duplicate_Override__c = false;
            if(Schema.sObjectType.Contact.isUpdateable()){update member;}
        }catch(Exception ex){
            Database.rollBack(sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error: The insert/update is failed due to "'+ex.getMessage() +'" error.'));
            confirmFlag = false;
            return null;
        }
        
        if(member.Id != null){
            return new PageReference('/'+member.Id);
        } else {
            return null;
        }
    }
    public static Integer getRandomInt (Integer lower, Integer upper)
    {
        return Math.round(Math.random() * (upper - lower)) + lower;
    }
    /*
    @Name   :backToApplicant
    @Description :Return back to applicant
    */
    public PageReference backToApplicant(){
        return new PageReference('/'+applicant.ID);
    }
}