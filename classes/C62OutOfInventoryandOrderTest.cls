/*
@Name           : C62OutOfInventoryandOrderTest
@Author         : customersuccess@cloud62.com
@Date           : 17/2/2014
@Description    : Test methods for C62OutOfInventoryAndOutOfOrder
*/
@isTest
public class C62OutOfInventoryandOrderTest{
    static testmethod void testOutOfInventory(){
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() AND Profile.Name=: 'System Administrator' ];
        System.runAs(thisUser){
            club62__C62CommunitySettings__c comSetting = C62TestHandler.getComSetting();
            insert new club62__C62Taxes__c(club62__Room_Res_Tax_Percentage_1__c=8.875,club62__Room_Res_Tax_Percentage_1_Description__c='New York Sales Tax',
                            club62__Room_Res_Tax_Percentage_2__c=5.875,club62__Room_Res_Tax_Percentage_2_Description__c='5.875% NYC Occupancy Tax',
                            club62__Room_Res_Tax_1_Amount__c=null,club62__Room_Res_Tax_1_Amount_Description__c='NYC Hotel Tax',club62__Sales_Tax__c=8.875,
                            club62__Room_Res_Tax_2_Amount_Description__c='Unit Tax - Javits Center Fee',club62__Room_Res_Tax_2_Amount__c=null);
            club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
            club62__Facility__c fc = C62TestHandler.getSportFacilitySquashCourt1();
            Contact c = C62TestHandler.getMember1();
            club62__Address__c cAdd = C62TestHandler.getMemAddress1(c);
            cAdd.club62__Active__c = true;
            update cAdd;
            Test.StartTest();
            club62__Category__c mc4 = C62TestHandler.getMetr4YrMemCat();
            club62__Billing_Schedule__c bs = C62TestHandler.getBillingSchedule1(mc4);
            List<club62__Billing_Schedule_Line__c> bsl = C62TestHandler.getBillingScheduleLineLst(bs);
            insert new club62__C62BillingSettings__c(club62__Invoice_Generation_Threshold__c=0);
            club62__Subscription__c ms = C62TestHandler.getMemberSubscription(c,mc4,'Monthly');
            c.club62__Status__c = 'Active';
            c.club62__Customer_Account_Enabled__c = TRUE;
            update c;
            club62__Payment_Method__c pmd = new club62__Payment_Method__c();
            insert pmd;
            club62__Room__c rm  = new club62__Room__c(club62__Status__c = 'Vacant',Name = 'New Room',club62__Room_Number__c = 52365,club62__Room_Category__c = rc.Id);
            insert rm;
            club62__Room_Out_of_Inventory__c roin = new club62__Room_Out_of_Inventory__c(club62__Room__c = rm.Id,club62__From__c = System.Today(),club62__To__c = System.Today().addDays(5),
            club62__Type__c = 'Out of Inventory');
            insert roin;
            update roin;
            delete roin;
            club62__Room_Out_of_Inventory__c roin1 = new club62__Room_Out_of_Inventory__c(club62__Room__c = rm.Id,club62__From__c = System.Today(),club62__To__c = System.Today(),
            club62__Type__c = 'Out of Inventory');
            insert roin1;
            System.assertEquals(1,[Select count() From club62__Room_Out_of_Inventory__c]);
            update roin1;
            delete roin1;
            Test.StopTest();
        }
    }
    /*
    @Name :TestC62OutOfInventoryAndOutOfOrder
    @Description : Test methods for C62OutOfInventoryAndOutOfOrder.
    */
    static testmethod void testC62OutOfInventoryAndOutOfOrder(){
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        List<club62__Room__c> roomList = C62TestHandler.getFullRoomCategoryRoomLst(rc);
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c();
        rr.club62__Type__c = 'Member';        
        rr.club62__Room_Category__c = rc.Id;
        rr.club62__Group_Category__c = rc.Id;
        rr.club62__from__c = system.today();
        rr.club62__to__c = system.today().addDays(1);
        rr.club62__Status__c = 'No Show';
        rr.club62__room__C = roomList[0].id;
        insert rr;
        Test.startTest();
        club62__Room_Out_of_Inventory__c roo = new club62__Room_Out_of_Inventory__c();
        roo.club62__Type__c = 'Out of Order';
        roo.club62__To__c = system.today().addDays(6);
        roo.club62__From__c = system.today();
        roo.club62__Room__c = roomList[0].id;
        insert roo;
        roo.club62__To__c = system.today();
        update roo;
        roo.club62__To__c = system.today().addDays(3);
        update roo;
        try{
        club62__Room_Out_of_Inventory__c roi = new club62__Room_Out_of_Inventory__c();
        roi.club62__Type__c = 'Out of Inventory';
        roi.club62__To__c = system.today().addDays(6);
        roi.club62__From__c = system.today();
        roi.club62__Room__c = roomList[0].id;
        insert roi;
        }catch(Exception e){}
        delete roo;
        roo = new club62__Room_Out_of_Inventory__c();
        roo.club62__Type__c = 'Out of Order';
        roo.club62__Update_Room_Status__c = false;
        roo.club62__To__c = system.today().addDays(6);
        roo.club62__From__c = system.today();
        roo.club62__Room__c = roomList[0].id;
        insert roo;
        roo.club62__To__c = system.today().addDays(3);
        roo.club62__Update_Room_Status__c = true;
        update roo;
        roo.club62__To__c = system.today().addDays(8);
        update roo;
        System.assertEquals(1,[Select count() From club62__Room_Out_of_Inventory__c]);
        Test.StopTest();
    }
}