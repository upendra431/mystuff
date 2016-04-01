/*
@Name           : C62PaymentComponentControllerTest
@Author         : customersuccess@cloud62.com
@Date           : 17/2/2014
@Description    : Test methods for C62PaymentComponentController
*/
@isTest
public class C62PaymentComponentControllerTest{
    /*
    @Name :testContactC62PaymentComponentController
    @Description : Test methods for C62PaymentComponentController
    */
    static testmethod void testContactC62PaymentComponentController(){
        club62__C62CommunitySettings__c comSetting = C62TestHandler.getComSetting();
        Contact c = C62TestHandler.getMember1();
        club62__Address__c a = C62TestHandler.getMemAddress1(c);
        club62__Payment_Method__c pm = new club62__Payment_Method__c(Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm;
        club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        club62__Payment__c pay = new club62__Payment__c(club62__Customer__c=c.Id,club62__Status__c='Paid',club62__Approval_Code__c='HDE08D',
                        club62__Payment_Method__c = pm.Id,club62__Amount__c=1000,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert pay;
        Test.startTest();
        C62PaymentComponentController pcc = new C62PaymentComponentController();
        pcc.doNothing();
        pcc.clearOldPaymentInfo();
        pcc.cNotToDisplayPassDirectBill = TRUE;
        pcc.cChosenMethodId = pm.Id;
        pcc.cSobjectId = pm.Id;
        pcc.cMode = 'Choose';
        pcc.bmcInitialize();
        try{pcc.createNew();}catch(Exception ex){}
        pcc.revert();
        pcc.setEditRedirect();
        pcc.cancel();
        pcc.chooseMethod();
        pm.club62__Payment_For__c = 'Default';
        update pm;
        pcc.cSobjectId = c.Id;
        pcc.cChosenMethodId = pm.Id;
        pcc.bmcInitialize();
        pcc.revert();
        pcc.setEditRedirect();
        pcc.cancel();
        pcc.chooseMethod();
        pcc.createNew();
        pcc.cIsValid = FALSE;
        pcc.bmcSaveInputOnly();
        pcc.bmcSave();
        pcc.selectedExpMonth = String.valueof(Date.Today().Month());
        pcc.selectedExpYear = String.valueof(Date.Today().Year()+2);
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Holder_Name__c = 'Testing';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Type__c = 'Visa';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__CVV_Code__c = '182';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        system.assertEquals(2,[SELECT Count() FROM club62__Payment_Method__c]);
        pcc.cDoReset = TRUE;
        pcc.cresetComponent = TRUE;
        pcc.cChosenMethodId = pm.Id;
        pcc.cDeletePayMethod();
        Test.stopTest();
    }
    /*
    @Name :testPersonC62PaymentComponentController
    @Description : Test methods for C62PaymentComponentController
    */
    static testmethod void testPersonC62PaymentComponentController(){
        club62__Person__c anna = C62TestHandler.getAnnaAppPerson();
        club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        Test.startTest();
        C62PaymentComponentController pcc = new C62PaymentComponentController();
        pcc.cNotToDisplayPassDirectBill = TRUE;
        pcc.cSobjectId = anna.Id;
        pcc.cMode = 'Choose';
        pcc.bmcInitialize();
        pcc.revert();
        pcc.setEditRedirect();
        pcc.cancel();
        pcc.chooseMethod();
        pcc.createNew();
        pcc.cIsValid = FALSE;
        pcc.bmcSaveInputOnly();
        pcc.bmcSave();
        pcc.selectedExpMonth = String.valueof(Date.Today().Month());
        pcc.selectedExpYear = String.valueof(Date.Today().Year()+2);
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Holder_Name__c = 'Testing';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Type__c = 'Visa';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__CVV_Code__c = '182';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        system.assertEquals(0,[SELECT Count() FROM club62__Payment_Method__c]);
        Test.stopTest();
    }
    /*
    @Name : testContactC62PaymentComponentController2
    @Description : Test method for C62PaymentComponentController
    */
    static testmethod void testContactC62PaymentComponentController2(){
        Contact c = C62TestHandler.getMember1();
        club62__Address__c a = C62TestHandler.getMemAddress1(c);
        c.club62__Customer_Account_Enabled__c = TRUE;
        update c;
        club62__Payment_Method__c pm = C62TestHandler.getPaymentMethod(c);
        club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        Test.startTest();
        C62PaymentComponentController pcc = new C62PaymentComponentController();
        pcc.cSobjectId = c.id;
        pcc.cMode = 'Choose';
        pcc.getCustomerAccountEnabled();
        pcc.cNotToDisplayPassDirectBill = TRUE;
        pcc.getPaymentTypes();
        pcc.doNothing();
        pcc.clearOldPaymentInfo();
        pcc.cChosenMethodId = pm.Id;
        pcc.cSobjectId = pm.Id;
        pcc.bmcInitialize();
        try{pcc.createNew();}catch(Exception ex){}
        pcc.revert();
        pcc.setEditRedirect();
        pcc.cancel();
        pcc.chooseMethod();
        pm.club62__Payment_For__c = 'Default';
        update pm;
        pcc.cSobjectId = c.Id;
        pcc.cChosenMethodId = pm.Id;
        pcc.bmcInitialize();
        pcc.revert();
        pcc.setEditRedirect();
        pcc.cancel();
        pcc.chooseMethod();
        pcc.createNew();
        pcc.cIsValid = FALSE;
        pcc.bmcSaveInputOnly();
        pcc.bmcSave();
        pcc.selectedExpMonth = String.valueof(Date.Today().Month());
        pcc.selectedExpYear = String.valueof(Date.Today().Year()+2);
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Holder_Name__c = 'Testing';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Type__c = 'Visa';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__CVV_Code__c = '182';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.bmcSaveSingleCard();
        pcc.cIsValid = TRUE;
        pcc.bmcSaveSingleCard();
        system.assertEquals(3,[SELECT Count() FROM club62__Payment_Method__c]);
        pcc.cIsValid = TRUE;
        pcc.bmcSaveInputOnly();
        Test.stopTest();
    }
    /*
    @Name : testContactC62PaymentComponentController3
    @Description : Test method for C62PaymentComponentController
    */
     static testmethod void testContactC62PaymentComponentController3(){
        Contact c = C62TestHandler.getMember1();
        club62__Person__c p = C62TestHandler.getElizabethInvPerson();
        club62__Address__c a = C62TestHandler.getMemAddress1(c);
        c.club62__Customer_Account_Enabled__c = TRUE;
        update c;
        club62__Payment_Method__c pm =  new club62__Payment_Method__c(Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Billing_Address__c = a.Id,club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm;
        club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        Test.startTest();
        C62PaymentComponentController pcc = new C62PaymentComponentController();
        pcc.cSobjectId = c.id;
        pcc.cMode = 'Choose';
        pcc.getCustomerAccountEnabled();
        pcc.cNotToDisplayPassDirectBill = TRUE;
        pcc.getPaymentTypes();
        pcc.doNothing();
        pcc.clearOldPaymentInfo();
        pcc.cChosenMethodId = pm.Id;
        pcc.cSobjectId = pm.Id;
        pcc.bmcInitialize();
        try{pcc.createNew();}catch(Exception ex){}
        pcc.revert();
        pcc.setEditRedirect();
        pcc.cancel();
        pcc.chooseMethod();
        pm.club62__Payment_For__c = 'Default';
        update pm;
        pcc.cSobjectId = c.Id;
        pcc.cChosenMethodId = pm.Id;
        pcc.bmcInitialize();
        pcc.revert();
        pcc.setEditRedirect();
        pcc.cancel();
        pcc.chooseMethod();
        pcc.createNew();
        pcc.cIsValid = FALSE;
        pcc.bmcSaveInputOnly();
        pcc.bmcSave();
        pcc.selectedExpMonth = String.valueof(Date.Today().Month());
        pcc.selectedExpYear = String.valueof(Date.Today().Year()+2);
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Holder_Name__c = 'Testing';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__Card_Type__c = 'Visa';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.cPayMethod.club62__CVV_Code__c = '182';
        pcc.validateInfo();
        pcc.bmcSaveInputOnly();
        pcc.validateInfo();
        pcc.bmcSave();
        pcc.bmcSaveSingleCard();
        pcc.cIsValid = TRUE;
        pcc.bmcSaveSingleCard();
        system.assertEquals(3,[SELECT Count() FROM club62__Payment_Method__c]);
        pcc.cIsValid = TRUE;
        pcc.bmcSaveInputOnly();
        pcc.cPayMethod = pm;
        pcc.loadBillAddr();
        pcc.cMode = 'Input Only';
        pcc.load();
        pcc.bmcInitialize();
        pcc.cMode = 'Single Card';
        pcc.bmcInitialize();
        pcc.cSobjectId = pm.Id;
        pcc.bmcInitialize();
        pcc.validateInfo();
        club62__Payment_Method__c pm1 =  new club62__Payment_Method__c(club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Billing_Address__c = a.Id,club62__Payment_Type__c='Credit Card',club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm1;
        pcc.cIsValid = true;
        pcc.cPayMethod = pm1;
        pcc.cSobjectId = c.Id;
        pcc.bmcSave();
        club62__Payment_Method__c pm2 =  new club62__Payment_Method__c(club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Billing_Address__c = a.Id,club62__Payment_Type__c='Credit Card',club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm2;
        pcc.cIsValid = true;
        pcc.cPayMethod = pm2;
        pcc.cSobjectId = p.Id;
        pcc.bmcSave();
        club62__Payment_Method__c pm3 =  new club62__Payment_Method__c(club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Billing_Address__c = a.Id,club62__Payment_Type__c='Credit Card',club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm3;
        pcc.cIsValid = true;
        pcc.cPayMethod = pm3;
        pcc.cSobjectId = c.Id;
        pcc.bmcSaveInputOnly();
        club62__Payment_Method__c pm4 =  new club62__Payment_Method__c(club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Billing_Address__c = a.Id,club62__Payment_Type__c='Credit Card',club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm4;
        pcc.cIsValid = true;
        pcc.cPayMethod = pm4;
        pcc.cSobjectId = p.Id;
        pcc.bmcSaveInputOnly();
        club62__Payment_Method__c pm5 =  new club62__Payment_Method__c(club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Billing_Address__c = a.Id,club62__Payment_Type__c='Credit Card',club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm5;
        pcc.cIsValid = true;
        pcc.cPayMethod = pm5;
        pcc.cSobjectId = c.Id;
        pcc.bmcSaveSingleCard();
        club62__Payment_Method__c pm6 =  new club62__Payment_Method__c(club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Billing_Address__c = a.Id,club62__Payment_Type__c='Credit Card',club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm6;
        pcc.cIsValid = true;
        pcc.cPayMethod = pm6;
        pcc.cSobjectId = p.Id;
        pcc.bmcSaveSingleCard();
        C62AuthorizeDotNet   adn = new C62AuthorizeDotNet(true);
        adn.retrieveBatch();
        pcc.cHideSaveButtons = true;
        pcc.cBlockMode = '';
        pcc.cGridStyleClass = '';
        pcc.cShowTemporary = true;
        pcc.autoChosenMethodId = '';
        pcc.cSetTemporary = true;
        new C62PaymentGatewayClasses.QueryRecordResponse();
        Test.stopTest();
    }
}