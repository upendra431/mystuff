/*
@Name            : C62RSVPController
@Author          : customersuccess@cloud62.com
@Date            : Dec 27, 2013
@Description     : Controller for RSVP page
*/
public with sharing class C62RSVPController {
    //Class Variables
    public String cPageName {get;set;}
    public club62__Reservation__c cRes {get;set;}
    public club62__Reservation_Registration__c cResReg {get;set;}
    public String cRecipResRegId{get;set;}
    public String cResponse {get;set;}
    public String cResRegId {get;set;}
    public String cSiteURL {get;set;}
    public Boolean cHttpsFlag {get;set;}
    public String cMemberId {get;set;}
    public Boolean justCreated{get;set;}
    public String cResRegFor{get;set;}
    public String pageType{get;set;}
    public Boolean hideFeaturedBox{get;set;}
    Boolean alreadyRegistered{get;set;}

    /*
    @Name   :C62RSVPController
    @Description :Constructor to initalize the page
    */
    public C62RSVPController(){
        cPageName = 'Message';
        //Getting URL parameters
        cResponse = ApexPages.CurrentPage().getParameters().get('response');
        cResRegId = ApexPages.CurrentPage().getParameters().get('rr');
        String memId = ApexPages.CurrentPage().getParameters().get('msid');
        String cMemId = ApexPages.CurrentPage().getParameters().get('mid');
        String cMemEmail = ApexPages.CurrentPage().getParameters().get('mem');
        String cResId = ApexPages.CurrentPage().getParameters().get('rid');
        String hashCode = ApexPages.CurrentPage().getParameters().get('hc');
        String type = ApexPages.CurrentPage().getParameters().get('t');
        String hideFeaturedBoxStr = ApexPages.CurrentPage().getParameters().get('hfb');
        //Should we hide the featured details on the page?
        if(hideFeaturedBoxStr!=null && hideFeaturedBoxStr!=''){
            if(hideFeaturedBoxStr=='1'){
                hideFeaturedBox = true;
            }
        }
        String errType;
        pageType = 'Details';
        Boolean justCreated = false;
        alreadyRegistered = false;
        //Check For page validation
        if(!((hashCode!=null && cResRegId!=null /*&& cresponse!=null && (cresponse=='0' || cResponse=='1')*/) || (cResId!=null && (hashcode!=null || type=='g') &&(cMemId!=null || memId!=null || cMemEmail!=null)))){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid URL, Please try clicking the link again.'));
        }else{
            try{
                if(cResRegId!=null){
                    //Query reservation and reservation registration if available
                    cResReg = Database.query('SELECT ' + C62Utilities.getFields('club62__Reservation_Registration__c') + ' FROM club62__Reservation_Registration__c WHERE Id = \'' + String.escapeSingleQuotes(cResRegId) + '\'');
                    cRes = Database.query('SELECT RecordType.Name,club62__Club_Location__r.Name,' + C62Utilities.getFields('club62__Reservation__c') + ' FROM club62__Reservation__c WHERE Id = \'' + String.escapeSingleQuotes(cResReg.club62__Reservation__c) + '\'');
                //If reservation registration does not exist then create new 
                }else if((memId!=null || cMemEmail!=null || cMemId!=null)&&cResId!=null){
                    Boolean alreadyExists = false;
                    cRes = Database.query('SELECT RecordType.Name,club62__Club_Location__r.Name,' + C62Utilities.getFields('club62__Reservation__c') + ' FROM club62__Reservation__c WHERE Id = \'' + String.escapeSingleQuotes(cResId) + '\'');
                    cResReg = new club62__Reservation_Registration__c();
                    if(cmemEmail!=null && hashcode!=null &&hashcode!='' &&hashcode!='null'){
                        List<Contact> con = [select id,Email from Contact where email=:cmemEmail and club62__hashcode__c=:hashcode limit 1];
                        if(con.size()>0){
                            memId = con[0].id;
                            cResReg.club62__Customer_Email__c = con[0].Email;
                        }else{
                            cPageName = 'Invalid Credentials Provided';
                            errType = 'info';
                            throw new C62Utilities.CustomException('Invalid Credentials Provided');
                        }
                    }else if(cmemid!=null && hashcode!=null &&hashcode!='' &&hashcode!='null'){
                        List<Contact> con = [select id,Email from Contact where club62__Customer_Id__c=:cMemId and club62__hashcode__c=:hashcode limit 1];
                        if(con.size()>0){
                            memId = con[0].id;
                            cResReg.club62__Customer_Email__c = con[0].Email;
                        }else{
                            cPageName = 'Invalid Credentials Provided';
                            errType = 'info';
                            throw new C62Utilities.CustomException('Invalid Credentials Provided');
                        }
                    }else if(memId!=null && hashcode!=null &&hashcode!='' &&hashcode!='null'){
                        List<Contact> con = [select id,Email from Contact where Id=:MemId and club62__hashcode__c =:hashcode limit 1];
                        if(con.size()>0){
                            cResReg.club62__Customer_Email__c = con[0].Email;
                        }else{
                            cPageName = 'Invalid Credentials Provided';
                            errType = 'info';
                            throw new C62Utilities.CustomException('Invalid Credentials Provided');
                        }
                    }else if(type!='g'){
                        cPageName = 'Invalid Credentials Provided';
                        errType = 'info';
                        throw new C62Utilities.CustomException('Invalid Credentials Provided');
                    }else if(type=='g'){
                        cResRegFor='Reciprocal Member';
                    }
                    //Getting Member reservation registration
                    List<club62__Reservation_Registration__c> resReg = [Select id,club62__Status__c,club62__Person__c,club62__Customer__c,club62__Reservation__c from club62__Reservation_Registration__c where club62__Reservation__c=:cresId and club62__Customer__c=:memId and club62__Person__c = null limit 1];
                        if(resReg.size()>0 && type!='g'){
                            //To get already registered 
                            if(resReg[0].club62__Status__c!= 'Invited' && resReg[0].club62__Status__c != 'Waitlist Pending Confirm'){
                                alreadyRegistered = true;
                            }
                            cResReg = resReg[0];
                            alreadyExists=true;
                        }else if(resReg.size()>0 && type=='g'){
                            cRecipResRegId = resReg[0].Id;
                        }
                    if(alreadyExists==false){
                        cResReg.club62__Customer__c=memId;
                        cResReg.club62__Status__c='Yes';
                        cResReg.club62__RSVP_Date__c=DateTime.now();
                        cResReg.club62__Who_is_Paying__c='Member';
                        cResReg.club62__Reservation__c=cRes.id;

                    }
                    justCreated=true;
                }
                if(cRes!=null){
                    if(cResponse!='0'){
                        if(cResReg!=null){
                            cPageName = 'Show Comp';
                            if(cResReg.club62__Person__c != null && cRes.club62__Paid_Event__c){
                                //The guest is rsvping
                                cPageName = 'Show Comp';
                            }else if(cRes.club62__Paid_Event__c && cResReg.club62__Person__c==null){
                                cPageName = 'Show Comp';
                            }else if(cRes.club62__Guests_Allowed__c && cResReg.club62__person__c == null){
                                cPageName = 'Show Comp';
                            }
                            if(cResReg.club62__Person__c!=null && cResRegFor==null){
                                cResRegFor = 'Guest';
                            }else if(cResRegFor==null){
                                cResRegFor = 'Member';
                            }
                        }else{
                            if(cRes.club62__Paid_Event__c){
                                cPageName = 'Show Comp';
                            }else if(cRes.club62__Guests_Allowed__c){
                                cPageName = 'Show Comp';
                            }
                        }
                    }
                    //If Rservation is cancelled
                    if(cRes.club62__Status__c == 'Cancelled'){
                        cPageName = 'Reservation Cancelled';
                        errType = 'info';
                        if(cRes.RecordType.Name == 'Class') throw new C62Utilities.CustomException('The class has been cancelled.');
                        if(cRes.RecordType.Name == 'Event' || cRes.RecordType.Name == 'Events - Child' || cRes.RecordType.Name == 'Sponsored Event') throw new C62Utilities.CustomException('The Event has been cancelled.');
                    }
                    if(cResReg!=null && justCreated==false){
                        if(cResReg.club62__Status__c != 'Invited' && cResReg.club62__Status__c != 'Waitlist Pending Confirm'){
                            alreadyRegistered = true;
                        }
                        if(hashCode != cResReg.club62__Hashcode__c){
                            cPageName = 'NoHashCode';
                            errType = 'error';
                            throw new C62Utilities.CustomException('Hashcode is invalid. Please contact a representative to get a new link.');
                        }
                        if(cResReg.club62__Person__c == null) cMemberId = cResReg.club62__Customer__c;
                    }

                    //Show message if after rsvp by date
                    if(cRes.club62__RSVP_By__c != null && cRes.club62__RSVP_By__c < DateTime.Now()){
                        cPageName = 'Late RSVP';
                        errType = 'info';
                        throw new C62Utilities.CustomException('Sorry but RSVP is closed.');
                    }
                }
            }catch(Exception e){
                if(errType != null){
                    if(errType == 'info'){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,e.getMessage()));
                    } else {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                    }
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid URL, Please try clicking the link again.'));
                }
            }
        }
        if(cRes!=null){
            List<club62__Reservation__c> childRes =[select id from club62__Reservation__c where club62__Parent_Reservation__c=:cRes.Id and RecordType.Name!='Reserved'];
            if(childRes!=null && childRes.size()>0){
                //pageType='Details Multiple';
            }else if(alreadyRegistered){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'You have already registered for this event.'));
            }
        }
        cSiteURL = URL.getSalesforceBaseUrl().toExternalForm();
        cHttpsFlag=true;
        if(cSiteURL.length()>5 && cSiteURL.subString(0,5)!='https'){
            cSiteURL = url.getCurrentRequestUrl().toExternalForm();
            cSiteURL = cSiteURL.replace('http://','https://');
            cSiteURL = cSiteURL.replace('force.com','secure.force.com');
            cHttpsFlag = false;
        }

    }

    /*
    @Name   :doResponse
    @Description :Automatically processes the rsvp if the event is not a paid event or if the response is no
    */
    public PageReference doResponse(){
        PageReference httpsCheck = httpsCheck();
        if(httpsCheck!=null){
            return httpsCheck;
        }
        try{
            if(cResReg != null && cResponse=='0'){
                if(cResReg.club62__Status__c == 'Invited' || cResReg.club62__Status__c == 'Waitlist Pending Confirm'){
                    if(cPageName == 'Message' || cResponse == '0'){
                        cResReg.club62__RSVP_Date__c = DateTime.NOW();
                        if(cResponse == '1'){
                            cResReg.club62__Status__c = 'Yes';
                        }else if(cResponse == '0'){
                            cResReg.club62__Status__c = 'No';
                        }
                        try{
                            updateResReg();
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'You have RSVPed Successfully.'));
                        }catch(DMLException e){
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'An Error has occured, please try again.'));
                        }
                    }
                }
            }
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid URL, Please try clicking the link again.'));
        }
        return httpsCheck();
    }
    //Update reservation registration
    public void updateResReg(){
        if(Schema.sObjectType.club62__Reservation_Registration__c.isUpdateable()){
            NoShareUpsert nsu = new NoShareUpsert();
            nsu.doUpsert(cresReg);
        }
    }

    /*
    @Name   :httpsCheck
    @Description :redirects to https if http
    */
    public PageReference httpsCheck(){
        if(cHttpsFlag==false){
            return new PageReference(cSiteURL);
        }else{
            return null;
        }
    }
    
    public without sharing class NoShareUpsert{
        public void doUpsert(sObject so){
            upsert so;
        }
    }
}