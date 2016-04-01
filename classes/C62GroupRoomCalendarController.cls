/*
@Name            : C62GroupRoomCalendarController 
@Author          : customersuccess@cloud62.com
@Date            : May 9, 2014
@Description     : Controller for C62GroupRoomCalendar page
*/
global with sharing class C62GroupRoomCalendarController {
    //Class variables
    public List<BookingObject> cBookings {get;set;}
    public List<String> cDays {get;set;}
    public club62__Room_Reservation__c cSearchRR {get;set;}
    public BookingObject totalsObject{get;set;}
    /*
    @Name   :C62RoomAvailabilityCalendarController
    @Description :Constructor SearchRR.club62__To__cr to initalize the page
    */
    public C62GroupRoomCalendarController (){
        cSearchRR = new club62__Room_Reservation__c();
        //Setting from and to date if you not entered the value
        if(cSearchRR.club62__From__c == null && cSearchRR.club62__To__c == null){
            cSearchRR.club62__From__c  = System.today();
            cSearchRR.club62__To__c = cSearchRR.club62__From__c.addDays(6); 
        }
        getReservations();
    } 
    
    /*
    @Name   :getBookings
    @Description :Sets up the bookings for the dates chosen
    */
    public void getReservations(){
        cDays = new List<String>();
        for(Integer i = 0; i < cSearchRR.club62__From__c.daysBetween(cSearchRR.club62__To__c)+1; i++){
                Date dt = cSearchRR.club62__From__c.addDays(i);
                cDays.add(dt.format());
            }
        cBookings = new List<BookingObject>();
        if(cSearchRR.club62__From__c != null && cSearchRR.club62__To__c != null && cSearchRR.club62__From__c < cSearchRR.club62__To__c){
            Date dupeFrom = cSearchRR.club62__From__c;
            Date dupeTo = cSearchRR.club62__To__c;
            //Get room reservation between search start date and search end date.
            String strQuery = 'Select count(id) roomSum, club62__Reservation__r.Name name, club62__From__c myFrom, club62__To__c myTo, club62__Group_Block_Name__c gbn FROM club62__Room_Reservation__c ' +
             ' WHERE ((club62__From__c >= '+String.valueOf(cSearchRR.club62__From__c)+' AND club62__From__c <= '+String.valueOf(cSearchRR.club62__To__c)+') OR'+
              ' (club62__To__c >= '+String.valueOf(cSearchRR.club62__From__c)+' AND club62__To__c <= '+String.valueOf(cSearchRR.club62__To__c)+') OR'+
              ' (club62__From__c < '+String.valueOf(cSearchRR.club62__From__c)+' AND club62__To__c > '+String.valueOf(cSearchRR.club62__To__c)+'))'+
            ' AND club62__Sponsoring_Customer__c != null  GROUP BY club62__Reservation__r.Name, club62__Group_Block_Name__c, club62__From__c, club62__To__c';
            
            AggregateResult[] groupedResults = Database.query(strQuery);

            //first off, get the data ready
            Map<String, Map<String, Integer>> dateCountMap = new Map<String, Map<String, Integer>>();
            for(AggregateResult ar: groupedResults){
                String tmpStr = String.valueof(ar.get('name'));
                if(tmpStr==null || tmpStr==''){
                    tmpStr = String.valueof(ar.get('gbn'));
                }
                if(!dateCountMap.containsKey(tmpStr) && tmpStr!=null && tmpStr!=''){
                    dateCountMap.put(tmpStr, new Map<String, Integer>());
                    Date tempFrom = parseDate(String.valueof(ar.get('myFrom')));
                    Date tempTo = parseDate(String.valueof(ar.get('myTo')));
                    for(Integer i = 0; i < tempFrom.daysBetween(tempTo)+1; i++){
                        dateCountMap.get(tmpStr).put(tempFrom.addDays(i).format(), Integer.valueOf(ar.get('roomSum')));
                    }
                } else if(tmpStr!=null && tmpStr!=''){
                    Date tempFrom = parseDate(String.valueof(ar.get('myFrom')));
                    Date tempTo = parseDate(String.valueof(ar.get('myTo')));
                    for(Integer i = 0; i < tempFrom.daysBetween(tempTo)+1; i++){
                        if(!dateCountMap.get(tmpStr).containsKey(tempFrom.addDays(i).format())){
                            dateCountMap.get(tmpStr).put(tempFrom.addDays(i).format(), Integer.valueOf(ar.get('roomSum')));
                        } else {
                            Integer newCount = dateCountMap.get(tmpStr).get(tempFrom.addDays(i).format()) +  Integer.valueOf(ar.get('roomSum'));
                            dateCountMap.get(tmpStr).put(tempFrom.addDays(i).format(), newCount);
                        }
                    }
                }
            }
            //get reservation id for the link
            Map<String, Id> resIdMap = new Map<String, Id>();
            Map<ID,club62__Reservation__c> resList = new Map<ID,club62__Reservation__c>([SELECT Id,Name,club62__Sponsoring_Customer__c,
                                                                    (SELECT ID,Name FROM club62__Room_Reservations__r) 
                                                                     FROM club62__Reservation__c WHERE Name IN :dateCountMap.keyset()]);
            for(club62__Reservation__c myRes: resList.values()){
                resIdMap.put(myRes.Name, myRes.Id);
            }
            Map<ID,club62__Room_Reservation__c> rresList = new Map<ID,club62__Room_Reservation__c>([SELECT Id,club62__Group_Category__c,club62__Group_Category__r.club62__Parent_Category__c,
                                                club62__Group_Block_Name__c FROM club62__Room_Reservation__c WHERE club62__Group_Block_Name__c IN :dateCountMap.keyset() AND club62__Reservation__c=null]);
            for(club62__Room_Reservation__c myRes: rresList.values()){
                resIdMap.put(myRes.club62__Group_Block_Name__c, myRes.Id);
            }
            //this is for the totals:
            Map<String, Integer> totalsMap = new Map<String, Integer>();
            for(String day: cDays){
                totalsMap.put(day, 0);
            }
            //now that that's over with, put that data in a format a chart can understand
            for(String res: dateCountMap.keyset()){
                BookingObject myBO = new BookingObject();
                myBO.cells = new List<String>();
                myBO.reservation = res;
                myBO.resId = resIdMap.get(res);
                if(((ID)(resIdMap.get(res))).getsObjectType().getDescribe().getName()=='club62__Room_Reservation__c' && 
                    rresList.containsKey(resIdMap.get(res)) && rresList.get(resIdMap.get(res)).club62__Group_Category__c!=null){
                    myBO.resId = 'apex/club62__Room_Reservation?id='+resIdMap.get(res)+'&groupBlock=true&groupRR=true';
                }
                
                if(((ID)(resIdMap.get(res))).getsObjectType().getDescribe().getName()=='club62__Reservation__c' 
                    && resList.containsKey(resIdMap.get(res)) && resList.get(resIdMap.get(res)).club62__Sponsoring_Customer__c!=null 
                    && resList.get(resIdMap.get(res)).club62__Room_Reservations__r!=null 
                    && resList.get(resIdMap.get(res)).club62__Room_Reservations__r.size()>0){
                    myBO.resId = 'apex/club62__Room_Reservation?id='+resList.get(resIdMap.get(res)).club62__Room_Reservations__r.get(0).ID
                                 +'&MemberSponsoredEventId='+resIdMap.get(res)+'&groupRR=true';
                }
                
                
                for(Integer i = 0; i < cSearchRR.club62__From__c.daysBetween(cSearchRR.club62__To__c)+1; i++){
                    if(dateCountMap.get(res).containsKey(cSearchRR.club62__From__c.addDays(i).format())){
                        myBO.cells.add(String.valueof(dateCountMap.get(res).get(cSearchRR.club62__From__c.addDays(i).format())));
                        Integer tempInt = totalsMap.get(cSearchRR.club62__From__c.addDays(i).format()) + dateCountMap.get(res).get(cSearchRR.club62__From__c.addDays(i).format());
                        totalsMap.put(cSearchRR.club62__From__c.addDays(i).format(), tempInt);
                    } else {
                        myBO.cells.add('0');
                    }
                }
                cBookings.add(myBO);
            }
            BookingObject totalObj = new BookingObject();
            totalObj.cells = new List<String>();
            totalObj.Reservation = 'Totals';
            for(Integer i = 0; i < cSearchRR.club62__From__c.daysBetween(cSearchRR.club62__To__c)+1; i++){
                totalObj.cells.add(String.valueof(totalsMap.get(cSearchRR.club62__From__c.addDays(i).format())));
            }
            totalsObject = totalObj;
        }
    }  
    
    /*
    @Name   :prevWeek
    @Description :Display the previous week 
    */
    public PageReference prevWeek(){
        cSearchRR.club62__From__c = cSearchRR.club62__From__c.addDays(-7);
        cSearchRR.club62__To__c = cSearchRR.club62__From__c.addDays(6);
        getReservations();
        return null;
    }
    
    /*
    @Name   :nextWeek
    @Description :Display the next week 
    */
    public PageReference nextWeek(){
        cSearchRR.club62__From__c = cSearchRR.club62__To__c.addDays(1);
        cSearchRR.club62__To__c = cSearchRR.club62__From__c.addDays(6);
        getReservations();
        return null;
    }
    
    /*
    @Name   :monthlyView
    @Description :Display the month view 
    */
    public PageReference monthlyView(){
        cSearchRR.club62__From__c = Date.newInstance(cSearchRR.club62__From__c.year(),cSearchRR.club62__From__c.month(),1);
        cSearchRR.club62__To__c = Date.newInstance(cSearchRR.club62__From__c.year(),cSearchRR.club62__From__c.month(),date.daysInMonth(cSearchRR.club62__From__c.year(),cSearchRR.club62__From__c.month()));
        getReservations();
        return null;
    }
    
    public void getBookings(){}
    /*
    @Name   :BookingObject
    @Description :Object 
    */
    public class BookingObject{
        public String reservation{get;set;}
        public String resId {get;set;}
        public List<String> cells {get;set;}
    }
    
    private Date parseDate(String s){
    Integer year, month, day;
    year = Integer.valueof(s.substring(0, 4));
    month = Integer.valueof(s.substring(5, 7));
    day = Integer.valueof(s.substring(8, 10));
    Date d = Date.newInstance(year,month,day);
    return d;
    }
    /*2014-04-14
    @Name   :CellItem
    @Description :Object 
    //
    public class CellItem{
        public String count{get;set;}
    }*/
}