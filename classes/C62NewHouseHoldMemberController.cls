/*
@Name               : C62NewHouseHoldMemberController
@Author             : customersuccess@cloud62.com
@Date               : November 06, 2013
@Description        :
*/
public with sharing class C62NewHouseHoldMemberController {
    //variables
    public Contact mem{get;set;}
    public Contact selectedMem{get;set;}
    public club62__Person__c selectedPerson{get;set;}
    public club62__Relationship__c relationship{get;set;}
    public String secondaryMember{get;set;}
    transient public Attachment attach{get;set;}

    /*
    @Name :C62NewHouseHoldMemberController
    @Description :Constructor
    */
    public C62NewHouseHoldMemberController(ApexPages.StandardController controller){
        relationship = new club62__Relationship__c();
        this.mem = (Contact) controller.getRecord();
        if(mem != null && mem.Id != null){
            mem = [SELECT Id,Name,Birthdate,club62__Join_Date__c,club62__Type__c,
                    AccountId,club62__Head_of_Household__c,Account.Name FROM Contact WHERE ID=:mem.ID];
        }
    }
    /*
    @Name        :getSelectedmemberInfo
    @Description : Getting selected contact or person's info
    */
    public PageReference getSelectedmemberInfo(){
        Schema.SOBjectType sT;
        if(secondaryMember!=null && secondaryMember!=''){
            sT = ((id)secondaryMember).getsObjectType();
        }
        if(secondaryMember != null && secondaryMember != '' && sT != null && sT.getDescribe().getName()=='Contact'){
            selectedMem = [SELECT Id,club62__Customer_Id__c,Name,Birthdate,club62__Join_Date__c,FirstName,
                            LastName,club62__Type__c,AccountId,club62__Head_of_Household__c,Account.Name,club62__HouseHold_Flag__c
                            FROM Contact WHERE ID=:secondaryMember];
            attach=C62MemberAttachmentDisplayController.getAttachmentIdForMember(selectedMem.Id);
            selectedPerson = new club62__Person__c();
        }else if(secondaryMember != null && secondaryMember != '' && sT != null && sT.getDescribe().getName()=='club62__Person__c'){
            selectedPerson = [SELECT Id,Name,club62__Birthdate__c,club62__Application_Date__c,club62__First_Name__c,club62__Photo_Attachment_Id__c,
                            club62__Last_Name__c,club62__Type__c,club62__Household__c,club62__Household__r.Name,club62__HouseHold_Flag__c
                            FROM club62__Person__c WHERE ID=:secondaryMember];
            if(selectedPerson!=null && selectedPerson.ID != null && selectedPerson.club62__Photo_Attachment_Id__c != null){
                attach=[Select Name, Id, Description, ContentType, BodyLength, Body From Attachment
                            WHERE ID=:selectedPerson.club62__Photo_Attachment_Id__c];
            }
            selectedMem = new Contact();
        }else{
            selectedMem = new Contact();
            selectedPerson = new club62__Person__c();
        }
        return null;
    }

    /*
    @Name        :save
    @Description : To save and redirect to house hold
    */
    public PageReference save(){
        Schema.SOBjectType sT;
        if(secondaryMember == null || secondaryMember == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a Customer or Person.'));
            return null;
        }else{
            sT = ((id)secondaryMember).getsObjectType();
        }
        relationship.club62__Primary_Customer__c = mem.ID;
        if(relationship.club62__Relationship__c != null){
            relationship.Name = relationship.club62__Relationship__c;
        }else{
            if(sT != null && sT.getDescribe().getName()=='Contact' && secondaryMember != null && secondaryMember != '' && selectedMem != null && selectedMem.Id != null){
                attach=C62MemberAttachmentDisplayController.getAttachmentIdForMember(selectedMem.Id);
                selectedPerson = new club62__Person__c();
            }
            if(secondaryMember != null && secondaryMember != '' && sT != null && sT.getDescribe().getName()=='club62__Person__c'){
                if(selectedPerson!=null && selectedPerson.ID != null && selectedPerson.club62__Photo_Attachment_Id__c != null){
                    //Fetching attachment
                    attach=[Select Name, Id, Description, ContentType, BodyLength, Body From Attachment
                                WHERE ID=:selectedPerson.club62__Photo_Attachment_Id__c];
                }
                selectedMem = new Contact();
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select relationship.'));
            return null;
        }
        if(secondaryMember != null && secondaryMember != '' && sT != null && sT.getDescribe().getName()=='Contact'){
            relationship.club62__Secondary_Customer__c = secondaryMember;
        }
        if(secondaryMember != null && secondaryMember != '' && sT != null && sT.getDescribe().getName()=='club62__Person__c'){
            relationship.club62__Secondary_Person__c = secondaryMember;
        }
        try{
            List<club62__Relationship__c> relList = new List<club62__Relationship__c>();
            if(secondaryMember != null && secondaryMember != '' && sT != null && sT.getDescribe().getName()=='Contact'){
                List<club62__Relationship__c> delrel = [Select Id From club62__Relationship__c Where club62__Primary_Customer__c !=:mem.Id AND
                                                club62__Secondary_Customer__c=:secondaryMember];
                if(delrel.size()>0 && Schema.sObjectType.club62__Relationship__c.isDeletable()){ delete delrel;}
                relList = [Select Id,club62__Primary_Customer__c,club62__Secondary_Customer__c,club62__Secondary_Person__c From club62__Relationship__c
                            Where club62__Primary_Customer__c=:mem.Id And club62__Secondary_Customer__c=:secondaryMember];
            }
            if(secondaryMember != null && secondaryMember != '' && sT != null && sT.getDescribe().getName()=='club62__Person__c'){
                List<club62__Relationship__c> delrel = [Select Id From club62__Relationship__c Where club62__Primary_Customer__c !=:mem.Id AND
                                                club62__Secondary_Person__c=:secondaryMember];
                if(delrel.size()>0 && Schema.sObjectType.club62__Relationship__c.isDeletable()){ delete delrel;}
                relList = [Select Id,club62__Primary_Customer__c,club62__Secondary_Customer__c,club62__Secondary_Person__c From club62__Relationship__c
                            Where club62__Primary_Customer__c=:mem.Id And club62__Secondary_Person__c=:secondaryMember];
            }

            if(relList.size()==0 && secondaryMember != null && secondaryMember != ''){
                if(Schema.sObjectType.club62__Relationship__c.isCreateable()){insert relationship;}
            }

            if(selectedMem!=null && selectedMem.Id!=null){
                if(selectedMem.club62__Head_of_Household__c==TRUE && selectedMem.AccountId != mem.AccountId){
                    List<Contact> mListToUpdate = [Select Id,club62__Head_of_Household__c,club62__HouseHold_Flag__c From Contact
                                        Where AccountId=:selectedMem.AccountId AND ID!=:selectedMem.ID];
                    selectedMem.club62__Head_of_Household__c = FALSE;
                    selectedMem.AccountId=mem.AccountId;
                    if(selectedMem.club62__HouseHold_Flag__c == TRUE){
                        selectedMem.club62__HouseHold_Flag__c = FALSE;
                    }else{
                        selectedMem.club62__HouseHold_Flag__c = TRUE;
                    }
                    if(Schema.sObjectType.Contact.isUpdateable()){update selectedMem;}
                    if(mListToUpdate.size()>0){
                        Contact memberHH = mListToUpdate[0];
                        memberHH.club62__Head_of_Household__c = true;
                        if(memberHH.club62__HouseHold_Flag__c==TRUE){
                            memberHH.club62__HouseHold_Flag__c=FALSE;
                        }else{
                            memberHH.club62__HouseHold_Flag__c=TRUE;
                        }
                        if(Schema.sObjectType.Contact.isUpdateable()){update memberHH;}
                    }
                    List<club62__Relationship__c> delrel = [Select Id From club62__Relationship__c Where club62__Primary_Customer__c=:selectedMem.Id];
                    if(delrel.size()>0 && Schema.sObjectType.club62__Relationship__c.isDeletable()){ delete delrel;}
                }else if(selectedMem.AccountId != mem.AccountId){
                    selectedMem.club62__Head_of_Household__c = FALSE;
                    selectedMem.AccountId=mem.AccountId;
                    if(selectedMem.club62__HouseHold_Flag__c == TRUE){
                        selectedMem.club62__HouseHold_Flag__c = FALSE;
                    }else{
                        selectedMem.club62__HouseHold_Flag__c = TRUE;
                    }
                    if(Schema.sObjectType.Contact.isUpdateable()){update selectedMem;}
                }
            }
            if(selectedPerson!=null && selectedPerson.Id!=null){
                selectedPerson.club62__Household__c=mem.AccountId;
                if(selectedPerson.club62__HouseHold_Flag__c == TRUE){
                    selectedPerson.club62__HouseHold_Flag__c = FALSE;
                }else{
                    selectedPerson.club62__HouseHold_Flag__c = TRUE;
                }
                if(Schema.sObjectType.club62__Person__c.isUpdateable()){update selectedPerson;}
            }
            List<Account> hhLst = [Select Id,(Select ID FROM Contacts Where Id!=null),(Select ID FROM club62__Persons__r Where Id!=null) From Account];
            List<Account> delHH = new List<Account>();
            for(Account hh : hhLst){
                if(hh.Contacts.size()==0 && hh.club62__Persons__r.size()==0){ delHH.add(hh); }
            }
            if(delHH.size()>0 && Schema.sObjectType.Account.isDeletable()){ delete delHH; }
        }catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,ex.getDMLMessage(0)));
            return null;
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,ex.getMessage()));
            return null;
        }
        return new PageReference('/apex/club62__Household?id='+mem.ID);
    }

    /*
    @Name        :cancel
    @Description :
    */
    public PageReference cancel(){
        return new PageReference('/'+mem.ID);
    }

    /*
    @Name        :getMembersList
    @Description :Returns the list of Members for the FlexBox to use
    */
    public String getMembersList(){
        List<Contact> lstMems = [SELECT Id,FirstName,LastName,club62__Customer_Id__c,Name
                                    FROM Contact WHERE ID!=:mem.ID AND AccountId !=:mem.AccountId
                                    ORDER BY FirstName asc];
        FlexItemSource fis = new FlexItemSource();
        List<FlexItem> lstFL = new list<FlexItem>();
        for(Contact mem : lstMems){
            FlexItem fl = new FlexItem();
            fl.id = mem.id;
            fl.name = mem.Name;
            if(mem.club62__Customer_Id__c!=null){
                fl.memId = mem.club62__Customer_Id__c;
            }
            /*if(mem.FirstName != null && mem.FirstName != ''){
                fl.name = mem.FirstName + ' ' + mem.LastName;
            }else{
                fl.name = mem.LastName;
            }*/
            lstFL.add(fl);
        }

        List<club62__Person__c> lstPersons = [SELECT Id,club62__First_Name__c,club62__Last_Name__c,Name
                                    FROM club62__Person__c WHERE ID!=:mem.ID AND club62__Household__c !=:mem.AccountId
                                    ORDER BY club62__First_Name__c asc];
        for(club62__Person__c a : lstPersons){
            FlexItem fl = new FlexItem();
            fl.id = a.id;
            if(a.club62__First_Name__c != null && a.club62__First_Name__c != ''){
                fl.name = a.club62__First_Name__c + ' ' + a.club62__Last_Name__c;
            }else{
                fl.name = a.club62__Last_Name__c;
            }
            lstFL.add(fl);
        }
        fis.results = lstFL;
        return JSON.serialize(fis);
    }
    /*
    @Name        :FlexItem
    @Description :Class to represent flexbox item that will be used in JSON for the flexboxes
    */
    public class FlexItem{
        public String id {get;set;}
        public String name {get;set;}
        public String memid {get;set;}
        public FlexItem(){
            memId = '';
        }
    }
    /*
    @Name        :FlexItemSource
    @Description :Class to represent flexbox source
    */
    public class FlexItemSource{
        public List<FlexItem> results {get;set;}
    }
}