/*
@Name            : C62MassApproveStatementsController
@Author          : customersuccess@cloud62.com
@Date            : Dec 18, 2014
@Description     : Controller for Unapply Payments
*/
public with sharing class C62MassApproveStatementsController{
    public List<ApprovalRow> approvalList {get;set;}
    //Wrapper Class
    public class ApprovalRow{
        public Boolean checked {get;set;}
        public ProcessInstanceWorkitem piw {get;set;}
        public String objectType {get;set;}
        public sObject theObject {get;set;}
        public ApprovalRow(ProcessInstanceWorkitem piw){
            this.piw = piw;
            this.checked = false;
            this.objectType = piw.ProcessInstance.TargetObjectId.getSObjectType().getDescribe().getName();
        }
    }

    public List<ApprovalRow> getSelectedRows(){
        List<ApprovalRow> a = new List<ApprovalRow>();
        for(ApprovalRow ar : approvalList){
            if(ar.checked) a.add(ar);
        }

        return a;
    }

    public Map<Id,sObject> sObjectMap {get;set;}

    private final static Set<Schema.sObjectType> OBJECT_TYPES_WE_CARE_ABOUT = new Set<Schema.sObjectType>{
        club62__Invoice__c.getSObjectType()        
    };
    //Constructor
    public C62MassApproveStatementsController(){
        /* might have gone a bit overboard here. It will collate the items that need to be approved by sobject type of the target id */
        setupData();
    }
    //To setup data
    public void setupData(){
        approvalList = new List<ApprovalRow>();
        sObjectMap = new Map<Id,sObject>();
        
        List<ProcessInstanceWorkitem> piw = [select Id, CreatedBy.Name, ProcessInstance.TargetObjectId,ProcessInstance.Status from ProcessInstanceWorkitem order by createddate desc limit 50];

        for(ProcessInstanceWorkitem p : piw){
            if(OBJECT_TYPES_WE_CARE_ABOUT.contains(p.ProcessInstance.TargetObjectId.getSObjectType())){
                sObjectMap.put(p.ProcessInstance.TargetObjectId, null);   
            }           
        }

        Map<sObjectType, List<Id>> sObjectTypeMap = new Map<sObjectType,List<Id>>();

        for(Id i : sObjectMap.keySet()){
            if(sObjectTypeMap.containsKey(i.getSobjectType()) == false){
                sObjectTypeMap.put(i.getSobjectType(), new List<Id>());
            }

            sObjectTypeMap.get(i.getSobjectType()).add(i);
        }

        for(sObjectType s : sObjectTypeMap.keySet()){
            List<Id> theseIds = sObjectTypeMap.get(s);
            sObjectMap.putAll(Database.query('Select Id,Name,club62__Customer__c,club62__Customer__r.Name,club62__Statement_Amount__c from ' + s.getDescribe().getName() + ' where Id in :theseIds'));
        }

        for(ProcessInstanceWorkitem p : piw){
            if(p.ProcessInstance.TargetObjectId.getSObjectType() == club62__Invoice__c.getSObjectType()){
                approvalList.add(new ApprovalRow(p));
            }
        }
    }
    //Mass Approve records
    public void DoApproval(){
        for(ApprovalRow ar : getSelectedRows()){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments('Approving request using Mass Approve Statement Page');
            req.setAction('Approve');
            req.setWorkItemId(ar.piw.id);
            Approval.ProcessResult result = Approval.process(req);
        }
        //To set data after approval
        setupData();
    }
}