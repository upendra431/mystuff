/*
@Name           : C62AlertControllerTest
@Author         : customersuccess@cloud62.com
@Date           : November 07, 2014
@Description    : Test methods for C62AlertController,
*/
@IsTest
public class C62AlertControllerTest{
    @IsTest
    //This test method is for C62AlertController
    public static void theTest1(){
        Contact con = new contact(FirstName='Cloud62',Email = 'abc@mail.com',lastname = 'Jones', Birthdate = system.today());
        Contact con1 = new contact(FirstName='Cloud62',Email = 'abc@mail.com',club62__Master_Duplicate_Person__c = null,club62__Master_Duplicate_Customer__c = null,club62__Possible_Duplicate_Override__c = false,lastname = 'Jones', Birthdate = system.today());
        Contact con2 = new contact(FirstName='Elizabeth',Email = 'club62tests@cloud62.com',club62__Master_Duplicate_Person__c = null,club62__Master_Duplicate_Customer__c = null,club62__Possible_Duplicate_Override__c = false,lastname = 'Wood', Birthdate = system.today());
        List<Contact> conLst = new List<Contact>{con,con1,con2};
        insert conLst;
        con1.club62__Master_Duplicate_Customer__c = null;
        con2.club62__Master_Duplicate_Person__c = null;
        con2.club62__Master_Duplicate_Customer__c = null;
        Update new List<Contact>{con1,con2};
        club62__Person__c p = new club62__Person__c(Name='Elizabeth Wood',club62__Salutation__c='Ms.',club62__First_Name__c='Elizabeth',club62__Last_Name__c='Wood',
                        club62__Gender__c='Female',club62__Status__c='Pending',club62__Reason__c='Looking for More Information',
                        club62__Home_Phone__c='(716)-555-4108',club62__Email__c='club62tests@cloud62.com',
                        club62__Birthdate__c=date.newinstance(1970,10,10));
        club62__Person__c p1 = new club62__Person__c(Name='Elizabeth',club62__Salutation__c='Ms.',club62__First_Name__c='Elizabeth',club62__Last_Name__c='Wood',
                        club62__Gender__c='Female',club62__Status__c='Pending',club62__Reason__c='Looking for More Information new',
                        club62__Possible_Duplicate_Override__c = false,club62__Home_Phone__c='(716)-555-4109',club62__Email__c='club62tests@cloud62.com',
                        club62__Birthdate__c=date.newinstance(1970,10,12));
        List<club62__Person__c> plist = new List<club62__Person__c>{p,p1};
        insert plist;
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c(club62__Room_Category__c=rc.Id, club62__To__C = system.today(), club62__From__c = system.today());
        insert rr;
        club62__Alert__c a1 = new club62__Alert__c(club62__Suppress__c = true,club62__Person__c = p.Id,club62__Customer__c = con.Id,club62__Message__c = 'New Alert Area',club62__Last_Alerted_Time__c = system.now(),club62__Room_Reservation__c = rr.Id);
        club62__Alert__c a2 = new club62__Alert__c(club62__Suppress__c = true,club62__Person__c = p.Id,club62__Customer__c = con.Id,club62__Message__c = 'New Alert Area',club62__Last_Alerted_Time__c = system.now(),club62__Room_Reservation__c = rr.Id);
        insert new List<club62__Alert__c>{a1,a2};
        apexpages.currentPage().getParameters().put('id', rr.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        C62AlertController arc = new C62AlertController();
        arc.alertObjectID = rr.Id;
        //To call init method and get Alert Object Data 
        arc.Init();
        arc.alertObjectID = con.Id;
        arc.Init();
        Test.StartTest();
        system.assertEquals(0,arc.thisAlertList.size());
        arc.thisAlertList = new List<club62__Alert__c>();
        arc.thisAlertList.add(a1);
        arc.getNextAlert();
        arc.secondObject = rr.Id;
        arc.init(); 
        arc.thisAlertList = new List<club62__Alert__c>();
        arc.thisAlertList.add(a1);
        arc.alertPosition = 0;
        arc.getCloseIt();
        arc.alertObjectID = p.Id;
        arc = new C62AlertController();
        club62__Payment_Gateway__c pg3 = new club62__Payment_Gateway__c(Name='PayFlow',club62__Default__c=FALSE,
                club62__Login_Encrypted__c='AaKc4RB5-ju6MePTXQ_b5tE6FpzmjncmHI4CmCi-_g7YNqbJ99JPOwA5Kpy-',
                club62__Password_Encrypted__c='EIvRtRDGyh-igF7Inww3yqcJf0MzAAuhlYJ0-d1MufQUUrwO1H-ZOF-meXWM',
                club62__Production_URL__c='https://api.paypal.com',club62__Test_URL__c='https://api.sandbox.paypal.com');
        insert pg3;
        pg3.name = 'PayFlow1';
        pg3.club62__Default__c = true;
        Update pg3;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        rr.club62__Rate__c = 50;
        Update rr;
        C62DupeMerge.Row dmr = new C62DupeMerge.Row();
        dmr.difference = true;
        dmr.getStyle();
        club62__Payment_Method__c pm = new club62__Payment_Method__c(club62__Card_Holder_Name__c = 'Smith',club62__Payment_For__c = 'Default',club62__Payment_Type__c = 'ACH/echeck',
                club62__Account_Type__c = 'Checking',club62__Account_Holder_Type__c = 'Personal',club62__Routing_Number__c = '36254789',club62__Account_Number__c = '3625487',club62__From_Date__c = System.Today(),club62__To_Date__c = System.Today().addDays(5));
        insert pm;
        C62PayGateEVOModel  pgevm = new C62PayGateEVOModel('','','');
        pgevm.doAuthorize(20,pm);
        pgevm.doSale(50,pm);
        pgevm.doValidate(pm);
        C62Dedupe.findDuplicate(con,true);
        new C62Dedupe.PossibleDuplicate(con);
        new C62Dedupe.PossibleDuplicate(p);
        C62PersonDupeCheckHandler.firstRun = true;
        p.Name = 'Elizabeth';
        Update p;
        C62Utilities.cSetExecuted.remove('avoidCheckHandler');
        C62MemberDupeCheckHandler.firstRun = true;
        con.Birthdate = system.today().adddays(-365);
        Update con;
        Test.StopTest();
    }
    /*
    @Name : C62RecurringJournalEntryControllerTest
    @Description : Test method for C62RecurringJournalEntryController.
    */
    static testmethod void C62RecurringJournalEntryControllerTest(){
        Contact con = new contact(lastname = 'Jones', Birthdate = system.today());
        insert con;
        club62__Person__c p = C62TestHandler.getElizabethInvPerson();
        club62__Room_Category__c rc = C62TestHandler.getSuiteRoomCategory();
        club62__Room_Reservation__c rr = new club62__Room_Reservation__c(club62__Status__c='Checked Out',club62__Room_Category__c=rc.Id,club62__Check_Out_Date__c = System.today(), club62__To__C = system.today(),club62__From__c = system.today().addDays(-3));
        insert rr;
        club62__Payment_Gateway__c pg3 = new club62__Payment_Gateway__c(Name='PayFlow',club62__Default__c=FALSE,
                club62__Login_Encrypted__c='AaKc4RB5-ju6MePTXQ_b5tE6FpzmjncmHI4CmCi-_g7YNqbJ99JPOwA5Kpy-',
                club62__Password_Encrypted__c='EIvRtRDGyh-igF7Inww3yqcJf0MzAAuhlYJ0-d1MufQUUrwO1H-ZOF-meXWM',
                club62__Production_URL__c='https://api.paypal.com',club62__Test_URL__c='https://api.sandbox.paypal.com');
        insert pg3;
        pg3.name = 'PayFlow1';
        pg3.club62__Default__c = true;
        Update pg3;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        System.AssertEquals('Checked Out',[SELECT club62__Status__c from club62__Room_Reservation__c where Id =: rr.Id][0].club62__Status__c);
        rr.club62__To__C =  System.today().AddDays(5);
        rr.club62__Rate__c = 50;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        Update rr;
        Test.StartTest();
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        rr.club62__To__C =  System.today().AddDays(6);
        rr.club62__Status__c = 'Checked In';
        Update rr;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        rr.club62__To__C =  System.today().AddDays(7);
        rr.club62__Status__c = 'Cancelled';
        rr.club62__Cancellation_Reason__c = 'Changed Reservation';
        Update rr;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        rr.club62__Status__c = 'Checked In';
        Update rr;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        rr.club62__To__C =  System.today().AddDays(8);
        rr.club62__Status__c = 'Checked Out';
        Update rr;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        rr.club62__Status__c = 'Checked In';
        Update rr;
        C62Utilities.cSetExecuted.remove('RoomReservationRoomStats');
        Delete rr;
        new C62PurchaseOrderController.GLLine();
        Date dt = System.Today();
        C62Utilities.getTime(dt,'12AM'); 
        C62Utilities.getTime(dt,'12PM'); 
        C62Utilities.getTime(dt,'11AM'); 
        C62Utilities.getTime(dt,'11PM');
        Financial_Journal_Line__c  conn = new Financial_Journal_Line__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(conn);
        new C62RecurringJournalEntryController(sc);
        Test.StopTest();
    }
    /*
    @Name : C62ActivitySheetControllerTest
    @Description : Test method for C62ActivitySheetController
    */
    static testmethod void C62ActivitySheetControllerTest(){
        club62__Location__c l = new club62__Location__c(Name = 'New');
        insert l;
        club62__Financial_Account__c fa = new club62__Financial_Account__c(club62__A_P_Trade__c=true,Name='Test',club62__Account_Number__c='asd32sd',club62__Balance_Sheet_Type__c='Current Assets',
                club62__Location__c = l.Id,club62__Balance_Sheet_Sub_Type__c='Accounts Receivables',club62__Category__c='Assets',club62__Type__c='Food',
                club62__Statement_of_Activities_Type__c='Operating Expenses',club62__Statement_of_Activities_Sub_Type__c='Food');
        insert fa;
        club62__Financial_Journal_Entry__c fje1 = new club62__Financial_Journal_Entry__c(club62__Posted__c = true,club62__Manual_Entry__c=true,
            club62__Recurring_Entry_Name__c = 'Another Name',club62__Recurring_Entry__c=true,club62__Entry_Date__c = System.Today());
        insert fje1;
        club62__Financial_Journal_Entry__c fje = new club62__Financial_Journal_Entry__c(club62__Posted__c = true,club62__Manual_Entry__c=true,
            club62__Recurring_Entry_Name__c = 'New Name',club62__Recurring_Entry__c=true,club62__Entry_Date__c = System.Today());
        insert fje;
        club62__Financial_Journal_Line__c fjl = new club62__Financial_Journal_Line__c();
        fjl.club62__Amount__c = 10.00;
        fjl.club62__Description__c = 'New Line';
        fjl.club62__Financial_Journal_Entry__c = fje.Id;
        fjl.club62__Transaction_Date__c = System.today();
        fjl.club62__Financial_Account__c = fa.Id;
        fjl.club62__Income_Journal__c = true;
        fjl.club62__Posted__c =false;
        fjl.club62__Manual_Journal__c =true;
        insert fjl;
        Test.StartTest();
        Contact c = C62TestHandler.getMember1();
        ApexPages.StandardController sc = new ApexPages.StandardController(fjl);
        C62RecurringJournalEntryController rjec = new C62RecurringJournalEntryController(sc);
        rjec.locationSelection = fa;
        rjec.loadEntries();
        rjec.cSelId = fje.Id;
        rjec.doNothing();
        rjec.setSelFJE();
        rjec.cSelDelId = fje.Id;
        try{
        rjec.delSelFJE();
        }catch(exception e){}
        Apexpages.currentPage().getParameters().put('fjeId',fje.Id);
        Apexpages.currentPage().getParameters().put('fjlId',fjl.Id);
        try{
        rjec.delFJL();
        }catch(exception e){}
        rjec.saveDeleteEntry();
        rjec.closeSelectedME();
        rjec.manEntry = new C62RecurringJournalEntryController.ManualEntry(fje1,0);
        rjec.manEntry.fje.club62__Recurring_Entry_Name__c = 'fje1';
        rjec.manEntry.addJournalLine();
        rjec.manEntry.addJournalLine(0);
        rjec.manEntry.getJournalList();
        rjec.manEntry.compareTo(rjec.manEntry);
        for(C62RecurringJournalEntryController.ManualJournalLine mjl : rjec.manEntry.mjlList.values()){
            mjl.FAAccount = fa.Id;
            mjl.fjl = fjl;
            mjl.debit = '10';
            mjl.credit = '20';    
        }
        rjec.addNewEntry();
        rjec.cObjIndex = '0';
        rjec.cObjIsInsert = true;
        rjec.cObjLabel = fa.Id;
        rjec.setLstChooseFA();
        rjec.getmanualEntries();
        rjec.selectedME = new C62RecurringJournalEntryController.ManualEntry(fje1,0);
        C62RecurringJournalEntryController.ManualJournalLine  mjli = new C62RecurringJournalEntryController.ManualJournalLine(0);
        rjec.selectedME.mjlList = new Map<Integer,C62RecurringJournalEntryController.ManualJournalLine>();
        rjec.selectedME.mjlList.put(0,mjli);
        rjec.numberLinesToAdd = 0;
        rjec.addNewEntryLines();
        rjec.addNewExistingLines();
        for(C62RecurringJournalEntryController.ManualJournalLine mjl : rjec.selectedME.mjlList.values()){
            mjl.FAAccount = fa.Id;
            mjl.fjl.club62__Description__c = 'hst';
            mjl.credit = '30';
            mjl.debit = '30';
            mjl.fjl.club62__Financial_Account__c = fa.Id;
        }
        rjec.updateEntry();
        rjec.calDebCredTotal();
        rjec.closedMonthWarning = '';
        rjec.searchDateOS = new club62__Transaction__c();
        rjec.searchDateOE = new club62__Transaction__c();
        rjec.searchDateS = system.today();
        rjec.searchDateE = system.today();
        rjec.resId = '';
        rjec.res = new club62__Reservation__c();
        rjec.transactionTotal = 10;
        rjec.paymentTotal = 10;
        rjec.foodCost = 10;
        rjec.barCost = 10;
        rjec.bevCost = 10;
        rjec.writeOffAmount = 10;
        rjec.selectedWriteOffAmount = 10;
        rjec.transMap = new Map<id,C62RecurringJournalEntryController.TransactionWrapper>();
        rjec.existingEntrySameName = true;
        rjec.fiscalStartMonth = 5;
        C62RecurringJournalEntryController.TransactionWrapper tw = new C62RecurringJournalEntryController.TransactionWrapper(new club62__Transaction__c());
        tw.selected = true;
        tw.selectedAmount = 30;
        club62__Invoice__c mi = C62TestHandler.getMemberInvoice(c);
        club62__Payment__c p = C62TestHandler.getPayment(c,mi);
        club62__Transaction__c cc2 = new club62__Transaction__c();
        cc2.club62__Amount__c = 10;
        cc2.club62__Date__c = system.today();
        cc2.club62__Description__c = 'Testing';
        cc2.club62__Customer__c = c.id;
        cc2.club62__Type__c = 'Class';
        cc2.club62__SubType__c = 'Tax';
        cc2.club62__Payment__c = p.Id;
        cc2.club62__House_Financial_Journal_Line__c = fjl.Id;
        cc2.club62__Batch_Or_Inactive_Member_Transaction__c = true;
        insert cc2;
        C62RecurringJournalEntryController.getFinancialAccounts('Test',l.Id);
        C62RecurringJournalEntryController.TransactionWrapper rje = new C62RecurringJournalEntryController.TransactionWrapper(cc2);
        rje.compareTo(rje);
        List<club62__Payment__c> pLst = new List<club62__Payment__c>{p};
        C62PaymentGatewayHandler.updatePayGatewaysFromILP(pLst);
        /*Depricated*/
        C62TestHandler  th = new C62TestHandler();
        try{
        Delete fa;
        }catch(exception e){
            System.assertEquals(e.getmessage(),e.getmessage());
        }
        club62__Room_Rate_Exception__c  rrex = new club62__Room_Rate_Exception__c(club62__Start_Date__c = system.today(),club62__End_Date__c = system.today().addDays(1),
                                                   club62__Active__c = true,club62__Guest_Price__c = 15,club62__Member_Price__c = 15,club62__Reciprocal_Price__c = 15);
        club62__Room_Rate_Exception__c  rrex1 = new club62__Room_Rate_Exception__c(club62__Start_Date__c = system.today(),club62__End_Date__c = system.today().addDays(1),
                                                   club62__From_Occupancy__c = 1,club62__To_Occupancy__c = 1,club62__Active__c = true,club62__Guest_Price__c = 15,club62__Member_Price__c = 15,club62__Reciprocal_Price__c = 15);
        insert new List<club62__Room_Rate_Exception__c>{rrex,rrex1};
        rrex.club62__Guest_Price__c = 30;
        rrex1.club62__Guest_Price__c = 30;
        try{
            Update new List<club62__Room_Rate_Exception__c>{rrex,rrex1};
        }catch(exception e){system.assertEquals(e.getMessage(),e.getmessage());}
        rrex.club62__Start_Date__c = system.today().addDays(-1);
        try{
            Update new List<club62__Room_Rate_Exception__c>{rrex,rrex1};
        }catch(exception e){system.assertEquals(e.getMessage(),e.getmessage());}
        rrex.club62__Start_Date__c = system.today();
        rrex.club62__End_Date__c  = system.today().addDays(-1);
        try{
            Update new List<club62__Room_Rate_Exception__c>{rrex,rrex1};
        }catch(exception e){system.assertEquals(e.getMessage(),e.getmessage());}
        
        rrex.club62__Start_Date__c = system.today().addDays(-1);
        rrex.club62__End_Date__c  = system.today();
        try{
            Update new List<club62__Room_Rate_Exception__c>{rrex,rrex1};
        }catch(exception e){system.assertEquals(e.getMessage(),e.getmessage());}
        th.testCoverage();
        ApexPages.StandardController scr = new ApexPages.standardController(new Financial_Summary__c());
        C62ActivitySheetController ascr = new C62ActivitySheetController(scr);
        C62AlertRedirectController arc = new C62AlertRedirectController();
        Test.Stoptest();    
    }
}