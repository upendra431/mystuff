/*
@Name            : C62CalendarController
@Author          : customersuccess@cloud62.com
@Date            : Nov 5, 2013
@Description     : Controller for EventCalendar page
*/
global with sharing class C62CalendarController{

    //Class variables
    private static club62__C62CalendarOptions__c cCalOpts{get;set;}
    public static Boolean cAllowDragging{get;set;}
    public static String cFacilityId {get;set;}
    public static Boolean cSeatsAvailable {get;set;}
    public static Boolean cConfirmedEvents {get;set;}
    public static String cJSONReservation {get;set;}
    public Boolean showAddRoom{get;set;}
    public Boolean sameAsPrimaryContact{get;set;}
    public Long cStartDt {get;set;}
    public Long cEndDt {get;set;}
    public String cFacId {get;set;}
    public Date bookingCompareDate{get;set;}
    public String cObjType {get;set;}
    public String cObjId {get;set;}
    public String cNewRecordType {get;set;}
    public String descriptionFromMemButton {get;set;}
    public String descriptionFromPrimaryButton {get;set;}
    public String descriptionFromPaymentButton {get;set;}
    public String descriptionFromInsButton {get;set;}
    public club62__Institution__c cNewInstitution {get;set;}
    public club62__Person__c cNewPrimaryPerson {get;set;}
    public club62__Person__c cNewPaymentPerson {get;set;}
    public club62__Address__c cNewPrimaryPerAdd {get;set;}
    public club62__Address__c cNewInstitutionAdd {get;set;}
    public club62__Address__c cNewPaymentPerAdd {get;set;}
    public Boolean cNewRecShowPopup {get;set;}
    public club62__Institution__c cSearchInstitution {get;set;}
    public Contact cSearchMember {get;set;}
    public String descriptionFromInsFilter {get;set;}
    public String descriptionFromMemFilter {get;set;}
    public String selectedEventTypeFilter{get;set;}
    public String cSearchObjType {get;set;}
    public String cSearchObjId {get;set;}
    public List<club62__Reservation__c> mseList {get;set;}
    public club62__Reservation__c cSearchReservation{get;set;}
    private Map<String,String> cMapIdObjName{get;set;}
    public static Map<String,RecordType> cmapRT {get
                                                    {
                                                        if(cmapRT == null){
                                                            cmapRT = new Map<String,RecordType>();
                                                            for(RecordType rt : [SELECT Id,Name FROM RecordType WHERE sObjectType = 'club62__Reservation__c']){
                                                                cmapRT.put(rt.Name,rt);
                                                            }
                                                        }
                                                        return cmapRT;
                                                    }set;} //singleton Map of record type.name to record type for reservation objects
    private String cPageName{get;set;}
    private List<String> clstFacTypes{get;set;}
    public static Map<String,String> cmapVARs {get{
                                                        if(cmapVARs == null){
                                                            cmapVARs = new Map<String,String>();
                                                            cmapVARs.put('"id":','"idVAR":');
                                                            cmapVARs.put('"title":','"titleVAR":');
                                                            cmapVARs.put('"allDay":','"allDayVAR":');
                                                            cmapVARs.put('"start":','"startVAR":');
                                                            cmapVARs.put('"url":','"urlVAR":');
                                                            cmapVARs.put('"color":','"colorVAR":');
                                                            cmapVARs.put('"tooltip":','"tooltipVAR":');
                                                            cmapVARs.put('"resource":','"resourceVAR":');
                                                            cmapVARs.put('"reservation":','"reservationVAR":');
                                                            cmapVARs.put('"editable":','"editableVAR":');
                                                            cmapVARs.put('"type":','"typeVAR":');
                                                            cmapVARs.put('"end":','"endVAR":');
                                                        }
                                                        return cmapVARs;
                                                    }set;}
    //Variables for popup
    public club62__Reservation__c cReservation {get;set;}
    public Boolean cShowPopup {get;set;}
    public club62__Reservation_Registration__c cRegFilter {get;set;}
    private Integer cIndex {get;set;}
    public List<GridItem> clstAddGrid {get;set;}
    public List<GridItem> clstAddGroupGrid {get;set;}
    public List<GridItem> clstMemberGrid {get;set;}
    public List<GridItem> clstBuddyGrid {get;set;}
    public String cRTName {get;set;}
    public String cGrpRes {get;set;}
    public String cGrpResCancel {get;set;}
    public List<GroupReservation> clstGrpRes {get;set;}
    public GroupReservation cGrpResSelected {get;set;}
    public Integer cResIndex {get;set;}
    public Integer cResSelectedIndex {get;set;}
    public club62__Room_Category__c cGrpRoomCat {get;set;}
    public Map<Id,Set<Id>> cMapOrigGrpCat {get;set;}
    public Map<Id,club62__Facility__c> facIdToMap{get;set;}
    public String cSportBuddyPopup{get;set;}
    public List<CancelTerm> clstCancelTerms {get;set;}
    public List<CancelTerm> clstDelCancelTerms {get;set;}
    public CancelTerm cCancelTermSelected {get;set;}
    public String cCancelPage {get;set;}
    public Integer cCancelTermIndex {get;set;}
    public club62__Sports_Buddy__c spbuddy {get;set;}
    public Boolean cNeedPartnerFilter {get;set;}
    public Boolean cDoCancel {get;set;}
    public Boolean addGroupMember{get;set;} //false for adding group, true for adding member
    public club62__Group_Customer__c cGrpFilter{get;set;}
    public String cCancelConfirmPage {get;set;}
    public List<SportCharge> clstSportCharges {get;set;}
    public Integer cSCIndex {get;set;}
    public Integer cSelSC {get;set;}
    public club62__Transaction__c cOptSC {get;set;}
    //Calendar Messages variables
    public Integer cStartYear {get;set;}
    public Integer cStartMonth {get;set;}
    public Integer cStartDay {get;set;}
    public Integer cEndYear {get;set;}
    public Integer cEndMonth {get;set;}
    public Integer cEndDay {get;set;}
    transient public List<club62__Calendar_Message__c> cCalMessages {get;set;}
    //Class calendar variables
    public String cFacName {get;set;}
    public String recurringday{get;set;}
    public List<SelectOption> statusPickListOptions{get;set;}
    public List<SelectOption> recStartEndTimes{get;set;}
    public Boolean crecurringEvent{get;set;}
    //Variables for Recurring Event
    public Boolean rMonday{get;set;}
    public Boolean rTuesday{get;set;}
    public Boolean rWednesday{get;set;}
    public Boolean rThursday{get;set;}
    public Boolean rFriday{get;set;}
    public Boolean rSaturday{get;set;}
    public Boolean rSunday{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListSu{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListM{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListTu{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListW{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListTh{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListF{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListSa{get;set;}
    public Integer removalIndex{get;set;}
    Map<Id,String> facNameMap {get;set;}
    //Variables for Action Chaining
    public boolean doneChaining {get;set;}
    Public List<String> errorStringList {get;set;}
    public List<club62__Reservation__c> clstRecurRes {get;set;}
    public List<club62__Reservation__c> clstValidatedRecur {get;set;}
    public List<String> clstErrorRecur {get;set;}
    public Boolean cSavingRecurrences {get;set;}
    public Boolean cSaveError {get;set;}
    public String sessionYear{get;set;}
    public String sessionMonth{get;set;}
    public String sessionDay{get;set;}
    public String squashType{get;set;}
    
    /*
    @Name   :CancelTerm
    @Description :Used in the Cancellation Terms section
    */
    public class CancelTerm{
        public club62__Reservation_Cancellation_Term__c cancelTerm {get;set;}
        public Integer intIndex {get;set;}
        public CancelTerm(Integer index){
            intIndex = index;
        }
    }

    public class RecurringWrapper{
        public String startTime{get;set;}
        public String endTime{get;set;}
        public Integer index{get;set;}
        public recurringWrapper(Integer indexNum){
            index=indexNum;
        }
    }

    /*
    @Name   :GroupReservation
    @Description :Used in the group reservation section
    */
    public class GroupReservation{
        public List<GroupItem> lstGIs {get;set;}
        public club62__Room_Category__c roomCat {get;set;}
        public List<club62__Room_Rate__c> roomRates {get;set;}
        public Integer intIndex {get;set;}
        public Boolean hasMemPer {get;set;} //indicates there is at least 1 member or person assigned to a room reservation
        public club62__Reservation__c grpParams {get;set;}//fields are used to store values according to type
                                                /*mapping is:
                                                    number of rooms = club62__max_seats__c
                                                    room rate = club62__deposit_amount__c
                                                    check in = club62__recurring_start_date__c
                                                    check out = club62__recurring_end_date__c
                                                    show grid = club62__paid_event__c*/
        public GroupReservation(Integer index){
            intIndex = index++;
            hasMemPer = false;
        }
    }

    /*
    @Name   :GroupItem
    @Description :Used in the group reservation section
    */
    public class GroupItem{
        public club62__Room_Category__c roomCat {get;set;}
        public List<club62__Room_Reservation__c> roomRes {get;set;}
        public List<SelectOption> availability {get;set;}
        public String numRoom {get;set;}
        public String origNumRoom {get;set;}
        public club62__Room_Reservation__c giParams {get;set;}
        public List<SelectOption> lstPaying {get{IF(lstPaying == null){
                                                    lstPaying = new List<SelectOption>();
                                                    lstPaying.add(new SelectOption('Guest','Guest'));
                                                    lstPaying.add(new SelectOption('Sponsoring Member','Sponsoring Member'));
                                                    lstPaying.add(new SelectOption('Banquet','Banquet'));
                                                }
                                                return lstPaying;}set;}
    }

    /*
    @Name   :GridItem
    @Description :Grid Item
    */
    public class GridItem{
        public Integer index {get;set;}
        public Boolean bolSelected {get;set;}
        public club62__Sports_Buddy__c spBuddy{get;set;}
        public club62__Reservation_Registration__c reg {get;set;}
        public String memberName {get;set;}
        public String memberID {get;set;}
        public club62__Game_Invite__c gInvite {get;set;}
        public String sbType {get;set;}
        public club62__Group__c mGroup{get;set;}
        public club62__Transaction__c classCharge {get;set;}
        public GridItem(Integer dex){
            bolSelected = false;
            reg = new club62__Reservation_Registration__c();
            index = dex;
        }
        public GridItem(Integer dex,String type){
            this(dex);
            sbType = type;
        }
    }

    /*
    @Name   :FCEvent
    @Description :Event object for the calendar fields gathered from this link: http://arshaw.com/fullcalendar/docs/event_data/Event_Object/
    @Note: Added VAR to end of each class variable as some are reserved words, remove VAR when converting to JSON
    */
    public class FCEvent{
        String idVAR {get;set;}
        String titleVAR {get;set;}
        Boolean allDayVAR {get;set;}
        DateTime startVAR {get;set;}
        DateTime endVAR {get;set;}
        String urlVAR {get;set;}
        String colorVAR {get;set;}
        String tooltipVAR {get;set;}
        String resourceVAR {get;set;}
        club62__Reservation__c reservationVAR {get;set;}
        Boolean editableVAR {get;set;}
        String typeVAR {get;set;}
    }

    /*
    @Name   :FCResource
    @Description :Resource object for the calendar fields gathered from this link: http://arshaw.com/fullcalendar/docs/event_data/Event_Object/
    @Note: Added VAR to end of each class variable as some are reserved words, remove VAR when converting to JSON
    */
    public class FCResource{
        String idVAR {get;set;}
        String nameVAR {get;set;}
        String parentVAR {get;set;}
        Boolean readonlyVAR {get;set;}
    }

    /*
    @Name   :SportCharge
    @Description :
    */
    public class SportCharge{
        public club62__Sport_Reservation_Equipment__c sre {get;set;}
        public Integer index {get;set;}
        public String name {get;set;}
        public SportCharge(Integer dex){
            index = dex;
        }
    }

    /*
    @Name   :C62CalendarController
    @Description :Constructor to initalize the page
    */
    public C62CalendarController(){
        //Initialize data
        clstSportCharges = new List<SportCharge>();
        cOptSC = new club62__Transaction__c();
        cOptSC.club62__Quantity__c = 1;
        cSCIndex = 0;
    bookingCompareDate = Date.Today().addYears(-1);
        cSavingRecurrences = false;
        cSaveError = false;
        cSportBuddyPopup= 'Hide';
        cDoCancel = false;
        spbuddy = new club62__Sports_Buddy__c();
        cGrpRes = 'Hide';
        cCancelPage = 'Hide';
        cCancelConfirmPage = 'Hide';
        showAddRoom = false;
        cCancelTermIndex = 0;
        clstGrpRes = null;
        cGrpResSelected = null;
        cResIndex = 0;
        cResSelectedIndex = null;
        cSeatsAvailable = false;
        cCalOpts = club62__C62CalendarOptions__c.getOrgDefaults();
        cAllowDragging = cCalOpts.club62__Allow_Dragging_Events__c;
        cReservation = new club62__Reservation__c();
        cShowPopup = false;
        cIndex = 0;
        cStartDt = DateTime.now().getTime();
        cEndDt = DateTime.now().getTime();
        cFacId = '';
        cMapIdObjName = C62Utilities.getPrefixMapCalCont(false);
        cNewRecShowPopup = false;
        cSearchInstitution = new club62__Institution__c();
        cSearchMember = new Contact();
        cSearchReservation = new club62__Reservation__c();
        //Set information based on the calendar we are on
        String strPageName = ApexPages.currentPage().getUrl();
        clstFacTypes = new List<String>();
        if(strPageName.toLowerCase().contains('event_calendar')){
            cPageName = 'Event_Calendar';
            clstFacTypes.add('Event');
        } else if (strPageName.toLowerCase().contains('class_calendar')){
            cPageName = 'Class_Calendar';
            clstFacTypes.add('Class');
        } else if (strPageName.toLowerCase().contains('sport_calendar')){
            cPageName = 'Sport_Calendar';
            clstFacTypes.add('Sport');
        } else {
            cPageName = null;
        }
        facIdToMap = new Map<Id,club62__Facility__c>();
        cNeedPartnerFilter = false;
        addGroupMember = false;
        cGrpFilter = new club62__Group_Customer__c();
        recurringstartEndTimeListSu = new List<recurringWrapper>();
        recurringstartEndTimeListM = new List<recurringWrapper>();
        recurringstartEndTimeListTu = new List<recurringWrapper>();
        recurringstartEndTimeListW = new List<recurringWrapper>();
        recurringstartEndTimeListTh = new List<recurringWrapper>();
        recurringstartEndTimeListF = new List<recurringWrapper>();
        recurringstartEndTimeListSa = new List<recurringWrapper>();
        for(Integer i=0; i<7;i++){
            recurringday=i+'';
            addRecurringRow();
        }
        cmapRT = new Map<String,RecordType>();
        for(RecordType rt : [SELECT Id,Name FROM RecordType WHERE sObjectType = 'club62__Reservation__c']){
            cmapRT.put(rt.Name,rt);
        }
        cRecurringEvent = false;
        cFacName = '';
        facNameMap  = new Map<Id,String>();
        cFacilityId = '';
        statusPickListOptions = new List<SelectOption>();
        getStatusPLValues();
        recStartEndTimes= new List<SelectOption>();
        getrecSEPLValues();
        doneChaining=true;
        errorStringList = new List<String>();
    }
    
    public void init(){
        if(ApexPages.currentPage().getUrl().toLowerCase().contains('event_calendar')){
            //Using custom setting C62User Session Settings to track last view of the calendar.
            List<club62__C62User_Session_Settings__c> usSettings = club62__C62User_Session_Settings__c.getAll().values();
            club62__C62User_Session_Settings__c newSession;
            for(club62__C62User_Session_Settings__c uss : usSettings){
                if(uss.Name==UserInfo.getUserId().subString(0,15)){
                    newSession = uss;
                    sessionYear = uss.club62__Event_Calendar_Last_View_Date__c.Year()+'';
                    sessionMonth = uss.club62__Event_Calendar_Last_View_Date__c.Month()+'';
                    sessionDay = uss.club62__Event_Calendar_Last_View_Date__c.Day()+'';
                }
            }
            if(newSession==null){newSession = new club62__C62User_Session_Settings__c(Name=UserInfo.getUserId().subString(0,15));}
            newSession.club62__Event_Calendar_Last_View_Date__c = System.today();
            upsert newSession;
        }
    }
    
    /*
    @Name   :JSONObject
    @Description :Object
    */
    public class JSONObject{
        public String category {get;set;}
        public String id {get;set;}
        public String label {get;set;}
    }

    /*
    @Name :getEquipment
    @Description :list of equipment available for the chosen facility
    */
    public List<SelectOption> getEquipment(){
        List<SelectOption> lstSO = new List<SelectOption>();
        club62__Sport_Equipment__c seTemp;
        Boolean exists = false;
        lstSO.add(new SelectOption('','None'));
        for(club62__Sport_Equipment__c se : facIdToMap.get(cReservation.club62__Club_Location__c).club62__Sports_Equipment__r){
            lstSO.add(new SelectOption(se.Id,se.Name));
            if(seTemp == null) seTemp = se;
            if(cOptSC.club62__Sport_Equipment__c == se.Id) exists = true;
        }
        if(exists) cOptSC.club62__Sport_Equipment__c = seTemp.Id;
        return lstSO;
    }

    /*
    @Name   :getQuantity
    @Description :returns the quantity picklist values used in sports equipment
    */
    public List<SelectOption> getQuantity(){
        List<SelectOption> lstSO = new List<SelectOption>();
        Integer quantity = 0;
        for(club62__Sport_Equipment__c se : facIdToMap.get(cReservation.club62__Club_Location__c).club62__Sports_Equipment__r){
            if(cOptSC.club62__Sport_Equipment__c == se.Id && se.club62__Max_Reserve_Quantity__c != null){
                quantity = Integer.valueOf(se.club62__Max_Reserve_Quantity__c);
            }
        }
        for(Integer i = 1; i <= quantity; i++){
            lstSO.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return lstSO;
    }

    /*
    @Name :addEquipment
    @Description :adds a new sports charge for the equipment
    */
    public void addEquipment(){
        //Create the sport reservation equipment for the equipment and add it to the list
        String strId = cOptSC.club62__Sport_Equipment__c;
        club62__Sport_Equipment__c se = Database.query('SELECT ' + C62Utilities.getFields('club62__Sport_Equipment__c') + ' FROM club62__Sport_Equipment__c WHERE Id = :strId');
        SportCharge scItem = new SportCharge(cSCIndex++);
        club62__Sport_Reservation_Equipment__c sc = new club62__Sport_Reservation_Equipment__c();
        sc.club62__Quantity__c = cOptSC.club62__Quantity__c;
        if(sc.club62__Quantity__c == null) sc.club62__Quantity__c = 1;
        sc.club62__Sport_Equipment__c = se.Id;
        sc.club62__Amount__c = sc.club62__Quantity__c * se.club62__Fee__c;
        scItem.sre = sc;
        scItem.name = se.Name;
        clstSportCharges.add(scItem);
    }

    /*
    @Name :removeSC
    @Description :removes a sport equipment charge
    */
    public void removeSC(){
        Integer intRemove;
        for(Integer i = 0;i < clstSportCharges.size();i++){
            SportCharge sc = clstSportCharges.get(i);
            if(sc.index == cSelSC){
                intRemove = i;
                break;
            }
        }
        if(intRemove != null) clstSportCharges.remove(intRemove);
    }

    /*
    @Name :getrecSEPLValues
    @Description :Custom list of picklist values for Status to remove the option value
    */
    public void getrecSEPLValues(){
        Integer maxHour = Integer.valueOf(getEndHour());
        Integer minHour = Integer.valueOf(getStartHour());
        for(Integer i = 0; i < 24; i++){
            if(minHour <= i && i < maxHour && i < 12){
                recStartEndTimes.add(new SelectOption(i + ':00',i + ':00 AM'));
                recStartEndTimes.add(new SelectOption(i + ':30',i + ':30 AM'));
            } else if(minHour <= i && i < maxHour && i == 12){
                recStartEndTimes.add(new SelectOption('12:00','12:00 PM'));
                recStartEndTimes.add(new SelectOption('12:30','12:30 PM'));
            } else if(minHour <= i && i < maxHour && i > 12){
                recStartEndTimes.add(new SelectOption(i + ':00',(i-12) + ':00 PM'));
                recStartEndTimes.add(new SelectOption(i + ':30',(i-12) + ':30 PM'));
            }
            if(i == maxHour && maxHour < 12){
                recStartEndTimes.add(new SelectOption(i + ':00',i + ':00 AM'));
            } else if(i == maxHour && maxHour == 12){
                recStartEndTimes.add(new SelectOption('12:00','12:00 PM'));
            } else if(i == maxHour && maxHour > 12){
                recStartEndTimes.add(new SelectOption(i + ':00',(i-12) + ':00 PM'));
            }
        }
    }

    /*
    @Name :getStatusPLValues
    @Description :Custom list of picklist values for Status to remove the option value
    */
    public void getStatusPLValues(){
       statusPickListOptions.clear();
       Schema.DescribeFieldResult fieldResult = club62__Reservation_Registration__c.club62__Status__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       Set<String> setSkipValues = new Set<String>{'Waitlisted','Waitlist Pending Confirm'};
       for(Schema.PicklistEntry f : ple){
           if(!setSkipValues.contains(f.getValue())){
               statusPickListOptions.add(new SelectOption(f.getLabel(),f.getValue()));
           }
       }
    }

    /*
    @Name   :validateRecur
    @Description :Takes a reservation from clstRecurRes and validates it into clstValidatedRecur or adds an error to clstErrorRecur
    */
    public void validateRecur(){
        if(clstRecurRes != null && clstRecurRes.size() > 0){
            club62__Reservation__c res = clstRecurRes.get(0);
            SavePoint sp = Database.setSavePoint();
            try{
                if(Schema.sObjectType.club62__Reservation__c.isCreateable()){insert res;}
                if(clstValidatedRecur == null) clstValidatedRecur = new List<club62__Reservation__c>();
                clstValidatedRecur.add(res);
            }catch(DMLException e){
                if(clstErrorRecur == null) clstErrorRecur = new List<String>();
                clstErrorRecur.add(res.club62__StartTime__c.format() + ' - ' + res.club62__EndTime__c.format() + '<br/>' + e.getDmlMessage(0));
            }finally{
                Database.rollBack(sp);
                clstRecurRes.remove(0);
                if(clstRecurRes.size() == 0) clstRecurRes = null;
            }
        } else {
            clstRecurRes = null;
        }
    }

    /*
    @Name   :saveValidated
    @Description :Saves the clstValidatedRecur
    */
    public void saveValidated(){
        SavePoint sp = Database.setSavePoint();
        try{
            List<club62__Reservation__c> lstSaveRes = new List<club62__Reservation__c>();
            String strRecurDescription = 'Schedule:';
            for(club62__Reservation__c res : clstValidatedRecur){
                lstSaveRes.add(res.clone(false,true,false,false)); //Need to remove the id from validation
                strRecurDescription += '\n' + res.club62__starttime__c.format() + ' - ' + res.club62__endtime__c.format();
            }
            for(club62__Reservation__c res : lstSaveRes){
                res.club62__Recurring_Description__c = strRecurDescription;
            }
            if(Schema.sObjectType.club62__Reservation__c.isCreateable()){insert lstSaveRes;}
            for(Integer i = 0; i < lstSaveRes.size();i++){ //associate the reservations, assume if you have a recurring start date and no parent that you are the parent
                club62__Reservation__c res = lstSaveRes.get(i);
                if(i == 0){

                } else {
                    res.club62__Parent_Reservation__c = lstSaveRes.get(0).id;
                }
            }
            if(Schema.sObjectType.club62__Reservation__c.isUpdateable()){update lstSaveRes;}
            closePopup();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
            Database.rollback(sp);
        }
        clstErrorRecur = null;
        clstValidatedRecur = null;
        cSavingRecurrences = false;
    }

    /*
    @Name   :resetRecur
    @Description :Resets the recurrance vars
    */
    public void resetRecur(){
        clstErrorRecur = null;
        clstValidatedRecur = null;
        clstRecurRes = null;
        cSavingRecurrences = false;
    }

    /*
    @Name   :editReservation
    @Description :Converts the reservatioin clicked in the grid and displays it in the popup
    */
    public void editReservation(){
        showAddRoom = false;
        clstSportCharges = new List<SportCharge>();
        clstCancelTerms = null;
        clstGrpRes = null;
        addGroupMember = false;
        String strJSON = cJSONReservation;
        for(String strKey : cmapVARs.keySet()){
            strJSON = strJSON.replaceFirst(strKey,cmapVARs.get(strKey));
        }
        FCEvent fce = (FCEvent)JSON.deserialize(strJSON,FCEvent.class);
        cReservation = convertToSFReservation(fce);
        String strId = cReservation.Id;
        club62__Reservation__c tmpRes = [Select Id,club62__Sponsoring_Customer__c,RecordType.Name,club62__Sponsoring_Customer__r.Name,club62__Institution__c,club62__Institution__r.Name,club62__Customer__r.Name,
            club62__Primary_Contact__c,club62__Primary_Contact__r.Name,club62__Payment_Contact__c,club62__Payment_Contact__r.Name From club62__Reservation__c Where Id=:strId];
        if(tmpRes.RecordType.Name=='Sponsored Event'){
            descriptionFromMemButton = tmpRes.club62__Sponsoring_Customer__r.Name;
            if(tmpRes.club62__Institution__c!=null){
                descriptionFromInsButton = tmpRes.club62__Institution__r.Name;
            }
            if(tmpRes.club62__Primary_Contact__c!=null){
                descriptionFromPrimaryButton = tmpRes.club62__Primary_Contact__r.Name;
            }
            if(tmpRes.club62__Payment_Contact__c!=null){
                descriptionFromPaymentButton = tmpRes.club62__Payment_Contact__r.Name;
            }
        }else if(tmpRes.RecordType.Name=='Sport'){
            descriptionFromMemButton = tmpRes.club62__Customer__r.Name;
        }else if(tmpRes.RecordType.Name=='Event' || tmpRes.RecordType.Name=='Class'){
            if(tmpRes.club62__Sponsoring_Customer__c!=null){descriptionFromMemButton = tmpRes.club62__Sponsoring_Customer__r.Name;}
        }
        List<club62__Sport_Reservation_Equipment__c> lstSC = Database.query('SELECT club62__Sport_Equipment__r.Name,' + C62Utilities.getFields('club62__Sport_Reservation_Equipment__c') + ' FROM club62__Sport_Reservation_Equipment__c WHERE club62__Reservation__c = :strId');
        clstSportCharges = new List<SportCharge>();
        for(club62__Sport_Reservation_Equipment__c resSC : lstSC){
            SportCharge sc = new SportCharge(cSCIndex++);
            sc.sre = resSC;
            sc.name = resSC.club62__Sport_Equipment__r.Name;
            clstSportCharges.add(sc);
        }
        if(facNameMap.containsKey(cReservation.club62__Club_Location__c)){
            cFacName = facNameMap.get(cReservation.club62__Club_Location__c);
        }else{
            cFacName = '';
        }
        resetMemberFilters();
        loadGrids();
        cShowPopup = true;
    }

    /*
    @Name   :resetMemberFilters
    @Description :Sets member filters to default values
    */
    public void resetMemberFilters(){
        cRegFilter = new club62__Reservation_Registration__c();
        cGrpFilter = new club62__Group_Customer__c();
    }

    /*
    @Name   :newCancelTerm
    @Description :Creates a new CancelTerm and selects it
    */
    public void newCancelTerm(){
        CancelTerm ct = new CancelTerm(cCancelTermIndex++);
        ct.cancelTerm = new club62__Reservation_Cancellation_Term__c();
        cCancelTermSelected = ct;
    }

    /*
    @Name   :doneCancelTerms
    @Description :Finished with cancellation terms
    */
    public void doneCancelTerms(){
        if(clstCancelTerms == null) clstCancelTerms = new List<CancelTerm>();
        if(clstCancelTerms.size() == 0){
            clstCancelTerms.add(cCancelTermSelected);
        } else {
            Boolean bolFound = false;
            for(CancelTerm ct : clstCancelTerms){
                if(ct.intIndex == cCancelTermSelected.intIndex) bolFound = true;
            }
            if(!bolFound) clstCancelTerms.add(cCancelTermSelected);
        }
        cCancelPage = 'Select';
    }

    /*
    @Name   :removeCancelTerm
    @Description :Removes the selected cancel term from the clstCancelTerms
    */
    public void removeCancelTerm(){
        if(cCancelTermIndex != null){
            Integer index;
            for(Integer i = 0; i < clstCancelTerms.size(); i++){
                if(clstCancelTerms.get(i).intIndex == cCancelTermIndex){
                    index = i;
                    break;
                }
            }
            if(index != null){
                CancelTerm ct = clstCancelTerms.remove(index);
                if(clstCancelTerms.size() == 0){
                    clstCancelTerms = null;
                }
                if(ct.cancelTerm.Id != null){
                    if(clstDelCancelTerms == null) clstDelCancelTerms = new List<CancelTerm>();
                    clstDelCancelTerms.add(ct);
                }
            }
        }
    }

    /*
    @Name   :selectCancelTerm
    @Description :Sets the chosen cancelterm
    */
    public void selectCancelTerm(){
        cCancelTermSelected = null;
        for(CancelTerm ct : clstCancelTerms){
            if(ct.intIndex == cCancelTermIndex){
                cCancelTermSelected = ct;
                break;
            }
        }
    }

    /*
    @Name   :loadCancelTerms
    @Description :Loads the Cancellation terms for the reservation
    */
    public void loadCancelTerms(){
        try{
            if(clstCancelTerms != null && clstCancelTerms.size() > 0){
                //do nothing, this will persist the temp variables
            } else {
                if(cReservation.Id != null){
                    //Querying associated Reservation cancellation term.
                    List<club62__Reservation_Cancellation_Term__c> lstCT = [SELECT Id,Name,club62__Penalty__c,club62__Cancel_Within__c,club62__Reservation__c
                                                                        FROM club62__Reservation_Cancellation_Term__c
                                                                        WHERE club62__Reservation__c = :cReservation.Id];
                    clstCancelTerms = new List<CancelTerm>();
                    for(club62__Reservation_Cancellation_Term__c rct : lstCT){
                        CancelTerm ct = new CancelTerm(cCancelTermIndex++);
                        ct.cancelTerm = rct;
                        clstCancelTerms.add(ct);
                    }
                }
            }
            //If the reservation cancellation fee is blank default it to be cancellation penalty * event fee
            if(clstCancelTerms != null && clstCancelTerms.size() > 0 && cReservation.club62__Total_Amount__c != null){
                Decimal decPen;
                Integer numDays = Date.today().daysBetween(cReservation.club62__StartTime__c.date());
                Decimal currDay = 999;
                for(CancelTerm ct : clstCancelTerms){
                    club62__Reservation_Cancellation_Term__c rct = ct.cancelTerm;
                    if(rct.club62__Cancel_Within__c >= numDays && rct.club62__Cancel_Within__c < currDay){
                        decPen = rct.club62__Penalty__c;
                        currDay = rct.club62__Cancel_Within__c;
                    }
                }
                if(decPen != null)
                cReservation.club62__Cancellation_Fee__c = (decPen/100) * cReservation.club62__Total_Amount__c;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,e.getMessage()));
        }
    }

    /*
    @Name   :newspBuddy
    @Description :Creates a new Sports Buddy
    */
    public void newspBuddy(){
        spBuddy = new club62__Sports_Buddy__c();
        spBuddy.club62__Initiating_Customer__c = cReservation.club62__Customer__c;
        spBuddy.club62__Status__c = 'Requested';
        spBuddy.club62__Requested_Date__c=Date.TODAY();
    }
    /*
    @Name   :savespBuddy
    @Description :Inserts new spBuddy
    */
    public void savespBuddy(){
        try{
            if(spBuddy.club62__Initiating_Customer__c == spBuddy.club62__Requested_Customer__c){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Requested Customer and Initiating Customer can\'t be same.'));
            }else{
                if(Schema.sObjectType.club62__Sports_Buddy__c.isCreateable()){insert spBuddy;}
                cSportBuddyPopup = 'Select';
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Buddy requested. They will be available to choose when they confirm.'));
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }

    }
    /*
    @Name   :newGrpRes
    @Description :Creates a new grpRes and selects it
    */
    public void newGrpRes(){
        GroupReservation gr = new GroupReservation(cResIndex++);
        gr.grpParams = new club62__Reservation__c();
        gr.lstGIs = new List<GroupItem>();
        gr.roomCat = new club62__Room_Category__c(Name=cReservation.Name);
        if(clstGrpRes == null)clstGrpRes = new List<GroupReservation>();
        clstGrpRes.add(gr);
        cGrpResSelected = gr;
        cResSelectedIndex = gr.intIndex;
    }

    /*
    @Name   :loadGrpRes
    @Description :Loads the group reservations for the
    */
    public void loadGrpRes(){
        try{
            //Get the most recent group room category for the reservation
            if(clstGrpRes != null && clstGrpRes.size() > 0){
                //do nothing, this will persist the temp variables
            } else {
                if(cReservation.Id != null){
                    List<club62__Room_Category__c> lstRC = [SELECT Id,Name,club62__Reservation__c,club62__Description__c,
                                                    (SELECT Id,Name,club62__Reservation__c,club62__Description__c FROM club62__Room_Categories__r)
                                                     FROM club62__Room_Category__c
                                                     WHERE club62__Reservation__c = :cReservation.Id
                                                     ORDER BY CreatedDate DESC LIMIT 1];
                   if(lstRC.size() > 0){
                       //Create the existing group reservation and group items
                       clstGrpRes = new List<GroupReservation>();
                       cGrpRoomCat = lstRC.get(0);
                       List<club62__Room_Category__c> lstGRPRC = [SELECT Id,Name,club62__Reservation__c,club62__Description__c,
                                                            (SELECT Id,club62__Customer__c,club62__Person__c,club62__Room_Category__c,club62__Room_Category__r.Name,club62__From__c,club62__To__c,club62__Rate__c,club62__Who_is_Paying__c,club62__Status__c
                                                                    FROM club62__Room_Reservations1__r),
                                                            (SELECT Id,Name,club62__Guest_Price__c,club62__Customer_Price__c,club62__Start_Date__c,club62__End_Date__c,club62__Room_Category__c,club62__Regular_Room_Category__c FROM club62__Room_Rates__r)
                                                             FROM club62__Room_Category__c
                                                             WHERE club62__Parent_Category__c = :cGrpRoomCat.Id];
                       Map<String,club62__Room_Category__c> mapCats = new Map<String,club62__Room_Category__c>();
                       for(club62__Room_Category__c rc : [SELECT Id,Name,club62__Description__c FROM club62__Room_Category__c WHERE club62__Is_Custom__c = false]){
                           mapCats.put(rc.Name,rc);
                       }
                       //Create the group reservations
                       for(club62__Room_Category__c rc : lstGRPRC){
                           GroupReservation gr = new GroupReservation(cResIndex++);
                           gr.grpParams = new club62__Reservation__c();
                           gr.roomCat = rc;
                           gr.roomRates = rc.club62__room_Rates__r;
                           gr.grpParams.club62__Max_Seats__c = rc.club62__Room_Reservations1__r.size();
                           gr.grpParams.club62__Deposit_Amount__c = 0;
                           gr.lstGIs = new List<GroupItem>();
                           //Create the group items for the group reservation
                           Map<String,List<club62__Room_Reservation__c>> mapRCRR = new Map<String,List<club62__Room_Reservation__c>>();
                           for(club62__Room_Reservation__c rr : rc.club62__Room_Reservations1__r){
                               if(rr.club62__Customer__c != null || rr.club62__Person__c != null) gr.hasMemPer = true;
                               if(mapRCRR.containsKey(rr.club62__Room_Category__r.Name)){
                                   mapRCRR.get(rr.club62__Room_Category__r.Name).add(rr);
                               } else {
                                   List<club62__Room_Reservation__c> lstRR = new List<club62__Room_Reservation__c>();
                                   lstRR.add(rr);
                                   mapRCRR.put(rr.club62__Room_Category__r.Name,lstRR);
                               }
                               gr.grpParams.club62__recurring_Start_Date__c = rr.club62__From__c;
                               gr.grpParams.club62__recurring_End_Date__c = rr.club62__To__c;
                               gr.grpParams.club62__Deposit_Amount__c += rr.club62__Rate__c;
                           }
                           for(String strKey : mapRCRR.keySet()){
                               GroupItem gi = new GroupItem();
                               gi.roomRes = mapRCRR.get(strKey);
                               gi.numRoom = String.valueOf(gi.roomRes.size());
                               gi.origNumRoom = gi.numRoom; //the orignal number of rooms so we don't update the availabile + reserved out of sync
                               if(gi.origNumRoom == null)gi.origNumRoom = '0';
                               gi.roomCat = mapCats.get(strKey);
                               gi.giParams = new club62__Room_Reservation__c();
                               if(gi.numRoom != '0' && gi.numRoom != null) gi.giParams.club62__Rate__c = gi.roomRes.get(0).club62__Rate__c;
                               if(gi.roomRes != null && gi.roomRes.size() > 0 && gi.roomRes.get(0).club62__Who_is_Paying__c != null){
                                   gi.giParams.club62__Who_is_Paying__c = gi.roomRes.get(0).club62__Who_is_Paying__c;
                               }else {
                                   gi.giParams.club62__Who_is_Paying__c = 'Guest';
                               }
                               gr.lstGIs.add(gi);
                           }
                           clstGrpRes.add(gr);
                       }
                       //Copy the list into cMapOrigGrpCat
                       cMapOrigGrpCat = new Map<Id,Set<Id>>();
                       Set<Id> setTempIds = new Set<Id>();
                       cMapOrigGrpCat.put(cGrpRoomCat.Id,setTempIds);
                       for(GroupReservation gr : clstGrpRes){
                           for(GroupItem gi : gr.lstGIs){
                               Set<Id> setIds = new Set<Id>();
                               for(club62__Room_Reservation__c rr : gi.roomRes){
                                   setIds.add(rr.Id);
                               }
                               if(cMapOrigGrpCat.get(gr.roomCat.Id) != null){
                                   setIds.addAll(cMapOrigGrpCat.get(gr.roomCat.Id));
                               }
                               cMapOrigGrpCat.put(gr.roomCat.Id,setIds);
                           }
                       }
                   } else {
                       cGrpRoomCat = new club62__Room_Category__c();
                       cGrpRoomCat.Name = cReservation.Name;
                       clstGrpRes = null;
                   }
                } else {
                    cGrpRoomCat = new club62__Room_Category__c();
                    cGrpRoomCat.Name = cReservation.Name;
                    clstGrpRes = null;
                }
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,e.getMessage()));
        }
    }

    /*
    @Name   :selectGrpRes
    @Description :Sets the chosen grpRes
    */
    public void selectGrpRes(){
        cGrpResSelected = null;
        for(GroupReservation gr : clstGrpRes){
            if(gr.intIndex == cResSelectedIndex){
                cGrpResSelected = gr;
                setAvailabilities();
                break;
            }
        }
    }

    /*
    @Name   :removeGrpRes
    @Description :Removes the selected group reservation from the clstGrpRes
    */
    public void removeGrpRes(){
        if(cGrpResSelected != null && cGrpRes!=null && cGrpRes=='Select' && cGrpResCancel!=null && cGrpResCancel=='Select'){
            Integer bookRooms = 0;
            Boolean noOfRoomFlag = false;
            for(GroupItem gi : cGrpResSelected.lstGis){
                if(gi.numRoom == null) gi.numRoom = '0';
                if(gi.origNumRoom == null){gi.origNumRoom = '0';}
                if(gi.origNumRoom!=gi.numRoom){gi.numRoom=gi.origNumRoom;}
            }
            grpCalcTotal();
            cGrpResCancel = 'Edit';
        }
        if(cResSelectedIndex != null && cResSelectedIndex != null && cDoCancel){
            Integer intRemoveId;
            for(Integer i = 0; i < clstGrpRes.size(); i++){
                if(clstGrpRes.get(i).intIndex == cResSelectedIndex){
                    intRemoveId = i;
                }
            }
            if(intRemoveId != null){
                clstGrpRes.remove(intRemoveId);
                if(clstGrpRes.size() == 0){
                    clstGrpRes = null;
                }
            }
        }
    }

    /*
    @Name   :grpCalcTotal
    @Description :Calculates the total for the groupitem, stores it in grpParam.club62__Max_Seats__c
    */
    public void grpCalcTotal(){
        try{
            if(cGrpResSelected != null){
                cGrpResSelected.grpParams.club62__Max_Seats__c = 0;
                cGrpResSelected.grpParams.club62__deposit_amount__c = 0;
                for(GroupItem gi : cGrpResSelected.lstGis){
                    if(gi.numRoom != null){
                        cGrpResSelected.grpParams.club62__Max_Seats__c += Integer.valueOf(gi.numRoom);
                    }
                    if(gi.giParams.club62__Rate__c != null && gi.numRoom != null){
                        cGrpResSelected.grpParams.club62__deposit_amount__c += (gi.giParams.club62__Rate__c * Integer.valueOf(gi.numRoom));
                    }
                }
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }
    }

    /*
    @Name   :saveGrpRes
    @Description :Sets the variables for the group res
    */
    public void saveGrpRes(){
        if(cGrpResSelected != null){
            if(cGrpResSelected.grpParams.club62__Recurring_Start_Date__c > cGrpResSelected.grpParams.club62__Recurring_End_Date__c){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Check Out date can\'t be less than Check In date.'));
                return ;
            }
            //Using C62Room Reservation custom setting to get the value of total number of rooms and maximum group room reservations.
            club62__C62Room_Reservation__c rrSetting = club62__C62Room_Reservation__c.getOrgDefaults();
            Integer totalRooms = 0;
            Integer groupReservation;
            if(rrSetting!=null && rrSetting.club62__Total_Number_of_Rooms__c!=null && rrSetting.club62__Total_Number_of_Rooms__c>0){
                totalRooms = Integer.valueOf(rrSetting.club62__Total_Number_of_Rooms__c);
            }
            if(rrSetting!=null && rrSetting.club62__Max_Group_Room_Reservations__c!=null && rrSetting.club62__Max_Group_Room_Reservations__c>0){
                groupReservation = Integer.valueOf(rrSetting.club62__Max_Group_Room_Reservations__c);
            }
            Integer bookRooms = 0;
            Boolean noOfRoomFlag = false;
            for(GroupItem gi : cGrpResSelected.lstGis){
                if(gi.numRoom == null) gi.numRoom = '0';
                bookRooms += Integer.valueOf(gi.numRoom);
                if(gi.origNumRoom == null){gi.origNumRoom = '0';}
                if(integer.valueOf(gi.numRoom)<integer.valueOf(gi.origNumRoom)){noOfRoomFlag=true;}
            }
            if(noOfRoomFlag){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'You can\'t decrement the number of rooms.'));
                return;
            }

            if(bookRooms > totalRooms){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'You can\'t book total rooms more than '+String.valueOf(totalRooms)+'.'));
                return ;
            }

            if(groupReservation!=null && bookRooms > groupReservation){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'You can\'t book group reservation more than ' +String.valueOf(groupReservation)+'.'));
                return ;
            }
            cGrpResSelected.grpParams.club62__Max_Seats__c = 0;
            Boolean hasRooms = false;

            for(GroupItem gi : cGrpResSelected.lstGis){
                if(gi.numRoom == null) gi.numRoom = '0';
                gi.origNumRoom = gi.numRoom;
                cGrpResSelected.grpParams.club62__Max_Seats__c += Integer.valueOf(gi.numRoom);
                if(gi.roomRes == null)gi.roomRes = new List<club62__Room_Reservation__c>();
                for(Integer i = 0; i < Integer.valueOf(gi.numRoom); i++){
                    //If roomRes is bigger than numRoom, remove rooms down to numRoom
                    if(gi.roomRes.size() > Integer.valueOf(gi.numRoom)){
                        List<club62__Room_Reservation__c> lstTemp = new List<club62__Room_Reservation__c>();
                        for(Integer j = 0; j < Integer.valueOf(gi.numRoom); j++){
                            lstTemp.add(gi.roomRes.get(j));
                        }
                        gi.roomRes = lstTemp;
                        if(gi.roomRes.size() > 1)hasRooms = true;
                        break;
                    }
                    if(gi.roomRes.size() > i){
                        //If the room res is size bigger than i then it has existing room reservations, use those
                        gi.roomRes.get(i).club62__From__c = cGrpResSelected.grpParams.club62__Recurring_Start_Date__c;
                        gi.roomRes.get(i).club62__To__c = cGrpResSelected.grpParams.club62__Recurring_End_Date__c;
                        gi.roomRes.get(i).club62__Group_Block_From__c = cGrpResSelected.grpParams.club62__Recurring_Start_Date__c;
                        gi.roomRes.get(i).club62__Group_Block_To__c = cGrpResSelected.grpParams.club62__Recurring_End_Date__c;
                        hasRooms = true;
                    } else {
                        club62__Room_Reservation__c rr = new club62__Room_Reservation__c();
                        rr.club62__From__c = cGrpResSelected.grpParams.club62__Recurring_Start_Date__c;
                        rr.club62__To__c = cGrpResSelected.grpParams.club62__Recurring_End_Date__c;
                        rr.club62__Group_Block_From__c = cGrpResSelected.grpParams.club62__Recurring_Start_Date__c;
                        rr.club62__Group_Block_To__c = cGrpResSelected.grpParams.club62__Recurring_End_Date__c;
                        gi.roomRes.add(rr);
                        hasRooms = true;
                    }
                }
            }
            Map<String,Integer> mapCatNums = new Map<String,Integer>();
            Map<String,Integer> mapCatRate = new Map<String,Integer>();
            cGrpResSelected.roomCat.club62__Description__c = '';
            for(GroupItem gi : cGrpResSelected.lstGis){
                if(gi.roomRes.size() > 0){
                    mapCatNums.put(gi.roomCat.Name,gi.roomRes.size());
                    if(gi.giParams != null && gi.giParams.club62__Rate__c != null){
                        mapCatRate.put(gi.roomCat.Name,Integer.valueOf(gi.giParams.club62__Rate__c));
                    }
                }
            }
            Boolean bolTemp = false;
            for(String strKey : mapCatNums.keySet()){
                if(bolTemp){
                    cGrpResSelected.roomCat.club62__Description__c += '\n';
                }
                cGrpResSelected.roomCat.club62__Description__c += mapCatNums.get(strKey) + ' ' + strKey;
                if(mapCatRate.size()>0 && mapCatRate.ContainsKey(strKey)){
                    cGrpResSelected.roomCat.club62__Description__c += ' @ $'+mapCatRate.get(strKey)+' per night.';
                }
                bolTemp = true;
            }
            if(cGrpResSelected.grpParams.club62__Max_Seats__c <= 0
                || cGrpResSelected.grpParams.club62__Recurring_Start_Date__c == null
                || cGrpResSelected.grpParams.club62__Recurring_End_Date__c == null
                || !hasRooms)
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Please reserve rooms to save.'));
            } else {
                cGrpRes = 'Select';
            }
        }
        grpCalcTotal();
    }

    /*
    @Name    :setAvailabilities
    @Description :Sets the GroupItems for the cGrpResSelected
    */
    public void setAvailabilities(){
        cGrpResSelected.grpParams.club62__Paid_Event__c = false;
        if(cGrpResSelected.grpParams.club62__Recurring_Start_Date__c != null && cGrpResSelected.grpParams.club62__Recurring_End_Date__c != null){
            Date dtStart = cGrpResSelected.grpParams.club62__Recurring_Start_Date__c;
            Date dtEnd = cGrpResSelected.grpParams.club62__Recurring_End_Date__c;
            List<club62__Room_Category__c> lstRCs = [SELECT Id,Name,club62__Description__c,
                                                     (SELECT Id,Name,club62__Status__c FROM club62__Rooms__r)
                                                     FROM club62__Room_Category__c
                                                     WHERE club62__Reservation__c = null
                                                     AND club62__Is_Custom__c = false];
            if(cGrpResSelected.lstGIs == null)cGrpResSelected.lstGIs = new List<GroupItem>();
            //Create map of existing rooms set for booking in other groupitems
            Map<String,Integer> mapRCTaken = new Map<String,Integer>();
            for(GroupReservation gr : clstGrpRes){
                if(cGrpResSelected.intIndex != gr.intIndex){
                    for(GroupItem gi : gr.lstGIs){
                        if(mapRCTaken.containsKey(gi.roomCat.Name)){
                            mapRCTaken.put(gi.roomCat.Name,mapRCTaken.get(gi.roomCat.Name)+Integer.valueOf(gi.numRoom));
                        } else {
                            mapRCTaken.put(gi.roomCat.Name,Integer.valueOf(gi.numRoom));
                        }
                    }
                }
            }
            //Map the existing group items
            Map<String,GroupItem> mapExistingGIs = new Map<String,GroupItem>();
            if(cGrpResSelected.lstGIs.size() > 0){
                for(GroupItem gi : cGrpResSelected.lstGIs){
                    mapExistingGIs.put(gi.roomCat.Name,gi);
                }
            }
            //Create the availabilities
            for(club62__Room_Category__c rc : lstRCs){
                GroupItem gi = new GroupItem();
                gi.giParams = new club62__Room_Reservation__c();
                gi.giParams.club62__Who_is_Paying__c = 'Guest';
                gi.roomCat = rc;
                gi.numRoom = '0';
                gi.origNumRoom = '0';
                gi.availability = new List<SelectOption>();
                //picklist values for availability are from 0-min number of rooms available during timeframe
                Integer intNumAvailable;
                if(intNumAvailable == null) intNumAvailable = rc.club62__Rooms__r.size(); //Sets availability to max num rooms if no stats available
                if(intNumAvailable == null)intNumAvailable = 0;
                //Subtract any availabilites from other Existing GroupItems
                if(mapRCTaken.containsKey(gi.roomCat.Name))intNumAvailable = intNumAvailable - mapRCTaken.get(gi.roomCat.Name);
                gi.availability.add(new SelectOption('0','0'));
                for(Integer i = 1; i <= intNumAvailable; i++){
                    gi.availability.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
                }
                //Add new if the room category does not exist, otherwise just update the availability
                if(mapExistingGIs.containsKey(gi.roomCat.Name)){
                    //If it already exists then the availbility is currently reserved + min available
                    Integer intNum = Integer.valueOf(mapExistingGIs.get(gi.roomCat.Name).origNumRoom) + gi.availability.size();
                    List<SelectOption> lstTemp = new List<SelectOption>();
                    lstTemp.add(new SelectOption('0','0'));
                    for(Integer i = 1; i < intNum; i++){
                        lstTemp.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
                    }
                    mapExistingGIs.get(gi.roomCat.Name).availability = lstTemp;
                } else {
                    cGrpResSelected.lstGIs.add(gi);
                }
            }
            cGrpResSelected.grpParams.club62__Paid_Event__c = true;
        }
    }

    /*
    @Name   :paidEvent
    @Description :for paid events we need to create charges
    */
    public club62__Transaction__c paidClass(club62__Reservation_Registration__c rr){
        club62__Transaction__c mc = new club62__Transaction__c();
        mc.club62__Customer__c = rr.club62__Customer__c;
        mc.club62__Reservation_Registration__c = rr.id;
        mc.club62__Amount__c = cReservation.club62__Event_Cost__c;
        mc.club62__Description__c = cReservation.Name;
        mc.club62__Reservation__c = rr.club62__Reservation__c;
        mc.club62__Type__c='Class';
        mc.club62__SubType__c = 'Entry Fee';
        mc.club62__Date__c=DateTime.now();
        Map<String,RecordType> tranRecTypeMap = new Map<String,RecordType>();
        List<RecordType> tranRecTypeLst = [SELECT ID,Name FROM RecordType WHERE sObjectType='club62__Transaction__c'];
        for(RecordType rt : tranRecTypeLst){tranRecTypeMap.put(rt.Name,rt);}
        if(tranRecTypeMap.containsKey('Class')){mc.RecordTypeId = tranRecTypeMap.get('Class').Id;}
        return mc;
    }

    /*
    @Name   :addSelected
    @Description :Create a reservation registration object for all selected items
    */
    public void addSelected(){
        if(clstAddGrid != null){
            for(GridItem gi : clstAddGrid){
                if(gi.bolSelected){
                    gi.bolSelected = false;
                    clstMemberGrid.add(gi);
                    if(cRTName == 'Class'){
                        gi.classCharge = paidClass(gi.reg);
                    }
                }
            }
            if(cPageName == 'Sport_Calendar'){
                populateAddBuddyGrid();
            }else{
                populateAddMemberGrid(cReservation.id);
            }
        }
    }

    /*
    @Name   :addSelectedGrp
    @Description :Create a reservation registration object for all selected items
    */
    public void addSelectedGrp(){
        if(clstAddGroupGrid != null){
            List<Id> grpIds = new List<Id>();
            for(GridItem gi : clstAddGroupGrid){
                if(gi.bolSelected){
                    gi.bolSelected = false;
                    grpIds.add(gi.mGroup.id);
                }
            }
            List<club62__Group_Customer__c> gLst = [select id,club62__Customer__c,club62__Customer__r.FirstName,club62__Customer__r.LastName,club62__Group__c from club62__Group_Customer__c where club62__group__c in :grpIds];
            Set<Id> memsInLst = new Set<Id>();
            for(GridItem gi : clstMemberGrid){
                if(gi.memberID!=null){
                    memsInLst.add(gi.memberID);
                }
                if(gi.reg!=null){
                    if(gi.reg.club62__Customer__c!=null){
                        memsInLst.add(gi.reg.club62__Customer__c);
                    }
                }
            }
            for(club62__Group_Customer__c mem : gLst){
               if(!memsInLst.contains(mem.club62__Customer__c)){
                   Contact m = new Contact(Id=mem.club62__Customer__c,FirstName=mem.club62__Customer__r.FirstName,LastName=mem.club62__Customer__r.LastName);
                   clstMemberGrid.add(convertSource(m));
               }
            }

            populateAddGroupGrid(cReservation.id);
            populateAddMemberGrid(cReservation.id);
        }
    }

    /*
    @Name   :addRecurringRow
    @Description :Add a time range
    */
    public PageReference addRecurringRow(){
        recurringday = recurringday.replace('\'','');
        if(recurringday=='0'){
            recurringstartEndTimeListSu.add(new recurringWrapper(recurringStartEndTimeListSu.size()));
        }else if(recurringday=='1'){
            recurringstartEndTimeListM.add(new recurringWrapper(recurringStartEndTimeListM.size()));
        }else if(recurringday=='2'){
            recurringstartEndTimeListTu.add(new recurringWrapper(recurringStartEndTimeListTu.size()));
        }else if(recurringday=='3'){
            recurringstartEndTimeListW.add(new recurringWrapper(recurringStartEndTimeListW.size()));
        }else if(recurringday=='4'){
            recurringstartEndTimeListTh.add(new recurringWrapper(recurringStartEndTimeListTh.size()));
        }else if(recurringday=='5'){
            recurringstartEndTimeListF.add(new recurringWrapper(recurringStartEndTimeListF.size()));
        }else if(recurringday=='6'){
            recurringstartEndTimeListSa.add(new recurringWrapper(recurringStartEndTimeListSa.size()));
        }
        return null;
    }

    /*
    @Name   :removeExpStatDateRow
    @Description :Remove a time range
    */
    public PageReference removeRecurringRow(){
        recurringday = recurringday.replace('\'','');
        try{
            if(recurringday=='0')
                recurringstartEndTimeListSu.remove(removalIndex);
            if(recurringday=='1')
                recurringstartEndTimeListM.remove(removalIndex);
            if(recurringday=='2')
                recurringstartEndTimeListTu.remove(removalIndex);
            if(recurringday=='3')
                recurringstartEndTimeListW.remove(removalIndex);
            if(recurringday=='4')
                recurringstartEndTimeListTh.remove(removalIndex);
            if(recurringday=='5')
                recurringstartEndTimeListF.remove(removalIndex);
            if(recurringday=='6')
                recurringstartEndTimeListSa.remove(removalIndex);
        }catch(Exception e){}
        Integer i =0;
        for(RecurringWrapper rw : recurringstartEndTimeListSu){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListM){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListTu){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListW){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListTh){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListF){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListSa){
            rw.index=i;
            i++;
        }
        return null;
    }


    /*
    @Name   :inviteBuddy
    @Description :Add the chosen grid items to the buddy grid
    */
    public void inviteBuddy(){System.debug(clstAddGrid);
        if(clstAddGrid != null){
            Integer j = 0;
            while (j < clstAddGrid.size()){
                GridItem gi = clstAddGrid[j];
                if(gi.bolSelected){
                    gi.bolSelected = False;
                    if(gi.gInvite==null){
                        club62__Game_Invite__c gInvite = new club62__Game_Invite__c();
                        gInvite.club62__Sports_Buddy__c = gi.spBuddy.Id;
                        gi.gInvite = gInvite;
                    }
                    gi.gInvite.club62__Status__c = 'Not Replied';
                    clstBuddyGrid.add(gi);
                    clstAddGrid.remove(j);
                }else{
                    j++;
                }
            }
        }
    }

    /*
    @Name   :delSelectedSB
    @Description :Deletes a reservation registration object for all selected items
    */
    public void delSelectedSB(){
        if(clstBuddyGrid != null){
            Integer j = 0;
            while (j < clstBuddyGrid.size()){
                GridItem gi = clstBuddyGrid[j];
                if(gi.bolSelected){
                    gi.bolSelected = False;
                    clstAddGrid.add(gi);
                    clstBuddyGrid.remove(j);
                }else{
                    j++;
                }
            }
        }
    }
    /*
    @Name   :gotoDetails
    @Description :Redirects to the cReservation details page
    */
    public PageReference gotoDetails(){
        return new PageReference('/' + cReservation.id);
    }

    /*
    @Name   :loadGrids
    @Description :Loads both grids
    */
    public void loadGrids(){
        populateMemberGrid(cReservation.id);
        if(cPageName == 'Sport_Calendar'){
            populateAddBuddyGrid();
        }else{
            populateAddMemberGrid(cReservation.id);
            populateAddGroupGrid(cReservation.id);
        }
    }

    /*
    @Name   :loadBuddyGrids
    @Description :Loads both buddy grids
    */
    public void loadBuddyGrids(){
        populateBuddyGrid(cReservation.id);
        populateAddBuddyGrid();
    }

    /*
    @Name   :cancelReservation
    @Description :Cancels the cReservation
    */
    public pageReference cancelReservation(){
        SavePoint sp = Database.setSavePoint();
        try{
            cReservation.club62__status__c = 'Cancelled';
            if(Schema.sObjectType.club62__Reservation__c.isUpdateable()){update cReservation;}
            closePopup();
        } catch (DMLException e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getdmlMessage(0)));
            Database.rollBack(sp);
        }
        return new PageReference('/' + cReservation.id);
    }

    /*
    @Name   :populateAddMemberGrid
    @Description :Datasource for add members grid, overload to automatically use cReservation.id
    */
    public void populateAddMemberGrid(){
        populateAddMemberGrid(cReservation.id);
    }
    /*
    @Name   :populateAddBuddyGrid
    @Description    :Datasource for add buddys grid
    */
    public void populateAddBuddyGrid(){
        //Get the available Sports Buddies for this Member
        if(cReservation.club62__Customer__c!=null){
            Set<ID> memberIDsSet = new Set<ID>();
            memberIDsSet.add(cReservation.club62__Customer__c);
            if(cRegFilter.club62__Customer__c != null){memberIDsSet.add(cRegFilter.club62__Customer__c);}
            Map<Id,club62__Sports_Buddy__c> sbLst = new Map<Id,club62__Sports_Buddy__c>([Select id,Name,club62__Type__c,club62__Initiating_Customer__r.Name,club62__Requested_Customer__r.Name from club62__Sports_Buddy__c where club62__Initiating_Customer__c  IN :memberIDsSet and club62__Status__c='Approved']);
            Map<Id,String> setMemberIds = new Map<Id,String>();
            Map<Id,club62__Sports_Buddy__c> setMemIdWithSPBuddy = new Map<Id,club62__Sports_Buddy__c>();
            for(club62__Sports_Buddy__c sb: sbLst.values()){
                if(sb.club62__Requested_Customer__c!=cReservation.club62__Customer__c && sb.club62__Requested_Customer__c!=cRegFilter.club62__Customer__c){
                    setMemberIds.put(sb.club62__Requested_Customer__c,sb.club62__Type__c);
                    setMemIdWithSPBuddy.put(sb.club62__Requested_Customer__c,sb);
                }

            }
            String strQuery = 'SELECT ' + C62Utilities.getFields('Contact')+ ' FROM Contact WHERE';
            strQuery += ' Id IN (\'' + String.join(new List<Id>(setMemberIds.keySet()),'\',\'') + '\')';
            Set<Id> setMemberIdsNotAdd = new Set<Id>();
            if(clstMemberGrid != null && clstMemberGrid.size() > 0){
                for(GridItem gi : clstMemberGrid){
                    setMemberIdsNotAdd.add(gi.reg.club62__Customer__c);
                }
            }

            if(clstBuddyGrid != null && clstBuddyGrid.size()>0){
                for(GridItem gi : clstBuddyGrid){
                    if(gi.memberID != null){
                        setMemberIdsNotAdd.add(gi.memberID);
                    }
                }
            }
            if(setMemberIdsNotAdd.size()>0){
                strQuery += ' AND Id NOT IN (\'' + String.join(new List<Id>(setMemberIdsNotAdd),'\',\'') + '\')';
            }
            strQuery +=' LIMIT 100';
            List<Contact> lstSource = Database.query(strQuery);

            clstAddGrid = new List<GridItem>();
            for(Contact mem :lstSource){
                clstAddGrid.add(convertSource(mem,setMemberIds.get(mem.id),setMemIdWithSPBuddy.get(mem.id)));
            }
        }
    }
    /*
    @Name   :populateAddGroupGrid
    @Description :Datasource for add group grid, overload to automatically use cReservation.id
    */
    public void populateAddGroupGrid(){
        populateAddGroupGrid(cReservation.id);
    }
    /*
    @Name   :populateAddGroupGrid
    @Description :Datasource for add group grid
    */
    public void populateAddGroupGrid(String eventId){
        //Get the members with the reservations for this event
        String strQuery = 'SELECT ' + C62Utilities.getFields('club62__Group__c');
        strQuery += ' FROM club62__Group__c WHERE id != null';
        if(cGrpFilter.club62__Group__c != null){
            strQuery += ' AND Id = \'' + String.escapeSingleQuotes(cGrpFilter.club62__Group__c) + '\'';
        }

        //Need to check if the member to be added already exists in the member grid
        if(clstMemberGrid != null && clstMemberGrid.size() > 0){
            Set<Id> setGroupIds = new Set<Id>();
            for(GridItem gi : clstMemberGrid){
                if(gi.mGroup!=null)
                    setGroupIds.add(gi.mGroup.id);
            }
            strQuery += ' AND Id NOT IN (\'' + String.join(new List<Id>(setGroupIds),'\',\'') + '\')';
        }
        strQuery += ' LIMIT 100';
        List<club62__Group__c> lstSource = Database.query(strQuery);
        clstAddGroupGrid = new List<GridItem>();
        for(club62__Group__c memG : lstSource){
           clstAddGroupGrid.add(convertSource(memG));
        }
    }
    /*
    @Name   :populateAddMemberGrid
    @Description :Datasource for add members grid
    */
    public void populateAddMemberGrid(String eventId){
        //Get the members with the reservations for this event
        String strQuery = 'SELECT ' + C62Utilities.getFields('Contact');
        if(strQuery.Contains(',OtherAddress')){strQuery = strQuery.replace(',OtherAddress','');}
        if(strQuery.Contains(',MailingAddress')){strQuery = strQuery.replace(',MailingAddress','');}
        if(strQuery.Contains('OtherAddress,')){strQuery = strQuery.replace('OtherAddress,','');}
        if(strQuery.Contains('MailingAddress,')){strQuery = strQuery.replace('MailingAddress,','');}
        if(eventId != null){
            strQuery += ',(SELECT ' + C62Utilities.getFields('club62__Reservation_Registration__c') + ' FROM club62__Reservation_Registrations__r WHERE Id = \'' + String.escapeSingleQuotes(eventId) + '\')';
        }
        strQuery += ' FROM Contact WHERE id != null';
        if(cRegFilter.club62__Customer__c != null){
            strQuery += ' AND Id = \'' + String.escapeSingleQuotes(cRegFilter.club62__Customer__c) + '\'';
        }
        //Need to check if the member to be added already exists in the member grid
        if(clstMemberGrid != null && clstMemberGrid.size() > 0){
            Set<Id> setMemberIds = new Set<Id>();
            for(GridItem gi : clstMemberGrid){
                setMemberIds.add(gi.reg.club62__Customer__c);
            }
            strQuery += ' AND Id NOT IN (\'' + String.join(new List<Id>(setMemberIds),'\',\'') + '\')';
        }
        strQuery += ' LIMIT 100';
        List<Contact> lstSource = Database.query(strQuery);
        clstAddGrid = new List<GridItem>();
        for(Contact mem : lstSource){
           clstAddGrid.add(convertSource(mem));
        }
    }
    /*
    @Name   :populateMemberGrid
    @Description :Datasource for members grid
    */
    public void populateMemberGrid(String eventId){
        List<club62__Reservation_Registration__c> lstSource = new List<club62__Reservation_Registration__c>();
        if(eventId != null){
            String strQuery = 'SELECT club62__Customer__c,club62__Reservation__c ' 
                                        + ' FROM club62__Reservation_Registration__c WHERE club62__Reservation__c = \'' + String.escapeSingleQuotes(eventId) + '\'';
            strQuery += ' LIMIT 1000';
            lstSource = Database.query(strQuery);
        }
        clstMemberGrid = new List<GridItem>();
        for(club62__Reservation_Registration__c er: lstSource){
           clstMemberGrid.add(convertSource(er));
        }
    }

    /*
    @Name   :populateBuddyGrid
    @Description :Datasource for existing buddy grid
    */
    public void populateBuddyGrid(String eventId){
        List<club62__Game_Invite__c> lstSource = new List<club62__Game_Invite__c>();
        if(eventId != null){
            String strQuery = 'SELECT club62__Sports_Buddy__r.club62__Requested_Customer__c,club62__Sports_Buddy__r.club62__Initiating_Customer__c,' + C62Utilities.getFields('club62__Game_Invite__c')
                                        + ' FROM club62__Game_Invite__c WHERE club62__Game_Reservation__c = \'' + String.escapeSingleQuotes(eventId) + '\'';
            strQuery += ' LIMIT 1000';
            lstSource = Database.query(strQuery);
        }
        clstBuddyGrid = new List<GridItem>();
        for(club62__Game_Invite__c gi: lstSource){
           clstBuddyGrid.add(convertSource(gi));
        }
    }

    /*
    @Name   :convertSource
    @Description :Converts sObjects into GridItem objects
    */
    public GridItem convertSource(sObject so){
        GridItem gi = new GridItem(cIndex++);
        String objPrefix = String.valueOf(so.id).substring(0,3);
        if(cMapIdObjName.get(objPrefix) != null){
            String objAPIName = cMapIdObjName.get(objPrefix);
            if(objAPIName == 'Contact'){
                //convert club62__Customer__c into jqgitem
                Contact mem = (Contact)so;
                gi.reg.club62__Reservation__c = cReservation.id;
                gi.reg.club62__Customer__c = mem.id;
                gi.reg.club62__Status__c = 'Invited';
                gi.reg.club62__Send_Invitation__c = true;
                gi.memberName = mem.Name;
                gi.memberID = mem.ID;
            } else if (objAPIName == 'club62__Reservation_Registration__c'){
                club62__Reservation_Registration__c er = (club62__Reservation_Registration__c)so;
                gi.reg = er;
                Integer intGuests = 0;
            } else if(objAPIName == 'club62__Game_Invite__c'){
                club62__Game_Invite__c er = (club62__Game_Invite__c)so;
                gi.sbType = er.club62__Sports_Buddy_Type__c;
                gi.memberName = er.club62__Requested_Customer__c;
                gi.memberID = er.club62__Sports_Buddy__r.club62__Requested_Customer__c;
                gi.gInvite = er;
            }else if(objAPIName == 'club62__Group__c'){
                club62__Group__c gr = (club62__Group__c)so;
                gi.mgroup = gr;
            }
        }
        return gi;
    }
    /*
    @Name   :convertSource
    @Description :Converts sObjects into GridItem objects for SBUDDY
    */
    public GridItem convertSource(sObject so,String sbuddyType,sObject spBuddy){
        GridItem gi = new GridItem(cIndex++,sbuddyType);
        String objPrefix = String.valueOf(so.id).substring(0,3);
        if(cMapIdObjName.get(objPrefix) != null){
            String objAPIName = cMapIdObjName.get(objPrefix);
            if(objAPIName == 'Contact'){
                //convert club62__Customer__c into jqgitem
                Contact mem = (Contact)so;
                gi.reg.club62__Reservation__c = cReservation.id;
                gi.memberName = mem.Name;
                gi.memberID = mem.id;
                gi.spBuddy = (club62__Sports_Buddy__c)spBuddy;
                gi.reg.club62__Customer__c = mem.id;
                gi.reg.club62__Status__c = 'Invited';
            } else if (objAPIName == 'club62__Reservation_Registration__c'){
                club62__Reservation_Registration__c er = (club62__Reservation_Registration__c)so;
                gi.reg = er;
            } else if(objAPIName == 'club62__Game_Invite__c'){
                club62__Game_Invite__c invite = (club62__Game_Invite__c)so;
                gi.sbType = invite.club62__Sports_Buddy_Type__c;
                gi.memberName = invite.club62__Requested_Customer__c;
                gi.memberID = invite.club62__Sports_Buddy__r.club62__Requested_Customer__c;
                gi.gInvite = invite;
            }
        }
        return gi;
    }
    /*
    @Name   :updateReservation
    @Description :Updates the start date and end date and facility of the reservation when its moved in the grid
    */
    @RemoteAction
    public Static String updateReservation(String jsonReservation){
        String strReturn = '';
        SavePoint sp = Database.setSavePoint();
        try{
            String strJSON = jsonReservation;
            for(String strKey : cmapVARs.keySet()){
                strJSON = strJSON.replaceFirst(strKey,cmapVARs.get(strKey));
            }
            FCEvent fce = (FCEvent)JSON.deserialize(strJSON,FCEvent.class);
            club62__Reservation__c reservation = [SELECT Id,club62__StartTime__c,club62__EndTime__c,club62__Club_Location__c FROM club62__Reservation__c WHERE Id = :fce.idVAR];
            reservation.club62__StartTime__c = fce.startVAR;
            reservation.club62__EndTime__c = fce.endVAR;
            reservation.club62__Club_Location__c = fce.resourceVAR;
            if(Schema.sObjectType.club62__Reservation__c.isUpdateable()){update reservation;}
        } catch (DMLException e){
            strReturn = e.getdmlMessage(0);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
            Database.rollBack(sp);
        }
        return strReturn;
    }

    /*
    @Name   :closePopup
    @Description :Used by VF to close the popup
    */
    public void closePopup() {
        cShowPopup = false;
        //Wipe group rate temp variables
        clstGrpRes = null;
        cGrpRoomCat = null;
        descriptionFromMemButton = '';
        descriptionFromPrimaryButton = '';
        descriptionFromPaymentButton = '';
        descriptionFromInsButton = '';
        cObjType = '';
        cObjId = '';
        cNewRecordType = '';
    }

    /*
    @Name   :showPopup
    @Description :Used by VF to display the popup
    */
    public void showPopup() {
        cShowPopup = true;
    }
    /*
    @Name:    getcalculateFacilityCost
    @Description    :return calculated facility cost based on reservation length and hourly cost
    */
    public Decimal getcalculateFacilityCost(){
        club62__Facility__c fac = facIdToMap.get(cReservation.club62__Club_Location__c);
        Decimal decMinutes = (cReservation.club62__EndTime__c.getTime() - cReservation.club62__StartTime__c.getTime()) / 1000 / 60 ;
        Decimal decPrice=0;
        if(fac.club62__Hourly_Charge__c!=null)
        {
         decPrice = ((fac.club62__Hourly_Charge__c / 60) * decMinutes);
        }
        
        
        
       // Decimal decPrice = ((fac.club62__Hourly_Charge__c / 60) * decMinutes);
        //during peak hours
        DateTime dtPS = C62Utilities.getTime(cReservation.club62__StartTime__c.date(),fac.club62__Peak_Start_Time__c);
        DateTime dtPE = C62Utilities.getTime(cReservation.club62__EndTime__c.date(),fac.club62__Peak_End_Time__c);
        if( dtPS != null && dtPE != null && fac.club62__Peak_Hourly_Charge__c != null
            && ((cReservation.club62__StartTime__c >= dtPS && cReservation.club62__StartTime__c < dtPE)
                || (cReservation.club62__EndTime__c <= dtPE && cReservation.club62__EndTime__c > dtPS)
                || (cReservation.club62__StartTime__c < dtPS && cReservation.club62__EndTime__c > dtPE)))
        {
            decPrice = ((fac.club62__Peak_Hourly_Charge__c / 60) * decMinutes);
        }
        //Add the Lesson Cost
        if(cReservation.Lesson_Cost__c != null) decPrice += cReservation.Lesson_Cost__c;
        //Set the price as the event cost and mark it as a paid event
        cReservation.club62__Event_Cost__c = decPrice;
        cReservation.club62__Paid_Event__c = true;
        for(SportCharge sc : clstSportCharges){
            if(sc.sre != null && sc.sre.club62__Amount__c != null) decPrice += sc.sre.club62__Amount__c;
        }
        return decPrice;
    }

    /*
    @Name    :donothing
    @Description    :Do Nothing
    */
    public void donothing(){
    }
    /*
    @Name   :saveReservation
    @Description :Saves the Reservation
    */
    public void saveReservation(){
        SavePoint sp = Database.setSavePoint();
        try{
            //Using C62Room Reservation custom setting for group reservation require approval and group reservation require e mail.
            club62__C62Room_Reservation__c rrSetting = club62__C62Room_Reservation__c.getOrgDefaults();
            if(cRTName == 'Sport' || cRTName == 'Class' || cRTName == 'Lesson'){
                String strQueryFac = 'SELECT ' + C62Utilities.getFields('club62__Facility_Availability_Exception__c')
                        +' FROM club62__Facility_Availability_Exception__c WHERE ((club62__Start__c >= '
                        + cReservation.club62__StartTime__c.format('yyyy-MM-dd\'T\'HH:mm:ssZ') + ' AND club62__Start__c < '+ cReservation.club62__EndTime__c.format('yyyy-MM-dd\'T\'HH:mm:ssZ') + ') OR (club62__End__c > ' + cReservation.club62__StartTime__c.format('yyyy-MM-dd\'T\'HH:mm:ssZ')
                        + ' AND club62__End__c <= ' + cReservation.club62__EndTime__c.format('yyyy-MM-dd\'T\'HH:mm:ssZ') + ') OR (club62__Start__c < ' + cReservation.club62__StartTime__c.format('yyyy-MM-dd\'T\'HH:mm:ssZ')
                        + ' AND club62__End__c > '+ cReservation.club62__EndTime__c.format('yyyy-MM-dd\'T\'HH:mm:ssZ') + ')) AND club62__Facility__c =\''+String.escapeSingleQuotes(cReservation.club62__Club_Location__c)+'\'';
                //Checking availability.
                List<club62__Facility_Availability_Exception__c> faeLst = Database.query(strQueryFac);
                Boolean isAvailable = true;
                for(club62__Facility_Availability_Exception__c fae : faeLst){
                    if((cReservation.club62__StartTime__c <= fae.club62__Start__c && fae.club62__Start__c < cReservation.club62__EndTime__c)
                        || ( fae.club62__End__c > cReservation.club62__StartTime__c && fae.club62__End__c <= cReservation.club62__EndTime__c)
                        || ( fae.club62__Start__c < cReservation.club62__StartTime__c && cReservation.club62__EndTime__c < fae.club62__End__c)){
                        isAvailable = false;
                        break;
                    }
                }
                if(!isAvailable){
                    throw new C62Utilities.CustomException('Sorry, this facility is not available at this time.');
                }
            }

            if((cReservation.Name == null || cReservation.Name == '') && cRTName != 'Sport' && cRTName != 'Lesson'){
                throw new C62Utilities.CustomException('Name is required.');
            }
            if(cRTName == 'Event' && cReservation.club62__Paid_Event__c && cReservation.club62__Guests_Allowed__c &&
                (cReservation.club62__Guest_Cost__c == null || cReservation.club62__Children_Cost__c == null)){
                throw new C62Utilities.CustomException('Guest Cost and Children Cost are required if event is paid and guests are allowed.');
            }
            if(cRTName == 'Sport' && cReservation.club62__Customer__c == null){
                throw new C62Utilities.CustomException('Customer is required.');
            }
            if(cRTName == 'Lesson' && cReservation.club62__POS_Lesson_Item_Name__c == null){
                throw new C62Utilities.CustomException('POS Lesson Item Name is required.');
            }
            if(cRTName == 'Lesson' && cReservation.club62__Instructor__c == null){
                throw new C62Utilities.CustomException('Instructor is required.');
            }
            if((cRTName == 'Sponsored Event' || cRTName == 'Event' || cRTName == 'Class') && cReservation.club62__Sponsoring_Customer__c == null){
                throw new C62Utilities.CustomException('Sponsoring Member is required.');
            }
            if(descriptionFromInsButton == '' || descriptionFromInsButton == null){
                cReservation.club62__Institution__c = null;
            }
            if(descriptionFromPrimaryButton == '' || descriptionFromPrimaryButton == null){
                cReservation.club62__Primary_Contact__c = null;
            }
            if(descriptionFromPaymentButton == '' || descriptionFromPaymentButton == null){
                cReservation.club62__Payment_Contact__c = null;
            }
            //descriptionFromMemButton = '';
            //descriptionFromPrimaryButton = '';
            //descriptionFromPaymentButton = '';
            //descriptionFromInsButton = '';
            cObjType = '';
            cObjId = '';
            cNewRecordType = '';
            if(cRTName == 'Class'){
                if(cReservation.club62__Guests_Allowed__c && cReservation.club62__Paid_Event__c && cReservation.club62__Guest_Cost__c==null){
                    throw new C62Utilities.CustomException('Guest Cost is required if event is paid and guests are allowed.');
                }
                Boolean recurring = false;
                if(cReservation.Id == null && cRecurringEvent == true){
                    recurring = true;
                    if(cReservation.club62__Recurring_Start_Date__c==null && cReservation.club62__Recurring_End_Date__c==null){
                        throw new C62Utilities.CustomException('Start and End Dates required.');
                    } else {
                        //Recurring Event, create recurrances and set recurrence vars
                        clstRecurRes = new List<club62__Reservation__c>();
                        Date curDate = cReservation.club62__Recurring_Start_Date__c;
                        while(curDate<=cReservation.club62__Recurring_End_Date__c){
                            Boolean cloneEvent = false;
                            Date startOfWeek = curDate.toStartofWeek();
                            Integer dayOfWeek = startOfWeek.daysBetween(curDate);
                            if((dayOfWeek==0 && rSunday==true)||(dayOfWeek==1 && rMonday==true)||(dayOfWeek==2 && rTuesday==true)||
                               (dayOfWeek==3 && rWednesday==true)||(dayOfWeek==4 && rThursday==true)||(dayOfWeek==5 && rFriday==true)||
                               (dayOfWeek==6 && rSaturday==true)){
                                    cloneEvent=true;
                            }
                            if(cloneEvent){
                                //Create the recurring events
                                //When creating recurring set the cReservation to the first recurrence and use the first event in the list as the parent event later
                                if(dayOfWeek==0){
                                    for(recurringWrapper res : recurringstartEndTimeListSu){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==1){
                                    for(recurringWrapper res : recurringstartEndTimeListM){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==2){
                                    for(recurringWrapper res : recurringstartEndTimeListTu){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==3){
                                    for(recurringWrapper res : recurringstartEndTimeListW){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==4){
                                   for(recurringWrapper res : recurringstartEndTimeListTh){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==5){
                                    for(recurringWrapper res : recurringstartEndTimeListF){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==6){
                                    for(recurringWrapper res : recurringstartEndTimeListSa){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }
                            }
                            curDate=curDate.addDays(1);
                        }
                        //Set recurrence vars
                        cSavingRecurrences = true;
                        clstValidatedRecur = null;
                        clstErrorRecur = null;
                    }
                } else {
                    //Existing event or new non recurring, just save it
                    if(Schema.sObjectType.club62__Reservation__c.isCreateable() && Schema.sObjectType.club62__Reservation__c.isUpdateable()){upsert cReservation;}
                }
                if(clstMemberGrid != null && clstMemberGrid.size() > 0){
                    List<club62__Reservation_Registration__c> lstRR = new List<club62__Reservation_Registration__c>();
                    for(GridItem gi : clstMemberGrid){
                        if(gi.reg.club62__Reservation__c == null){
                            gi.reg.club62__Reservation__c = cReservation.id;
                        }
                        lstRR.add(gi.reg);
                    }
                    if(Schema.sObjectType.club62__Reservation_Registration__c.isCreateable() && Schema.sObjectType.club62__Reservation_Registration__c.isUpdateable()){upsert lstRR;}
                }
                cSaveError = false;
                if(!recurring)closePopup();
            } else {
                if(cRTName == 'Sport' || cRTName == 'Lesson'){
                    cReservation.Name='Sport Reservation';
                    DateTime st = DateTime.newInstance(cReservation.club62__StartTime__c.Date(),Time.newInstance(0,0,0,0));
                    DateTime et = DateTime.newInstance(cReservation.club62__StartTime__c.Date(),Time.newInstance(23,59,59,999));
                }

                //If require approval for group res, set status to tentative for room reservations and send email to setting email for the event approval
                Boolean reqApproval = false;
                if(clstGrpRes != null && rrSetting.club62__Group_Reservation_Require_Approval__c != null && rrSetting.club62__Group_Reservation_Require_Approval__c) reqApproval = true;
                if(reqApproval){
                    cReservation.club62__Group_Reservation_Require_Approval__c = true;
                    cReservation.club62__Group_Reservations_Approval_Email__c = rrSetting.club62__Group_Reservations_Approval_Email__c;
                }
                Map<Id,RecordType> mapRTs = new Map<Id,RecordType>([SELECT Id,Name FROM RecordType WHERE sObjectType = 'club62__Reservation__c']);
                Boolean bolInsertSport = false;
                if(mapRTs.containsKey(cReservation.RecordTypeId) && mapRTs.get(cReservation.RecordTypeId).Name == 'Sport' && cReservation.Id == null){
                    bolInsertSport = true;
                }
                
                //Recurring lessons
                Boolean recurring = false;
                if(cRTName == 'Lesson' && cRecurringEvent && cReservation.Id == null){
                    recurring = true;
                    if(cReservation.club62__Recurring_Start_Date__c==null && cReservation.club62__Recurring_End_Date__c==null){
                        throw new C62Utilities.CustomException('Start and End Dates required.');
                    } else {
                        //Recurring Event, create recurrances and set recurrence vars
                        clstRecurRes = new List<club62__Reservation__c>();
                        Date curDate = cReservation.club62__Recurring_Start_Date__c;
                        while(curDate<=cReservation.club62__Recurring_End_Date__c){
                            Boolean cloneEvent = false;
                            Date startOfWeek = curDate.toStartofWeek();
                            Integer dayOfWeek = startOfWeek.daysBetween(curDate);
                            if((dayOfWeek==0 && rSunday==true)||(dayOfWeek==1 && rMonday==true)||(dayOfWeek==2 && rTuesday==true)||
                               (dayOfWeek==3 && rWednesday==true)||(dayOfWeek==4 && rThursday==true)||(dayOfWeek==5 && rFriday==true)||
                               (dayOfWeek==6 && rSaturday==true)){
                                    cloneEvent=true;
                            }
                            if(cloneEvent){
                                //Create the recurring events
                                //When creating recurring set the cReservation to the first recurrence and use the first event in the list as the parent event later
                                if(dayOfWeek==0){
                                    for(recurringWrapper res : recurringstartEndTimeListSu){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==1){
                                    for(recurringWrapper res : recurringstartEndTimeListM){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==2){
                                    for(recurringWrapper res : recurringstartEndTimeListTu){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==3){
                                    for(recurringWrapper res : recurringstartEndTimeListW){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==4){
                                   for(recurringWrapper res : recurringstartEndTimeListTh){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==5){
                                    for(recurringWrapper res : recurringstartEndTimeListF){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }else if(dayOfWeek==6){
                                    for(recurringWrapper res : recurringstartEndTimeListSa){
                                       club62__Reservation__c clonedEvent = cReservation.clone(false,true,false,false);
                                       List<String> sTimeSplit = res.StartTime.Split(':');
                                       List<String> eTimeSplit = res.EndTime.Split(':');
                                       clonedEvent.club62__startTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
                                       clonedEvent.club62__endTime__c=DateTime.newInstance(curDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
                                       clstRecurRes.add(clonedEvent);
                                    }
                                }
                            }
                            curDate=curDate.addDays(1);
                        }
                        //Set recurrence vars
                        cSavingRecurrences = true;
                        clstValidatedRecur = null;
                        clstErrorRecur = null;
                    }
                } else if(Schema.sObjectType.club62__Reservation__c.isCreateable() && Schema.sObjectType.club62__Reservation__c.isUpdateable()){
                    upsert cReservation;
                }
                
                cSaveError = false;
                if(recurring){
                
                } else {
                    string str_id= cReservation.Id;
                    cReservation= Database.query('SELECT ' + C62Utilities.getFields('club62__Reservation__c') + ' FROM club62__Reservation__c WHERE Id = :str_id');
                    List<club62__Game_Invite__c> giLst = new List<club62__Game_Invite__c>();
                    List<club62__Game_Invite__c> delGILst = new List<club62__Game_Invite__c>();
                    if(clstBuddyGrid!=null && clstBuddyGrid.size()>0){
                        for(GridItem gi : clstBuddyGrid){
                            if(gi.gInvite==null){
                                club62__Game_Invite__c gInvite = new club62__Game_Invite__c();
                                gInvite.club62__Game_Reservation__c = cReservation.Id;
                                gInvite.club62__Sports_Buddy__c = gi.spBuddy.Id;
                                giLst.add(gInvite);
                            } else if(gi.gInvite.club62__Game_Reservation__c == null){
                                gi.gInvite.club62__Game_Reservation__c = cReservation.id;
                                giLst.add(gi.gInvite);
                            }
                        }
                    }
                    if(Schema.sObjectType.club62__Game_Invite__c.isCreateable() && giLst.size()>0){insert giLst;}
                    if(clstAddGrid!=null && clstAddGrid.size()>0){
                        for(GridItem gi : clstAddGrid){
                            if(gi.gInvite!=null){
                                delGILst.add(gi.gInvite);
                            }
                        }
                    }
                    if(Schema.sObjectType.club62__Game_Invite__c.isDeletable() && delGILst.size()>0){delete delGILst;}
                    List<club62__Receivable__c> mcList = [select id from club62__Receivable__c where club62__status__c!='Cancelled' and club62__Reservation_Registration__r.club62__Reservation__c=:cReservation.id];
                    for(club62__Receivable__c mc : mcList){
                        mc.club62__Status__c='Cancelled';
                    }
                    if(Schema.sObjectType.club62__Receivable__c.isUpdateable()){update mcList;}
                    //upsert the sport charges
                    List<club62__Sport_Reservation_Equipment__c> lstSCExist = [SELECT Id FROM club62__Sport_Reservation_Equipment__c WHERE club62__Reservation__c = :cReservation.id];
                    Set<Id> setRemainIds = new Set<Id>();
                    List<club62__Sport_Reservation_Equipment__c> lstSC = new List<club62__Sport_Reservation_Equipment__c>();
                    List<club62__Sport_Reservation_Equipment__c> lstSCDelete = new List<club62__Sport_Reservation_Equipment__c>();
                    for(SportCharge sc : clstSportCharges){
                        if(sc.sre.club62__Reservation__c == null) sc.sre.club62__Reservation__c = cReservation.id;
                        if(sc.sre.Id != null) setRemainIds.add(sc.sre.Id);
                        lstSC.add(sc.sre);
                    }
                    for(club62__Sport_Reservation_Equipment__c sc : lstSCExist){
                        if(!setRemainIds.contains(sc.id)) lstSCDelete.add(sc);
                    }
                    if(Schema.sObjectType.club62__Sport_Reservation_Equipment__c.isCreateable() && Schema.sObjectType.club62__Sport_Reservation_Equipment__c.isUpdateable()){upsert lstSC;}
                    if(Schema.sObjectType.club62__Sport_Reservation_Equipment__c.isDeletable()){delete lstSCDelete;}
    
                    if(clstGrpRes != null){
                        //Upsert the master room category
                        cGrpRoomCat.club62__Reservation__c = cReservation.Id;
                        cGrpRoomCat.Name = cReservation.Name + ' Main Category';
                        if(Schema.sObjectType.club62__Room_Category__c.isCreateable() && Schema.sObjectType.club62__Room_Category__c.isUpdateable()){upsert cGrpRoomCat;}
                        //Upsert all child custom categories and associate to the master
                        List<club62__Room_Category__c> lstRC = new List<club62__Room_Category__c>();
                        Map<GroupReservation,Map<Id,GroupItem>> mapGRCatGIs = new Map<GroupReservation,Map<Id,GroupItem>>();
                        for(GroupReservation gr : clstGrpRes){
                            gr.roomCat.club62__Parent_Category__c = cGrpRoomCat.Id;
                            Map<Id,GroupItem> mapGI = new Map<Id,GroupItem>();
                            for(GroupItem gi : gr.lstGIs){
                                mapGI.put(gi.roomCat.Id,gi);
                            }
                            mapGRCatGIs.put(gr,mapGI);
                            lstRC.add(gr.roomCat);
                        }
                        if(Schema.sObjectType.club62__Room_Category__c.isCreateable() && Schema.sObjectType.club62__Room_Category__c.isUpdateable()){upsert lstRC;}
                        //Upsert all room rates for each custom category for each actual category
                        List<club62__Room_Rate__c> lstRR = new List<club62__Room_Rate__c>();
                        for(GroupReservation gr : clstGrpRes){
                            if(gr.roomRates != null && gr.roomRates.size() > 0){
                                for(club62__Room_Rate__c rr : gr.roomRates){
                                    Decimal decPrice = mapGRCatGIs.get(gr).get(rr.club62__Regular_Room_Category__c).giParams.club62__Rate__c;
                                    //Update existing rates if they exist
                                    rr.club62__Start_Date__c = gr.grpParams.club62__recurring_start_Date__c;
                                    rr.club62__End_Date__c = gr.grpParams.club62__recurring_end_date__c;
                                    rr.club62__Guest_Price__c = decPrice;
                                    rr.club62__Customer_Price__c = decPrice;
                                    lstRR.add(rr);
                                }
                            } else {
                                Date dtStart = gr.grpParams.club62__recurring_start_Date__c;
                                Date dtEnd = gr.grpParams.club62__recurring_end_date__c;
                                for(GroupItem gi : gr.lstGIs){
                                    if(gi.numRoom != '0' && gi.numRoom != null){
                                        club62__Room_Rate__c rr = new club62__Room_Rate__c();
                                        rr.club62__Room_Category__c = gr.roomCat.Id;
                                        rr.club62__Regular_Room_Category__c = gi.roomCat.Id;
                                        rr.club62__Guest_Price__c = gi.giParams.club62__Rate__c;
                                        rr.club62__Customer_Price__c = gi.giParams.club62__Rate__c;
                                        rr.club62__Start_Date__c = dtStart;
                                        rr.club62__End_Date__c = dtEnd;
                                        String tmpName = 'Group Rate(' + gr.roomCat.Name + ' for ' + gi.roomCat.Name + ')';
                                        if(tmpName.length()>80){rr.Name = tmpName.subString(0,80);}
                                        else{rr.Name = tmpName;}
                                        lstRR.add(rr);
                                    }
                                }
                            }
                        }
                        if(Schema.sObjectType.club62__Room_Rate__c.isCreateable() && Schema.sObjectType.club62__Room_Rate__c.isUpdateable()){upsert lstRR;}
                        //Upsert all room reservations for each custom category
                        List<club62__Room_Reservation__c> lstRRES = new List<club62__Room_Reservation__c>();
                        for(GroupReservation gr : clstGrpRes){
                            for(GroupItem gi : gr.lstGIs){
                                if(gi != null && gi.roomRes != null){
                                    for(club62__Room_Reservation__c rr : gi.roomRes){
                                        rr.club62__Group_Block_Name__c = cReservation.Name;
                                        rr.club62__Who_is_Paying__c = gi.giParams.club62__Who_is_Paying__c;
                                        rr.club62__Room_Category__c = gi.roomCat.Id;
                                        rr.club62__Group_Category__c = gr.roomCat.Id;
                                        if(rr.club62__Status__c == null){
                                            rr.club62__Status__c = 'Confirmed';
                                            if(reqApproval)rr.club62__Status__c = 'Tentative';
                                        }
                                        rr.club62__Rate__c = gi.giParams.club62__Rate__c;
                                        rr.club62__Reservation__c = cReservation.Id;
                                        lstRRES.add(rr);
                                    }
                                }
                            }
                        }
                        if(Schema.sObjectType.club62__Room_Reservation__c.isCreateable() && Schema.sObjectType.club62__Room_Reservation__c.isUpdateable()){upsert lstRRES;}
                        //Upsert all room reservation rates for each room reservation
                        List<club62__Room_Reservation_Rate__c> lstRRR = new List<club62__Room_Reservation_Rate__c>();
                        Set<Id> setRRIds = new Set<Id>();
                        for(club62__Room_Reservation__c rr : lstRRES){
                            setRRIds.add(rr.Id);
                        }
                        Map<Id,club62__Room_Reservation__c> mapRR = new Map<Id,club62__Room_Reservation__c>([SELECT Id,
                                                                                    (SELECT Id,club62__Amount__c,club62__Date__c,club62__Room_Reservation__c FROM club62__Room_Reservation_Rates__r)
                                                                                    FROM club62__Room_Reservation__c
                                                                                    WHERE Id IN :setRRIds]);
                        for(GroupReservation gr : clstGrpRes){
                            for(GroupItem gi : gr.lstGIs){
                                if(gi != null && gi.roomRes != null){
                                    for(club62__Room_Reservation__c rr : gi.roomRes){
                                        Date dtStart = rr.club62__From__c;
                                        Date dtEnd = rr.club62__To__c;
                                        Decimal decDays = dtStart.daysBetween(dtEnd);
                                        for(Integer i = 0; i < decDays; i++){
                                            Date dt = dtStart.addDays(i);
                                            //Update the existing rrr or create a new one
                                            club62__Room_Reservation_Rate__c rrr;
                                            Boolean exists = false;
                                            if(mapRR.get(rr.Id) != null){
                                                for(club62__Room_Reservation_Rate__c rrrTemp : mapRR.get(rr.Id).club62__Room_Reservation_Rates__r){
                                                    if(rrrTemp.club62__Date__c == dt){
                                                        rrr = rrrTemp;
                                                        rrr.club62__Amount__c = gi.giParams.club62__Rate__c;
                                                        exists = true;
                                                    }
                                                }
                                            }
                                            if(!exists){
                                                rrr = new club62__Room_Reservation_Rate__c(
                                                    club62__Amount__c=gi.giParams.club62__Rate__c,
                                                    club62__Date__c=dt,
                                                    club62__Room_Reservation__c=rr.Id
                                                );
                                            }
                                            lstRRR.add(rrr);
                                        }
                                    }
                                }
                            }
                        }
                        if(Schema.sObjectType.club62__Room_Reservation_Rate__c.isCreateable() && Schema.sObjectType.club62__Room_Reservation_Rate__c.isUpdateable()){upsert lstRRR;}
                        //If any categories are removed, delete the category and the room reservations
                        if(cMapOrigGrpCat != null){
                            List<Id> lstDelRC = new List<Id>();
                            List<Id> lstDelRR = new List<Id>();
                            //Existing items maps
                            Map<Id,club62__Room_Category__c> mapUpsertedRCs = new Map<Id,club62__Room_Category__c>(lstRC);
                            mapUpsertedRCs.put(cGrpRoomCat.Id,cGrpRoomCat);
                            Map<Id,club62__Room_Reservation__c> mapUpsertedRRs = new Map<Id,club62__Room_Reservation__c>(lstRRES);
                            for(Id origCatId : cMapOrigGrpCat.keySet()){
                                if(!mapUpsertedRCs.containsKey(origCatId)){
                                    //If the original room category does not exist in the upsert items, add it to the delete list
                                    lstDelRC.add(origCatId);
                                }
                                for(Id origRRId : cMapOrigGrpCat.get(origCatId)){
                                    if(!mapUpsertedRRs.containsKey(origRRId)){
                                        //If the original room reservation does not exist in the upsert items, add it to the delete list
                                        lstDelRR.add(origRRId);
                                    }
                                }
                            }
                            if(lstDelRC.size() > 0){
                                //Set status to Cancelled instead of deleting
                                if(Schema.sObjectType.club62__Room_Category__c.isDeletable()){delete [SELECT Id FROM club62__Room_Category__c WHERE Id IN :lstDelRC];}
                            }
                            if(lstDelRR.size() > 0){
                                //Set status to Cancelled instead of deleting
                                if(Schema.sObjectType.club62__Room_Reservation__c.isDeletable()){delete [SELECT Id FROM club62__Room_Reservation__c WHERE Id IN :lstDelRR];}
                            }
                        }
                    } else if(cMapOrigGrpCat != null && cMapOrigGrpCat.size() > 0){ //If the list is null check if there was any originals and delete them
                        List<Id> lstDelRC = new List<Id>();
                        List<Id> lstDelRR = new List<Id>();
                        for(Id origCatId : cMapOrigGrpCat.keySet()){
                            lstDelRC.add(origCatId);
                            lstDelRR.addAll(cMapOrigGrpCat.get(origCatId));
                        }
                        if(Schema.sObjectType.club62__Room_Category__c.isDeletable() && cGrpRoomCat != null) delete cGrpRoomCat;
                        if(lstDelRC.size() > 0){
                            if(Schema.sObjectType.club62__Room_Category__c.isDeletable()){delete [SELECT Id FROM club62__Room_Category__c WHERE Id IN :lstDelRC];}
                        }
                        if(lstDelRR.size() > 0){
                            if(Schema.sObjectType.club62__Room_Reservation__c.isDeletable()){delete [SELECT Id FROM club62__Room_Reservation__c WHERE Id IN :lstDelRR];}
                        }
                    }
                    //Save the reservation cancellation terms
                    if(clstCancelTerms != null && clstCancelTerms.size() > 0){
                        List<club62__Reservation_Cancellation_Term__c> lstRCT = new List<club62__Reservation_Cancellation_Term__c>();
                        for(CancelTerm ct : clstCancelTerms){
                            if(ct.cancelTerm.club62__Reservation__c == null) ct.cancelTerm.club62__Reservation__c = cReservation.Id;
                            lstRCT.add(ct.cancelTerm);
                        }
                        if(Schema.sObjectType.club62__Reservation_Cancellation_Term__c.isCreateable() && Schema.sObjectType.club62__Reservation_Cancellation_Term__c.isUpdateable()){upsert lstRCT;}
                        clstCancelTerms = null;
                    }
                    if(clstDelCancelTerms != null && clstDelCancelTerms.size() > 0){
                        List<club62__Reservation_Cancellation_Term__c> lstRCT = new List<club62__Reservation_Cancellation_Term__c>();
                        for(CancelTerm ct : clstDelCancelTerms){
                            lstRCT.add(ct.cancelTerm);
                        }
                        if(Schema.sObjectType.club62__Reservation_Cancellation_Term__c.isDeletable()){delete lstRCT;}
                        clstDelCancelTerms = null;
                    }
                }
            }
            cRecurringEvent = false;
        } catch (Exception e){
            ApexPages.addMessages(e);
            Database.rollBack(sp);
            cSaveError = true;
        }
    }

    /*
    @Name   :createReservation
    @Description :Defaults the values and redirects to the new reservation page
    */
    public PageReference createReservation(){
        PageReference pgReturn = null;
        clstSportCharges = new List<SportCharge>();
        clstCancelTerms = null;
        if(cRTName == 'Sponsored Event'){
            cReservation = new club62__Reservation__c(
                club62__StartTime__c= DateTime.newInstance(cStartDt),
                club62__EndTime__c= DateTime.newInstance(cEndDt),
                club62__Club_Location__c=cFacId,
                club62__Setup_Time__c='Half Hour',
                club62__Cleanup_Time__c='Half Hour',
                club62__Contract_Deposit_Due_Date__c=DateTime.now().addDays(14),
                RecordTypeId=cmapRT.get(cRTName).id
            );
        } else {
            cReservation = new club62__Reservation__c(
                club62__StartTime__c= DateTime.newInstance(cStartDt),
                club62__EndTime__c= DateTime.newInstance(cEndDt),
                club62__Club_Location__c=cFacId,
                club62__Setup_Time__c='Half Hour',
                club62__Cleanup_Time__c='Half Hour',
                RecordTypeId=cmapRT.get(cRTName).id
            );
            if(cPageName == 'Sport_Calendar' || cPageName == 'Class_Calendar'){
                cReservation.club62__Setup_Time__c='';
                cReservation.club62__Cleanup_Time__c='';
            }
            if(cPageName == 'Sport_Calendar'){
                cReservation.POS_Item__c = 'COURT FEE';
            }
            resetMemberFilters();
            loadGrids();
        }
        showAddRoom = true;
        cShowPopup = true;
        return pgReturn;
    }

    /*
    @Name   :convertToSFReservation
    @Description :Converts an FCEvent to an club62__Reservation__c
    */
    public club62__Reservation__c convertToSFReservation(FCEvent fce){
        CRTName=fce.reservationVAR.RecordType.Name;
        return fce.reservationVAR;
    }

    /*
    @Name   :getReservations
    @Description :Populates the grid
    */
    @RemoteAction
    public static String getReservations(Long startTime, Long endTime, String facilityId, Boolean noFacilities, Boolean seatsAvailable,
        Boolean needPartnerFilter, Boolean confirmedEvent, List<String> lstRTNames, List<String> lstFacTypes,String selectedEventTypeFilter,String squTY){
        DateTime startDT = DateTime.newInstance(startTime);
        DateTime endDT = DateTime.newInstance(endTime);
        String startT = startDT.format('yyyy-MM-dd\'T\'HH:mm:ssZ');
        String endT = endDT.format('yyyy-MM-dd\'T\'HH:mm:ssZ');
        List<FCEvent> lstGridEvents = new List<FCEvent>();
        //Only show reservations for the facilities
        String strQueryFac = 'SELECT Id,Name,club62__Parent_Facility__c,'
                            + '(SELECT ' + C62Utilities.getFields('club62__Facility_Availability__c') + ' FROM club62__Facility_Availabilities__r WHERE club62__Active__c = true),'
                            + '(SELECT ' + C62Utilities.getFields('club62__Facility_Availability_Exception__c')
                                + ' FROM club62__Facility_Availability_Exceptions__r '
                                + ' WHERE ((club62__Start__c >= '
                                    + startT + ' AND club62__Start__c < '
                                    + endT + ') OR (club62__End__c > '
                                    + startT + ' AND club62__End__c <= '
                                    + endT + ') OR (club62__Start__c < '
                                    + startT + ' AND club62__End__c > '
                                    + endT + '))) '
                            + 'FROM club62__Facility__c '
                            + 'WHERE club62__Type__c INCLUDES (\'' + String.escapeSingleQuotes(String.join(lstFacTypes,'\',\'')) + '\') ';
        if(facilityId != null && facilityId != ''){
            strQueryFac += ' AND Id = \'' + String.escapeSingleQuotes(facilityId) + '\'';
        }
        List<club62__Facility__c> lstFac = Database.query(strQueryFac);
        //Create Unavailable timeslots in the grid if the facility is not available
        //The facility is not available outside available hours and during availability exception times
        //NOTE: tri nested loop - maximum should be #offacilities * 1(active facility availability) * 31
        for(club62__Facility__c fac : lstFac){
            for(club62__Facility_Availability__c fa : fac.club62__Facility_Availabilities__r){ //There should only be one faciilty availability per facility
                for(Integer i = 0; i <= startDT.date().daysBetween(endDT.date()); i++){
                    //for each day shown in the grid create the unavailable timeslots based on availability
                    DateTime currDT = startDT.addDays(i).addHours(-startDT.hour());
                    String currDay = currDT.format('EEEE');
                    if(fa.club62__Available_Days__c.contains(currDay)){
                        //Create the empty time from midnight to start time
                        lstGridEvents.add(createUnavailble(currDT,currDT.addHours(Integer.valueOf(fa.club62__Available_FROM__c)),fac.id,''));
                        //Create the emtpy time from end time to midnight
                        lstGridEvents.add(createUnavailble(currDT.addHours(Integer.valueOf(fa.club62__Available_To__c)),currDT.addMinutes(1439),fac.id,''));
                    } else {
                        //Facility is not available on this day
                        lstGridEvents.add(createUnavailble(currDT,currDT.addDays(1),fac.id,''));
                    }
                }
            }
            for(club62__Facility_Availability_Exception__c fae : fac.club62__Facility_Availability_Exceptions__r){
                //Add the exception as a unavailable timeslot
                lstGridEvents.add(createUnavailble(fae.club62__Start__c,fae.club62__End__c,fac.id,fae.club62__Description__c));
            }
        }
        //Get the reservations for the timeframe
        DateTime dateNow = DateTime.Now();
        String strQuery = 'SELECT Owner__r.Name, club62__Parent_Reservation__r.Name,RecordType.Name,club62__Club_Location__r.club62__Hourly_Charge__c,club62__Club_Location__r.Name,club62__Sponsoring_Customer__r.Name,club62__Institution__r.Name,'
                                    + 'club62__Parent_Reservation__r.club62__Sponsoring_Customer__c,club62__Parent_Reservation__r.club62__Sponsoring_Customer__r.Name,club62__Parent_Reservation__r.club62__Status__c,club62__Customer__r.club62__Status__c,'
                                    + C62Utilities.getFields('club62__Reservation__c')
                                    + ', (SELECT '+C62Utilities.getFields('club62__Game_Invite__c')+',club62__Sports_Buddy__r.club62__Initiating_Customer__c FROM club62__Game_Invites__r)'
                                    + ', (SELECT '+C62Utilities.getFields('club62__Sport_Reservation_Equipment__c')+' FROM club62__Sports_Reservation_Equipment__r)'
                                    + ' FROM club62__Reservation__c WHERE ((club62__StartTime__c >= '
                                    + startT + ' AND club62__StartTime__c < '
                                    + endT + ') OR (club62__EndTime__c > '
                                    + startT + ' AND club62__EndTime__c <= '
                                    + endT + ') OR (club62__StartTime__c < '
                                    + startT + ' AND club62__EndTime__c > '
                                    + endT + '))'
                                    + ' AND (club62__Status__c in (\'Tentative\',\'Confirmed\',\'Requires Partner\') or (club62__Status__c = \'Closed/Posted\' and club62__EndTime__c<=:dateNow) or (RecordType.Name = \'Reserved\'))';
        if(lstFac.size() > 0){
            List<String> lstFacIds = new List<String>();
            for(club62__Facility__c fac : lstFac){
                lstFacIds.add(fac.Id);
            }
            strQuery += ' AND club62__Club_Location__c IN (\'' + String.join(lstFacIds,'\',\'') + '\')';
        }
        if(facilityId != null && facilityId != ''){
            strQuery += ' AND club62__Club_Location__c = \'' + String.escapeSingleQuotes(facilityId) + '\'';
        } else if(noFacilities){
            strQuery += ' AND club62__Club_Location__c = null';
        }
        if(needPartnerFilter==true){
            strQuery += ' AND (club62__Total_Registration__c = 0 or club62__Total_Registration__c = 1)  AND club62__Require_Partner__c = true';
        }
        if(seatsAvailable){
            strQuery += ' AND club62__Seats_Available__c > 0';
        }
        if(confirmedEvent){
            strQuery += ' AND club62__Status__c = \'Confirmed\'';
        }
        //5-19-2015 Dru: show all types in the grid to indicate what timeslots are and are not available, show types that are not part of this grid as detail only
        /*if(selectedEventTypeFilter!=null && selectedEventTypeFilter!=''){
            if(selectedEventTypeFilter=='Sport' && squTY!=null && squTY=='Lesson'){
                strQuery +=' AND RecordType.Name=\'Lesson\' AND club62__Practice__c=FALSE';
            }else if(selectedEventTypeFilter=='Sport' && squTY!=null && squTY=='All Squash'){
                strQuery +=' AND RecordType.Name=\'Sport\' AND club62__Practice__c=FALSE';
            }else if(selectedEventTypeFilter=='Sport' && squTY!=null && squTY=='Practice'){
                strQuery +=' AND RecordType.Name=\'Sport\' AND club62__Practice__c=TRUE';
            }else if(selectedEventTypeFilter=='Sport'){
                strQuery += ' AND RecordType.Name IN (\'Sport\',\'Lesson\')';
            }else{
                strQuery += ' AND RecordType.Name = \'' + String.escapeSingleQuotes(selectedEventTypeFilter) + '\'';
            }
        }*/
        
        List<club62__Reservation__c> lstReservations = Database.query(strQuery);
        for(club62__Reservation__c reservation : lstReservations){
           convertReservation(reservation,lstGridEvents,reservation.RecordType.Name,new Set<String>(lstRTNames));
        }
        String jsonGridEventsTMP = JSON.serialize(lstGridEvents);
        List<String> tmpJsonLst = safeSplit(jsonGridEventsTMP,'VAR');
        String jsonGridEvents = '';
        for(String s : tmpJsonLst){
            jsonGridEvents += s.replaceAll('VAR','');
        }
        //jsonGridEvents = jsonGridEvents.replaceAll('VAR','');
        return jsonGridEvents;
    }
    
    /**
    * Split a string of any size, while avoiding the dreaded 'Regex too complicated'
    * error, which the String.split(String) method causes on some large inputs.
    * Note that this method does not avoid other errors, such as those related to excess heap size or CPU time.
    */
    public static List<String> safeSplit(String inStr, String delim){
        Integer regexFindLimit = 100;
        Integer regexFindCount = 0;    
        List<String> output = new List<String>();    
        Matcher m = Pattern.compile(delim).matcher(inStr);
        Integer lastEnd = 0;
        while(!m.hitEnd()){
            while(regexFindCount < regexFindLimit && !m.hitEnd()){
                if(m.find()){
                    output.add(inStr.substring(lastEnd, m.start()));  
                    lastEnd = m.end();
                }else{
                    output.add(inStr.substring(lastEnd));
                    lastEnd = inStr.length();
                }
                regexFindCount++;
            }

            // Note: Using region() to advance instead of substring() saves drastically on heap size. 
            // Nonetheless, we still must reset the (unmodified) input sequence to avoid a 'Regex too complicated' error.
            m.reset(inStr);        
            m.region(lastEnd, m.regionEnd());
            regexFindCount = 0;
        }
        return output;
    }

    /*
    @Name   :getResources
    @Description :Returns the Facilities as json string to be used for resources
    */
    public String getResources(){
        String strQuery = 'SELECT ' + C62Utilities.getFields('club62__Facility__c')
                            + ',(SELECT ' + C62Utilities.getFields('club62__Sport_Equipment__c') + ' FROM club62__Sports_Equipment__r)'
                            + ' FROM club62__Facility__c '
                            + 'WHERE club62__Type__c INCLUDES (\'' + String.escapeSingleQuotes(String.join(clstFacTypes,'\',\'')) + '\') '
                            + 'ORDER BY club62__Parent_Facility__c,club62__Order__c Asc';
        List<club62__Facility__c> lstFac = Database.query(strQuery);
        Set<club62__Facility__c> setFac = new Set<club62__Facility__c>(lstFac);
        Map<String,List<club62__Facility__c>> mapPCFac = new Map<String,List<club62__Facility__c>>();
        for(club62__Facility__c fac : lstFac){
            if(fac.club62__Parent_Facility__c != null){
                if(mapPCFac.containsKey(fac.club62__Parent_Facility__c)){
                    mapPCFac.get(fac.club62__Parent_Facility__c).add(fac);
                } else {
                    List<club62__Facility__c> lstF = new List<club62__Facility__c>();
                    lstF.add(fac);
                    mapPCFac.put(fac.club62__Parent_Facility__c,lstF);
                }
            }
        }
        
        if(facIdToMap!=null){facIdToMap.clear();}else{facIdToMap = new Map<Id,club62__Facility__c>();}

        List<FCResource> lstRes = new List<FCResource>();
        //Go through the list of facilities
        for(club62__Facility__c fac : lstFac){
            facIdToMap.put(fac.id,fac);
            //If the facility exists in the set, convert it to the final list, remove it from the set, and look for its children
            if(setFac.contains(fac)){
                lstRes.add(convertResource(fac));
                setFac.remove(fac);
                orderHierarchy(fac.id,setFac,mapPCFac,lstRes,'&nbsp;&nbsp;&nbsp;&nbsp;');
            }
        }
        String jsonResources = JSON.serialize(lstRes);
        jsonResources = jsonResources.replaceAll('VAR','');
        return jsonResources;
    }

    /*
    @Name   :orderHierarchy
    @Description :Recursive function to add children,grandchildren etc to the hierarchy list
    */
    public void orderHierarchy(String parentId, Set<club62__Facility__c> setUnmoved, Map<String,List<club62__Facility__c>> mapPC, List<FCResource> lstHier, String indent){
        //check if the parent has children
        String moreIndent = indent + '&nbsp;&nbsp;&nbsp;&nbsp;';
        if(mapPC.containsKey(parentId)){
            for(club62__Facility__c fac : mapPC.get(parentId)){
                //convert and add the child to the list, remove it from the set, and search for its children
                fac.name = indent + fac.name;
                lstHier.add(convertResource(fac));
                setUnmoved.remove(fac);
                orderHierarchy(fac.id,setUnmoved,mapPC,lstHier,moreIndent);
            }
        }
    }

    /*
    @Name   :getFacilities
    @Description :Returns the selectoption list for all facilities
    */
    public List<SelectOption> getFacilities(){
        List<SelectOption> lstSO = new List<SelectOption>();
        lstSO.add(new SelectOption('','--None--'));
        //Set information based on the calendar we are on
        String strPageName = ApexPages.currentPage().getUrl();
        clstFacTypes = new List<String>();
        if(strPageName.toLowerCase().contains('event_calendar')){
            clstFacTypes.add('Event');
        } else if (strPageName.toLowerCase().contains('class_calendar')){
            clstFacTypes.add('Class');
        } else if (strPageName.toLowerCase().contains('sport_calendar')){
            clstFacTypes.add('Sport');
        }
        String strQuery = 'SELECT Id,Name,club62__Parent_Facility__c '
                            + ' FROM club62__Facility__c'
                            + ' WHERE club62__Type__c INCLUDES (\'' + String.escapeSingleQuotes(String.join(clstFacTypes,'\',\'')) + '\')'
                            + ' ORDER By Name ASC';
        List<club62__Facility__c> lstFacs = Database.query(strQuery);
        for(club62__Facility__c fac : lstFacs){
            lstSO.add(new SelectOption(fac.Id,fac.Name));
        }
        return lstSO;
    }

    /*
    @Name   :getStartHour
    @Description :Returns the start hour used in the day view
    */
    public Decimal getStartHour(){
        Decimal decSH = 6;
        if(cCalOpts != null && cCalOpts.club62__Start_Hour__c != null && cCalOpts.club62__Start_Hour__c > -1 && cCalOpts.club62__Start_Hour__c < 24){
            decSH = cCalOpts.club62__Start_Hour__c;
        }
        return decSH;
    }

    /*
    @Name   :getEndHour
    @Description :Returns the end hour used in the day view
    */
    public Decimal getEndHour(){
        Decimal decEH = 22;
        if(cCalOpts != null && cCalOpts.club62__End_Hour__c != null && cCalOpts.club62__End_Hour__c > -1 && cCalOpts.club62__End_Hour__c < 24){
            decEH = cCalOpts.club62__End_Hour__c ;
        }
        return decEH;
    }
    
    /*
    @Name   :getSportStart
    @Description :Returns the start time used in the sport calendar
    */
    public String getSportStart(){
        String sStart = '6:15am';
        if(cCalOpts != null && cCalOpts.club62__Sport_Start_Time__c != null){
            sStart = cCalOpts.club62__Sport_Start_Time__c;
        }
        return sStart;
    }

    /*
    @Name   :getSportEnd
    @Description :Returns the end time used in the sport calendar
    */
    public String getSportEnd(){
        String sEnd = '9:00pm';
        if(cCalOpts != null && cCalOpts.club62__Sport_End_Time__c != null){
            sEnd = cCalOpts.club62__Sport_End_Time__c;
        }
        return sEnd;
    }

    /*
    @Name   :getSlotMinutes
    @Description :Returns the minutes per slot for the day view
    */
    public Decimal getSlotMinutes(){
        Decimal decSM = 30;
        if(cPageName == 'Sport_Calendar'){
            decSM = 45;
            if(cCalOpts != null && cCalOpts.club62__Sport_Slot_Minutes__c != null && cCalOpts.club62__Sport_Slot_Minutes__c > 0 && cCalOpts.club62__Sport_Slot_Minutes__c <= 60){
                decSM = cCalOpts.club62__Sport_Slot_Minutes__c;
            }
        } else if(cCalOpts != null && cCalOpts.club62__Slot_Minutes__c != null && cCalOpts.club62__Slot_Minutes__c > 0 && cCalOpts.club62__Slot_Minutes__c <= 60){
            decSM = cCalOpts.club62__Slot_Minutes__c;
        }
        return decSM;
    }

    /*
    @Name   :createUnavailble
    @Description :Creates an unavailable time slot for the given time frame and resource id
    */
    public static FCEvent createUnavailble(DateTime dtStart, DateTime dtEnd, String strResId,String tooltipDes){
        FCEvent fce = new FCEvent();
        fce.startVAR = dtStart;
        fce.endVAR = dtEnd;
        fce.resourceVAR = strResId;
        fce.titleVAR = 'Unavailable';
        fce.editableVAR = false;
        fce.allDayVAR = false;
        fce.tooltipVAR = fce.startVAR.format('h:mm a') + ' - ' + fce.endVAR.format('h:mm a');
        if(tooltipDes!=null && tooltipDes!='' && tooltipDes.length()>1){
            fce.tooltipVAR += '<br/>'+tooltipDes;
        }else{
            fce.tooltipVAR += '<br/>Facility is not available during this time.';
        }
        return fce;
    }

    /*
    @Name   :convertReservation
    @Description :Converts club62__Reservation__c objects into FCEvent objects and add them to the passed in list
    */
    public static void convertReservation(club62__Reservation__c reservation,List<FCEvent> lstGridEvents,String CRTName,Set<String> setPageRTs){
        FCEvent fce = new FCEvent();
        fce.idVAR = reservation.id;
        if(reservation.Name.startsWith('<')){reservation.Name = reservation.Name.replace('<','');}
        fce.reservationVAR = reservation;
        if(reservation.club62__Sponsoring_Customer__c != null){
            if(reservation.club62__Institution__c!=null){
                fce.titleVAR = reservation.club62__Institution__r.Name + '\n' + reservation.name;
            } else {fce.titleVAR = reservation.name;}
            //fce.titleVAR = reservation.name +' - '+reservation.club62__Sponsoring_Customer__r.name;
        } else {
            fce.titleVAR = reservation.name;
        }
        if(reservation.club62__Hidden_From_Portal__c == TRUE && CRTName=='Event'){
            fce.titleVAR = '*' + fce.titleVAR;
        }
        fce.startVAR = reservation.club62__StartTime__c;
        fce.endVAR = reservation.club62__EndTime__c;
        if(reservation.club62__All_Day__c){
            fce.allDayVAR = true;
        } else {
            fce.allDayVAR = false;
        }
        //Keep track of the setup and cleanup time offset in minutes
        Integer intSetup = 0;
        Integer intCleanup = 0;
        if(reservation.club62__Setup_Time__c == 'Half Hour'){
            intSetup = 30;
        } else if (reservation.club62__Setup_Time__c == '1 Hour'){
            intSetup = 60;
        } else if (reservation.club62__Setup_Time__c == '2 Hours'){
            intSetup = 120;
        }
        if(reservation.club62__Cleanup_Time__c == 'Half Hour'){
            intCleanup = 30;
        } else if (reservation.club62__Cleanup_Time__c == '1 Hour'){
            intCleanup = 60;
        } else if (reservation.club62__Cleanup_Time__c == '2 Hours'){
            intCleanup = 120;
        }
        //Past reservations are grey, future reservations are green, reserved slots are light blue
        if(reservation.RecordType.Name == 'Reserved'){ //Reserved type event
            //Add setup and cleanup time to the reserved time
            fce.tooltipVAR = fce.startVAR.format('h:mm a') + ' - ' + fce.endVAR.format('h:mm a')
                                + '<br/>Reserved by ' + reservation.club62__Parent_Reservation__r.Name;
            if(reservation.club62__Parent_Reservation__r.club62__Sponsoring_Customer__c != null){
                //fce.titleVAR = 'Reserved by Parent';
                fce.titleVAR = 'Unavailable';
                
                fce.tooltipVAR += '<br/>Sponsored by ' + reservation.club62__Parent_Reservation__r.club62__Sponsoring_Customer__r.Name;
                if(fce.endVAR < DateTime.now()){ //Past reservation
                    fce.colorVAR = '#D0D0D0';
                }else if(reservation.club62__Parent_reservation__r.club62__Status__c=='Tentative'){
                        fce.colorVAR='#FF7744';
                }else if(reservation.club62__Parent_reservation__r.club62__Status__c=='Confirmed'){
                        fce.colorVar = '#33AACC';
                }else if(reservation.club62__Status__c=='Approved'){
                        fce.colorVAR='#FFFF00';
                }else{fce.colorVAR='#f4a80f';}
            } else {
                //fce.titleVAR = 'Reserved by Parent';
                fce.titleVAR = 'Unavailable';

                if(fce.endVAR < DateTime.now()){ //Past reservation
                    fce.colorVAR = '#D0D0D0';
                }else if(reservation.club62__Parent_reservation__r.club62__Status__c=='Tentative'){
                        fce.colorVAR='#FF7744';
                }else if(reservation.club62__Parent_reservation__r.club62__Status__c=='Confirmed'){
                        fce.colorVar = '#33AACC';
                }else if(reservation.club62__Status__c=='Approved'){
                        fce.colorVAR='#FFFF00';
                }else{fce.colorVAR='#f4a80f';}
            }

            fce.startVAR = fce.startVAR.addMinutes(-intSetup);
            fce.endVAR = fce.endVAR.addMinutes(intCleanup);
            fce.editableVAR = false;
            fce.typeVAR = 'reserved';
            //The url points to the parent if there is one, otherwise point to the reservation
            if(reservation.club62__Parent_Reservation__c != null){
                fce.urlVAR = '/' + reservation.club62__Parent_Reservation__c;
            } else {
                fce.urlVAR = '/' + reservation.id;
            }

        } else {
            fce.tooltipVAR = fce.startVAR.format('h:mm a') + ' - ' + fce.endVAR.format('h:mm a');
            if(reservation.club62__Sponsoring_Customer__c != null){
                fce.tooltipVAR += '<br/> B: ' + reservation.Name;
            }
            if(reservation.RecordType.Name=='Event'){
                fce.tooltipVAR += '<br/> P: ' + reservation.Name;
            }
            fce.tooltipVAR += //'<br/>' + reservation.club62__Seats_Available__c + ' Seats Available'+
                             '<br/>' + reservation.club62__Club_Location__r.Name;
            if(reservation.club62__Owner__c!=null){
                fce.tooltipVAR += '<br/>' + 'Sales Manager: '+ reservation.club62__Owner__r.Name;
            }
            if(reservation.RecordType.Name=='Sponsored Event' && reservation.club62__Function__c!=null){
                fce.tooltipVAR += '<br/>' + reservation.club62__Function__c;
            }
            if(reservation.club62__Street_Address__c != null){
                fce.tooltipVAR += '<br/>' + reservation.club62__Street_Address__c;
            }
            if(reservation.club62__City__c != null && reservation.club62__State_Province__c != null){
                fce.tooltipVAR += '<br/>' + reservation.club62__City__c + ', ' + reservation.club62__State_Province__c;
            }
            if(reservation.club62__Zip__c != null){
                fce.tooltipVAR += '<br/>' + reservation.club62__Zip__c;
            }
            if(fce.endVAR < DateTime.now()){ //Past reservation
                fce.colorVAR = '#D0D0D0';
                fce.editableVAR = false;
                fce.typeVAR = 'pastReservation';
                fce.urlVAR = '/' + reservation.id;
                if(reservation.RecordType.Name == 'Sport'){
                    fce.tooltipVAR = '';
                }
            } else { //Future reservation
                //fce.colorVAR = '#00CC00';
                fce.editableVAR = false;
                fce.typeVAR = 'futureReservation';
                //Editable only if type is future and record type name matches the page we are on
                if(setPageRTs.contains(CRTName)) fce.editableVAR = true;
                else fce.urlVAR = '/' + reservation.id;
                if(reservation.RecordType.Name == 'Sport' || reservation.RecordType.Name == 'Lesson'){
                    fce.tooltipVAR = fce.startVAR.format('h:mm a') + ' - ' + fce.endVAR.format('h:mm a');
                    if(reservation.club62__Require_Partner__c == TRUE){
                        if(reservation.club62__Game_Invites__r.size()>0){
                            Boolean confirmedFlag = False;
                            for(club62__Game_Invite__c gi : reservation.club62__Game_Invites__r){
                                if(gi.club62__Status__c=='Accepted'){
                                    confirmedFlag = TRUE;
                                }
                            }
                            if(confirmedFlag){
                                fce.tooltipVAR += '<br/>Confirmed';
                                fce.colorVAR = '#54E55A';
                            }else{
                                fce.tooltipVAR += '<br/>Partner Required';
                                fce.colorVAR = '#F0E190';
                            }
                        }else{
                            fce.tooltipVAR += '<br/>Partner Required';
                            fce.colorVAR = '#F0E190';
                        }
                    }else if(reservation.RecordType.Name == 'Lesson'){
                        fce.tooltipVAR += '<br/>Lesson';
                        fce.colorVAR = '#33AACC';
                    }else{
                        fce.tooltipVAR += '<br/>Confirmed';
                        fce.colorVAR = '#54e55a';
                    }
                    if(reservation.club62__Practice__c){
                        fce.colorVAR = '#FFCCFF';
                    }
                    if(reservation.club62__Event_Cost__c!=null){
                        fce.tooltipVAR += '<br/> $' + String.valueOf(reservation.club62__Event_Cost__c.setScale(2));
                    }else{
                        fce.tooltipVAR += '<br/> $0.00';
                    }
                    
                    if(reservation.club62__Customer__c!=null){
                        fce.tooltipVAR += '<br/> Member Status: ' + reservation.club62__Customer__r.club62__Status__c;
                    }
                }
                //set the legends for event calendar
                if(reservation.RecordType.Name=='Event' || reservation.RecordType.Name=='Sponsored Event' || reservation.RecordType.Name == 'Events - Child' || reservation.RecordType.Name =='Sponsored Event - Child'){
                    if(reservation.RecordType.Name=='Event' || reservation.RecordType.Name == 'Events - Child'){if(reservation.club62__Status__c=='Tentative'){fce.colorVAR='#FF7744';}else if(reservation.club62__Status__c=='Confirmed'){fce.colorVAR='#33AACC';}else if(reservation.club62__Status__c=='Approved'){fce.colorVAR='#FFFF00';}else{fce.colorVAR='#f4a80f';}}
                    if(reservation.RecordType.Name=='Sponsored Event' || reservation.RecordType.Name=='Sponsored Event - Child'){if(reservation.club62__Status__c=='Tentative'){fce.colorVAR='#FF7744';}else if(reservation.club62__Status__c=='Confirmed'){fce.colorVAR='#33AACC';}else if(reservation.club62__Status__c=='Approved'){fce.colorVAR='#FFFF00';}else{fce.colorVAR='#f4a80f';}}
                }


                //set the legends for class calendar
                if(reservation.RecordType.Name=='Class'){
                    if(reservation.club62__Seats_Available__c<=0){
                        fce.colorVAR = '#EBDACA';
                    }else {
                        fce.colorVAR = '#F0E190';
                    }
                }
            }
            //Create setup and cleanup timeslots for actual reservations
            if(intSetup != 0){
                FCEvent fceSetup = new FCEvent();
                fceSetup.resourceVAR = reservation.club62__Club_Location__c;
                if(fce.endVAR < DateTime.now()){
                    fceSetup.colorVAR = '#D0D0D0';
                }else{
                    if(reservation.club62__Status__c=='Tentative' || reservation.club62__Status__c=='Approved'){
                        fceSetup.colorVAR='#FF7744';
                    }
                    else if(reservation.club62__Status__c=='Confirmed'){
                        fceSetup.colorVar = '#33AACC';
                    }else{fceSetup.colorVAR='#f4a80f';}
                }
                fceSetup.idVAR = reservation.id + 'setup';
                fceSetup.titleVAR = '';
                fceSetup.startVAR = reservation.club62__StartTime__c.addMinutes(-intSetup);
                fceSetup.endVAR = reservation.club62__StartTime__c;
                fceSetup.tooltipVAR = fceSetup.startVAR.format('h:mm a') + ' - ' + fceSetup.endVAR.format('h:mm a') + '<br/>Setup time for ' + reservation.name;
                fceSetup.editableVAR = false;
                fceSetup.typeVAR = 'setupTime';
                lstGridEvents.add(fceSetup);
            }
            if(intCleanup != 0){
                FCEvent fceCleanup = new FCEvent();
                fceCleanup.resourceVAR = reservation.club62__Club_Location__c;
                if(fce.endVAR < DateTime.now()){
                    fceCleanup.colorVAR = '#D0D0D0';
                }else{
                    if(reservation.club62__Status__c=='Tentative' || reservation.club62__Status__c=='Approved'){
                        fceCleanup.colorVAR='#FF7744';
                }
                    else if(reservation.club62__Status__c=='Confirmed'){
                        fceCleanup.colorVar = '#33AACC';
                    }else{fceCleanup.colorVAR='#f4a80f';}
                }
                fceCleanup.idVAR = reservation.id + 'cleanup';
                fceCleanup.titleVAR = '';
                fceCleanup.startVAR = reservation.club62__EndTime__c;
                fceCleanup.endVAR = reservation.club62__EndTime__c.addMinutes(intCleanup);
                fceCleanup.tooltipVAR = fceCleanup.startVAR.format('h:mm a') + ' - ' + fceCleanup.endVAR.format('h:mm a') + '<br/>Cleanup time for ' + reservation.name;
                fceCleanup.editableVAR = false;
                fceCleanup.typeVAR = 'cleanupTime';
                lstGridEvents.add(fceCleanup);
            }
        }
        if(reservation.RecordType.Name == 'Sport' && reservation.club62__Customer__c!=null && (reservation.club62__Customer__r.club62__Status__c=='Expelled' || 
            reservation.club62__Customer__r.club62__Status__c=='Expelled Collections' || reservation.club62__Customer__r.club62__Status__c=='Suspended'
            || reservation.club62__Customer__r.club62__Status__c=='Deceased')){
            fce.colorVAR = '#FF7744';
        }
        fce.resourceVAR = reservation.club62__Club_Location__c;

        //check if reservation is reserved type and parent reservation status is cancelled then do not display
        if(reservation.RecordType.Name=='Reserved' && reservation.club62__Parent_Reservation__c!=null && reservation.club62__Parent_Reservation__r.club62__Status__c=='Cancelled'){
            //do not add
        } else {
            // see if there is another event in the same location with a time conflict
            /*for(integer i = 0; i < lstGridEvents.size(); i++){
                FCEvent f = lstGridEvents[i];
                if(fce.resourceVAR == f.resourceVAR && fce.startVAR <= f.endVAR && fce.endVAR >= f.startVAR){
                    // we have a conflict with something in the list
                    // updated fce to include the full time of both events
                    // remove the old event and add fce to list
                    
                    //fce.tooltipVAR = 'More than one event.';
                    //fce.titleVAR = 'Unavailable';
                    if(fce.startVAR > f.startVAR){fce.startVAR = f.startVAR;}
                    if(fce.endVAR < f.endVAR){fce.endVAR = f.startVAR;}
                    lstGridEvents.remove(i);
                    i = 0;
                }
            }*/
            lstGridEvents.add(fce);
        }
    }

    /*
    @Name   :convertResource
    @Description :Converts club62__Facility__c objects into FCResource objects
    */
    public static FCResource convertResource(club62__Facility__c resource){
        FCResource fcr = new FCResource();
        fcr.idVAR = resource.id;
        if(resource.name.contains('&nbsp;')){
            String strSpaces = '';
            String strName = '';
            strSpaces = resource.name.substring(0,resource.name.lastIndexOf('&nbsp;')+6);
            strName = resource.name.substring(resource.name.lastIndexOf('&nbsp;')+6);
            if(strName.startsWith('<')){strName = strName.replace('<','');}
            fcr.nameVAR = strSpaces + '<a href=\'/' + resource.id + '\'>' + strName + '</a>';
        } else {
            String strName = resource.name;
            if(strName.startsWith('<')){strName = strName.replace('<','');}
            fcr.nameVAR = '<a href=\'/' + resource.id + '\'>' + strName + '</a>';
        }
        fcr.readonlyVAR = false;
        fcr.parentVAR = resource.club62__Parent_Facility__c;
        return fcr;
    }

    /*
    @Name   :calendarMsgTab
    @Description :redirects to calendar message tab
    */
    public PageReference calendarMsgTab(){
        String prefix = C62Utilities.getPrefixMapCalCont(true).get('club62__Calendar_Message__c');
        return new PageReference('/' + prefix);
    }

    /*
    @Name   :getCalMessages
    @Description :sets the list of calendar messages based on the date range shown in the grid
    */
    public void getCalMessages(){
        Date dtStart = Date.newInstance(cStartYear,cStartMonth+1,cStartDay);
        Date dtEnd = Date.newInstance(cEndYear,cEndMonth+1,cEndDay);
        cCalMessages = [SELECT Id,Name,club62__Date__c,club62__Description__c
                        FROM club62__Calendar_Message__c
                        WHERE club62__Date__c >= :dtStart AND club62__Date__c <= :dtEnd];
        if(ApexPages.currentPage().getUrl().toLowerCase().contains('event_calendar')){
            //Using C62user Session Setting, for the last view of claendar.
            List<club62__C62User_Session_Settings__c> usSettings = club62__C62User_Session_Settings__c.getAll().values();
            club62__C62User_Session_Settings__c newSession;
            for(club62__C62User_Session_Settings__c uss : usSettings){
                if(uss.Name==UserInfo.getUserId().subString(0,15)){
                    newSession = uss;
                }
            }
            if(newSession==null){newSession = new club62__C62User_Session_Settings__c(Name=UserInfo.getUserId().subString(0,15));}
            newSession.club62__Event_Calendar_Last_View_Date__c = dtStart;
            upsert newSession;
        }
    }

    /*
    @Name   :getMemberReservers
    @Description :Remote method that returns json for members with the name
    */
    @RemoteAction
    public static List<JSONObject> getMemberReservers(String strName){
        List<JSONObject> lstReturn = new List<JSONObject>();
        strName = '%' + strName + '%';
        List<Contact> lstMems = [SELECT Id,Name,club62__Customer_Id__c,club62__Status__c FROM Contact WHERE Name LIKE :strName AND
                                club62__Status__c IN ('Active','Reinstated') ORDER BY Name ASC LIMIT 999];
        for(Contact mem : lstMems){
            JSONObject jso = new JSONObject();
            jso.category = 'Members';
            jso.id = mem.id;
            jso.label = mem.Name;
            if(mem.club62__Customer_Id__c!=null){jso.label += ' - '+mem.club62__Customer_Id__c;}
            lstReturn.add(jso);
        }
        return lstReturn;
    }

    /*
    @Name   :getInstitutionReservers
    @Description :Remote method that returns json for Institution with the name
    */
    @RemoteAction
    public static List<JSONObject> getInstitutionReservers(String strName,String section){
        List<JSONObject> lstReturn = new List<JSONObject>();
        strName = '%' + strName + '%';
        List<club62__Institution__c> lstIns = [SELECT Id,Name FROM club62__Institution__c WHERE Name LIKE :strName ORDER BY Name ASC LIMIT 10];
        for(club62__Institution__c ins : lstIns){
            JSONObject jso = new JSONObject();
            jso.category = 'Institutions';
            jso.id = ins.id;
            jso.label = ins.Name;
            lstReturn.add(jso);
        }
        if((lstIns==null || lstIns.size()<=0) && section=='popup'){
            JSONObject jso = new JSONObject();
            jso.category = 'Institutions';
            jso.id = '';
            jso.label = 'Create a new Institution';
            lstReturn.add(jso);
        }
        return lstReturn;
    }

    /*
    @Name   :getPersonReservers
    @Description :Remote method that returns json for persons with the name
    */
    @RemoteAction
    public static List<JSONObject> getPersonReservers(String strName,String ins){
        List<JSONObject> lstReturn = new List<JSONObject>();
        strName = '%' + String.escapeSingleQuotes(strName) + '%';
        String qry = 'SELECT Id,Name,club62__Email__c,club62__Status__c FROM club62__Person__c WHERE Name LIKE \'' + strName + '\'';
        if(ins!=null && ins!= ''){qry += ' AND club62__Primary_Institution__c = \''+String.escapeSingleQuotes(ins)+'\'';}
        List<club62__Person__c> lstPeeps = Database.query(qry);
        for(club62__Person__c per : lstPeeps){
            JSONObject jso = new JSONObject();
            jso.category = 'Persons';
            jso.id = per.id;
            jso.label = per.Name;
            if(per.club62__Email__c!=null){jso.label += ' - ' +per.club62__Email__c;}
            lstReturn.add(jso);
        }
        if(lstPeeps==null || lstPeeps.size()<=0){
            JSONObject jso = new JSONObject();
            jso.category = 'Persons';
            jso.id = '';
            jso.label = 'Create a new Person';
            lstReturn.add(jso);
        }
        return lstReturn;
    }

    /*
    @Name   :sportResAutoFields
    @Description :Populate the reservation type ahead feilds
    */
    public void sportResAutoFields(){
        try{
            if(cObjId != null){
                descriptionFromMemButton = '';
                Contact spMember = [SELECT Id,Name FROM Contact WHERE Id =:cObjId LIMIT 1];
                descriptionFromMemButton = spMember.Name;
                cReservation.club62__Customer__c = spMember.Id;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

    /*
    @Name   :resAutoFields
    @Description :Populate the reservation type ahead feilds
    */
    public void resAutoFields(){
        try{
            if(cObjId != null && cObjType == 'Contact'){
                Contact c = [SELECT Id,Name FROM Contact WHERE Id = :cObjId LIMIT 1];
                descriptionFromMemButton = c.Name;
                cReservation.club62__Sponsoring_Customer__c = c.Id;
            } else if(cObjId != null && cObjType == 'club62__Institution__c'){
                club62__Institution__c c = [SELECT Id,Name FROM club62__Institution__c WHERE Id = :cObjId LIMIT 1];
                descriptionFromInsButton = c.Name;
                cReservation.club62__Institution__c = c.Id;
            } else if(cObjid != null && cObjType == 'club62__PrimaryPerson__c'){
                club62__Person__c c = [SELECT Id,Name FROM club62__Person__c WHERE Id = :cObjId LIMIT 1];
                descriptionFromPrimaryButton = c.Name;
                cReservation.club62__Primary_Contact__c = c.Id;
            } else if(cObjid != null && cObjType == 'club62__PaymentPerson__c'){
                club62__Person__c c = [SELECT Id,Name FROM club62__Person__c WHERE Id = :cObjId LIMIT 1];
                descriptionFromPaymentButton = c.Name;
                cReservation.club62__Payment_Contact__c = c.Id;
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }

    /*
    @Name   :createNewRecord
    @Description :Redirect to the standard edit page for a given type
    */
    public void createNewRecord(){
        if(cNewRecordType=='club62__Institution__c'){
            cNewInstitution = new club62__Institution__c();
            cNewInstitutionAdd = new club62__Address__c();
            cNewInstitutionAdd.club62__Country__c = 'United States';
        } else if(cNewRecordType=='club62__PrimaryPerson__c'){
            cNewPrimaryPerson = new club62__Person__c();
            cNewPrimaryPerAdd = new club62__Address__c();
            cNewPrimaryPerAdd.club62__Country__c = 'United States';
        } else if(cNewRecordType=='club62__PaymentPerson__c'){
            cNewPaymentPerson = new club62__Person__c();
            cNewPaymentPerAdd = new club62__Address__c();
            cNewPaymentPerAdd.club62__Country__c = 'United States';
        }
        cNewRecShowPopup = true;
    }

    /*
    @Name   :closeNewRecPopup
    @Description :Close the new record popup window
    */
    public void closeNewRecPopup(){
        cNewRecShowPopup = false;
    }

    /*
    @Name   :saveNewRec
    @Description :Save the new record and populate it on reservation
    */
    public void saveNewRec(){
        SavePoint sp = Database.setSavePoint();
        try{
            if(cNewRecordType=='club62__Institution__c'){
                RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'club62__Institution__c' AND Name = 'Business'];
                cNewInstitution.RecordTypeId = rt.Id;
                if(Schema.sObjectType.club62__Institution__c.isCreateable()){insert cNewInstitution;}
                String strInstitutionQuery = 'SELECT ' + C62Utilities.getFields('club62__Institution__c') + ' FROM club62__Institution__c WHERE Id = \'' + String.escapeSingleQuotes(cNewInstitution.Id) + '\'';
                club62__Institution__c ins = Database.query(strInstitutionQuery);
                if(cNewInstitutionAdd.club62__Type__c!=null || cNewInstitutionAdd.club62__Street_1__c!=null || cNewInstitutionAdd.club62__Street_2__c!=null
                    || cNewInstitutionAdd.club62__Street_3__c!=null || cNewInstitutionAdd.club62__City__c!=null || cNewInstitutionAdd.club62__State_Province__c!=null
                    || cNewInstitutionAdd.club62__Country__c!=null || cNewInstitutionAdd.club62__Zip_Postal_Code__c!=null){
                    if(cNewInstitutionAdd.club62__Type__c!=null){cNewInstitutionAdd.Name=ins.Name+' '+cNewInstitutionAdd.club62__Type__c+' Address';}
                    else{cNewInstitutionAdd.Name=ins.Name+' Address';}
                    cNewInstitutionAdd.club62__Institution__c = ins.Id;
                    if(Schema.sObjectType.club62__Address__c.isCreateable()){insert cNewInstitutionAdd;}
                }
                descriptionFromInsButton = ins.Name;
                cReservation.club62__Institution__c = ins.Id;
                cNewInstitution = null;
            } else if(cNewRecordType=='club62__PrimaryPerson__c'){
                RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'club62__Person__c' AND Name = 'Individual'];
                cNewPrimaryPerson.RecordTypeId = rt.Id;
                if(cReservation.club62__Institution__c!=null){
                    cNewPrimaryPerson.club62__Primary_Institution__c = cReservation.club62__Institution__c;
                }
                if(Schema.sObjectType.club62__Person__c.isCreateable()){insert cNewPrimaryPerson;}
                String strPersonQuery = 'SELECT ' + C62Utilities.getFields('club62__Person__c') + ' FROM club62__Person__c WHERE Id = \'' + String.escapeSingleQuotes(cNewPrimaryPerson.Id) + '\'';
                club62__Person__c per = Database.query(strPersonQuery);
                if(cNewPrimaryPerAdd.club62__Type__c!=null || cNewPrimaryPerAdd.club62__Street_1__c!=null || cNewPrimaryPerAdd.club62__Street_2__c!=null
                    || cNewPrimaryPerAdd.club62__Street_3__c!=null || cNewPrimaryPerAdd.club62__City__c!=null || cNewPrimaryPerAdd.club62__State_Province__c!=null
                    || cNewPrimaryPerAdd.club62__Country__c!=null || cNewPrimaryPerAdd.club62__Zip_Postal_Code__c!=null){
                    if(cNewPrimaryPerAdd.club62__Type__c!=null){cNewPrimaryPerAdd.Name=per.Name+' '+cNewPrimaryPerAdd.club62__Type__c+' Address';}
                    else{cNewPrimaryPerAdd.Name=per.Name+' Address';}
                    cNewPrimaryPerAdd.club62__Person__c = per.Id;
                    if(Schema.sObjectType.club62__Address__c.isCreateable()){insert cNewPrimaryPerAdd;}
                }
                descriptionFromPrimaryButton = per.Name;
                cReservation.club62__Primary_Contact__c = per.Id;
                cNewPrimaryPerson = null;
            } else if(cNewRecordType=='club62__PaymentPerson__c'){
                RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'club62__Person__c' AND Name = 'Individual'];
                cNewPaymentPerson.RecordTypeId = rt.Id;
                if(cReservation.club62__Institution__c!=null){
                    cNewPaymentPerson.club62__Primary_Institution__c = cReservation.club62__Institution__c;
                }
                if(Schema.sObjectType.club62__Person__c.isCreateable()){insert cNewPaymentPerson;}
                String strPersonQuery = 'SELECT ' + C62Utilities.getFields('club62__Person__c') + ' FROM club62__Person__c WHERE Id = \'' + String.escapeSingleQuotes(cNewPaymentPerson.Id) + '\'';
                club62__Person__c per = Database.query(strPersonQuery);
                if(cNewPaymentPerAdd.club62__Type__c!=null || cNewPaymentPerAdd.club62__Street_1__c!=null || cNewPaymentPerAdd.club62__Street_2__c!=null
                    || cNewPaymentPerAdd.club62__Street_3__c!=null || cNewPaymentPerAdd.club62__City__c!=null || cNewPaymentPerAdd.club62__State_Province__c!=null
                    || cNewPaymentPerAdd.club62__Country__c!=null || cNewPaymentPerAdd.club62__Zip_Postal_Code__c!=null){
                    if(cNewPaymentPerAdd.club62__Type__c!=null){cNewPaymentPerAdd.Name=per.Name+' '+cNewPaymentPerAdd.club62__Type__c+' Address';}
                    else{cNewPaymentPerAdd.Name=per.Name+' Address';}
                    cNewPaymentPerAdd.club62__Person__c = per.Id;
                    if(Schema.sObjectType.club62__Address__c.isCreateable()){insert cNewPaymentPerAdd;}
                }
                descriptionFromPaymentButton = per.Name;
                cReservation.club62__Payment_Contact__c = per.Id;
                cNewPaymentPerson = null;
            }

        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        cNewRecShowPopup = false;
    }

    /*
    @Name   :displayEventGrid
    @Description :display member sponsored event grid based on filters
    */
    public void displayEventGrid(){
        String qry = 'Select Id,Name,club62__StartTime__c From club62__Reservation__c Where Id!=null ';
        if(cSearchObjType=='club62__Institution__c'){
            if(cSearchObjId!=null && cSearchObjId!=''){
                cSearchReservation.club62__Institution__c = cSearchObjId;
                descriptionFromInsFilter = [Select Id,Name From club62__Institution__c Where Id=:cSearchObjId].Name;
            } else {
                cSearchReservation.club62__Institution__c = null;
                descriptionFromInsFilter = null;
            }
        }
        if(cSearchObjType=='Contact'){
            if(cSearchObjId!=null && cSearchObjId!=''){
                cSearchReservation.club62__Sponsoring_Customer__c = cSearchObjId;
                descriptionFromMemFilter = [Select Id,Name From Contact Where Id=:cSearchObjId].Name;
            } else {
                cSearchReservation.club62__Sponsoring_Customer__c = null;
                descriptionFromMemFilter = null;
            }
        }
        if(cSearchReservation.club62__Institution__c!=null){
            qry += ' AND club62__Institution__c = \'' + String.escapeSingleQuotes(cSearchReservation.club62__Institution__c) + '\'';
        }
        if(cSearchReservation.club62__Sponsoring_Customer__c!=null){
            qry += ' AND club62__Sponsoring_Customer__c = \'' + String.escapeSingleQuotes(cSearchReservation.club62__Sponsoring_Customer__c) + '\'';
        }
        if(cSearchObjType=='EventType' && selectedEventTypeFilter!=null && selectedEventTypeFilter!=''){
            qry +=' AND RecordType.Name = \'' + String.escapeSingleQuotes(selectedEventTypeFilter) + '\'';
        }
        mseList = Database.query(qry);
    }
    /*
    @Name   :copyPrimaryContact
    @Description :Copy primary contact of Reservations.
    */
    public void copyPrimaryContact(){
        if(sameAsPrimaryContact){
            descriptionFromPaymentButton = descriptionFromPrimaryButton;
            cReservation.club62__Payment_Contact__c = cReservation.club62__Primary_Contact__c;
        }else{
            descriptionFromPaymentButton = '';
            cReservation.club62__Payment_Contact__c = null;
        }
    }
}