/*
@Name               : C62CommunityMyEventsController
@Author             : customersuccess@cloud62.com
@Date               : Mar 6, 2014
@Description        : Controller for CommunityMyEvents page
*/
public with sharing class C62CommunityMyEventsController{
    //Class variables
    public club62__Reservation__c cFilterRes {get;set;}
    public List<ResReg> clstResReg {get;set;}
    public Contact cMember {get;set;}
    public ResReg cResReg {get;set;}
    public String cSelResRegId {get;set;}
    public Boolean cShowRegComp {get;set;}
    
    /*
    @Name   :ResReg
    @Description :Inner class that holds the full reservation with the full registration
    */
    public class ResReg{
        public club62__Reservation__c res {get;set;}
        public club62__Reservation_Registration__c reg {get;set;}
    }
    
    /*
    @Name   :C62CommunityMyEventsController
    @Description :Constructor to initalize the page
    */
    public C62CommunityMyEventsController(){
        try{
            cShowRegComp = false;
            cFilterRes = new club62__Reservation__c();
            User use = [SELECT Id,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            String memId = use.ContactId;
            List<Contact> lstCon = Database.query('SELECT ' + C62Utilities.getFields('Contact') + ' FROM Contact WHERE Id = :memId');
            cMember = lstCon.get(0);
            load();
        }catch(Exception e){
            throw new C62Utilities.CustomException(e.getMessage() + e.getLineNumber() + e.getStackTraceString());
        }
    }
    
    /*
    @Name   :load
    @Description :loads the reservation and registrations
    */
    public void load(){
        Set<String> setStatuses = new Set<String>{'No','Cancelled'};
        Date dtFStart = cFilterRes.club62__Recurring_Start_Date__c;
        Date dtFEnd = cFilterRes.club62__Recurring_End_Date__c;
        String strResRegQuery = 'SELECT '
            + C62Utilities.getFields('club62__Reservation_Registration__c')
            + ' FROM club62__Reservation_Registration__c'
            + ' WHERE club62__Reservation__r.RecordType.Name = \'Event\''
            + ' AND club62__Customer__c = \'' + String.escapeSingleQuotes(cMember.Id) + '\''
            + ' AND club62__Person__c = null'
            + ' AND club62__Status__c NOT IN :setStatuses'
            + ' AND club62__Reservation__r.club62__Hidden_From_Portal__c=FALSE';
        //Apply filters    
        if(dtFStart != null){
            strResRegQuery += ' AND club62__Reservation__r.club62__StartTime__c >= :dtFStart';
        } else {
            strResRegQuery += ' AND club62__Reservation__r.club62__StartTime__c >= YESTERDAY';
        }
        if(dtFEnd != null){
            strResRegQuery += ' AND club62__Reservation__r.club62__EndTime__c <= :dtFEnd';
        }    
        List<club62__Reservation_Registration__c> lstResRegs = Database.query(strResRegQuery);
        //Get the reservations for the registrations
        Set<Id> setResIds = new Set<Id>();
        for(club62__Reservation_Registration__c resReg : lstResRegs){
            setResIds.add(resReg.club62__Reservation__c);
        }
        //Getting reservation details where hidden from portal is false.
        String strResQuery = 'SELECT club62__Club_Location__r.Name,'
            + C62Utilities.getFields('club62__Reservation__c')
            + ' FROM club62__Reservation__c'
            + ' WHERE Id IN :setResIds'
            + ' AND club62__Hidden_From_Portal__c=FALSE';
        List<club62__Reservation__c> lstRes = Database.query(strResQuery);
        Map<Id,club62__Reservation__c> mapRes = new Map<Id,club62__Reservation__c>();
        for(club62__Reservation__c res : lstRes){
            if(!mapRes.containsKey(res.Id)) mapRes.put(res.Id,res);
        }
        clstResReg = new List<ResReg>();
        for(club62__Reservation_Registration__c resReg : lstResRegs){
            club62__Reservation__c res = mapRes.get(resReg.club62__Reservation__c);
            ResReg rr = new ResReg();
            rr.res = res;
            rr.reg = resReg;
            clstResReg.add(rr);
        }
    }
    
    /*
    @Name   :selectResReg
    @Description :sets the cResReg based on the cSelResRegId from the clstResReg
    */
    //Select reservation registration.
    public void selectResReg(){
        cResReg = null;
        if(cSelResRegId != null){
            for(ResReg resReg : clstResReg){
                if(resReg.reg.Id == cSelResRegId){
                    cResReg = resReg;
                    break;
                }
            }
        }
        if(cResReg != null){
            cShowRegComp = true;
        } else {
            cShowRegComp = false;
        }
    }
}