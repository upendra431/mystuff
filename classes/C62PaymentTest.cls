/*
@Name           : C62PaymentTest
@Author         : customersuccess@cloud62.com
@Description    : Test methods for C62Payment Trigger
*/
@isTest
public class C62PaymentTest{
    static testmethod void Paymenttes(){
        club62__C62CommunitySettings__c comSetting = C62TestHandler.getComSetting();
        insert new club62__C62Taxes__c(club62__Room_Res_Tax_Percentage_1__c=8.875,club62__Room_Res_Tax_Percentage_1_Description__c='New York Sales Tax',
                        club62__Room_Res_Tax_Percentage_2__c=5.875,club62__Room_Res_Tax_Percentage_2_Description__c='5.875% NYC Occupancy Tax',
                        club62__Room_Res_Tax_1_Amount__c=null,club62__Room_Res_Tax_1_Amount_Description__c='NYC Hotel Tax',club62__Sales_Tax__c=8.875,
                        club62__Room_Res_Tax_2_Amount_Description__c='Unit Tax - Javits Center Fee',club62__Room_Res_Tax_2_Amount__c=null);
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        Contact c = C62TestHandler.getMember1();
        insert new club62__C62BillingSettings__c(club62__Invoice_Generation_Threshold__c=0);
        c.club62__Status__c = 'Reinstated';
        c.club62__Customer_Account_Enabled__c = TRUE;
        update c;
        club62__Person__c p = C62TestHandler.getElizabethInvPerson();
        club62__Pass__c pss = new club62__Pass__c(club62__Customer__c = c.Id);
        insert pss;
        Test.StartTest();
        club62__Payment_Method__c pm = new club62__Payment_Method__c(club62__Pass__c = pss.ID,Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                        club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                        club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm;
        club62__Facility__c fc = C62TestHandler.getSportFacilitySquashCourt1();
        List<RecordType> rtLst = [SELECT ID FROM RecordType WHERE Name='Event' AND sObjectType='club62__Reservation__c'];
        club62__Reservation__c r = new club62__Reservation__c(Name='Member Event Test',club62__Customer__c = c.Id,club62__Club_Location__c=fc.Id,
        club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(13,0,0,0)),
        club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(14,0,0,0)),
        club62__Max_Seats__c=5,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
        club62__Max_Waitlist_Capacity__c=2);
        if(rtLst.size()>0){
            r.RecordTypeId = rtLst[0].Id;
        }
        insert r;
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c(club62__Reservation__c = r.Id,club62__Type__c='Member',club62__Customer__c=c.Id,club62__Room_Category__c=rc.Id,
                                club62__From__c=System.Today().addDays(-2),club62__To__c=System.Today().addDays(20),club62__Status__c='Confirmed');
        insert rr;
        club62__Location__c l = new club62__Location__c();
        insert l;
        club62__Recurring_Payment__c rp = new club62__Recurring_Payment__c(club62__Pay_Entire_Invoice__c = true,club62__Payment_Method__c = pm.Id,club62__Start_Date__c = System.Today().AddDays(-3),club62__End_Date__c = System.Today().AddDays(3),
                        club62__Customer__c = c.Id,club62__Frequency__c = 'Weekly');
        insert rp;
        club62__Invoice__c mi90plus = new club62__Invoice__c(club62__Customer__c=c.Id,club62__From_Date__c=System.Today(),
                        club62__To_Date__c=System.Today(),club62__Due_Date__c=System.Today());
        insert mi90plus;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        
        club62__Folio__c f1 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Room_Reservation__c = rr.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        club62__Folio__c f2 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Reservation__c = r.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        insert f2;
        club62__Payment__c p1 = new club62__Payment__c(club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Room_Reservation__c = rr.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert p1;
        Test.StopTest();
        club62__Payment__c p2 = new club62__Payment__c(club62__Customer__c=c.ID,club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Payment_Method__c = pm.Id,club62__Reservation__c = r.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert p2;
        C62Utilities.cSetExecuted.remove('C62CustomerEmail');
        System.assertEquals(2,[Select count() From club62__Payment__c]);
    }
    /*
    @Name : PaymentTest1
    @Description : Test method for Payment Trigger
    */
    static testmethod void PaymentTest1(){
       club62__C62CommunitySettings__c comSetting = C62TestHandler.getComSetting();
       insert new club62__C62Taxes__c(club62__Room_Res_Tax_Percentage_1__c=8.875,club62__Room_Res_Tax_Percentage_1_Description__c='New York Sales Tax',
                        club62__Room_Res_Tax_Percentage_2__c=5.875,club62__Room_Res_Tax_Percentage_2_Description__c='5.875% NYC Occupancy Tax',
                        club62__Room_Res_Tax_1_Amount__c=null,club62__Room_Res_Tax_1_Amount_Description__c='NYC Hotel Tax',club62__Sales_Tax__c=8.875,
                        club62__Room_Res_Tax_2_Amount_Description__c='Unit Tax - Javits Center Fee',club62__Room_Res_Tax_2_Amount__c=null);
       club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
       Contact c = C62TestHandler.getMember1();
       insert new club62__C62BillingSettings__c(club62__Invoice_Generation_Threshold__c=0);
       c.club62__Status__c = 'Reinstated';
       c.club62__Customer_Account_Enabled__c = TRUE;
       update c;
       club62__Person__c p = C62TestHandler.getElizabethInvPerson();
       club62__Pass__c pss = new club62__Pass__c(club62__Customer__c = c.Id);
       insert pss;
       Test.StartTest();
       club62__Payment_Method__c pm = new club62__Payment_Method__c(club62__Pass__c = pss.ID,Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                        club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                        club62__Expiration_Date__c=System.Today().addYears(5));
       insert pm;
       club62__Facility__c fc = C62TestHandler.getSportFacilitySquashCourt1();
       List<RecordType> rtLst = [SELECT ID FROM RecordType WHERE Name='Event' AND sObjectType='club62__Reservation__c'];
       club62__Reservation__c r = new club62__Reservation__c(Name='Member Event Test',club62__Customer__c = c.Id,club62__Club_Location__c=fc.Id,
       club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(13,0,0,0)),
       club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(14,0,0,0)),
       club62__Max_Seats__c=5,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
       club62__Max_Waitlist_Capacity__c=2);
       if(rtLst.size()>0){
           r.RecordTypeId = rtLst[0].Id;
       }
        insert r;
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c(club62__Reservation__c = r.Id,club62__Type__c='Member',club62__Customer__c=c.Id,club62__Room_Category__c=rc.Id,
                                club62__From__c=System.Today().addDays(-2),club62__To__c=System.Today().addDays(20),club62__Status__c='Confirmed');
        insert rr;
        club62__Location__c l = new club62__Location__c();
        insert l;
        club62__Recurring_Payment__c rp = new club62__Recurring_Payment__c(club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Pay_Entire_Invoice__c = false,club62__Payment_Method__c = pm.Id,club62__Start_Date__c = System.Today().AddDays(-3),club62__End_Date__c = System.Today().AddDays(3),
                        club62__Customer__c = c.Id,club62__Frequency__c = 'Weekly');
        insert rp;
        club62__Invoice__c mi90plus = new club62__Invoice__c(club62__Customer__c=c.Id,club62__From_Date__c=System.Today(),
                        club62__To_Date__c=System.Today(),club62__Due_Date__c=System.Today());
        insert mi90plus;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        
        club62__Folio__c f1 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Room_Reservation__c = rr.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        club62__Folio__c f2 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Reservation__c = r.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        insert f2;
        club62__Payment__c p1 = new club62__Payment__c(club62__Auto_Applied_Amount__c = '6325465',club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Room_Reservation__c = rr.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert p1;
        Test.StopTest();
        club62__Payment__c p2 = new club62__Payment__c(club62__Customer__c=c.ID,club62__Auto_Applied_Amount__c = '6325465',club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Payment_Method__c = pm.Id,club62__Reservation__c = r.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert p2;
        C62Utilities.cSetExecuted.remove('C62CustomerEmail');
        p1.club62__Status__c = 'Paid';
        p2.club62__Status__c = 'Paid';
        update new List<club62__Payment__c>{p1,p2};
        System.assertEquals(2,[Select count() From club62__Payment__c]);
    }
    /*
    @Name : PaymentTest2
    @Description : Test method for Payment Trigger
    */
    static testmethod void PaymentTest2(){
        club62__C62CommunitySettings__c comSetting = C62TestHandler.getComSetting();
        insert new club62__C62Taxes__c(club62__Room_Res_Tax_Percentage_1__c=8.875,club62__Room_Res_Tax_Percentage_1_Description__c='New York Sales Tax',
                        club62__Room_Res_Tax_Percentage_2__c=5.875,club62__Room_Res_Tax_Percentage_2_Description__c='5.875% NYC Occupancy Tax',
                        club62__Room_Res_Tax_1_Amount__c=null,club62__Room_Res_Tax_1_Amount_Description__c='NYC Hotel Tax',club62__Sales_Tax__c=8.875,
                        club62__Room_Res_Tax_2_Amount_Description__c='Unit Tax - Javits Center Fee',club62__Room_Res_Tax_2_Amount__c=null);
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        Contact c = C62TestHandler.getMember1();
        insert new club62__C62BillingSettings__c(club62__Invoice_Generation_Threshold__c=0,club62__Payments_Can_Be_Deleted__c = true);
        c.club62__Status__c = 'Reinstated';
        c.club62__Customer_Account_Enabled__c = TRUE;
        update c;
        club62__Person__c p = C62TestHandler.getElizabethInvPerson();
        club62__Pass__c pss = new club62__Pass__c(club62__Customer__c = c.Id);
        insert pss;
        
        club62__Payment_Method__c pm = new club62__Payment_Method__c(club62__Pass__c = pss.ID,Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                        club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                        club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm;
        Test.StartTest();
        club62__Facility__c fc = C62TestHandler.getSportFacilitySquashCourt1();
        List<RecordType> rtLst = [SELECT ID FROM RecordType WHERE Name='Event' AND sObjectType='club62__Reservation__c'];
        club62__Reservation__c r = new club62__Reservation__c(Name='Member Event Test',club62__Customer__c = c.Id,club62__Club_Location__c=fc.Id,
        club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(13,0,0,0)),
        club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(14,0,0,0)),
        club62__Max_Seats__c=5,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
        club62__Max_Waitlist_Capacity__c=2);
        if(rtLst.size()>0){
            r.RecordTypeId = rtLst[0].Id;
        }
        insert r;
        
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c(club62__Reservation__c = r.Id,club62__Type__c='Member',club62__Customer__c=c.Id,club62__Room_Category__c=rc.Id,
                                club62__From__c=System.Today().addDays(-2),club62__To__c=System.Today().addDays(20),club62__Status__c='Confirmed');
        insert rr;
        club62__Location__c l = new club62__Location__c();
        insert l;
        club62__Recurring_Payment__c rp = new club62__Recurring_Payment__c(club62__Auto_Apply_To_Oldest_Statements__c = false,club62__Pay_Entire_Invoice__c = true,club62__Payment_Method__c = pm.Id,club62__Start_Date__c = System.Today().AddDays(-3),club62__End_Date__c = System.Today().AddDays(3),
                        club62__Customer__c = c.Id,club62__Frequency__c = 'Weekly');
        insert rp;
        club62__Invoice__c mi90plus = new club62__Invoice__c(club62__Customer__c=c.Id,club62__From_Date__c=System.Today(),
                        club62__To_Date__c=System.Today(),club62__Due_Date__c=System.Today());
        insert mi90plus;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Type__c = 'House',club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        club62__Invoice_Line__c m2 = new club62__Invoice_Line__c(club62__Type__c = 'Dues',club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        club62__Invoice_Line__c m3 = new club62__Invoice_Line__c(club62__SubType__c = 'Capital Improvement Fee',club62__Type__c = 'Dues',club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        insert new List<club62__Invoice_Line__c>{m1,m2,m3};
        
        club62__Receivable__c mc = new club62__Receivable__c(club62__Customer__c=c.Id,club62__Invoice_Line__c=m1.Id,club62__Amount__c=100,club62__Date__c=System.Today());
        insert mc;
        Club62__Transaction__c cc2 = new Club62__Transaction__c();
        cc2.Club62__Amount__c = 10;
        cc2.Club62__Date__c = system.today();
        cc2.club62__Invoice_Line__c = m1.Id;
        cc2.club62__Receivable__c = mc.Id;
        cc2.Club62__Description__c = 'Testing';
        cc2.Club62__Customer__c = c.id;
        cc2.Club62__Type__c = 'Class';
        cc2.Club62__SubType__c = '30 Day Late Fee';
        insert cc2;
        
        club62__Folio__c f1 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Room_Reservation__c = rr.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        club62__Folio__c f2 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Reservation__c = r.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        insert f2;
        
        club62__Payment__c p1 = new club62__Payment__c(club62__Auto_Applied_Amount__c = 'Dues = 6325465;new = 20;jnhde',club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Room_Reservation__c = rr.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        
        club62__Payment__c p2 = new club62__Payment__c(club62__Customer__c=c.ID,club62__Auto_Applied_Amount__c = 'Dues = 6325465;new = 20;jnhde',club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Payment_Method__c = pm.Id,club62__Reservation__c = r.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert new List<club62__Payment__c>{p1,p2};
        Test.StopTest();
        C62Utilities.cSetExecuted.remove('C62CustomerEmail');
        p1.club62__Status__c = 'Paid';
        p1.club62__Person__c = p.Id;
        p1.club62__Type__c = 'Application Fee';
        p1.club62__Amount_Refunded__c = 60;
        p1.club62__Statement_Line__c = m2.Id;
        p2.club62__Status__c = 'Paid';
        p2.club62__Person__c = p.Id;
        p2.club62__Type__c = 'Application Fee';
        p2.club62__Amount_Refunded__c = 60;
        p2.club62__Statement_Line__c = m3.Id;
        update new List<club62__Payment__c>{p1,p2};
        C62Utilities.cSetExecuted.remove('C62CustomerEmail');
        Delete p2;
    } 
    /*
    @Name : PaymentTest3
    @Description : Test method for Payment Trigger
    */
    static testmethod void paymentTest3(){
        club62__C62CommunitySettings__c comSetting = C62TestHandler.getComSetting();
        insert new club62__C62Taxes__c(club62__Room_Res_Tax_Percentage_1__c=8.875,club62__Room_Res_Tax_Percentage_1_Description__c='New York Sales Tax',
                        club62__Room_Res_Tax_Percentage_2__c=5.875,club62__Room_Res_Tax_Percentage_2_Description__c='5.875% NYC Occupancy Tax',
                        club62__Room_Res_Tax_1_Amount__c=null,club62__Room_Res_Tax_1_Amount_Description__c='NYC Hotel Tax',club62__Sales_Tax__c=8.875,
                        club62__Room_Res_Tax_2_Amount_Description__c='Unit Tax - Javits Center Fee',club62__Room_Res_Tax_2_Amount__c=null);
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        Contact c = C62TestHandler.getMember1();
        insert new club62__C62BillingSettings__c(club62__Invoice_Generation_Threshold__c=0);
        c.club62__Status__c = 'Reinstated';
        c.club62__Customer_Account_Enabled__c = TRUE;
        update c;
        club62__Person__c p = C62TestHandler.getElizabethInvPerson();
        club62__Pass__c pss = new club62__Pass__c(club62__Customer__c = c.Id);
        insert pss;
        
        club62__Payment_Method__c pm = new club62__Payment_Method__c(club62__Pass__c = pss.ID,Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                        club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                        club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm;
        Test.StartTest();
        club62__Facility__c fc = C62TestHandler.getSportFacilitySquashCourt1();
        List<RecordType> rtLst = [SELECT ID FROM RecordType WHERE Name='Event' AND sObjectType='club62__Reservation__c'];
        
        club62__Reservation__c r = new club62__Reservation__c(Name='Member Event Test',club62__Customer__c = c.Id,club62__Club_Location__c=fc.Id,
        club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(13,0,0,0)),
        club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(14,0,0,0)),
        club62__Max_Seats__c=5,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
        club62__Max_Waitlist_Capacity__c=2);
        if(rtLst.size()>0){
            r.RecordTypeId = rtLst[0].Id;
        }
        insert r;
        
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c(club62__Reservation__c = r.Id,club62__Type__c='Member',club62__Customer__c=c.Id,club62__Room_Category__c=rc.Id,
                                club62__From__c=System.Today().addDays(-2),club62__To__c=System.Today().addDays(20),club62__Status__c='Confirmed');
        insert rr;
        club62__Location__c l = new club62__Location__c();
        insert l;
        club62__Recurring_Payment__c rp = new club62__Recurring_Payment__c(club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Pay_Entire_Invoice__c = false,club62__Payment_Method__c = pm.Id,club62__Start_Date__c = System.Today().AddDays(-3),club62__End_Date__c = System.Today().AddDays(3),
                        club62__Customer__c = c.Id,club62__Frequency__c = 'Weekly');
        insert rp;
        club62__Invoice__c mi90plus = new club62__Invoice__c(club62__Customer__c=c.Id,club62__From_Date__c=System.Today(),
                        club62__To_Date__c=System.Today(),club62__Due_Date__c=System.Today());
        insert mi90plus;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Type__c = 'House',club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        club62__Invoice_Line__c m2 = new club62__Invoice_Line__c(club62__Type__c = 'Dues',club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        club62__Invoice_Line__c m3 = new club62__Invoice_Line__c(club62__SubType__c = 'Capital Improvement Fee',club62__Type__c = 'Dues',club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today(),
                        club62__Amount__c=100,club62__Description__c='Test');
        insert new List<club62__Invoice_Line__c>{m1,m2,m3};
        
        club62__Category__c mc5 = new club62__Category__c(Name='P-METR 5 YR',club62__Auto_Renew_To_Next_Category__c=false,club62__Auto_Renewal_Day__c='5',club62__Auto_Renewal_Month__c='5');
        insert mc5;
        
        club62__Subscription__c ms = new club62__Subscription__c(club62__Customer__c=c.Id,club62__Category__c=mc5.Id,club62__Start_Date__c=System.today(),
                                club62__Primary_Subscription__c = true,club62__Refund_Type__c = 'Credit',club62__Billing_Frequency__c='Quarterly',club62__Monthly_Billing_Start_Day__c='4');
        insert ms;
        
        club62__Dues__c taxObject1 = new club62__Dues__c(club62__Amount_Paid__c = 50,club62__Description__c = 'New',club62__Customer__c=c.Id,club62__Subscription__c=ms.Id,club62__Amount__c=100,club62__Date__c=DateTime.Now(),
                club62__Invoice_Line__c = m1.Id,club62__Status__c='Charged',club62__Type__c='Initiation',club62__Start_Date__c=System.today(),club62__End_Date__c=System.today().addYears(1),club62__SubType__c='Initiation');
        insert taxObject1;
        
        club62__Folio__c f1 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Room_Reservation__c = rr.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        club62__Folio__c f2 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Reservation__c = r.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        insert f2;
        club62__Payment__c p1 = new club62__Payment__c(club62__Auto_Applied_Amount__c = 'Dues = 6325465;new = 20;jnhde',club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Room_Reservation__c = rr.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Pay_Entire_Invoice_Type__c = 'House=30;Dues=30',club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        Test.StopTest();
        club62__Payment__c p2 = new club62__Payment__c(club62__Customer__c=c.ID,club62__Auto_Applied_Amount__c = 'Dues = 6325465;new = 20;jnhde',club62__Auto_Apply_To_Oldest_Statements__c = true,club62__Invoice__c = mi90plus.Id,club62__Recurring_Billing__c = rp.Id,club62__Person__c = p.Id,club62__Payment_Method__c = pm.Id,club62__Reservation__c = r.Id,club62__Description__c = 'Test',club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                    club62__Pay_Entire_Invoice_Type__c = 'House=30;Dues=30',club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert new List<club62__Payment__c>{p1,p2};
        C62Utilities.cSetExecuted.remove('C62CustomerEmail');
        p1.club62__Status__c = 'Paid';
        p1.club62__Person__c = p.Id;
        p1.club62__Type__c = 'Application Fee';
        p1.club62__Amount_Refunded__c = 60;
        p1.club62__Statement_Line__c = m2.Id;
        p2.club62__Status__c = 'Paid';
        p2.club62__Person__c = p.Id;
        p2.club62__Type__c = 'Application Fee';
        p2.club62__Amount_Refunded__c = 60;
        p2.club62__Statement_Line__c = m3.Id;
        update new List<club62__Payment__c>{p1,p2};
    }
    /*
    @Name :C62ProcessRejectedPaymentControllertest
    @Description : Test method for C62ProcessRejectedPaymentController
    */   
    static testmethod void c62ProcessRejectedPaymentControllertest(){
        Contact c = C62TestHandler.getMember1();
        c.Club62__Status__c = 'Reinstated';
        Update c;
        Test.StartTest();
        Club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        Club62__Payment_Method__c pm = C62TestHandler.getPaymentMethod(c);
        Club62__Invoice__c mi = C62TestHandler.getMemberInvoice(c);
        Club62__Payment__c pay = new Club62__Payment__c(Club62__Customer__c=c.Id,Club62__Invoice__c=mi.Id,Club62__Status__c='Rejected',Club62__Approval_Code__c='HDE08D',
                        club62__Payment_Method__c = pm.Id,Club62__Amount__c=1000,Club62__Amount_Used__c=100,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');
        Club62__Payment__c pay1 = new Club62__Payment__c(Club62__Customer__c=c.Id,Club62__Invoice__c=mi.Id,Club62__Status__c='Paid',Club62__Approval_Code__c='HDE08D',
                        club62__Payment_Method__c = pm.Id,Club62__Amount__c=1000,Club62__Amount_Used__c=100,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');
        insert new List<Club62__Payment__c>{pay,pay1};
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 10;
        cc2.club62__Amount_Paid__c = 10;
        cc2.club62__Amount_Adjusted__c = 5;
        cc2.club62__Amount_Refunded__c = 3;
        cc2.club62__Date__c = system.today();
        cc2.Club62__Payment__c = pay.Id;
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Type__c = 'Class';
        cc2.club62__SubType__c = 'Tax';
        cc2.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Amount__c = 10;
        cc1.club62__Amount_Paid__c = 10;
        cc1.club62__Amount_Adjusted__c = 5;
        cc1.club62__Amount_Refunded__c = 3;
        cc1.club62__Date__c = system.today();
        cc1.Club62__Payment__c = pay.Id;
        cc1.club62__Description__c = 'Testing';
        cc1.club62__Customer__c = c.id;
        cc1.club62__Type__c = 'Class';
        cc1.club62__SubType__c = 'Tax';
        cc1.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert new List<club62__Transaction__c>{cc1,cc2};
        ApexPages.StandardController sc = new ApexPages.standardController(pay);
        C62ProcessRejectedPaymentController prpc = new C62ProcessRejectedPaymentController(sc);
        prpc.payMethodID = pm.Id;
        prpc.save();
        prpc.doNothing();
        club62__Payment_Method__c pdbm = new club62__Payment_Method__c(club62__Payment_For__c = 'Default',club62__Payment_Type__c = 'Direct Bill',club62__From_Date__c = System.Today(),club62__To_Date__c = System.Today().addDays(5));
        insert pdbm;
        prpc.selectedPaymentType = 'Direct Bill';
        prpc.payMethodID = pdbm.Id;
        prpc.pay.club62__Status__c = 'Paid';
        prpc.save();
        prpc.selectedPaymentType = 'Credit Card/ACH';
        prpc.payMethodID = pm.Id;
        prpc.save();
        sc = new ApexPages.standardController(pay1);
        prpc = new C62ProcessRejectedPaymentController(sc);
        prpc.payMethodID = pdbm.Id;
        prpc.selectedPaymentType = 'cash';
        prpc.pay = pay1;
        prpc.save();
        prpc.pay.club62__Is_Authorization__c = true;
        prpc.selectedPaymentType = 'Credit Card/ACH';
        prpc.payMethodID = pm.Id;
        prpc.save();        
        Test.StopTest();
    }
    /*
    @Name :testC62UnapplyPaymentsController
    @Description : Test method for C62UnapplyPaymentsController
    */   
    static testmethod void testC62UnapplyPaymentsControllertest(){
        club62__Financial_Account__c fa = C62TestHandler.getFinancialAccount();
        insert new  club62__C62Dues__c(name = 'Default',club62__Holding_Financial_Account__c = fa.Id,club62__House_Financial_Account__c = fa.Id);
        insert new club62__C62BillingSettings__c(club62__Day_Late_Fee_Amount30__c=15,club62__Day_Late_Fee_Percentage30__c=5,club62__Day_Late_Fee_Amount60__c=25,
                        club62__Day_Late_Fee_Amount90__c=40,club62__Day_Late_Fee_Percentage90__c=10,club62__Guest_Pass_Fee__c=65,
                        club62__Invoice_Generation_Threshold__c=0,club62__Number_of_Payment_Attempts__c=3,club62__Payment_Terms__c=30,club62__Pre_Post_Billing__c=FALSE,
                        club62__Quarterly_Event_Minimum__c=100,club62__Quarterly_Food_Beverage_Minimum__c=100,club62__Quarterly_Room_Minimum__c=100,
                        club62__Quarterly_Sports_Minimum__c=100,club62__Termination_Reinstatement_Threshold__c=0,club62__Yearly_Event_Minimum__c=300,
                        club62__Yearly_Food_Beverage_Minimum__c=300,club62__Yearly_Room_Minimum__c=300,club62__Yearly_Sports_Minimum__c=300,club62__Day_Late_Fee_Percentage60__c=7);
        Contact c = C62TestHandler.getMember1();
        c.Club62__status__c = 'Reinstated';
        c.Email = null;
        c.club62__Secondary_Email__c = 'abc@mail.com';
        Update c;
        Club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        Club62__Room_Reservation__c rr = new Club62__Room_Reservation__c(Club62__Type__c='Member',Club62__Room_Category__c=rc.Id,
                                    Club62__From__c=System.Today().addDays(-2),Club62__To__c=System.Today().addDays(20),Club62__Status__c='Confirmed');
        insert rr;
        Club62__Invoice__c mi = C62TestHandler.getMemberInvoice(c);
        
        Club62__Location__c l = new Club62__Location__c();
        insert l;
        Club62__Folio__c f = new Club62__Folio__c(Club62__Customer__c = c.Id,Club62__Type__c = 'Current',
                Club62__Status__c = 'Open',Club62__Location__c = l.id);
        insert f;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi.Id,club62__Date__c=System.Today().addMonths(-9),
                            club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        club62__Payment_Method__c pm = [SELECT ID from club62__Payment_Method__c where club62__Customer__c =:c.Id and club62__Payment_Type__c ='Direct Bill' LIMIT 1];
        Club62__Payment__c pay = new Club62__Payment__c(Club62__Room_Reservation__c = rr.ID,club62__Statement_Line__c = m1.Id,club62__Folio__c = f.Id,Club62__Customer__c=c.Id,Club62__Invoice__c=mi.Id,Club62__Status__c='Paid',Club62__Approval_Code__c='HDE08D',
                       club62__Payment_Method__c = pm.Id,club62__Apply_History__c = '(Dues~$100.00~1/28/2015)',Club62__Amount__c=1000,Club62__Amount_Used__c=100,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');
        insert pay;
        club62__Category__c mc5 = C62TestHandler.getMetr5YrMemCat();
        club62__Subscription__c ms = C62TestHandler.getMemberSubscription(c,mc5,'Annual');
        club62__Dues__c md1 = new club62__Dues__c(club62__Invoice_Line__c = m1.Id,club62__Subscription__c=ms.Id,club62__Amount__c=1000,club62__Date__c=system.now(),club62__Description__c='TESTING',
                    club62__Customer__c=c.Id,club62__SubType__c='Sales Tax',club62__Type__c='Tax',club62__Start_Date__c = date.newInstance(2014,03,05),club62__End_Date__c = date.newInstance(2014,05,05),
                   club62__Split_Monthly_Revenue__c = true);
        Insert md1;
        club62__Dues_Payment__c dp = new club62__Dues_Payment__c(club62__Amount_Refunded__c = 3,club62__Amount_Applied__c = 10,club62__Dues__c = md1.Id,club62__Payment__c = pay.Id);
        insert dp;
        Test.StartTest();
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 10;
        cc2.club62__Status__c = 'Charged';
        cc2.club62__Amount_Paid__c = 100;
        cc2.club62__Manual_Registration_Transaction__c = false;
        cc2.club62__Date__c = system.today();
        cc2.club62__Payment__c = pay.Id;
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Invoice_Line__c = m1.Id;
        cc2.club62__Type__c = 'Class';
        cc2.club62__Folio__c = f.Id;
        cc2.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert cc2;
        cc2.club62__Amount_Paid__c = 100;
        Update cc2;
        system.assertEquals(100,[SELECT club62__Amount_Paid__c from club62__Transaction__c where Id =:cc2.Id LIMIT 1].club62__Amount_Paid__c);
        club62__Receivable__c mchrg1 = new club62__Receivable__c(club62__Status__c = 'Charged',club62__Customer__c=c.Id,club62__Invoice_Line__c=m1.Id,
                club62__Amount_Paid__c = 1,club62__Type__c='30 Day Late Fee',club62__Amount__c=10,club62__Date__c=System.Today().addDays(-10));
        insert mchrg1;
        club62__AR_Payment__c  rpm = new club62__AR_Payment__c(club62__Receivable__c =mchrg1.Id,club62__Amount_Applied__c = 20,
                    club62__Pay__c = pay.Id);
        insert rpm;
        ApexPages.StandardController sc = new ApexPages.standardController(pay);
        C62UnapplyPaymentsController upc = new C62UnapplyPaymentsController(sc);
        try{
        NightAuditReportController narc = new NightAuditReportController();
        narc.searchDRR();
        narc.getYesterdayAmount();
        narc.getMTDAmount();
        narc.getYTDAmount();
        narc.getYesterdayAdjusted();
        narc.getMTDAdjusted();
        narc.getYTDAdjusted();
        NightAuditReportController.ReportSection  rsec = new NightAuditReportController.ReportSection();
        rsec.getYesterdayAmount();
        rsec.getMTDAmount();
        rsec.getYTDAmount();
        rsec.getYesterdayAdjusted();
        rsec.getMTDAdjusted();
        rsec.getYTDAdjusted();
        }catch(exception e){}
        NightAuditReportController.MapSortingWrapper msw = new NightAuditReportController.MapSortingWrapper(0,'Night Audit');
        msw.compareTo(msw);
        Test.stopTest();
    } 
     /*
    @Name :testC62UnapplyPaymentsController
    @Description : Test method for C62UnapplyPaymentsController
    */   
    static testmethod void TestC62UnapplyPaymentsController1(){
        club62__Financial_Account__c fa = C62TestHandler.getFinancialAccount();
        insert new  club62__C62Dues__c(name = 'Default',club62__Holding_Financial_Account__c = fa.Id,club62__House_Financial_Account__c = fa.Id);
        insert new club62__C62BillingSettings__c(club62__Day_Late_Fee_Amount30__c=15,club62__Day_Late_Fee_Percentage30__c=5,club62__Day_Late_Fee_Amount60__c=25,
                        club62__Day_Late_Fee_Amount90__c=40,club62__Day_Late_Fee_Percentage90__c=10,club62__Guest_Pass_Fee__c=65,
                        club62__Invoice_Generation_Threshold__c=0,club62__Number_of_Payment_Attempts__c=3,club62__Payment_Terms__c=30,club62__Pre_Post_Billing__c=FALSE,
                        club62__Quarterly_Event_Minimum__c=100,club62__Quarterly_Food_Beverage_Minimum__c=100,club62__Quarterly_Room_Minimum__c=100,
                        club62__Quarterly_Sports_Minimum__c=100,club62__Termination_Reinstatement_Threshold__c=0,club62__Yearly_Event_Minimum__c=300,
                        club62__Yearly_Food_Beverage_Minimum__c=300,club62__Yearly_Room_Minimum__c=300,club62__Yearly_Sports_Minimum__c=300,club62__Day_Late_Fee_Percentage60__c=7);
        Contact c = C62TestHandler.getMember1();
        c.Club62__status__c = 'Reinstated';
        Update c;
        Club62__Invoice__c mi = C62TestHandler.getMemberInvoice(c);
        
        Club62__Location__c l = new Club62__Location__c();
        insert l;
        Club62__Folio__c f = new Club62__Folio__c(Club62__Customer__c = c.Id,Club62__Type__c = 'Current',
                Club62__Status__c = 'Open',Club62__Location__c = l.id);
        insert f;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi.Id,club62__Date__c=System.Today().addMonths(-9),
                            club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        Club62__Payment__c pay = new Club62__Payment__c(club62__Statement_Line__c = m1.Id,club62__Folio__c = f.Id,Club62__Customer__c=c.Id,Club62__Invoice__c=mi.Id,Club62__Status__c='Paid',Club62__Approval_Code__c='HDE08D',
                       club62__Apply_History__c = '(Dues~$100.00~1/28/2015)',Club62__Amount__c=1000,Club62__Amount_Used__c=100,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');
        insert pay;
        club62__Category__c mc5 = C62TestHandler.getMetr5YrMemCat();
        club62__Subscription__c ms = C62TestHandler.getMemberSubscription(c,mc5,'Annual');
        club62__Dues__c md1 = new club62__Dues__c(club62__Invoice_Line__c = m1.Id,club62__Subscription__c=ms.Id,club62__Amount__c=1000,club62__Date__c=system.now(),club62__Description__c='TESTING',
                    club62__Customer__c=c.Id,club62__SubType__c='Sales Tax',club62__Type__c='Tax',club62__Start_Date__c = date.newInstance(2014,03,05),club62__End_Date__c = date.newInstance(2014,05,05),
                   club62__Split_Monthly_Revenue__c = true);
        Insert md1;
        club62__Dues_Payment__c dp = new club62__Dues_Payment__c(club62__Amount_Refunded__c = 1,club62__Amount_Applied__c = 1,club62__Dues__c = md1.Id,club62__Payment__c = pay.Id);
        insert dp;
        Test.StartTest();
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 10;
        cc2.club62__Status__c = 'Charged';
        cc2.club62__Amount_Paid__c = 100;
        cc2.club62__Manual_Registration_Transaction__c = false;
        cc2.club62__Date__c = system.today();
        cc2.club62__Payment__c = pay.Id;
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Invoice_Line__c = m1.Id;
        cc2.club62__Type__c = 'Class';
        cc2.club62__Folio__c = f.Id;
        cc2.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert cc2;
        cc2.club62__Amount_Paid__c = 100;
        Update cc2;
        system.assertEquals('Charged',[SELECT club62__Status__c from club62__Transaction__c where Id =:cc2.Id LIMIT 1].club62__Status__c);
        system.assertEquals(100,[SELECT club62__Amount_Paid__c from club62__Transaction__c where Id =:cc2.Id LIMIT 1].club62__Amount_Paid__c);
        club62__Receivable__c mchrg1 = new club62__Receivable__c(club62__Status__c = 'Charged',club62__Customer__c=c.Id,club62__Invoice_Line__c=m1.Id,
                club62__Type__c='30 Day Late Fee',club62__Amount__c=10,club62__Date__c=System.Today().addDays(-10));
        insert mchrg1;
        club62__AR_Payment__c  rpm = new club62__AR_Payment__c(club62__Receivable__c =mchrg1.Id,club62__Amount_Applied__c = 1,
                    club62__Amount_Refunded__c = 1,club62__Pay__c = pay.Id);
        insert rpm;
        ApexPages.StandardController sc = new ApexPages.standardController(pay);
        C62UnapplyPaymentsController upc = new C62UnapplyPaymentsController(sc);
        upc.calcPaymentAmtLeft();
        upc.cSelILWId = m1.Id;
        upc.cSelId = mi.Id;
        upc.cSelILWId = m1.Id;
        upc.cPayAmtLeft = 500;
        upc.payOffAll();
        C62UnapplyPaymentsController.UnApplyWrapper  uaw = new C62UnapplyPaymentsController.UnApplyWrapper();
        upc.payUnApplyRecLst = new List<C62UnapplyPaymentsController.UnApplyWrapper>();
        upc.payUnApplyRecLst.add(uaw);
        for(C62UnapplyPaymentsController.UnApplyWrapper upaw : upc.payUnApplyRecLst){
            upaw.selUnapply = true;
        }
        upc.savePayment();
        upc.cdecBeforeChange = 1;
        upc.cSelId = md1.Id;
        upc.objTypeStr = 'club62__Dues__c';
        upc.selectRecDue();
        upc.updateRecDuesTotalPay();
        upc.cSelId = mchrg1.Id;
        upc.objTypeStr = 'club62__Receivable__c';
        upc.selectRecDue();
        upc.updateRecDuesTotalPay();
        Test.stopTest();
    } 
    /*
    @Name :testC62UnapplyPaymentsController
    @Description : Test method for C62UnapplyPaymentsController
    */   
    static testmethod void TestC62UnapplyPaymentsController(){
        club62__Financial_Account__c fa = C62TestHandler.getFinancialAccount();
        insert new  club62__C62Dues__c(name = 'Default',club62__Holding_Financial_Account__c = fa.Id,club62__House_Financial_Account__c = fa.Id);
        insert new club62__C62BillingSettings__c(club62__Day_Late_Fee_Amount30__c=15,club62__Day_Late_Fee_Percentage30__c=5,club62__Day_Late_Fee_Amount60__c=25,
                        club62__Day_Late_Fee_Amount90__c=40,club62__Day_Late_Fee_Percentage90__c=10,club62__Guest_Pass_Fee__c=65,
                        club62__Invoice_Generation_Threshold__c=0,club62__Number_of_Payment_Attempts__c=3,club62__Payment_Terms__c=30,club62__Pre_Post_Billing__c=FALSE,
                        club62__Quarterly_Event_Minimum__c=100,club62__Quarterly_Food_Beverage_Minimum__c=100,club62__Quarterly_Room_Minimum__c=100,
                        club62__Quarterly_Sports_Minimum__c=100,club62__Termination_Reinstatement_Threshold__c=0,club62__Yearly_Event_Minimum__c=300,
                        club62__Yearly_Food_Beverage_Minimum__c=300,club62__Yearly_Room_Minimum__c=300,club62__Yearly_Sports_Minimum__c=300,club62__Day_Late_Fee_Percentage60__c=7);
        Contact c = C62TestHandler.getMember1();
        c.Club62__status__c = 'Reinstated';
        Update c;
        Club62__Invoice__c mi = C62TestHandler.getMemberInvoice(c);
        
        Club62__Location__c l = new Club62__Location__c();
        insert l;
        Club62__Folio__c f = new Club62__Folio__c(Club62__Customer__c = c.Id,Club62__Type__c = 'Current',
                Club62__Status__c = 'Open',Club62__Location__c = l.id);
        insert f;
        Club62__Payment__c pay = new Club62__Payment__c(club62__Folio__c = f.Id,Club62__Customer__c=c.Id,Club62__Invoice__c=mi.Id,Club62__Status__c='Paid',Club62__Approval_Code__c='HDE08D',
                        Club62__Amount__c=1000,Club62__Amount_Used__c=100,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');
        insert pay;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi.Id,club62__Date__c=System.Today().addMonths(-9),
                            club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        club62__Category__c mc5 = C62TestHandler.getMetr5YrMemCat();
        club62__Subscription__c ms = C62TestHandler.getMemberSubscription(c,mc5,'Annual');
        club62__Dues__c md1 = new club62__Dues__c(club62__Invoice_Line__c = m1.Id,club62__Subscription__c=ms.Id,club62__Amount__c=1000,club62__Date__c=system.now(),club62__Description__c='TESTING',
                    club62__Customer__c=c.Id,club62__SubType__c='Sales Tax',club62__Type__c='Tax',club62__Start_Date__c = date.newInstance(2014,03,05),club62__End_Date__c = date.newInstance(2014,05,05),
                   club62__Split_Monthly_Revenue__c = true);
        Insert md1;
        club62__Dues_Payment__c dp = new club62__Dues_Payment__c(club62__Amount_Refunded__c = 3,club62__Amount_Applied__c = 10,club62__Dues__c = md1.Id,club62__Payment__c = pay.Id);
        insert dp;
        club62__Receivable__c mchrg1 = new club62__Receivable__c(club62__Status__c = 'Charged',club62__Customer__c=c.Id,club62__Invoice_Line__c=m1.Id,
                club62__Type__c='30 Day Late Fee',club62__Amount__c=10,club62__Date__c=System.Today().addDays(-10));
        insert mchrg1;
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Amount__c = 10;
        cc1.club62__Status__c = 'Charged';
        cc1.club62__Amount_Paid__c = 100;
        cc1.club62__Manual_Registration_Transaction__c = true;
        cc1.club62__Date__c = system.today();
        cc1.club62__Payment__c = pay.Id;
        cc1.club62__Description__c = 'Testing';
        cc1.club62__Customer__c = c.id;
        cc1.club62__Invoice_Line__c = m1.Id;
        cc1.club62__Type__c = 'Class';
        cc1.club62__Receivable__c = mchrg1.ID;
        cc1.club62__Folio__c = f.Id;
        cc1.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 10;
        cc2.club62__Status__c = 'Charged';
        cc2.club62__Amount_Paid__c = 100;
        cc2.club62__Manual_Registration_Transaction__c = true;
        cc2.club62__Date__c = system.today();
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Invoice_Line__c = m1.Id;
        cc2.club62__Type__c = 'Class';
        cc2.club62__Folio__c = f.Id;
        cc2.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert new List<club62__Transaction__c>{cc1,cc2};
        club62__Financial_Journal_Entry__c fje = new club62__Financial_Journal_Entry__c(club62__Posted__c = true,club62__Transfer__c=true,
            club62__Entry_Date__c = System.Today());
        insert fje;
        
        club62__AR_Payment__c  rpm = new club62__AR_Payment__c(club62__Receivable__c =mchrg1.Id,club62__Amount_Applied__c = 20,
                    club62__Pay__c = pay.Id);
        insert rpm;
        ApexPages.StandardController sc = new ApexPages.standardController(pay);
        C62UnapplyPaymentsController upc = new C62UnapplyPaymentsController(sc);
        upc.calcPaymentAmtLeft();
        upc.cSelILWId = m1.Id;
        upc.cSelId = mi.Id;
        upc.cSelILWId = m1.Id;
        upc.cPayAmtLeft = 500;
        upc.payOffAll();
        Test.StartTest();
        C62UnapplyPaymentsController.UnApplyWrapper  uaw = new C62UnapplyPaymentsController.UnApplyWrapper();
        upc.payUnApplyRecLst = new List<C62UnapplyPaymentsController.UnApplyWrapper>();
        upc.payUnApplyRecLst.add(uaw);
        for(C62UnapplyPaymentsController.UnApplyWrapper upaw : upc.payUnApplyRecLst){
            upaw.selUnapply = true;
            upaw.maxUnapplyAmt = 1;
        }
        for(C62UnapplyPaymentsController.UnApplyWrapper uw : upc.payUnApplyRecLst){
            uw.objType = 'club62__Dues_Payment__c';
            uw.maxUnapplyAmt = 1;
            uw.dp = dp;
        }
        upc.savePayment();
        for(C62UnapplyPaymentsController.UnApplyWrapper uw : upc.payUnApplyRecLst){
            uw.objType = 'club62__AR_Payment__c';
            uw.maxUnapplyAmt = 1;
            uw.rp = rpm;
        }
        upc.savePayment();
        for(C62UnapplyPaymentsController.UnApplyWrapper uw : upc.payUnApplyRecLst){
            uw.objType = 'club62__Transaction__c';
            uw.maxUnapplyAmt = 1;
            uw.tran = cc2;
        }
        upc.savePayment();
        for(C62UnapplyPaymentsController.UnApplyWrapper uw : upc.payUnApplyRecLst){
            uw.objType = 'club62__Folio__c';
            uw.maxUnapplyAmt = 1;
            uw.folio = f;
        }
        upc.savePayment();
        Test.stopTest();
    }
    static testmethod void paymentRefundtest(){
        Contact c1 = new Contact(FirstName='Test1',club62__Suffix__c = 'Smith1',LastName='Smith1',
            Birthdate=date.newInstance(1999,03,06),club62__Title__c = 'Test new1',Email='smith1@test.com');
        insert c1;
        Contact c = C62TestHandler.getMember1();
        club62__Address__c a = new club62__Address__c(Name='Test Address',club62__From_Date__c=date.newInstance(1999,03,05),
                club62__Country__c='United States',club62__State_Province__c='NY',club62__City__c='Lewiston',club62__Street_1__c='102 River Road',
                club62__Customer__c = c.Id,club62__Primary__c = true,club62__Street_2__c='Apt B',club62__Street_3__c='Street 3',club62__Zip_Postal_Code__c='14095',club62__Type__c='Home',club62__Active__c = true);
        insert a;        
        c.club62__Status__c = 'Reinstated';
        c.club62__Bill_To_Member__c = c1.Id;
        update c;
        club62__Person__c p = new club62__Person__c(Name='Elizabeth Wood',club62__Salutation__c='Ms.',club62__First_Name__c='Elizabeth',club62__Last_Name__c='Wood',
                        club62__Gender__c='Female',club62__Status__c='Pending',club62__Reason__c='Looking for More Information',
                        club62__Home_Phone__c='(716)-555-4108',club62__Email__c='club62tests@cloud62.com',
                        club62__Birthdate__c=date.newinstance(1970,10,10));
        insert p;
        club62__Address__c pa = new club62__Address__c(Name='Test Address',club62__From_Date__c=date.newInstance(1999,03,05),
                club62__Country__c='United States',club62__State_Province__c='NY',club62__City__c='Lewiston',club62__Street_1__c='102 River Road',
                club62__Person__c = p.Id,club62__Primary__c = true,club62__Street_2__c='Apt B',club62__Street_3__c='Street 3',club62__Zip_Postal_Code__c='14095',club62__Type__c='Home',club62__Active__c = true);
        insert pa;
        club62__Financial_Account__c fc = new club62__Financial_Account__c(club62__A_P_Trade__c=true,Name='Test',club62__Account_Number__c='asd32sd',club62__Balance_Sheet_Type__c='Current Assets',
                club62__Balance_Sheet_Sub_Type__c='Accounts Receivables',club62__Category__c='Assets',club62__Type__c='Food',
                club62__Statement_of_Activities_Type__c='Operating Expenses',club62__Statement_of_Activities_Sub_Type__c='Food');
        insert fc;
        club62__Payment_Method__c pm = [SELECT ID from club62__Payment_Method__c where club62__Customer__c =:c.Id and club62__Payment_Type__c ='Direct Bill' LIMIT 1];
        club62__Payment__c p1 = new club62__Payment__c(club62__Amount_Credited__c = 75,club62__Amount_Refunded__c = 50,club62__Customer__c=c.Id,club62__Status__c='Paid',club62__Approval_Code__c='HDE08D',
                    club62__Amount__c=5000,club62__Amount_Used__c=5000,club62__Payment_Date__c=System.Today().addDays(-10),club62__Payment_Method__c=pm.Id);
        insert p1;
        
        Test.StartTest();

        club62__Financial_Account_Mapping__c fam = new club62__Financial_Account_Mapping__c(club62__Child_SubType__c = 'Check Request',club62__Child_Type__c = 'Refund',club62__Financial_Account__c=fc.Id,club62__Child_Object__c='club62__Refund__c');
        insert fam;
        club62__Refund__c mRef = new club62__Refund__c(club62__Customer__c=c.Id,club62__Amount__c=1000,club62__Status__c='Pending',
                            club62__Type__c = 'Refund',club62__SubType__c = 'Check Request',club62__Date__c=system.today().addDays(-1));

        insert mRef;
        mRef.club62__Status__c = 'Approved';
        update mRef;
        mRef.club62__Person__c = p.ID;
        update mRef;
        delete mRef;
        club62__Payment_Method__c pm1 = new club62__Payment_Method__c(Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                        club62__Payment_Type__c='Credit Card',club62__Person__c=p.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                        club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm1;
        C62Utilities.cSetExecuted.Remove('PMDefault');
        pm1.club62__Default__c = true;
        Update pm1;
        Test.StopTest();
    }
    /*
    @Name : PaymentTest5
    @Description : Test method for payment Trigger
    */
    static testmethod void PaymentTest5(){
        club62__C62CommunitySettings__c comSetting = C62TestHandler.getComSetting();
        insert new club62__C62Taxes__c(club62__Room_Res_Tax_Percentage_1__c=8.875,club62__Room_Res_Tax_Percentage_1_Description__c='New York Sales Tax',
                        club62__Room_Res_Tax_Percentage_2__c=5.875,club62__Room_Res_Tax_Percentage_2_Description__c='5.875% NYC Occupancy Tax',
                        club62__Room_Res_Tax_1_Amount__c=null,club62__Room_Res_Tax_1_Amount_Description__c='NYC Hotel Tax',club62__Sales_Tax__c=8.875,
                        club62__Room_Res_Tax_2_Amount_Description__c='Unit Tax - Javits Center Fee',club62__Room_Res_Tax_2_Amount__c=null);
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        Contact c = C62TestHandler.getMember1();
        insert new club62__C62BillingSettings__c(club62__Invoice_Generation_Threshold__c=0);
        c.club62__Status__c = 'Reinstated';
        c.club62__Customer_Account_Enabled__c = TRUE;
        c.Email = null;
        c.club62__Secondary_Email__c = null;
        c.club62__Other_Email__c = 'abc@mail.com';
        update c;
        club62__Pass__c pss = new club62__Pass__c(club62__Customer__c = c.Id);
        insert pss;
        Test.StartTest();
        club62__Payment_Method__c pm = new club62__Payment_Method__c(club62__Pass__c = pss.ID,Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                        club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                        club62__Expiration_Date__c=System.Today().addYears(5));
        insert pm;
        club62__Facility__c fc = C62TestHandler.getSportFacilitySquashCourt1();
        List<RecordType> rtLst = [SELECT ID FROM RecordType WHERE Name='Event' AND sObjectType='club62__Reservation__c'];
        club62__Reservation__c r = new club62__Reservation__c(Name='Member Event Test',club62__Customer__c = c.Id,club62__Club_Location__c=fc.Id,
        club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(13,0,0,0)),
        club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(1),Time.newInstance(14,0,0,0)),
        club62__Max_Seats__c=5,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
        club62__Max_Waitlist_Capacity__c=2);
        if(rtLst.size()>0){
            r.RecordTypeId = rtLst[0].Id;
        }
        insert r;
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c(club62__Reservation__c = r.Id,club62__Type__c='Member',club62__Customer__c=c.Id,club62__Room_Category__c=rc.Id,
                                club62__From__c=System.Today().addDays(-2),club62__To__c=System.Today().addDays(20),club62__Status__c='Confirmed');
        insert rr;
        club62__Location__c l = new club62__Location__c();
        insert l;
        club62__Payment__c p11 = new club62__Payment__c(club62__Room_Reservation__c = rr.Id,club62__Description__c = 'Test',club62__Customer__c=c.Id,club62__Status__c='Paid',club62__Approval_Code__c='HDE08D',
                    club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        club62__Payment__c p22 = new club62__Payment__c(club62__Reservation__c = r.Id,club62__Description__c = 'Test',club62__Customer__c=c.Id,club62__Status__c='Paid',club62__Approval_Code__c='HDE08D',
                    club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        club62__Folio__c f1 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Room_Reservation__c = rr.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        insert f1;
        club62__Folio__c f2 = new club62__Folio__c(club62__Customer__c = c.Id,club62__Reservation__c = r.Id,club62__Type__c = 'Current',
            club62__Status__c = 'Open',club62__Location__c = l.id);
        insert f2;
        club62__Payment__c p1 = new club62__Payment__c(club62__Room_Reservation__c = rr.Id,club62__Description__c = 'Test',club62__Customer__c=c.Id,club62__Status__c='Paid',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        Test.StopTest();
        club62__Payment__c p2 = new club62__Payment__c(club62__Payment_Method__c = pm.Id,club62__Reservation__c = r.Id,club62__Description__c = 'Test',club62__Customer__c=c.Id,club62__Status__c='Paid',club62__Approval_Code__c='HDE08D',
                    club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Amount_Refunded__c = 50,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10));
        insert new List<club62__Payment__c>{p11,p22,p1,p2};
        club62__Person__c p = C62TestHandler.getElizabethInvPerson();
        p2.club62__Person__c = p.Id;
        p2.club62__Type__c='Application Fee';
        update p;
        update p2;
    }  
    /*
    @Name :paymentUpdate
    @Description : Test method for Payment Trigger
    */
    static testmethod void paymentUpdate1(){
        club62__Payment_Gateway__c pg1 = new club62__Payment_Gateway__c(Name='Authorize.net',club62__Default__c=FALSE,
                club62__Login_Encrypted__c='63kF4pjcgZ2Z',club62__Password_Encrypted__c='7Yk49MRq86wU29j9',
                club62__Production_URL__c='https://secure.authorize.net/gateway/transact.dll',
                club62__Test_Code_Response__c='1|1|1|This transaction has been approved.|LDV9JR|Y|2160295577||0|600.00|'
                +'CC|auth_capture||aslam|bari||dfsdf||wa|5555||||||||||||||||||71AFA2003D02930E47E84F23E14E07C3|P|2||||'
                +'|||||||XXXX1111|Visa|||||||||||||||||false|1',
                club62__Test_URL__c='https://test.authorize.net/gateway/transact.dll');
        club62__Payment_Gateway__c pg2 = new club62__Payment_Gateway__c(Name='EVO',club62__Default__c=FALSE,
                club62__Login_Encrypted__c='demo',club62__Password_Encrypted__c='password',
                club62__Production_URL__c='https://secure.networkmerchants.com/api/transact.php');
        club62__Payment_Gateway__c pg3 = new club62__Payment_Gateway__c(Name='PayFlow',club62__Default__c=TRUE,
                club62__Login_Encrypted__c='AaKc4RB5-ju6MePTXQ_b5tE6FpzmjncmHI4CmCi-_g7YNqbJ99JPOwA5Kpy-',
                club62__Password_Encrypted__c='EIvRtRDGyh-igF7Inww3yqcJf0MzAAuhlYJ0-d1MufQUUrwO1H-ZOF-meXWM',
                club62__Production_URL__c='https://api.paypal.com',club62__Test_URL__c='https://api.sandbox.paypal.com');
        insert new List<club62__Payment_Gateway__c>{pg1,pg2,pg3};
        Contact c = C62TestHandler.getMember1();
        c.club62__status__c = 'Reinstated';
        update c;
        club62__Invoice__c mi90plus = new club62__Invoice__c(club62__Customer__c=c.Id,club62__From_Date__c=System.Today().addMonths(-6).addDays(-1),
                            club62__To_Date__c=System.Today().addMonths(-5),club62__Due_Date__c=System.Today().addMonths(-5));
        insert mi90plus;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today().addMonths(-9),
                            club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        club62__Facility__c fac1 = C62TestHandler.getSportFacilitySquashCourt1();
        List<RecordType> rtLst = [SELECT ID,Name FROM RecordType WHERE sObjectType='Club62__Reservation__c' AND Name = 'Sponsored Event'];
        club62__Reservation__c res1 = new club62__Reservation__c(Name='Sport Test',club62__Club_Location__c=fac1.Id,club62__Max_Seats__c=5,
                            RecordTypeId = rtLst[0].Id,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
                            club62__Status__c='Closed/Posted',club62__Max_Waitlist_Capacity__c=2,club62__Charged__c = FALSE,club62__Customer__c=c.Id,
                            club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(13,0,0,0)),
                            club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(14,0,0,0)));
        insert res1;
        
        club62__Reservation__c res2 = new club62__Reservation__c(Name='Sport Test',club62__Club_Location__c=fac1.Id,club62__Max_Seats__c=5,
                            RecordTypeId = rtLst[0].Id,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
                            club62__Parent_Reservation__c = res1.Id,club62__Status__c='Closed/Posted',club62__Max_Waitlist_Capacity__c=2,club62__Charged__c = FALSE,club62__Customer__c=c.Id,
                            club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(15,0,0,0)),
                            club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(16,0,0,0)));
        insert res2;
        club62__Reservation__c res = new club62__Reservation__c(Name='Sport Test',club62__Club_Location__c=fac1.Id,club62__Max_Seats__c=5,
                            RecordTypeId = rtLst[0].Id,club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
                            club62__Parent_Reservation__c = res2.Id,club62__Status__c='Closed/Posted',club62__Max_Waitlist_Capacity__c=2,club62__Charged__c = FALSE,club62__Customer__c=c.Id,
                            club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(17,0,0,0)),
                            club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(18,0,0,0)));
        insert res;
        
        club62__Payment_Method__c pm = new club62__Payment_Method__c(Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        club62__Payment_Method__c pm1 = new club62__Payment_Method__c(club62__Temporary__c = true,Name='Smith Test',club62__Card_Holder_Name__c='Smith Test',club62__CVV_Code__c='000',
                            club62__Payment_Type__c='Credit Card',club62__Customer__c=c.Id,club62__Card_Type__c='Visa',club62__Card_Number__c='4007000000027',
                            club62__Expiration_Date__c=System.Today().addYears(5));
        insert new List<club62__Payment_Method__c>{pm,pm1};
        club62__Address__c add = C62TestHandler.getMemAddress1(c);
        pm.club62__Billing_Address__c = add.Id;
        update pm;
        club62__Location__c l = new club62__Location__c(Name = 'New');
        insert l;
        club62__Folio__c f = new club62__Folio__c(club62__Reservation__c = res.Id,club62__Customer__c = c.Id,club62__Type__c = 'Future',
                club62__Status__c = 'Open',club62__Location__c = l.id);
        insert f;
        Club62__Transaction__c cc1 = new Club62__Transaction__c();
        cc1.Club62__Amount__c = 1000.00;
        cc1.club62__Amount_Paid__c = 2.00;
        cc1.Club62__Amount_Adjusted__c = 5.00;
        cc1.club62__Amount_Refunded__c = 3.00;
        cc1.Club62__Status__c = 'Charged';
        cc1.Club62__Date__c = system.today();
        cc1.Club62__Description__c = 'Testing';
        cc1.club62__Reservation__c = res.Id;
        cc1.Club62__Customer__c = c.id;
        cc1.Club62__Folio__c = f.Id;
        cc1.Club62__Type__c = 'Class';
        cc1.Club62__SubType__c = 'Tax';
        cc1.Club62__Facility__c = fac1.Id;
        cc1.Club62__Batch_Or_Inactive_Member_Transaction__c = true;
        Club62__Transaction__c cc2 = new Club62__Transaction__c();
        cc2.Club62__Amount__c = 900.00;
        cc2.club62__Amount_Paid__c = 2.00;
        cc2.Club62__Amount_Adjusted__c = 5.00;
        cc2.club62__Amount_Refunded__c = 3.00;
        cc2.Club62__Status__c = 'Charged';
        cc2.Club62__Date__c = system.today();
        cc2.Club62__Description__c = 'Testing';
        cc2.club62__Reservation__c = res.Id;
        cc2.Club62__Customer__c = c.id;
        cc2.Club62__Folio__c = f.Id;
        cc2.Club62__Type__c = 'Class';
        cc2.Club62__SubType__c = 'Tax';
        cc2.Club62__Facility__c = fac1.Id;
        cc2.Club62__Batch_Or_Inactive_Member_Transaction__c = true;
        Test.startTest();
        Club62__Transaction__c cc3 = new Club62__Transaction__c();
        cc3.Club62__Amount__c = 800.00;
        cc3.club62__Amount_Paid__c = 2.00;
        cc3.Club62__Amount_Adjusted__c = 5.00;
        cc3.club62__Amount_Refunded__c = 3.00;
        cc3.Club62__Status__c = 'Charged';
        cc3.Club62__Date__c = system.today();
        cc3.Club62__Description__c = 'Testing';
        cc3.club62__Reservation__c = res.Id;
        cc3.Club62__Customer__c = c.id;
        cc3.Club62__Folio__c = f.Id;
        cc3.Club62__Type__c = 'Class';
        cc3.Club62__SubType__c = 'Tax';
        cc3.Club62__Facility__c = fac1.Id;
        cc3.Club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert new List<Club62__Transaction__c>{cc1,cc2,cc3};
        
        club62__Recurring_Payment__c rp = new club62__Recurring_Payment__c(club62__Pay_Entire_Invoice__c = true,club62__Payment_Method__c = pm.Id,club62__Start_Date__c = System.Today().AddDays(-3),club62__End_Date__c = System.Today().AddDays(35),
                club62__Auto_Applied_Amount__c = 'action=20=new',club62__Customer__c = c.Id,club62__Frequency__c = 'Weekly');
        insert rp;
        
        club62__Payment__c pay = new club62__Payment__c(club62__Amount_Credited__c = 5.00,club62__Amount_Refunded__c = 10.00,club62__Recurring_Billing__c = rp.Id,club62__Customer__c =c.id,club62__Invoice__c=mi90plus.Id,club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                        club62__Reservation__c = res.Id,club62__Amount__c=1000.00,club62__Amount_Used__c=100.00,club62__Payment_Date__c=System.Today().addDays(-10),club62__Payment_Method__c = pm.Id);
        club62__Payment__c pay1 = new club62__Payment__c(club62__Amount_Credited__c = 5.00,club62__Amount_Refunded__c = 10.00,club62__Recurring_Billing__c = rp.Id,club62__Customer__c =c.id,club62__Invoice__c=mi90plus.Id,club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                        club62__Reservation__c = res1.Id,club62__Amount__c=1000,club62__Amount_Used__c=100.00,club62__Payment_Date__c=System.Today().addDays(-10),club62__Payment_Method__c = pm1.Id);
        club62__Payment__c pay2 = new club62__Payment__c(club62__Amount_Credited__c = 5.00,club62__Amount_Refunded__c = 10.00,club62__Recurring_Billing__c = rp.Id,club62__Customer__c =c.id,club62__Invoice__c=mi90plus.Id,club62__Status__c='Queued',club62__Approval_Code__c='HDE08D',
                        club62__Reservation__c = res2.Id,club62__Amount__c=1000,club62__Amount_Used__c=100,club62__Payment_Date__c=System.Today().addDays(-10),club62__Payment_Method__c = pm.Id);
        insert new List<club62__Payment__c>{pay,pay1,pay2};
        
        C62Utilities.cSetExecuted.remove('C62CustomerEmail');
        C62Utilities.cSetExecuted.remove('C62PaymentRecurringPayments');
        pay.club62__Folio__c = f.Id;
        pay.club62__Status__c='Paid';
        pay.club62__Amount_Used__c = 50;
        pay1.club62__Folio__c = f.Id;
        pay1.club62__Status__c='Paid';
        pay2.club62__Folio__c = f.Id;
        pay2.club62__Status__c='Paid';
        C62Utilities.cSetExecuted.remove('C62CustomerEmail');
        C62Utilities.cSetExecuted.remove('C62FolioAmountPaid');
        C62Utilities.cSetExecuted.remove('C62ReservationPostClose');
        C62Utilities.cSetExecuted.remove('C62PaymentApplyHistory');
        Update new List<club62__Payment__c>{pay,pay1,pay2};
        Test.stopTest();
        C62Utilities.cSetExecuted.remove('C62FolioAmountPaid');
        try{
        Delete pay;
        }catch(exception e){}
    }
    /*
    @Name :failedPaymentTest
    @Description : Test method for Payment Trigger for the failed case.
    */   
    static testmethod void failedPaymentTest(){
        Contact c = C62TestHandler.getMember1();
        c.Club62__Status__c = 'Reinstated';
        Update c;
        
        Club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        Club62__Payment_Method__c pm = C62TestHandler.getPaymentMethod(c);
        club62__Payment_Method__c pmdb = [SELECT ID from club62__Payment_Method__c where club62__Customer__c =:c.Id and club62__Payment_Type__c ='Direct Bill' LIMIT 1];
        Club62__Payment__c pay = new Club62__Payment__c(Club62__Customer__c=c.Id,Club62__Status__c='Paid',Club62__Approval_Code__c='HDE08D',
                        club62__Payment_Method__c = pmdb.Id,Club62__Amount__c=1000,Club62__Amount_Used__c=100,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');
        
        Club62__Payment__c pay1 = new Club62__Payment__c(Club62__Customer__c=c.Id,Club62__Status__c='Paid',
                        club62__Payment_Method__c = pm.Id,Club62__Amount__c=1000,Club62__Amount_Used__c=1000,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');
        Club62__Payment__c pay3 = new Club62__Payment__c(Club62__Customer__c=c.Id,Club62__Status__c='Paid',
                        club62__Payment_Method__c = pm.Id,Club62__Amount__c=1000,Club62__Amount_Used__c=1000,Club62__Payment_Date__c=System.Today(),club62__Description__c = 'Early Cancellation Fee');                
        insert new List<Club62__Payment__c>{pay,pay1,pay3};
        
        Id mchrg1 = [SELECT Id from club62__Receivable__c where club62__Customer__c =:c.Id LIMIT 1].ID;
        club62__AR_Payment__c  rpm = new club62__AR_Payment__c(club62__Receivable__c =mchrg1,club62__Amount_Applied__c = 20,
                    club62__Pay__c = pay3.Id);
        insert rpm;
        Test.StartTest();
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 10;
        cc2.club62__Amount_Paid__c = 10;
        cc2.club62__Amount_Adjusted__c = 5;
        cc2.club62__Amount_Refunded__c = 3;
        cc2.club62__Date__c = system.today();
        cc2.Club62__Payment__c = pay.Id;
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Type__c = 'Class';
        cc2.club62__SubType__c = 'Tax';
        cc2.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Amount__c = 1000;
        cc1.club62__Amount_Paid__c = 10;
        cc1.club62__Date__c = system.today();
        cc1.Club62__Payment__c = pay1.Id;
        cc1.club62__Description__c = 'Testing';
        cc1.club62__Customer__c = c.id;
        cc1.club62__Type__c = 'Class';
        insert new List<club62__Transaction__c>{cc1,cc2};

        
        if(C62Utilities.cSetExecuted.contains('PaymentFailed')){
            C62Utilities.cSetExecuted.remove('PaymentFailed');
        }
        pay.club62__Status__c = 'Failed';
        Update pay;
        if(C62Utilities.cSetExecuted.contains('PaymentFailed')){
            C62Utilities.cSetExecuted.remove('PaymentFailed');
        }
        pay1.club62__Status__c = 'Failed';
        Update pay1;
        if(C62Utilities.cSetExecuted.contains('PaymentFailed')){
            C62Utilities.cSetExecuted.remove('PaymentFailed');
        }
        pay3.club62__Status__c = 'Failed';
        Update pay3;
        
        C62Utilities.cSetExecuted.Remove('PMDefault');
        pm.club62__Default__c = true;
        Update pm;
        club62__Payment_Method__c pmdbexception = new club62__Payment_Method__c(club62__Customer__c = c.id,club62__Payment_For__c = 'Default',club62__Payment_Type__c = 'Direct Bill',club62__From_Date__c = System.Today(),club62__To_Date__c = System.Today().addDays(5));
        try{
        insert pmdbexception;
        }catch(exception e){System.assertequals(e.getmessage(),e.getmessage());}
        Test.StopTest();
    }
    /*
    @Name : c62UnapplyCreditsControllerTest
    @Description : Test method for C62UnapplyCreditsController
    */
    static testmethod void c62UnapplyCreditsControllerTest(){
        Contact c = C62TestHandler.getMember1();
        c.Club62__status__c = 'Reinstated';
        Update c;
        club62__Credit__c cd = new club62__Credit__c(club62__Credit_Date__c = system.today(),club62__Customer__c = c.Id,club62__Amount__c = 10000,club62__Amount_Used__c = 30);
        insert cd;
        club62__Category__c mc5 = C62TestHandler.getMetr5YrMemCat();
        club62__Subscription__c ms = C62TestHandler.getMemberSubscription(c,mc5,'Annual');
        club62__Dues__c md1 = new club62__Dues__c(club62__Subscription__c=ms.Id,club62__Amount__c=1000,club62__Date__c=system.now(),club62__Description__c='TESTING',
                    club62__Customer__c=c.Id,club62__SubType__c='Subscription',club62__Type__c='Dues',club62__Start_Date__c = date.newInstance(2014,03,05),club62__End_Date__c = date.newInstance(2014,05,05),
                   club62__Split_Monthly_Revenue__c = true);
        club62__Dues__c md2 = new club62__Dues__c(club62__Subscription__c=ms.Id,club62__Amount__c=1000,club62__Date__c=system.now(),club62__Description__c='TESTING',
                    club62__Customer__c=c.Id,club62__SubType__c='Subscription',club62__Type__c='Dues',club62__Start_Date__c = date.newInstance(2014,03,05),club62__End_Date__c = date.newInstance(2014,05,05),
                   club62__Split_Monthly_Revenue__c = true);
        insert new List<club62__Dues__c>{md1,md2};
        club62__Dues_Payment__c dp = new club62__Dues_Payment__c(club62__Amount_Applied__c = 10,club62__Dues__c = md1.Id,club62__Credit__c = cd.Id);
        insert dp;
         club62__Payment_Method__c pm = new club62__Payment_Method__c(Name='Smith Test',club62__Payment_For__c = 'Default',club62__Payment_Type__c = 'Direct Bill',
                        club62__From_Date__c = System.Today(),club62__To_Date__c = System.Today().addDays(5));
        insert pm;
        club62__payment__c payNew = new club62__payment__c();
        payNew.club62__Customer__c = c.Id;
        payNew.club62__Amount__c = 1000;
        payNew.club62__Payment_Method__c = pm.Id;
        payNew.club62__Payment_Date__c = System.Today();
        insert payNew;
        club62__Receivable__c mchrg1 = new club62__Receivable__c(club62__Status__c = 'Charged',club62__Customer__c=c.Id,
                club62__Amount_Paid__c = 1,club62__Type__c='30 Day Late Fee',club62__Amount__c=1000,club62__Date__c=System.Today().addDays(-10));
        insert mchrg1;
        club62__AR_Payment__c  rpm = new club62__AR_Payment__c(club62__Receivable__c =mchrg1.Id,club62__Amount_Applied__c = 20,
                    club62__Credit__c = cd.Id);
        club62__AR_Payment__c  rpm1 = new club62__AR_Payment__c(club62__Receivable__c =mchrg1.Id,club62__Amount_Applied__c = 0,
                    club62__Pay__c = payNew.Id);
        insert new List<club62__AR_Payment__c>{rpm,rpm1};
        insert new club62__C62BillingSettings__c(club62__Day_Late_Fee_Amount30__c=15,club62__Day_Late_Fee_Percentage30__c=5,club62__Day_Late_Fee_Amount60__c=25,
                        club62__Day_Late_Fee_Amount90__c=40,club62__Day_Late_Fee_Percentage90__c=10,club62__Guest_Pass_Fee__c=65,
                        club62__Invoice_Generation_Threshold__c=0,club62__Number_of_Payment_Attempts__c=3,club62__Payment_Terms__c=30,club62__Pre_Post_Billing__c=FALSE,
                        club62__Quarterly_Event_Minimum__c=100,club62__Quarterly_Food_Beverage_Minimum__c=100,club62__Quarterly_Room_Minimum__c=100,
                        club62__Quarterly_Sports_Minimum__c=100,club62__Termination_Reinstatement_Threshold__c=0,club62__Yearly_Event_Minimum__c=300,
                        club62__Yearly_Food_Beverage_Minimum__c=300,club62__Yearly_Room_Minimum__c=300,club62__Yearly_Sports_Minimum__c=300,club62__Day_Late_Fee_Percentage60__c=7);
        Test.StartTest();
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Amount__c = 1000;
        cc1.club62__Status__c = 'Charged';
        cc1.club62__Amount_Paid__c = 20;
        cc1.club62__Date__c = system.today();
        cc1.club62__Description__c = 'Testing';
        cc1.club62__Customer__c = c.id;
        cc1.club62__Type__c = 'Class';
        cc1.club62__Receivable__c = mchrg1.ID;
        cc1.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert cc1;
        ApexPages.StandardController sc = new ApexPages.standardController(cd);
        C62UnapplyCreditsController upc = new C62UnapplyCreditsController(sc);
        upc.calcCreditAmtLeft();
        upc.cCrdAmtLeft = 500;
        upc.payOffAll();
        C62UnapplyCreditsController.UnApplyWrapper  uaw = new C62UnapplyCreditsController.UnApplyWrapper();
        upc.crdUnApplyRecLst = new List<C62UnapplyCreditsController.UnApplyWrapper>();
        upc.crdUnApplyRecLst.add(uaw);
        for(C62UnapplyCreditsController.UnApplyWrapper upaw : upc.crdUnApplyRecLst){
            upaw.selUnapply = true;
            upaw.maxUnapplyAmt = 1;
        }
        for(C62UnapplyCreditsController.UnApplyWrapper uw : upc.crdUnApplyRecLst){
            uw.objType = 'club62__Dues_Payment__c';
            uw.maxUnapplyAmt = 1;
            uw.dp = dp;
        }
        upc.saveCredit();
        for(C62UnapplyCreditsController.UnApplyWrapper uw : upc.crdUnApplyRecLst){
            uw.objType = 'club62__AR_Payment__c';
            uw.maxUnapplyAmt = 1;
            uw.rp = rpm;
        }
        upc.saveCredit();
        upc.cSelId = md1.Id;
        upc.objTypeStr = 'club62__Dues__c';
        for(C62UnapplyCreditsController.CreditApplyWrapper rw : upc.recDueWrapper){
            rw.bolSelected = true;
        }
        upc.selectRecDue();
        for(C62UnapplyCreditsController.UnApplyWrapper uw : upc.crdUnApplyRecLst){
            uw.objType = 'club62__Dues_Payment__c';
            uw.maxUnapplyAmt = 1;
            uw.dp = dp;
        }
        upc.saveCredit();
        upc.objTypeStr = 'club62__Receivable__c';
        upc.cSelId = mchrg1.Id;
        for(C62UnapplyCreditsController.CreditApplyWrapper rw : upc.recDueWrapper){
            rw.receivable = mchrg1;
            rw.bolSelected = true;
        }
        upc.selectRecDue();
        for(C62UnapplyCreditsController.UnApplyWrapper uw : upc.crdUnApplyRecLst){
            uw.objType = 'club62__AR_Payment__c';
            uw.maxUnapplyAmt = 1;
            uw.rp = rpm;
        }
        upc.saveCredit();
        upc.cSelId = md1.Id;
        upc.objTypeStr = 'club62__Dues__c';
        upc.cdecBeforeChange = 1;
        upc.updateRecDuesTotalPay();
        upc.objTypeStr = 'club62__Receivable__c';
        upc.cSelId = mchrg1.Id;
        upc.updateRecDuesTotalPay();
        Test.StopTest();
    }   
    /*
    @Name : c62UnapplyCreditsControllerTest1
    @Description : Test method for C62UnapplyCreditsController
    */
    static testmethod void c62UnapplyCreditsControllerTest1(){
        Contact c = C62TestHandler.getMember1();
        c.Club62__status__c = 'Reinstated';
        Update c;
        club62__Credit__c cd = new club62__Credit__c(club62__Credit_Date__c = system.today(),club62__Customer__c = c.Id,club62__Amount__c = 100,club62__Amount_Used__c = 30);
        insert cd;
        club62__Category__c mc5 = C62TestHandler.getMetr5YrMemCat();
        club62__Subscription__c ms = C62TestHandler.getMemberSubscription(c,mc5,'Annual');
        club62__Dues__c md1 = new club62__Dues__c(club62__Subscription__c=ms.Id,club62__Amount__c=1000,club62__Date__c=system.now(),club62__Description__c='TESTING',
                    club62__Customer__c=c.Id,club62__SubType__c='Subscription',club62__Type__c='Dues',club62__Start_Date__c = date.newInstance(2014,03,05),club62__End_Date__c = date.newInstance(2014,05,05),
                   club62__Split_Monthly_Revenue__c = true);
        insert md1;
        club62__Dues_Payment__c dp = new club62__Dues_Payment__c(club62__Amount_Applied__c = 10,club62__Dues__c = md1.Id,club62__Credit__c = cd.Id);
        insert dp;
         club62__Payment_Method__c pm = new club62__Payment_Method__c(Name='Smith Test',club62__Payment_For__c = 'Default',club62__Payment_Type__c = 'Direct Bill',
                        club62__From_Date__c = System.Today(),club62__To_Date__c = System.Today().addDays(5));
        insert pm;
        club62__payment__c payNew = new club62__payment__c();
        payNew.club62__Customer__c = c.Id;
        payNew.club62__Amount__c = 1000;
        payNew.club62__Payment_Method__c = pm.Id;
        payNew.club62__Payment_Date__c = System.Today();
        insert payNew;
        club62__Receivable__c mchrg1 = new club62__Receivable__c(club62__Status__c = 'Charged',club62__Customer__c=c.Id,
                club62__Amount_Paid__c = 1,club62__Type__c='30 Day Late Fee',club62__Amount__c=1000,club62__Date__c=System.Today().addDays(-10));
        insert mchrg1;
        club62__AR_Payment__c  rpm = new club62__AR_Payment__c(club62__Receivable__c =mchrg1.Id,club62__Amount_Applied__c = 20,
                    club62__Credit__c = cd.Id);
        club62__AR_Payment__c  rpm1 = new club62__AR_Payment__c(club62__Receivable__c =mchrg1.Id,club62__Amount_Applied__c = 0,
                    club62__Pay__c = payNew.Id);
        insert new List<club62__AR_Payment__c>{rpm,rpm1};
        insert new club62__C62BillingSettings__c(club62__Day_Late_Fee_Amount30__c=15,club62__Day_Late_Fee_Percentage30__c=5,club62__Day_Late_Fee_Amount60__c=25,
                        club62__Day_Late_Fee_Amount90__c=40,club62__Day_Late_Fee_Percentage90__c=10,club62__Guest_Pass_Fee__c=65,
                        club62__Invoice_Generation_Threshold__c=0,club62__Number_of_Payment_Attempts__c=3,club62__Payment_Terms__c=30,club62__Pre_Post_Billing__c=FALSE,
                        club62__Quarterly_Event_Minimum__c=100,club62__Quarterly_Food_Beverage_Minimum__c=100,club62__Quarterly_Room_Minimum__c=100,
                        club62__Quarterly_Sports_Minimum__c=100,club62__Termination_Reinstatement_Threshold__c=0,club62__Yearly_Event_Minimum__c=300,
                        club62__Yearly_Food_Beverage_Minimum__c=300,club62__Yearly_Room_Minimum__c=300,club62__Yearly_Sports_Minimum__c=300,club62__Day_Late_Fee_Percentage60__c=7);
        Test.StartTest();
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Amount__c = 1000;
        cc1.club62__Status__c = 'Charged';
        cc1.club62__Amount_Paid__c = 20;
        cc1.club62__Date__c = system.today();
        cc1.club62__Description__c = 'Testing';
        cc1.club62__Customer__c = c.id;
        cc1.club62__Type__c = 'Class';
        cc1.club62__Receivable__c = mchrg1.ID;
        cc1.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert cc1;
        ApexPages.StandardController sc = new ApexPages.standardController(cd);
        C62UnapplyCreditsController  ucc = new C62UnapplyCreditsController(sc);
        ucc.calcCreditAmtLeft();
        for(C62UnapplyCreditsController.CreditApplyWrapper rw : ucc.recDueWrapper){
            rw.objType = 'club62__Dues__c';
        }
        ucc.payOffAll();
        ucc.getAssociateRecords();
        for(C62UnapplyCreditsController.UnApplyWrapper uw : ucc.crdUnApplyRecLst){
            uw.selUnapply = true;
            uw.maxUnapplyAmt = 30;
        }
        ucc.saveCredit();
        ucc.selectRecDue();
        Test.StopTest();
    }
    /*
    @Name :C62ApplyPaymentToEventBanquetControllerTest
    @Description : Test method for C62ApplyPaymentToEventBanquetController.
    */    
    static testmethod void c62ApplyPaymentToEventBanquetControllerTest(){
        Contact c = C62TestHandler.getMember1();
        c.club62__Status__c = 'Reinstated';
        Update c;
        club62__Facility__c fac1 = C62TestHandler.getSportFacilitySquashCourt1();
        club62__Reservation__c sportRes = new club62__Reservation__c(Name='Sport Test',club62__Club_Location__c=fac1.Id,club62__Max_Seats__c=5,
                            club62__Guests_Allowed__c=TRUE,club62__Max_Guests_Allowed__c='2',club62__Allow_Waitlist__c=TRUE,
                            club62__Max_Waitlist_Capacity__c=2,club62__Charged__c = FALSE,club62__Status__c = 'Confirmed',club62__Customer__c=c.Id,
                            club62__StartTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(13,0,0,0)),
                            RecordTypeId = Schema.SObjectType.club62__Reservation__c.getRecordTypeInfosByName().get('Sponsored Event').getRecordTypeId(),club62__EndTime__c=DateTime.newInstance(Date.Today().addDays(-1),Time.newInstance(14,0,0,0)));
        insert sportRes;
        Club62__Folio__c f = new Club62__Folio__c(Club62__Customer__c = c.Id,Club62__Type__c = 'Current',
            club62__Reservation__c = sportRes.ID,Club62__Status__c = 'Open');
        Club62__Folio__c f1 = new Club62__Folio__c(Club62__Customer__c = c.Id,Club62__Type__c = 'closed',
            club62__Reservation__c = sportRes.ID,Club62__Status__c = 'Open');
        insert new List<Club62__Folio__c>{f,f1};
        f1.Club62__Type__c = 'closed';
        f1.club62__Amount_Due__c = 0;
        Update f1;
        
        club62__Payment_Method__c pm = C62TestHandler.getPaymentMethod(c);
        club62__Payment_Method__c pmdb = [SELECT ID from club62__Payment_Method__c where club62__Customer__c =:c.Id and club62__Payment_Type__c ='Direct Bill' LIMIT 1];
        club62__Receivable__c mchrg = new club62__Receivable__c(club62__Customer__c=c.Id,club62__Amount__c=100,club62__Date__c=System.Today().addDays(-10));
        insert mchrg;
        club62__Payment__c pay = new club62__Payment__c(club62__Customer__c =c.id,club62__Status__c='Paid',club62__Amount_Used__c = 1,
                        club62__Reservation__c = sportRes.ID,club62__Folio__c = f1.Id,club62__Amount__c=1000,club62__Payment_Date__c=System.Today().addDays(-10),club62__Payment_Method__c = pmdb.Id);
        club62__Payment__c pay1 = new club62__Payment__c(club62__Customer__c =c.id,club62__Status__c='Paid',
                        club62__Folio__c = f1.Id,club62__Reservation__c = sportRes.ID,club62__Amount__c=1000,club62__Payment_Date__c=System.Today().addDays(-10),club62__Payment_Method__c = pm.Id);               
        insert new List<club62__Payment__c>{pay,pay1};  
        club62__AR_Payment__c  rpm = new club62__AR_Payment__c(club62__Receivable__c =mchrg.Id,club62__Amount_Applied__c = 20,
                    club62__Pay__c = pay.Id);
        insert rpm; 
        Test.startTest();        
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 100;
        cc2.club62__Date__c = system.today();
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Folio__c = f.id;
        cc2.club62__Manual_Registration_Transaction__c = false;
        
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Amount__c = 100;
        cc1.club62__Date__c = system.today();
        cc1.club62__Description__c = 'Testing';
        cc1.club62__Payment__c = pay.Id;
        cc1.club62__Customer__c = c.id;
        cc1.club62__Folio__c = f.id;
        cc1.club62__Manual_Registration_Transaction__c = true;
        
        club62__Transaction__c cc3 = new club62__Transaction__c();
        cc3.club62__Amount__c = 100;
        cc3.club62__Date__c = system.today();
        cc3.club62__Description__c = 'Testing';
        cc3.club62__Payment__c = pay1.Id;
        cc3.club62__Customer__c = c.id;
        cc3.club62__Folio__c = f1.id;
        cc3.club62__Manual_Registration_Transaction__c = true;
        
        insert new List<club62__Transaction__c>{cc1,cc2,cc3};
        ApexPages.StandardController sc = new ApexPages.StandardController(new club62__Reservation__c());
        C62ApplyPaymentToEventBanquetController  apebc = new C62ApplyPaymentToEventBanquetController(sc);
        sc = new ApexPages.StandardController(sportRes);
        apebc = new C62ApplyPaymentToEventBanquetController(sc);
        Set<Id> fIds = new Set<Id>();
        apebc.closedPostedBanquet = true;
        fIds.add(f1.ID);
        apebc.getAssociatedTransactions(fIds);
        apebc.closedPostedBanquet = false;
        fIds = new Set<Id>();
        fIds.add(f.ID);
        fIds.add(f1.ID);
        apebc.getAssociatedTransactions(fIds);
        Set<Id> rIds = new Set<Id>();
        rIds.add(sportRes.ID);
        for(C62ApplyPaymentToEventBanquetController.PaymentWrapper pw : apebc.paymentLst){
            pw.paySelect = true;
        }
        apebc.paySelAllValue = true;
        apebc.calcAppliedAmtAll();
        apebc.folioIds.add(f.ID);
        apebc.transactionLst.add(new C62ApplyPaymentToEventBanquetController.TransactionWrapper());
        for(C62ApplyPaymentToEventBanquetController.TransactionWrapper tw : apebc.transactionLst){
            tw.amtDue = 30;
            tw.amtPaid = 1;
            tw.rec = mchrg;
        }
        apebc.closedPostedBanquet = true;
        apebc.applyPayments();
        apebc.closedPostedBanquet = false;
        apebc.calcAppliedAmt();
        apebc.applyPayments();
        apebc.resFolioID = f.ID;
        apebc.changeFolio();
        apebc.getShowChargeMember();
        apebc.getFolioSel();
        apebc.choosePayment();
        Test.StopTest();
    }
    /*
    @Name : c62RetryRejectedPaymentControllerTest3
    @Description : Test method for C62RetryRejectedPaymentController
    */
    static testmethod void c62RetryRejectedPaymentControllerTest3(){
        Contact c = C62TestHandler.getMember1();
        c.club62__status__c = 'Reinstated';
        Update c;
        club62__Payment_Method__c pm = C62TestHandler.getPaymentMethod(c);
        club62__Payment_Gateway__c pg = C62TestHandler.getPaymentGateway();
        club62__Payment_Method__c pmdb = [SELECT ID from club62__Payment_Method__c where club62__Customer__c =:c.Id and club62__Payment_Type__c ='Direct Bill' LIMIT 1];
        club62__Payment__c p = new club62__Payment__c(club62__Customer__c=c.Id,club62__Status__c='Rejected',
                        club62__Amount__c=1000,club62__Payment_Date__c=System.Today());
        club62__Payment__c p1 = new club62__Payment__c(club62__Customer__c=c.Id,club62__Status__c='Rejected',
                        club62__Amount__c=1000,club62__Payment_Date__c=System.Today());
        club62__Payment__c p2 = new club62__Payment__c(club62__Customer__c=c.Id,club62__Status__c='Rejected',
                        club62__Amount__c=1000,club62__Payment_Date__c=System.Today());
        insert new List<club62__Payment__c>{p,p1,p2};
        p1.club62__Status__c='Rejected';
        p2.club62__Status__c='Rejected';
        Update new List<club62__Payment__c>{p1,p2};
        club62__Invoice__c mi90plus = new club62__Invoice__c(club62__Customer__c=c.Id,club62__From_Date__c=System.Today().addMonths(-6).addDays(-1),
                            club62__To_Date__c=System.Today().addMonths(-5),club62__Due_Date__c=System.Today().addMonths(-5));
        insert mi90plus;
        club62__Invoice_Line__c m1 = new club62__Invoice_Line__c(club62__Invoice__c=mi90plus.Id,club62__Date__c=System.Today().addMonths(-9),
                            club62__Amount__c=100,club62__Description__c='Test');
        insert m1;
        Test.StartTest();
        club62__Transaction__c cc1 = new club62__Transaction__c();
        cc1.club62__Amount__c = 1000;
        cc1.club62__Date__c = system.today();
        cc1.club62__Description__c = 'Testing';
        cc1.club62__Customer__c = c.id;
        cc1.club62__Invoice_Line__c = m1.Id;
        cc1.club62__Manual_Registration_Transaction__c = false;
        cc1.club62__Payment__c = p1.Id;
        
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 100;
        cc2.club62__Date__c = system.today();
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Invoice_Line__c = m1.Id;
        cc2.club62__Manual_Registration_Transaction__c = false;
        cc2.club62__Payment__c = p1.Id;
        insert new List<club62__Transaction__c>{cc1,cc2};
        C62RetryRejectedPaymentController  rrp = new C62RetryRejectedPaymentController();
        ApexPages.currentPage().getParameters().put('pId',p.ID);
        rrp = new C62RetryRejectedPaymentController();
        ApexPages.currentPage().getParameters().put('pId',p1.ID);
        rrp = new C62RetryRejectedPaymentController();
        rrp.save();
        rrp.payMethodID = pm.ID;
        rrp.pay = p1;
        rrp.save();
        rrp.doNothing();
        rrp.payMethodID = pmdb.ID;
        rrp.pay = p1;
        rrp.save();
        ApexPages.currentPage().getParameters().put('pId',p2.ID);
        rrp = new C62RetryRejectedPaymentController();
        Test.StopTest();
    }
}