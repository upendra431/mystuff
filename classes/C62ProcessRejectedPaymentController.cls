/*
@Name            : C62ProcessRejectedPaymentController
@Author          : customersuccess@cloud62.com
@Date            : November 24th, 2014
@Description     : Controller for ProcessRejectedPayment page
*/
public with sharing class C62ProcessRejectedPaymentController{
    //Class Variables
    public club62__Payment__c pay{get;set;}
    public Boolean errorFlag{get;set;}
    public club62__Payment_Method__c cPayMethod {get;set;}
    public String payMethodID{get;set;}
    public String selectedPaymentType{get;set;}
    public Boolean paymentAmountConfirmed{get;set;}
    //Constructor
    public C62ProcessRejectedPaymentController(ApexPages.StandardController sc){
        String payID = sc.getId();
        errorFlag = false;
        cPayMethod = null;
        paymentAmountConfirmed = false;
        if(payID!=null && payID!=''){
            selectedPaymentType = 'Credit Card/ACH';
            //Query Payment wheather it is not rejected
            List<club62__Payment__c> payLst = Database.query('SELECT club62__Person__r.Name,club62__Customer__r.Name,'
                                +C62Utilities.getFields('club62__Payment__c')+',(SELECT '+C62Utilities.getFields('club62__Transaction__c')
                                +' FROM club62__Transactions__r WHERE club62__Invoice_Line__c!=null AND club62__Status__c!=\'Adjusted\')'
                                +' FROM club62__Payment__c WHERE ID=:payID AND club62__Status__c=\'Rejected\'');
            if(payLst.size()!=null && payLst.size()>0){
                if(payLst.get(0).club62__Transactions__r!=null && payLst.get(0).club62__Transactions__r.size()>0){
                    errorFlag = true;
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'The transactions associated with this payments '
                    +'has been invoiced so you can not retry this payment now. Please pay the statement lines.'));
                }else{
                    pay = payLst.get(0);
                    if(pay.club62__Customer__c==null && pay.club62__Person__c==null){
                        errorFlag = true;
                        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'There is no associated member or guest found to retry this payment.'));
                    }else if(pay.club62__Payment_Method__c != null){
                        cPayMethod = Database.query('SELECT ' + C62Utilities.getFields('club62__Payment_Method__c') 
                            + ' FROM club62__Payment_Method__c WHERE Id = \'' + String.escapeSingleQuotes(pay.club62__Payment_Method__c) + '\'');
                    }
                }
            }else{
                errorFlag = true;
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Payment not found.'));
            }
        }else{
            errorFlag = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Payment not found.'));
        }
    }
    
    /*
    @Name   :save
    @Description :Save Payment
    */
    public PageReference save(){
        try{
            if(selectedPaymentType==null || selectedPaymentType=='' || selectedPaymentType=='--None--'){
                throw new C62Utilities.CustomException('Please select a payment type to retry this payment.');
            }
            if(selectedPaymentType=='Credit Card/ACH' && (payMethodID==null || payMethodID=='')){
                throw new C62Utilities.CustomException('No Payment Method was Selected');
            }
            if(selectedPaymentType=='Credit Card/ACH' && payMethodID!=null && pay.club62__Payment_Method__c != null && payMethodID==pay.club62__Payment_Method__c){
                throw new C62Utilities.CustomException('Please select a New Payment method.');
            }
            List<RecordType> rtLst = [SELECT ID,Name FROM RecordType WHERE sObjectType='club62__Payment__c'];
            Map<String,ID> rtMap = new Map<String,ID>();
            for(RecordType rt : rtLst){ rtMap.put(rt.Name,rt.Id); }
            Decimal amtUsed = 0;
            List<club62__Transaction__c> tansLst = Database.query('SELECT ' + C62Utilities.getFields('club62__Transaction__c') 
                                    +' FROM club62__Transaction__c WHERE club62__Payment__c=\''+String.escapeSingleQuotes(pay.Id)+'\' AND club62__Amount_Due__c>0 AND club62__Manual_Registration_Transaction__c=false AND club62__Reservation_Registration__c=null');
            if(tansLst!=null && tansLst.size()>0){
                for(Integer k = 0; k < tansLst.size() - 1; k++){
                    for(Integer j = k + 1; j < tansLst.size(); j++){
                        if(tansLst.get(j).club62__Amount_Due__c < tansLst.get(k).club62__Amount_Due__c){
                            club62__Transaction__c t = tansLst.get(k);
                            tansLst.set(k,tansLst.get(j));
                            tansLst.set(j,t);
                        }
                    }
                }
            }
            if(selectedPaymentType=='Credit Card/ACH'){
                List<club62__Payment_Method__c> payMethodLst = Database.query('SELECT club62__Customer__r.FirstName,club62__Customer__r.LastName,' 
                        + 'club62__Person__r.club62__First_Name__c,club62__Person__r.club62__Last_Name__c,' 
                        + C62Utilities.getFields('club62__Payment_Method__c') 
                        + ' FROM club62__Payment_Method__c WHERE Id = \'' + String.escapeSingleQuotes(payMethodID) + '\'');
                pay.Check_Number__c=null;
                pay.Check_Date__c = null;
                if(payMethodLst.size()>0){
                    pay.club62__Payment_Method__c = payMethodLst.get(0).Id;
                    cPayMethod = payMethodLst.get(0);
                    if(payMethodLst.get(0).club62__Payment_Type__c=='Direct Bill' || 
                        payMethodLst.get(0).club62__Payment_Type__c=='Pass Direct Bill'){
                        pay.club62__Status__c = 'Paid';
                        if(rtMap.size()>0 && rtMap.ContainsKey('Payment')){pay.RecordTypeId=rtMap.get('Payment');}
                    }else{
                        //FIND ME BEN
                        C62PaymentGatewayController payGateCont = new C62PaymentGatewayController();
                        String firstName, lastName;
                        //Add details about cardholder
                        if(payMethodLst.get(0).club62__Person__c!=null){
                            firstName = payMethodLst.get(0).club62__Person__r.club62__First_Name__c;
                            lastName = payMethodLst.get(0).club62__Person__r.club62__Last_Name__c;
                        }else if(payMethodLst.get(0).club62__Customer__c!=null){
                            firstName = payMethodLst.get(0).club62__Customer__r.FirstName;
                            lastName = payMethodLst.get(0).club62__Customer__r.LastName;
                        }
                        if(pay.club62__Is_Authorization__c){
                            C62PaymentGatewayClasses.AuthorizePaymentResponse result = payGateCont.AuthorizePayment(payMethodLst.get(0), pay.club62__Amount__c, firstName, lastName);
                            if(result.Effect == C62PaymentGatewayClasses.TransactionEffect.Success){
                                //Void the validation hold
                                pay.club62__Transaction_Id__c = result.TransactionID;
                                pay.club62__Approval_Code__c = result.AuthorizationID;
                                pay.club62__Status__c = 'Authorized';
                                if(rtMap.size()>0 && rtMap.ContainsKey('Authorization')){pay.RecordTypeId=rtMap.get('Authorization');}
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payment successful!'));
                            } else {
                                //If not successful mark as Rejected
                                pay.club62__Status__c='Rejected';
                                throw new C62Utilities.CustomException('Payment has been Rejected.');
                            }
                            pay.club62__Processing_Message__c = (result.ErrorDescription != null) ? result.ErrorDescription : 'Payment Succeeded';
                        }else{
                            C62PaymentGatewayClasses.MakePaymentResponse result = payGateCont.MakePayment(payMethodLst.get(0), pay.club62__Amount__c, firstName, lastName);
                            if(result.Effect == C62PaymentGatewayClasses.TransactionEffect.Success){
                                //If successful mark as Paid
                                pay.club62__Status__c='Paid';
                                pay.club62__Transaction_Id__c = result.TransactionID;
                                pay.club62__Approval_Code__c = result.AuthorizationID;
                                if(rtMap.size()>0 && rtMap.ContainsKey('Payment')){pay.RecordTypeId=rtMap.get('Payment');}
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payment successful!'));
                            }else{
                                //If not successful mark as Rejected
                                pay.club62__Status__c='Rejected';
                                throw new C62Utilities.CustomException('Payment has been Rejected.');
                            }
                            pay.club62__Processing_Message__c = (result.ErrorDescription != null) ? result.ErrorDescription : 'Payment Succeeded';
                        }
                    }
                    //Payment method of non Direct Bill
                    if(payMethodLst.get(0).club62__Payment_Type__c!='Direct Bill' && payMethodLst.get(0).club62__Payment_Type__c!='Pass Direct Bill' 
                        && pay.club62__Status__c=='Paid' && tansLst!=null && tansLst.size()>0){
                        Decimal amtPaid = pay.club62__Amount__c.setScale(2, System.RoundingMode.HALF_UP);
                        for(club62__Transaction__c t : tansLst){
                            if(amtPaid!=null && amtPaid>0.00 && amtPaid>0){
                                if(t.club62__Amount_Paid__c==null){t.club62__Amount_Paid__c=0;}
                                if(amtPaid>t.club62__Amount_Due__c){
                                    amtPaid -= t.club62__Amount_Due__c.setScale(2, System.RoundingMode.HALF_UP);
                                    amtUsed += t.club62__Amount_Due__c.setScale(2, System.RoundingMode.HALF_UP);
                                    t.club62__Amount_Paid__c += t.club62__Amount_Due__c.setScale(2, System.RoundingMode.HALF_UP);
                                }else{
                                    amtUsed += amtPaid.setScale(2, System.RoundingMode.HALF_UP);
                                    t.club62__Amount_Paid__c += amtPaid.setScale(2, System.RoundingMode.HALF_UP);
                                    amtPaid = 0;
                                }
                            }
                        }
                    }
                    if(Schema.sObjectType.club62__Transaction__c.isUpdateable() && amtUsed>0){pay.club62__Amount_Used__c = amtUsed.setScale(2, System.RoundingMode.HALF_UP);}
                    if(pay.club62__Reservation__c==null && (payMethodLst.get(0).club62__Payment_Type__c=='Direct Bill' || payMethodLst.get(0).club62__Payment_Type__c=='Pass Direct Bill')){
                        pay.club62__Amount_Used__c = pay.club62__Amount__c;
                    }
                    if(Schema.sObjectType.club62__Payment__c.isUpdateable()){update pay;}
                    if(payMethodLst.get(0).club62__Payment_Type__c=='Direct Bill' || payMethodLst.get(0).club62__Payment_Type__c=='Pass Direct Bill'){
                        List<club62__AR_Payment__c> rpLst = [SELECT ID,club62__Receivable__c FROM club62__AR_Payment__c 
                                                                    WHERE club62__Pay__c=:pay.Id 
                                                                    AND club62__Pay__r.club62__Payment_Method__r.club62__Payment_Type__c IN ('Direct Bill','Pass Direct Bill')];
                        if(rpLst.size()>0){
                            for(club62__Transaction__c t : tansLst){
                                t.club62__Receivable__c = rpLst.get(0).club62__Receivable__c;
                            }
                        }
                    }
                    if(Schema.sObjectType.club62__Transaction__c.isUpdateable() && tansLst.size()>0){update tansLst;}
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payment successful!'));
                }else{
                    throw new C62Utilities.CustomException('No Payment Method was Selected');
                }
            }else{
                if(rtMap.size()>0 && rtMap.ContainsKey('Payment')){pay.RecordTypeId=rtMap.get('Payment');}
                pay.club62__Payment_Method__c = null;
                if(selectedPaymentType=='Cash'){
                    pay.Check_Number__c=null;
                    pay.Check_Date__c = null;
                }
                pay.club62__Status__c = 'Paid';
                if(tansLst!=null && tansLst.size()>0){
                    Decimal amtPaid = pay.club62__Amount__c.setScale(2, System.RoundingMode.HALF_UP);
                    for(club62__Transaction__c t : tansLst){
                        if(amtPaid!=null && amtPaid>0.00 && amtPaid>0){
                            if(t.club62__Amount_Paid__c==null){t.club62__Amount_Paid__c=0;}
                            if(amtPaid>t.club62__Amount_Due__c){
                                amtPaid -= t.club62__Amount_Due__c.setScale(2, System.RoundingMode.HALF_UP);
                                amtUsed += t.club62__Amount_Due__c.setScale(2, System.RoundingMode.HALF_UP);
                                t.club62__Amount_Paid__c += t.club62__Amount_Due__c.setScale(2, System.RoundingMode.HALF_UP);
                            }else{
                                amtUsed += amtPaid.setScale(2, System.RoundingMode.HALF_UP);
                                t.club62__Amount_Paid__c += amtPaid.setScale(2, System.RoundingMode.HALF_UP);
                                amtPaid = 0;
                            }
                        }
                    }
                }
                if(Schema.sObjectType.club62__Transaction__c.isUpdateable() && amtUsed>0){pay.club62__Amount_Used__c = amtUsed.setScale(2, System.RoundingMode.HALF_UP);}
                if(Schema.sObjectType.club62__Payment__c.isUpdateable()){update pay;}
                if(Schema.sObjectType.club62__Transaction__c.isUpdateable() && tansLst.size()>0){update tansLst;}
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Payment successful!'));
            }
            paymentAmountConfirmed = true;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
        }
        return null;
    }
    /*
    @Name   :doNothing
    @Description :Do nothing
    */
    public void doNothing(){}
}