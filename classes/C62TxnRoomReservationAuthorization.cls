/*
@Name            : C62TxnRoomReservationAuthorization
@Author          : customersuccess@cloud62.com
@Date            : June 8, 2015
@Description     : Controller for create authorization and void the payment records for Room Reservation.
*/
public with sharing class C62TxnRoomReservationAuthorization{
    //class variables
    public club62__Room_Reservation__c roomRes{get;set;}
    public club62__TXN__c p {get;set;}
    public List<club62__TXN__c> paymentCanLst{get;set;}
    public List<voidPayment> voidPayLst{get;set;}
    public String cAPMId{get;set;}
    public String cPage{get;set;}
    public Boolean paymentSucceeded{get;set;}
    public Boolean voidFlag{get;set;}
    
    /*
    @Name   :C62RoomReservationAuthorization
    @Description :Constructor to initalize the page
    */
    public C62TxnRoomReservationAuthorization(ApexPages.StandardController sc){
        voidPayLst = new List<voidPayment>();
        paymentCanLst = new List<club62__TXN__c>();
        String rrID = sc.getID();
        roomRes = new club62__Room_Reservation__c();
        p = new club62__TXN__c();
        paymentSucceeded = false;
        voidFlag = false;
        cPage = 'voidAuthPay';
        if(rrID != null && rrID != ''){
            List<club62__Room_Reservation__c> rrLst = DataBase.Query('SELECT club62__Reservation__r.club62__Sponsoring_Customer__c,'
                                + C62Utilities.getFields('club62__Room_Reservation__c')
                                +' FROM club62__Room_Reservation__c'
                                +' WHERE ID =\''+String.escapeSingleQuotes(rrID)+'\'');
            if(rrLst != null && rrLst.size()>0){
                roomRes = rrLst.get(0);
                loadAuthPayments();
                // Removed club62__Authorization_Date_Time__c=DateTime.now() since field doesn't exist on TXN
                p = new club62__TXN__c(club62__Room_Reservation__c=roomRes.Id,
                    club62__Status__c='Queued');
                List<RecordType> rtLst = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'club62__TXN__c' AND Name = 'Payment'];
                if(rtLst!=null && rtLst.size()>0){p.RecordTypeId = rtLst.get(0).Id;}
                if(((ID)(getPayingId())).getsObjectType().getDescribe().getName()=='club62__Person__c'){
                    p.club62__Guest__c = getPayingId();
                }else{
                    p.club62__Member__c = getPayingId();
                }
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Invaild Room Reservation Id.'));
            }
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Invaild Room Reservation Id.'));
        }
    }
    
    /*
    @Name :loadAuthPayments
    @Description :Authorize the payment
    */
    public void loadAuthPayments(){
        voidPayLst = new List<voidPayment>();
        paymentCanLst = new List<club62__TXN__c>();
        if(roomRes!=null && roomRes.Id!=null){
            List<club62__TXN__c> payLst = DataBase.Query('SELECT RecordType.Name,club62__Customer__r.Name,club62__Person__r.Name,'+
                                            +C62Utilities.getFields('club62__TXN__c')+' FROM club62__TXN__c'
                                            +' WHERE RecordType.Name=\'Payment\' AND club62__Room_Reservation__c=\''
                                            +String.escapeSingleQuotes(roomRes.Id)+'\'');
            for(club62__TXN__c pay : payLst){
                voidPayment vp = new voidPayment();
                vp.pay = pay;
                if(pay.club62__Status__c!='Authorized'){
                    vp.voidFlag = true;
                    vp.allowVoid = false;
                }else{
                    vp.voidFlag = false;
                    vp.allowVoid = true;
                }
                voidPayLst.add(vp);
            }
            if(voidPayLst.size()==0){cPage = 'newAuthPay';}
        }
    }
    
    /*
    @Name :updateAuthorizePayment
    @Description :Authorize the payment
    */
    public PageReference updateAuthorizePayment(){
        voidFlag = false;
        paymentCanLst = new List<club62__TXN__c>();
        Integer totalVoidPay = 0;
        List<club62__TXN__c> tempPay = new List<club62__TXN__c>();
        
        for(voidPayment vp : voidPayLst){
            if(vp.voidFlag == true && vp.allowVoid == true){totalVoidPay++;}
        }
        
        if(totalVoidPay==0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select at least one payment to void authorization.'));
            voidFlag = false;
            return null;
        }
        if(totalVoidPay>10){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can\'t void more than 10 payments at a time.'));
            voidFlag = false;
            return null;
        }
        
        for(voidPayment vp : voidPayLst){
            if(vp.voidFlag == true && vp.allowVoid == true){
                tempPay.add(vp.pay);
            }
        }
        
        try{
            if(tempPay!=null && tempPay.size()>0){
                //void the authorization payment
                for(club62__TXN__c payToUpdate : tempPay){
                    //void the authorization payment
                    C62PaymentGatewayController payGateCont = new C62PaymentGatewayController();
                    // VoidAuthorization method doesn't exist in class
                    /*C62PaymentGatewayClasses.VoidAuthorizationResponse result = payGateCont.VoidAuthorization(payToUpdate);
                    if(result.Effect == C62PaymentGatewayClasses.TransactionEffect.Success){
                        //Successful void
                        payToUpdate.club62__Status__c = 'Cancelled';
                        paymentCanLst.add(payToUpdate);
                    } else {
                        //void failed
                        throw new C62Utilities.CustomException(result.ErrorDescription);
                    }
                    */
                }
                voidFlag = true;
            }
        }catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
            voidFlag = false;
        }
        return null;
    }
    
    /*
    @Name :voidAssociatePayments
    @Description :Authorize the payment
    */
    public PageReference voidAssociatePayments(){
        if(voidFlag){
            try{
                if(Schema.sObjectType.club62__TXN__c.isUpdateable()){ 
                    update paymentCanLst;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payments void Successfully!'));
                    paymentCanLst = new List<club62__TXN__c>();
                    // Removed club62__Authorization_Date_Time__c=DateTime.now() since the field doesn't exist on TXN
                    p = new club62__TXN__c(club62__Room_Reservation__c=roomRes.Id,
                        club62__Status__c='Queued');
                    List<RecordType> rtLst = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'club62__TXN__c' AND Name = 'Payment'];
                    if(rtLst!=null && rtLst.size()>0){p.RecordTypeId = rtLst.get(0).Id;}
                    if(((ID)(getPayingId())).getsObjectType().getDescribe().getName()=='club62__Person__c'){
                        p.club62__Guest__c = getPayingId();
                    }else{
                        p.club62__Member__c = getPayingId();
                    }
                    cAPMId=null;
                    paymentSucceeded=false;
                    voidFlag = false;
                    loadAuthPayments();
                }
            }catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
                voidFlag = false;
            }
        }
        return null;
    }
    
    /*
    @Name :sendToAuthorize
    @Description :Authorize the payment
    */
    public PageReference sendToAuthorize(){
        paymentSucceeded = false;
        if(p!=null && p.club62__Amount__c!=null && p.club62__Amount__c>0){
            if(cAPMId!=null && cAPMId!=''){
                club62__Payment_Method__c pm = Database.query('SELECT club62__Customer__r.FirstName,'
                    +'club62__Customer__r.LastName,club62__Person__r.club62__First_Name__c,club62__Person__r.club62__Last_Name__c,' 
                    + C62Utilities.getFields('club62__Payment_Method__c') + ' FROM club62__Payment_Method__c WHERE Id = :cAPMId');
                String fName='';
                String lName='';
                if(pm.club62__Person__c!=null){
                    fName = pm.club62__Person__r.club62__First_Name__c;
                    lName = pm.club62__Person__r.club62__Last_Name__c;
                } else {
                    fName = pm.club62__Customer__r.FirstName;
                    lName = pm.club62__Customer__r.LastName;
                }
                p.club62__Payment_Method__c = pm.Id;
                //FIND ME BEN
                C62PaymentGatewayController payGateCont = new C62PaymentGatewayController();
                C62PaymentGatewayClasses.AuthorizePaymentResponse result = payGateCont.AuthorizePayment(pm, p.club62__Amount__c, fName, lName);
                if(result.Effect == C62PaymentGatewayClasses.TransactionEffect.Success){
                    //Void the validation hold
                    p.club62__Transaction_Id__c = result.TransactionID;
                    p.club62__Approval_Code__c = result.AuthorizationID;
                    p.club62__Status__c = 'Authorized';
                    paymentSucceeded = true;
                } else {
                    //Card failed validation
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Credit card failed authorization charge'));
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Method is Required.'));
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Payment Amount is Required.'));
        }
        return null;
    }
    
    
    /*
    @Name   :save
    @Description :Save method to insert the Receivable, Payment or Refund record
    */
    public PageReference save(){
        if(paymentSucceeded){
            SavePoint sp = Database.setSavePoint();
            try{
                if(Schema.sObjectType.club62__TXN__c.isCreateable()){ 
                    insert p;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Authorization Made Successfully!'));
                    // Removed club62__Authorization_Date_Time__c=DateTime.now() since the field doesn't exist on TXN
                    p = new club62__TXN__c(club62__Room_Reservation__c=roomRes.Id,
                        club62__Status__c='Queued');
                    List<RecordType> rtLst = [SELECT Id,Name FROM RecordType WHERE sObjectType = 'club62__TXN__c' AND Name = 'Payment'];
                    if(rtLst!=null && rtLst.size()>0){p.RecordTypeId = rtLst.get(0).Id;}
                    if(((ID)(getPayingId())).getsObjectType().getDescribe().getName()=='club62__Person__c'){
                        p.club62__Guest__c = getPayingId();
                    }else{
                        p.club62__Member__c = getPayingId();
                    }
                    cAPMId=null;
                    paymentSucceeded=false;
                    loadAuthPayments();
                }
            }catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,e.getMessage()));
                Database.rollBack(sp);
                paymentSucceeded=false;
            }
        }
        return null;
    }
    
    /*
    @Name   :getPayingId
    @Description :Returns the id of the member or person who is paying
    */
    public String getPayingId(){
        String strReturn = '';
        if((roomRes.club62__Who_is_Paying__c == 'Sponsoring Member' || roomRes.club62__Who_is_Paying__c == 'Banquet') && roomRes.club62__Reservation__c!=null 
            && roomRes.club62__Reservation__r.club62__Sponsoring_Customer__c!=null){
            strReturn = roomRes.club62__Reservation__r.club62__Sponsoring_Customer__c;
        } else if (roomRes.club62__Who_is_Paying__c == 'Guest' && roomRes.club62__Person__c!=null){
            strReturn = roomRes.club62__Person__c;
        } else if (roomRes.club62__Who_is_Paying__c == 'Member'){
            strReturn = roomRes.club62__Customer__c;
        } else {
            strReturn = roomRes.club62__Customer__c;
        }
        return strReturn;
    }
    /*
    @Name : voidPayment
    @Description : Wrapper Class
    */
    public class voidPayment{
        public Boolean voidFlag{get;set;}
        public Boolean allowVoid{get;set;}
        public club62__TXN__c pay{get;set;}
    }
}