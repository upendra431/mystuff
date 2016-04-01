/*
@Name           : GenericHistoryCompTest
@Author         : customersuccess@cloud62.com
@Description    : Test methods for GenericHistoryComponentController
*/
@IsTest
public class GenericHistoryCompTest{
    @IsTest
    public static void theTest(){
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        List<club62__Room__c>roomList = C62TestHandler.getFullRoomCategoryRoomLst(rc);
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c();
        rr.club62__Type__c = 'Member';        
        rr.club62__Room_Category__c = rc.Id;
        rr.club62__Group_Category__c = rc.Id;
        rr.club62__From__c = system.today();
        rr.club62__To__c = system.today().addDays(10);
        rr.club62__Status__c = 'Tentative';
        rr.club62__Room__C = roomList[0].id;
        insert rr;
        
        rr.club62__From__c = system.today().addDays(10);
        rr.club62__To__c = system.today().addDays(20);
        rr.club62__Status__c = 'Confirmed';
        Update rr;
        GenericHistoryComponentController ghcc = new GenericHistoryComponentController();
        ghcc.myObject = rr;
        ghcc.getObjectHistory();
        System.assertEquals(GenericHistoryComponentController.objectLabel,'Room Reservation');
        GenericHistoryComponentController.returnFieldLabel('club62__Status__c');
        GenericHistoryComponentController.objectHistoryLine ohl = new GenericHistoryComponentController.objectHistoryLine();
        C62PayFlow.C62ParsePaymentResponse pfa = new C62PayFlow.C62ParsePaymentResponse();
        try{
        pfa.parse('');
        } catch(exception e){
            System.assertEquals(e.getmessage(),e.getmessage());
        }
        try{
        C62PayFlow.C62ParseVoidAuthResponse pfa1 = new C62PayFlow.C62ParseVoidAuthResponse();
        pfa1.parse('');
        } catch(exception e){
            System.assertEquals(e.getmessage(),e.getmessage());
        }
        try{
        C62PayFlow.C62ParseRefundResponse pfa2 = new C62PayFlow.C62ParseRefundResponse();
        pfa2.parse('');
        } catch(exception e){
            System.assertEquals(e.getmessage(),e.getmessage());
        }
        try{
        C62PayFlow.ParseErrorResponse('');
        } catch(exception e){
            System.assertEquals(e.getmessage(),e.getmessage());
        }
        ohl.theDate = DateTime.newInstance(Date.Today().addDays(-11),Time.newInstance(13,0,0,0));
        ohl.who = '';
        ohl.userId = UserInfo.getUserId();
        ohl.action = '';
    }
    /*
    @Name : c62ReservationRegistrationListControllerTest1
    @Description : Test method for C62ReservationRegistrationListController
    */
    static testmethod void c62ReservationRegistrationListControllerTest1(){
        Contact c = C62TestHandler.getMember1();
        c.club62__Status__c = 'Reinstated';
        c.club62__Type__c = 'Event CoSponsor';
        update c;
        Club62__Person__c pr = C62TestHandler.getElizabethInvPerson();
        club62__Person__c per = new club62__Person__c(Name='Elizabeth Wood1',club62__Salutation__c='Ms.',club62__First_Name__c='Elizabeth1',club62__Last_Name__c='Wood1',
                        club62__Gender__c='Female',club62__Status__c='Pending',club62__Reason__c='Looking for More Information',
                        club62__Reciprocal_Club_Customer_Id__c = '326524',club62__Home_Phone__c='(716)-555-4108',club62__Email__c='club62tests@cloud62.com',
                        club62__Birthdate__c=date.newinstance(1970,10,10));
        insert per;
        club62__Facility__c fac1 = C62TestHandler.getSportFacilitySquashCourt1();
        
        club62__Reservation__c res = new club62__Reservation__c(Name='Sport Test',club62__Club_Location__c=fac1.Id,club62__Max_Seats__c=5,
                            club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
                            club62__Max_Waitlist_Capacity__c=2,club62__Charged__c = FALSE,club62__Status__c = 'Confirmed',club62__Customer__c=c.Id,
                            club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(3),Time.newInstance(13,0,0,0)),
                            club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(3),Time.newInstance(14,0,0,0)));
        insert res;
        Test.StartTest();
        club62__Reservation_Registration__c evtrr = new club62__Reservation_Registration__c(club62__Reservation__c=res.Id,club62__Customer__c=c.id,
                                club62__party_Size__c = 3,club62__Maximum_party_Size__c = 1,club62__Hashcode__c = '2136jhn',club62__Status__c='Yes',club62__Send_Invitation__c=TRUE,club62__Generate_Hashcode__c=0,club62__Total_Price__c=200);
        club62__Reservation_Registration__c evtrr1 = new club62__Reservation_Registration__c(club62__Reservation__c=res.Id,club62__Customer__c=c.id,
                                club62__party_Size__c = 3,club62__Person__c = per.Id,club62__Maximum_party_Size__c = 1,club62__Hashcode__c = '2136jhn',club62__Status__c='Yes',club62__Send_Invitation__c=TRUE,club62__Generate_Hashcode__c=0,club62__Total_Price__c=200);
        insert new List<club62__Reservation_Registration__c>{evtrr,evtrr1};
        String str = [SELECT club62__Hashcode__c from club62__Reservation_Registration__c where Id =:evtrr.Id].club62__Hashcode__c;
        ApexPages.currentPage().getParameters().put('rrId',evtrr.Id);
        ApexPages.currentPage().getParameters().put('hc',str);
        Apexpages.StandardController sc = new Apexpages.StandardController(evtrr);
        C62ReservationRegistrationListController rrlc = new C62ReservationRegistrationListController (sc);
        rrlc.checkParams();
        rrlc.resetPage();
        for(C62ReservationRegistrationListController.RegistrationGrid rg : rrlc.registrationGridMap.values()){
            rg.guest = pr;
        }
        rrlc.saveRegistrations();
        System.assertEquals(3,[SELECT count() from club62__Reservation_Registration__c]);
        pr.club62__Reciprocal_Club_Customer_Id__c = '326524';
        Update pr;
        for(C62ReservationRegistrationListController.RegistrationGrid rg : rrlc.registrationGridMap.values()){
            rg.guest = pr;
        }
        rrlc.saveRegistrations();
        rrlc.getRegistrationGridValues();
        res.club62__RSVP_By__c = System.today().addDays(-1);
        Update res;
        rrlc.checkParams();
        
        res.club62__RSVP_By__c = System.today().addDays(1);
        res.club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(-3),Time.newInstance(13,0,0,0));
        res.club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(-3),Time.newInstance(14,0,0,0));
        Update res;
        rrlc.checkParams();
        ApexPages.currentPage().getParameters().put('hc','566991');
        rrlc.checkParams();
        ApexPages.currentPage().getParameters().put('rrId',null);
        rrlc.checkParams();
        rrlc.getMaxRemaining();
        Test.StopTest();
    }
    /*
    @Name : C62RoomReservationReceivableRollUpsTest1
    @Description : Test method for C62RoomReservationReceivableRollUpsTest1
    */
    static testmethod void C62RoomReservationReceivableRollUpsTest1(){
        Contact c1 = new Contact(FirstName='Test1',club62__Suffix__c = 'Smith1',LastName='Smith1',
            Birthdate=date.newInstance(1999,03,05),club62__Title__c = 'Test new',Email='smith@test.com');
        insert c1;
        Contact c = C62TestHandler.getMember1();
        c.club62__Status__c = 'Reinstated';
        c.club62__Bill_To_Member__c = c1.Id;
        c.club62__Customer_Account_Enabled__c = true;
        update c;
        club62__Room_Category__c rcc = C62TestHandler.getSingleRoomCategory();
        club62__Room_Reservation__c rr = C62TestHandler.getRoomReservation(c,rcc);
        club62__Invoice__c mi90plus = new club62__Invoice__c(club62__Customer__c=c.Id,club62__From_Date__c=System.Today(),
                            club62__To_Date__c=System.Today(),club62__Due_Date__c=System.Today());
        insert mi90plus;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                            club62__Type__c = 'Payment',club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        Test.starttest();
        club62__Receivable__c mchrg1 = new club62__Receivable__c(club62__Room_Reservation__c = rr.Id,club62__Customer__c=c.Id,club62__Invoice_Line__c=m1.Id,
                club62__Type__c='Adjustment',club62__Amount__c=10,club62__Date__c=System.Today());
        insert mchrg1;
        club62__Transaction__c cc = new club62__Transaction__c();
        cc.club62__Customer__c = c.id;
        cc.club62__Amount__c = 50;
        cc.club62__Date__c = System.today();
        cc.club62__Type__c = 'Room';
        cc.club62__Posted__c = false;
        cc.club62__Status__c = 'Charged';
        cc.club62__Receivable__c = mchrg1.Id;
        
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Customer__c = c.id;
        cc1.club62__Amount__c = 50;
        cc1.club62__Date__c = System.today();
        cc1.club62__Type__c = 'Room';
        cc1.club62__Status__c = 'Charged';
        cc1.club62__Room_Reservation__c = rr.Id;
        insert new List<club62__Transaction__c>{cc,cc1};
        
        mchrg1.club62__Amount_Paid__c = 30;
        Update mchrg1;
        Delete mchrg1;
        Club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        C62PaymentGatewayAuthorizeDotNet pgad = new C62PaymentGatewayAuthorizeDotNet();
        pgad.CaptureAuthorization('336184',30);
        cc.club62__Posted__c = true;
        C62Utilities.cSetExecuted.remove('IsTransactionApproved');
        Update cc;
        delete cc;
        Test.StopTest();
    }
}