@RestResource(urlMapping='/C62ReservationEvent/*')
global without sharing class C62ReservationEvent{

    /*
    @Name   :getMonthlyEvents
    @Description :returns the events for the month for the top quick access table
    */
    @HttpPost
    global static List<ReservationWrapper> getReservationEvent(String exampleParam){
        if(exampleParam!=null && exampleParam!=''){exampleParam = EncodingUtil.urlDecode(exampleParam, 'ISO-8859-1');}
        system.debug('<<<<exampleParam>>>>'+exampleParam);
        List<club62__Reservation__c> lstRes = Database.query('SELECT club62__Club_Location__r.Name,' + C62Utilities.getFields('club62__Reservation__c') + ' FROM club62__Reservation__c WHERE Id = \'' + String.escapeSingleQuotes(exampleParam) + '\' LIMIT 1');
        User usr = [SELECT Id,ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        List<club62__Reservation_Registration__c> rrLst = database.query('Select '+C62Utilities.getFields('club62__Reservation_Registration__c')
                +',(Select club62__Person__r.Name,club62__Person__r.club62__Email__c,'+C62Utilities.getFields('club62__Reservation_Registration__c')
                +' FROM club62__Reservation_Registrations__r) FROM club62__Reservation_Registration__c where club62__Reservation__c =\''
                +String.escapeSingleQuotes(exampleParam)+'\' AND club62__Customer__c =\''+usr.ContactId+'\' AND club62__Reservation_Registration__c=null');
        List<ReservationWrapper> resWLst = new List<ReservationWrapper>();
        ReservationWrapper rw = new ReservationWrapper();
        rw.userData=usr;
        if(lstRes.size()>0){
            rw.res=lstRes.get(0);
            rw.timeList = String.valueOf(lstRes.get(0).StartTime__c);
            if(lstRes.get(0).StartTime__c!=null){
                rw.startTime = lstRes.get(0).StartTime__c.format('h:mm a');
                rw.startDate = lstRes.get(0).StartTime__c.format('MM/dd/YYYY');
            }else{
                rw.startTime = '';
                rw.startDate = '';
            }
            if(lstRes.get(0).club62__Club_Location__c!=null){rw.clubName=lstRes.get(0).club62__Club_Location__r.Name;}
        }
        if(rrLst.size()>0){rw.rr=rrLst.get(0);}else{rw.rr=new club62__Reservation_Registration__c();}
        resWLst.add(rw);
        return resWLst;
    }
    
    global class ReservationWrapper{
        public User userData{get;set;}
        public club62__Reservation__c res{get;set;}
        public club62__Reservation_Registration__c rr{get;set;}
        public String clubName{get;set;}
        public String timeList{get;set;}
        public String startTime{get;set;}
        public String startDate{get;set;}
    }
}