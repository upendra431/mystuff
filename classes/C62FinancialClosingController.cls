/*
@Name            : C62FinancialClosingController
@Author          : customersuccess@cloud62.com
@Date            : February 26, 2014
@Description     : Controller for FinancialClosing visualforce page
*/
public with sharing class C62FinancialClosingController {
    public Map<String, FinancialClosingWrapper> fcwMap{get;set;}
    public String selectedClosing{get;set;}
    public String selectedClosingYear{get;set;}
    public Boolean batchRunning{get;set;}
    public Integer fiscalStartMonth {get;set;}
    public C62FinancialClosingController(ApexPages.StandardController stdController) {
        regenerateMap();
        batchRunning = checkBatchRunning();
        fiscalStartMonth = [Select FiscalYearStartMonth from Organization limit 1].FiscalYearStartMonth;
    }

    //return list of fc for pageBlockTable
    public List<FinancialClosingWrapper> getfcwMapVal(){
        List<FinancialClosingWrapper> retList = fcwMap.values();
        retList.sort();
        return retList;
    }
    //When we close a year we need to run the closing batch to generate the EOY Entry
    public PageReference yearClosing(){
        regenerateMap();
        if(fcwMap.containsKey(selectedClosing)){
            club62__Financial_Closing__c fc = fcwMap.get(selectedClosing).yearClosing;
            Boolean closable = true;
            for(FinancialClosingMonthWrapper fcm : fcwMap.get(selectedClosing).monthClosing.values()){
                if(fcm.fcm.club62__Closed__c==false){
                    closable = false;
                }
            }
            if(closable==true){

                //Calculate CY and LY Closing Balance
                Date sDate = Date.newInstance(Integer.valueOf(fc.club62__Year__c.left(fc.club62__Year__c.indexOf('-'))), fiscalStartMonth, 1);
                Date eDate = sDate.addYears(1).addDays(-1);
                Database.executeBatch(new C62BatchFinancialClosing(sDate,eDate));
                fc.club62__Closed__c = true;
                if(Schema.sObjectType.club62__Financial_Closing__c.isUpdateable()){update fc;}
                batchRunning = checkBatchRunning();
                if(Schema.sObjectType.club62__Financial_Summary__c.isDeletable()){delete [select id from club62__Financial_Summary__c where club62__Date__c=:eDate and club62__Yearly_Summary__c=true];}
                if(batchRunning==false){
                    /*c62BatchGenerateFinancialSummary gfs = new c62BatchGenerateFinancialSummary(sDate,eDate);
                    Database.executeBatch(gfs);*/
                    batchRunning = true;
                }
            }else{
                batchRunning = checkBatchRunning();
            }
        }
        regenerateMap();
        return null;
    }
    //Clears checkbox on yearly summary
    public PageReference reOpenYear(){
        if(fcwMap.containsKey(selectedClosing)){
            club62__Financial_Closing__c fc = fcwMap.get(selectedClosing).yearClosing;
            fc.club62__Closed__c = false;
            if(Schema.sObjectType.club62__Financial_Closing__c.isUpdateable()){update fc;}
        }
        batchRunning = checkBatchRunning();
        regenerateMap();
        return null;
    }
    //Pull all financial closing to populate visualforce page
    public void regenerateMap(){
        fcwMap = new Map<String, FinancialClosingWrapper>();
        List<club62__Financial_Closing__c> fcList = [Select id,club62__Month__c,club62__year_string__c,club62__Year__c,club62__Closed__c,club62__Date_Closed__c,club62__Year_Closing__c from club62__Financial_Closing__c Where Id!=null];
        Map<String,FinancialClosingWrapper> yearsAdded = new Map<String,FinancialClosingWrapper>();
        for(club62__Financial_Closing__c fc : fcList){
            if(fc.club62__Year_Closing__c==true){
                FinancialClosingWrapper fcy;
                if(yearsAdded.containsKey(fc.club62__Year__c)){
                    yearsAdded.get(fc.club62__Year__c).yearClosing = fc;
                }else{
                    fcy = new FinancialClosingWrapper();
                    fcy.yearClosing = fc;
                    yearsAdded.put(fc.club62__Year__c,fcy);
                }
            }else{
                if(yearsAdded.containsKey(fc.club62__Year__c)){
                    yearsAdded.get(fc.club62__Year__c).monthClosing.put(fc.club62__Month__c,new FinancialClosingMonthWrapper(fc));
                }else{
                    FinancialClosingWrapper fcy = new FinancialClosingWrapper();
                    fcy.monthClosing.put(fc.club62__Month__c,new FinancialClosingMonthWrapper(fc));
                    yearsAdded.put(fc.club62__Year__c,fcy);
                }
            }
        }
        for(FinancialClosingWrapper fcy : yearsAdded.values()){
            Boolean closable = true;
            for(FinancialClosingMonthWrapper fc : fcy.monthClosing.values() ){
                if(fc.fcm.club62__Closed__c==false){
                    closable = false;
                    break;
                }
            }
            fcy.closable = closable;
            fcwMap.put(fcy.yearClosing.club62__year__c,fcy);
        }
    }
    //Close the month from button on visualforce page
    public void monthClosing(){
        if(fcwMap.containsKey(selectedClosingYear)){
            if(fcwMap.get(selectedClosingYear).monthClosing.containsKey(selectedClosing)){
                club62__Financial_Closing__c fc = fcwMap.get(selectedClosingYear).monthClosing.get(selectedClosing).fcm;
                fc.club62__Closed__c = true;
                fc.club62__Date_Closed__c = Date.today();
                if(Schema.sObjectType.club62__Financial_Closing__c.isUpdateable()){update fc;}

                batchRunning = checkBatchRunning();
                if(batchRunning==false){
                    database.executeBatch(new c62BatchGenerateFinancialSummary());
                    batchRunning = true;
                }
            }
        }
        regenerateMap();

    }

    //Check if batch is running to gray out button
    public boolean checkBatchRunning(){
        List<ApexClass> apexClassList = [Select Id,Name from ApexClass Where Name in ('C62BatchFinancialClosing','c62BatchGenerateFinancialSummary')];
        if(apexClassList.size()>0){

            List<AsyncApexJob> aajLst = [select Id, ApexClassId, Status from AsyncApexJob where ApexClassId=:apexClassList[0].Id and status!='Completed' and Status!='Aborted' and Status!='Failed'];
            if(aajLst.size()>0){
                return true;
            }
                return false;
        }
        return false;
    }
    public PageReference reopenMonth(){
        if(fcwMap.containsKey(selectedClosingYear)){
            if(fcwMap.get(selectedClosingYear).monthClosing.containsKey(selectedClosing)){
                FinancialClosingMonthWrapper fc = fcwMap.get(selectedClosingYear).monthClosing.get(selectedClosing);
                fc.fcm.club62__Closed__c = false;
                if(Schema.sObjectType.club62__Financial_Closing__c.isUpdateable()){update fc.fcm;}
            }
        }
        //batchRunning = checkBatchRunning();
        regenerateMap();
        return null;
    }
    public class FinancialClosingWrapper implements Comparable{
        public club62__Financial_Closing__c yearClosing{get;set;}
        public Map<String,FinancialClosingMonthWrapper> monthClosing{get;set;}
        public Boolean closable{get;set;}
        public FinancialClosingWrapper(){
            monthClosing = new Map<String,FinancialClosingMonthWrapper>();
            closable = false;
        }
        public List<FinancialClosingMonthWrapper> getfcmList(){
            List<FinancialClosingMonthWrapper> fcmwtemp = monthclosing.values();
            fcmwtemp.sort();
            return fcmwtemp;
        }
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            FinancialClosingWrapper compareToFC = (FinancialClosingWrapper)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (yearClosing.club62__Year__c > compareToFC.yearClosing.club62__Year__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (yearClosing.club62__Year__c < compareToFC.yearClosing.club62__Year__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }

            return returnValue;
        }

    }
    //for sorting
    public class FinancialClosingMonthWrapper implements Comparable{
        public club62__Financial_Closing__c fcm{get;set;}
        public FinancialClosingMonthWrapper(club62__Financial_Closing__c fcmIn){
            fcm = fcmIn;
        }
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            FinancialClosingMonthWrapper compareToFC = (FinancialClosingMonthWrapper)compareTo;

            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (Integer.valueOf(fcm.club62__Month__c) > Integer.valueOf(compareToFC.fcm.club62__Month__c)) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (Integer.valueOf(fcm.club62__Month__c) < Integer.valueOf(compareToFC.fcm.club62__Month__c)) {
                // Set return value to a negative value.
                returnValue = -1;
            }

            return returnValue;
        }
    }
}