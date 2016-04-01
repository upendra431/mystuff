/*
@Name            : C62NewEditRelationshipsController
@Author          : customersuccess@cloud62.com
@Date            : January 08, 2014
@Description     : Controller for insert/update the relationships record.
*/
public with sharing class C62NewEditRelationshipsController{
    //class variables
    public Contact member{get;set;}
    public club62__Person__c person{get;set;}
    public Contact selectedMem{get;set;}
    public club62__Person__c selectedPerson{get;set;}
    public club62__Relationship__c relationship{get;set;}
    transient public Attachment attachment{get;set;}
    transient public Attachment attach{get;set;}
    public String cPage{get;set;}
    public String selRecordID{get;set;}
    public List<RelatedRelationshipWrapper> wrapperLst{get;set;}
    public Set<ID> recordIDSet;
    
    /*
    @Name   :C62NewEditRelationshipsController
    @Description :Constructor to initalize the page
    */
    public C62NewEditRelationshipsController(){
        String recordID = Apexpages.currentPage().getParameters().get('id');
        Schema.SOBjectType sT;
        if(recordID != null && recordID != ''){sT = ((id)recordID).getsObjectType();}
        attachment = new Attachment();
        relationship = new club62__Relationship__c();
        recordIDSet = new Set<ID>();
        wrapperLst = new List<RelatedRelationshipWrapper>();
        if(recordID != null && recordID != '' && st.getDescribe().getName()=='Contact'){
            String qry = 'SELECT Account.Name,(Select ParentId, OwnerId, Name, IsPrivate, Id, Description From Attachments),'
                        +C62Utilities.getFields('Contact')+' FROM Contact WHERE ID=\''+String.escapeSingleQuotes(recordID)+'\' LIMIT 1';
            List<Contact> membersList = Database.query(qry);
            member = membersList[0];
            if(member != null && member.ID != null && member.club62__Photo_Attachment_Id__c != null){
                Boolean flag = false;
                for(Attachment attach : member.Attachments){
                    if(attach.ID == member.club62__Photo_Attachment_Id__c && flag == false){
                        attachment = attach;
                        flag = true;
                    }
                }
            }
            cPage = 'MemberPerson';
            relationshipList();
        }else if(recordID != null && recordID != '' && st.getDescribe().getName()=='club62__Person__c'){
            String qry = 'SELECT club62__Household__r.Name,(Select ParentId, OwnerId, Name, IsPrivate, Id, Description From Attachments),'
                        +C62Utilities.getFields('club62__Person__c')+' FROM club62__Person__c WHERE ID=\''+String.escapeSingleQuotes(recordID)+'\' LIMIT 1';
            person = Database.query(qry);
            if(person != null && person.ID != null && person.club62__Photo_Attachment_Id__c != null){
                Boolean flag = false;
                for(Attachment attach : person.Attachments){
                    if(attach.ID == person.club62__Photo_Attachment_Id__c && flag == false){
                        attachment = attach;
                        flag = true;
                    }
                }
            }
            cPage = 'MemberPerson';
            relationshipList();
        }
    }
    
    /*
    @Name   :relationshipList
    @Description :get the associated Relationships records.
    */
    public void relationshipList(){
        wrapperLst = new List<RelatedRelationshipWrapper>();
        List<club62__Relationship__c> relLst = new List<club62__Relationship__c>();
        String qry = 'SELECT '+C62Utilities.getFields('club62__Relationship__c')+' FROM club62__Relationship__c ';
        Map<ID,club62__Relationship__c> relationshipMap = new Map<ID,club62__Relationship__c>();
        recordIDSet = new Set<ID>();
        if(member != null && member.Id != null){
            recordIDSet.add(member.Id);
            qry += 'WHERE club62__Primary_Customer__c=\''+String.escapeSingleQuotes(member.Id)+'\' OR club62__Secondary_Customer__c=\''+String.escapeSingleQuotes(member.Id)+'\'';
            relLst = Database.query(qry);
            for(club62__Relationship__c r : relLst){
                if(r.club62__Primary_Customer__c==member.Id){
                    if(r.club62__Secondary_Customer__c != null){
                        relationshipMap.put(r.club62__Secondary_Customer__c,r);
                    }else if(r.club62__Secondary_Person__c != null){
                        relationshipMap.put(r.club62__Secondary_Person__c,r);
                    }
                    
                }else{
                    relationshipMap.put(r.club62__Primary_Customer__c,r);
                }
            }
            
        }else if(person != null && person.Id != null){
            recordIDSet.add(person.Id);
            qry += 'WHERE club62__Secondary_Person__c=\''+person.Id+'\'';
            relLst = Database.query(qry);
            for(club62__Relationship__c r : relLst){
                relationshipMap.put(r.club62__Primary_Customer__c,r);
            }
        }
        
        if(relationshipMap.size()>0){
            recordIDSet.addAll(relationshipMap.keySet());
            //get the associated member records.
            Map<ID,Contact> memMap = new Map<ID,Contact>([SELECT ID,Name,club62__Status__c,Birthdate,club62__Join_Date__c,club62__Type__c,club62__Customer_Id__c,
                        club62__Photo_Attachment_Id__c,(Select ParentId, OwnerId, Name, IsPrivate, Id, Description From Attachments) 
                        FROM Contact WHERE ID IN :relationshipMap.keySet()]);
            
            //get the associated person records.
            Map<ID,club62__Person__c> perMap = new Map<ID,club62__Person__c>([SELECT ID,Name,club62__Status__c,club62__Birthdate__c,club62__Application_Date__c,club62__Type__c,
                        club62__Photo_Attachment_Id__c,(Select ParentId, OwnerId, Name, IsPrivate, Id, Description From Attachments) 
                        FROM club62__Person__c WHERE ID IN :relationshipMap.keySet()]);
                        
            for(ID recordId : relationshipMap.keySet()){
                if(memMap != null && memMap.containsKey(recordId)){
                    RelatedRelationshipWrapper rw = new RelatedRelationshipWrapper();
                    rw.member = memMap.get(recordId);
                    rw.relationship = relationshipMap.get(recordId);
                    rw.relation = rw.relationship.club62__Relationship__c;
                    rw.memFlag = TRUE;
                    if(rw.member.club62__Photo_Attachment_Id__c != null){
                        Boolean flag = false;
                        for(Attachment attach : rw.member.Attachments){
                            if(attach.ID == rw.member.club62__Photo_Attachment_Id__c && flag == false){
                                rw.attachment = attach;
                                flag = true;
                            }
                        }
                    }
                    wrapperLst.add(rw);
                }
                if(perMap != null && perMap.containsKey(recordId)){
                    RelatedRelationshipWrapper rw = new RelatedRelationshipWrapper();
                    rw.person = perMap.get(recordId);
                    rw.relationship = relationshipMap.get(recordId);
                    rw.relation = rw.relationship.club62__Relationship__c;
                    rw.memFlag = FALSE;
                    if(rw.person.club62__Photo_Attachment_Id__c != null){
                        Boolean flag = false;
                        for(Attachment attach : rw.person.Attachments){
                            if(attach.ID == rw.person.club62__Photo_Attachment_Id__c && flag == false){
                                rw.attachment = attach;
                                flag = true;
                            }
                        }
                    }
                    wrapperLst.add(rw);
                }
            }
        }
    }
    
    /*
    @Name :newRelationship
    @Description :redirect to new Relationship
    */
    public PageReference newRelationship() {
        String recordID='';
        Schema.SOBjectType sT;
        if(selRecordID == null || selRecordID == ''){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a Customer or a Person.'));
            return null;
        }else{
            sT = ((id)selRecordID).getsObjectType();
        }
        if(relationship.club62__Relationship__c != null){
            relationship.Name = relationship.club62__Relationship__c;
        }else{
            if(sT != null && sT.getDescribe().getName()=='Contact' && selectedMem != null && selectedMem.Id != null){
                attach=C62MemberAttachmentDisplayController.getAttachmentIdForMember(selectedMem.Id);
                selectedPerson = new club62__Person__c();
            }
            if(sT != null && sT.getDescribe().getName()=='club62__Person__c'){
                if(selectedPerson!=null && selectedPerson.ID != null && selectedPerson.club62__Photo_Attachment_Id__c != null){
                    attach=[Select Name, Id, Description, ContentType, BodyLength, Body From Attachment 
                                WHERE ID=:selectedPerson.club62__Photo_Attachment_Id__c];
                }
                selectedMem = new Contact();
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select a relationship.'));
            return null;
        }
        if(member != null && member.ID != null){
            relationship.club62__Primary_Customer__c = member.ID;
            recordID = member.ID;
            if(sT != null && sT.getDescribe().getName()=='Contact'){
                relationship.club62__Secondary_Customer__c = selRecordID;
            }else if(sT != null && sT.getDescribe().getName()=='club62__Person__c'){
                relationship.club62__Secondary_Person__c = selRecordID;
            }
        }else if(person != null && person.ID != null){
            recordID = person.ID;
            relationship.club62__Primary_Customer__c = selRecordID;
            relationship.club62__Secondary_Person__c = person.ID;
        }
        try{
            if(Schema.sObjectType.club62__Relationship__c.isCreateable()){insert relationship;}
        }catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,ex.getMessage()));
            return null;
        }
        PageReference page = new PageReference('/apex/club62__NewEditRelationships?id='+recordID);
        page.setRedirect(true);
        return page;
    }
    
    /*
    @Name :getSelectedRecINFO
    @Description :get the selected record information.
    */
    public PageReference getSelectedRecINFO() {
        if(selRecordID != null && selRecordID != ''){
            Schema.SOBjectType sT = ((id)selRecordID).getsObjectType();
            if(st.getDescribe().getName()=='Contact'){
                selectedMem = [SELECT Id,Name,Birthdate,club62__Join_Date__c,FirstName,club62__Customer_Id__c,
                            LastName,club62__Type__c,AccountId,club62__Head_of_Household__c,Account.Name,club62__HouseHold_Flag__c 
                            FROM Contact WHERE ID=:selRecordID];
                attach=C62MemberAttachmentDisplayController.getAttachmentIdForMember(selectedMem.Id);
                selectedPerson = new club62__Person__c();
            }else if(st.getDescribe().getName()=='club62__Person__c'){
                selectedPerson = [SELECT Id,Name,club62__Birthdate__c,club62__Application_Date__c,club62__First_Name__c,club62__Photo_Attachment_Id__c,
                            club62__Last_Name__c,club62__Type__c,club62__Household__c,club62__Household__r.Name,club62__HouseHold_Flag__c 
                            FROM club62__Person__c WHERE ID=:selRecordID];
                if(selectedPerson!=null && selectedPerson.ID != null && selectedPerson.club62__Photo_Attachment_Id__c != null){
                    attach=[Select Name, Id, Description, ContentType, BodyLength, Body From Attachment 
                                WHERE ID=:selectedPerson.club62__Photo_Attachment_Id__c];
                }
                selectedMem = new Contact();
            }
        }else{
            selectedMem = new Contact();
            selectedPerson = new club62__Person__c();
        }
        return null;
    }
    
    /*
    @Name :changeRelationship
    @Description :Change the relationship.
    */
    public PageReference changeRelationship() {
        List<club62__Relationship__c> updateRelationship = new List<club62__Relationship__c>();
        if(wrapperLst.size()>0){
            for(RelatedRelationshipWrapper rw : wrapperLst){
                if(rw.relationship!=null && rw.relationship.club62__Relationship__c!=null && rw.relation != rw.relationship.club62__Relationship__c){
                    updateRelationship.add(rw.relationship);
                }
            }
            if(updateRelationship.size()>0){
                try{
                    if(Schema.sObjectType.club62__Relationship__c.isUpdateable()){update updateRelationship;}
                }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
                }
            }
        }
        relationshipList();
        return null;
    }
    
    /*
    @Name :removeRelationship
    @Description :Delete the selected relationship records.
    */
    public void removeRelationship() {
        List<club62__Relationship__c> delRelationship = new List<club62__Relationship__c>();
        if(wrapperLst.size()>0){
            Boolean errorFlag = TRUE;
            for(RelatedRelationshipWrapper rw : wrapperLst){
                if(rw.selFlag){
                    if(rw.relationship!=null){delRelationship.add(rw.relationship);}
                    errorFlag = FALSE;
                }
            }
            if(errorFlag){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one record to remove the relationship.'));
            }
            if(delRelationship.size()>0){
                try{
                    if(Schema.sObjectType.club62__Relationship__c.isDeletable()){delete delRelationship;}
                }catch(Exception e){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
                }
            }
        }
        relationshipList();
    }
    
    /*
    @Name :cancel
    @Description :Back to record
    */
    public PageReference cancel() {
        String recordID = '';
        if(member != null && member.ID != null){
            recordID = member.ID;
        }else if(person != null && person.ID != null){
            recordID = person.ID;
        }
        return new PageReference('/'+recordID);
    }
    
    /*
    @Name        :getRecordList
    @Description :Returns the list of Members and Person for the FlexBox to use
    */
    public String getRecordList(){
        FlexItemSource fis = new FlexItemSource();
        List<FlexItem> lstFL = new list<FlexItem>();
        List<Contact> lstMems = [SELECT Id,Name,club62__Customer_Id__c FROM Contact WHERE ID NOT IN :recordIDSet AND club62__Status__c NOT IN ('Terminated','Cancelled','Resigned','Suspended') ORDER BY Name asc];
        for(Contact mem : lstMems){
            FlexItem fl = new FlexItem();
            fl.id = mem.id;
            fl.name = mem.Name;
            lstFL.add(fl);
        }
        if(person==null){
            List<club62__Person__c> lstPersons = [SELECT Id,Name FROM club62__Person__c WHERE ID NOT IN :recordIDSet ORDER BY Name asc];
            for(club62__Person__c p : lstPersons){
                FlexItem fl = new FlexItem();
                fl.id = p.id;
                fl.name = p.Name;
                lstFL.add(fl);
            }
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
    }
    
    /*
    @Name        :FlexItemSource
    @Description :Class to represent flexbox source
    */
    public class FlexItemSource{
        public List<FlexItem> results {get;set;}
    }
    
    /*
    @Name :RelatedRelationshipWrapper
    @Description :Wrapper class
    */
    public class RelatedRelationshipWrapper{
        public Contact member{get;set;}
        public club62__Person__c person{get;set;}
        public String relation{get;set;}
        public club62__Relationship__c relationship{get;set;}
        public Boolean selFlag{get;set;}
        public Boolean memFlag{get;set;}
        transient public Attachment attachment{get;set;}
    }
}