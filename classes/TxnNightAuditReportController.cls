public class TxnNightAuditReportController{
    //This is a map of string to ReportSection class (inner class)
    public Map<MapSortingWrapper,ReportSection> masterMap{get;set;}
    public Map<MapSortingWrapper,ReportSection> paymentMap{get;set;}
    public Map<String,Decimal> amountMap;
    public Map<String,Decimal> adjustedMap;
    public club62__Financial_Journal_Line__c dateAsOf{get;set;}
    private Date fiscalStartDate;
    private String reportId1;
    private String reportId2;
    private String reportId3;

    public club62__C62Taxes__c taxes;
    public TxnNightAuditReportController(){

        String report1DevName = 'TXN_Daily_Revenue_Report_pt1';
        String report2DevName = 'TXN_Daily_Revenue_Report_pt2';
        String report3DevName = 'TXN_Daily_Revenue_Report_pt3';

        reportID1 = '00Oo0000004Cf7N';
        reportID2 = '00Oo0000004Cf7h';
        reportID3 = '00Oo0000004Cf7S';

        List<Report> drrReports = [select id,DeveloperName from Report where DeveloperName in (:report1DevName,:report2DevName,:report3DevName)];
        for(Report drrReport : drrReports){
            if(report1DevName == drrReport.DeveloperName){
                reportID1 = drrReport.Id;
            }else if(report2DevName == drrReport.DeveloperName){
                reportID2 = drrReport.Id;
            }else if(report3DevName == drrReport.DeveloperName){
                reportID3 = drrReport.Id;
            }
        }
        dateAsOf = new club62__Financial_Journal_Line__c();
        dateAsOf.club62__Post_Date__c = Date.today().addDays(-1);

        String dateString = ApexPages.currentPage().getParameters().get('s');
        if(dateString!=null && dateString!=''){
            dateAsOf.club62__Post_Date__c = Date.valueOf(dateString);
        }

        Integer fiscalStartMonth = [Select fiscalYearStartMonth from Organization limit 1].fiscalYearStartMonth;
        Integer fiscalYear;
        //Calculate current fiscal year
        if(dateAsOf.club62__Post_Date__c.Month()>=fiscalStartMonth){
            fiscalYear = dateAsOf.club62__Post_Date__c.YEAR();
        }else{
            fiscalYear = dateAsOf.club62__Post_Date__c.YEAR()-1;
        }
        fiscalStartDate = Date.newInstance(fiscalYear,fiscalStartMonth,1);
        runDailyRevenueReport();

    }
    public PageReference searchDRR(){
        PageReference pr = Page.club62__NightAuditReport;
        pr.setRedirect(true);
        pr.getParameters().put('s',dateasOf.club62__Post_Date__c+'');
        return pr;
    }

    public void runDailyRevenueReport(){
        masterMap = null;
        Reports.ReportMetadata meta = new Reports.ReportMetadata();
        List<Reports.ReportFilter> filList = new List<Reports.ReportFilter>();
        Date minDate = fiscalStartDate;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge'));
        meta.setReportFilters(filList);
        Reports.ReportResults topYear = Reports.ReportManager.runReport(reportID1,meta,false);

        //top month
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = Date.newInstance(dateAsOf.club62__Post_Date__c.year(), dateAsOf.club62__Post_Date__c.month(), 1);
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge'));
        meta.setReportFilters(filList);
        Reports.ReportResults topMonth = Reports.ReportManager.runReport(reportID1,meta,false);

        //top yesterday
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = dateAsOf.club62__Post_Date__c;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge'));
        meta.setReportFilters(filList);
        Reports.ReportResults topYesterday = Reports.ReportManager.runReport(reportID1,meta,false);

        //top year adjust
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = fiscalStartDate;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults topYearAdj = Reports.ReportManager.runReport(reportID1,meta,false);

        //top month adjust
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = Date.newInstance(dateAsOf.club62__Post_Date__c.year(), dateAsOf.club62__Post_Date__c.month(), 1);
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults topMonthAdj = Reports.ReportManager.runReport(reportID1,meta,false);

        //top yesterday adjust
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = dateAsOf.club62__Post_Date__c;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults topYesterdayAdj = Reports.ReportManager.runReport(reportID1,meta,false);

        //Regular Charges Year
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = fiscalStartDate;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','notEqual','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge,Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults regularChargesYear = Reports.ReportManager.runReport(reportID1,meta,false);

        //Regular Charges Month
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = Date.newInstance(dateAsOf.club62__Post_Date__c.year(), dateAsOf.club62__Post_Date__c.month(), 1);
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','notEqual','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge,Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults regularChargesMonth = Reports.ReportManager.runReport(reportID1,meta,false);

        //Regular Charges Yesterday
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = dateAsOf.club62__Post_Date__c;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Id','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','notEqual','Room Rate'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge,Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults regularChargesYesterday = Reports.ReportManager.runReport(reportID1,meta,false);
        //get bottom half info
        //bottom Year
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = fiscalStartDate;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','notEqual','Direct Bill'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Name','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Payment,Authorization'));
        meta.setReportFilters(filList);
        Reports.ReportResults botYear = Reports.ReportManager.runReport(reportID2,meta,false);

        //bottom month
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = Date.newInstance(dateAsOf.club62__Post_Date__c.year(), dateAsOf.club62__Post_Date__c.month(), 1);
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','notEqual','Direct Bill'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Name','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Payment,Authorization'));
        meta.setReportFilters(filList);
        Reports.ReportResults botMonth = Reports.ReportManager.runReport(reportID2,meta,false);

        //bottom yesterday
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = dateAsOf.club62__Post_Date__c;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','notEqual','Direct Bill'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Name','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Payment,Authorization'));
        meta.setReportFilters(filList);
        Reports.ReportResults botYesterday = Reports.ReportManager.runReport(reportID2,meta,false);

        //get bottom half info - DB
        //bottom Year - DB
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = fiscalStartDate;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Direct Bill'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Name','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Payment,Authorization'));
        meta.setReportFilters(filList);
        Reports.ReportResults botYearDB = Reports.ReportManager.runReport(reportID2,meta,false);

        //bottom month - DB
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = Date.newInstance(dateAsOf.club62__Post_Date__c.year(), dateAsOf.club62__Post_Date__c.month(), 1);
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Direct Bill'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Name','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Payment,Authorization'));
        meta.setReportFilters(filList);
        Reports.ReportResults botMonthDB = Reports.ReportManager.runReport(reportID2,meta,false);

        //bottom yesterday - DB
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = dateAsOf.club62__Post_Date__c;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__SubType__c','equals','Direct Bill'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__Room_Reservation__c.Name','notEqual',''));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Payment,Authorization'));
        meta.setReportFilters(filList);
        Reports.ReportResults botYesterdayDB = Reports.ReportManager.runReport(reportID2,meta,false);

        //get food data
        //food Year
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = fiscalStartDate;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge,Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults foodYear = Reports.ReportManager.runReport(reportID3,meta,false);

        //food month
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = Date.newInstance(dateAsOf.club62__Post_Date__c.year(), dateAsOf.club62__Post_Date__c.month(), 1);
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge,Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults foodMonth = Reports.ReportManager.runReport(reportID3,meta,false);

        //food yesterday
        meta = new Reports.ReportMetadata();
        filList = new List<Reports.ReportFilter>();
        minDate = dateAsOf.club62__Post_Date__c;
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','greaterOrEqual',minDate.year()+'-'+minDate.month()+'-'+minDate.day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.club62__DateTime__c','lessOrEqual',dateasOf.club62__Post_Date__c.addDays(1).year()+'-'+dateasOf.club62__Post_Date__c.addDays(1).month()+'-'+dateasOf.club62__Post_Date__c.addDays(1).day()+'T09:00:00Z'));
        filList.add(new Reports.ReportFilter('club62__Txn__c.RecordType.Name','equals','Charge,Adjustment'));
        meta.setReportFilters(filList);
        Reports.ReportResults foodYesterday = Reports.ReportManager.runReport(reportID3,meta,false);

        amountMap = new Map<String,Decimal>();
        adjustedMap = new Map<String,Decimal>();


        taxes = club62__C62Taxes__c.getOrgDefaults();

        //Room Charges
        MapSortingWrapper msw  = new MapSortingWrapper(0,'Room Charges');
        MapSortingWrapper mswTax  = new MapSortingWrapper(3,'Tax Charges');
        masterMap = getReportMap(topYesterday.getFactMap(),topYesterday.getGroupingsDown().getGroupings(),null,msw,'Yesterday',true,1,false,false,true,mswTax,'Amount',false);
        masterMap = getReportMap(topMonth.getFactMap(),topMonth.getGroupingsDown().getGroupings(),masterMap,msw,'MTD',true,1,false,false,true,mswTax,'Amount',false);
        masterMap = getReportMap(topYear.getFactMap(),topYear.getGroupingsDown().getGroupings(),masterMap,msw,'YTD',true,1,false,false,true,mswTax,'Amount',false);
        masterMap = getReportMap(topYesterdayAdj.getFactMap(),topYesterday.getGroupingsDown().getGroupings(),masterMap,msw,'Yesterday',true,1,false,false,true,mswTax,'Adjust',false);
        masterMap = getReportMap(topYesterdayAdj.getFactMap(),topMonth.getGroupingsDown().getGroupings(),masterMap,msw,'MTD',true,1,false,false,true,mswTax,'Adjust',false);
        masterMap = getReportMap(topYesterdayAdj.getFactMap(),topYear.getGroupingsDown().getGroupings(),masterMap,msw,'YTD',true,1,false,false,true,mswTax,'Adjust',false);

        //Regular Charges
        msw = new MapSortingWrapper(1,'Regular Charges');
        msw.level = 2;
        masterMap = getReportMap(regularChargesYesterday.getFactMap(),regularChargesYesterday.getGroupingsDown().getGroupings(),masterMap,msw,'Yesterday',true,2,false,false,true,mswTax,'Both',true);
        masterMap = getReportMap(regularChargesMonth.getFactMap(),regularChargesMonth.getGroupingsDown().getGroupings(),masterMap,msw,'MTD',true,2,false,false,true,mswTax,'Both',true);
        masterMap = getReportMap(regularChargesYear.getFactMap(),regularChargesYear.getGroupingsDown().getGroupings(),masterMap,msw,'YTD',true,2,false,false,true,mswTax,'Both',true);
        //Food Section
        msw = new MapSortingWrapper(2,'Food Charges');
        masterMap = getReportMap(foodYesterday.getFactMap(),foodYesterday.getGroupingsDown().getGroupings(),masterMap,msw,'Yesterday',true,1,false,false,true,null,'Both',true);
        masterMap = getReportMap(foodMonth.getFactMap(),foodMonth.getGroupingsDown().getGroupings(),masterMap,msw,'MTD',true,1,false,false,true,null,'Both',true);
        masterMap = getReportMap(foodYear.getFactMap(),foodYear.getGroupingsDown().getGroupings(),masterMap,msw,'YTD',true,1,false,false,true,null,'Both',true);


        //Payment Section
        msw = new MapSortingWrapper(0,'Receipts');
        paymentMap = getReportMap(botYesterday.getFactMap(),botYesterday.getGroupingsDown().getGroupings(),null,msw,'Yesterday',true,2,true,false,true,null,'Both',false);
        paymentMap = getReportMap(botMonth.getFactMap(),botMonth.getGroupingsDown().getGroupings(),paymentMap,msw,'MTD',true,2,true,false,true,null,'Both',false);
        paymentMap = getReportMap(botYear.getFactMap(),botYear.getGroupingsDown().getGroupings(),paymentMap,msw,'YTD',true,2,true,false,true,null,'Both',false);
        //DirectBill Section
        msw = new MapSortingWrapper(1,'Direct Bills');
        paymentMap = getReportMap(botYesterdayDB.getFactMap(),botYesterdayDB.getGroupingsDown().getGroupings(),paymentMap,msw,'Yesterday',true,2,true,false,false,null,'Both',false);
        paymentMap = getReportMap(botMonthDB.getFactMap(),botMonthDB.getGroupingsDown().getGroupings(),paymentMap,msw,'MTD',true,2,true,false,false,null,'Both',false);
        paymentMap = getReportMap(botYearDB.getFactMap(),botYearDB.getGroupingsDown().getGroupings(),paymentMap,msw,'YTD',true,2,true,false,false,null,'Both',false);


    }

    public Map<MapSortingWrapper,ReportSection> getReportMap(Map<String,Reports.ReportFact> factMap, List<Reports.GroupingValue> groupDown, Map<MapSortingWrapper, ReportSection> reworkedMap,MapSortingWrapper reportSection,String reportTime,Boolean isRevenue,Integer levelsDown,Boolean negateAmount,Boolean negateAdjustment,Boolean createTotalSection,MapSortingWrapper mswTax,String fieldToUse,Boolean includeTax){

        Map<MapSortingWrapper,ReportSection> newFactMap;
        if(reworkedMap==null){
            newFactMap = new Map<MapSortingWrapper,ReportSection>();
        }else{
            newFactMap = reworkedMap;
        }
        if(!newFactMap.containsKey(reportSection)){
            newFactMap.put(reportSection,new ReportSection());
            if(createTotalSection==true){
                newFactMap.get(reportSection).createReportSection = true;
            }
        }
        if(reportSection.title=='Room Charges'){

            if(!newFactMap.containsKey(mswTax)){
                newFactMap.put(mswTax,new ReportSection());
                if(createTotalSection==true){
                    newFactMap.get(mswTax).createReportSection = true;
                }
            }
        }

        Map<String,GroupingSection> groupMap = new Map<String,GroupingSection>();
        for(Reports.GroupingValue gv : groupDown){
            if(!groupMap.containsKey(gv.getKey())){
                groupMap.put(gv.getKey(),new GroupingSection(gv.getLabel(),(String)gv.getValue(),gv.getKey()));
            }
            if(levelsDown>=2){
                for(Reports.GroupingValue gv2 : gv.getGroupings()){
                    if(!groupMap.containsKey(gv2.getKey())){
                        groupMap.put(gv2.getKey(), new GroupingSection(gv2.getLabel(),(String)gv2.getValue(),gv2.getKey()));
                        if(gv2.getValue()==null){
                            groupMap.get(gv2.getKey()).name = gv.getlabel();
                        }
                    }
                }
            }
        }
        for(String s : factMap.keySet()){
            String s2 = s.split('!')[0];
            Integer index = 0;
            if(!s2.contains('T')){
                List<String> splitString = s2.split('_');
                Decimal Amount=null;
                Decimal Adjusted=null;
                Decimal salesTax = null;
                Decimal Tax1 = null;
                Decimal Tax2 = null;
                Decimal Tax3 = null;
                Decimal Tax4 = null;
                GroupingSection gs;
                Reports.SummaryValue sumVal = factMap.get(s).getAggregates()[0];

                Reports.SummaryValue sumVal2;
                if(factMap.get(s).getAggregates().size()>1){
                    sumVal2 = factMap.get(s).getAggregates()[1];
                    if(reportSection.title == 'Room Charges'){
                        Tax1 = ((Decimal)factMap.get(s).getAggregates()[2].getValue()).setScale(2);
                        Tax2 = ((Decimal)factMap.get(s).getAggregates()[3].getValue()).setScale(2);
                        Tax3 = ((Decimal)factMap.get(s).getAggregates()[4].getValue()).setScale(2);
                        Tax4 = ((Decimal)factMap.get(s).getAggregates()[5].getValue()).setScale(2);
                    }else if(sumVal!=null && includeTax == true){
                        salesTax = ((Decimal)factMap.get(s).getAggregates()[2].getValue()).setScale(2);
                    }
                }
                if(groupMap.containsKey(splitString[0])){
                    gs = groupMap.get(splitString[0]);
                }else{
                    gs = new GroupingSection();
                }
                if(splitString.size()==1){
                    Amount = ((Decimal)sumVal.getValue()).setScale(2);
                    if(includeTax == true){
                        Amount += salesTax;
                    }
                    if(negateAmount==true){
                        Amount*=-1;
                    }
                    if(sumVal2!=null && fieldToUse == 'Both'){
                        Adjusted = ((Decimal)sumVal2.getValue()).setScale(2);
                        if(negateAdjustment==true){
                            Adjusted*=-1;
                        }
                    }
                    if(fieldToUse == 'Adjust'){
                        Adjusted = Amount;
                    }
                }
                if(!newFactMap.get(reportSection).reportSec.containsKey(gs.value))
                    newFactMap.get(reportSection).reportSec.put(gs.value,new ReportSection(gs,true));
                if(reportSection.title == 'Room Charges'){
                    if(!newFactMap.get(mswTax).reportSec.containsKey(taxes.club62__Room_Res_Tax_Percentage_1_Description__c))
                        newFactMap.get(mswTax).reportSec.put(taxes.club62__Room_Res_Tax_Percentage_1_Description__c,new ReportSection(new GroupingSection(taxes.club62__Room_Res_Tax_Percentage_1_Description__c,taxes.club62__Room_Res_Tax_Percentage_1_Description__c,taxes.club62__Room_Res_Tax_Percentage_1_Description__c),true));
                    if(!newFactMap.get(mswTax).reportSec.containsKey(taxes.club62__Room_Res_Tax_Percentage_2_Description__c))
                        newFactMap.get(mswTax).reportSec.put(taxes.club62__Room_Res_Tax_Percentage_2_Description__c,new ReportSection(new GroupingSection(taxes.club62__Room_Res_Tax_Percentage_2_Description__c,taxes.club62__Room_Res_Tax_Percentage_2_Description__c,taxes.club62__Room_Res_Tax_Percentage_2_Description__c),true));
                    if(!newFactMap.get(mswTax).reportSec.containsKey(taxes.club62__Room_Res_Tax_1_Amount_Description__c))
                        newFactMap.get(mswTax).reportSec.put(taxes.club62__Room_Res_Tax_1_Amount_Description__c,new ReportSection(new GroupingSection(taxes.club62__Room_Res_Tax_1_Amount_Description__c,taxes.club62__Room_Res_Tax_1_Amount_Description__c,taxes.club62__Room_Res_Tax_1_Amount_Description__c),true));
                    if(!newFactMap.get(mswTax).reportSec.containsKey(taxes.club62__Room_Res_Tax_2_Amount_Description__c))
                        newFactMap.get(mswTax).reportSec.put(taxes.club62__Room_Res_Tax_2_Amount_Description__c,new ReportSection(new GroupingSection(taxes.club62__Room_Res_Tax_2_Amount_Description__c,taxes.club62__Room_Res_Tax_2_Amount_Description__c,taxes.club62__Room_Res_Tax_2_Amount_Description__c),true));
                }
                if(Amount!=null && (fieldToUse == 'Amount' || fieldToUse == 'Both')){
                    newFactMap.get(reportSection).reportSec.get(gs.value).amountMap.put(reportTime,amount);
                    if(!newFactMap.get(reportSection).amountMap.containsKey(reportTime)){
                        newFactMap.get(reportSection).amountMap.put(reportTime,amount);
                    }else{
                        newFactMap.get(reportSection).amountMap.put(reportTime,amount+newFactMap.get(reportSection).amountMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!amountMap.containsKey(reportTime)){
                            amountMap.put(reportTime,amount);
                        }else{
                            amountMap.put(reportTime,amount+amountMap.get(reportTime));
                        }
                    }
                }
                if(Adjusted!=null && (fieldToUse == 'Adjust' || fieldToUse == 'Both')){
                    newFactMap.get(reportSection).reportSec.get(gs.value).adjustedMap.put(reportTime,adjusted);
                    if(!newFactMap.get(reportSection).adjustedMap.containsKey(reportTime)){
                        newFactMap.get(reportSection).adjustedMap.put(reportTime,adjusted);
                    }else{
                        newFactMap.get(reportSection).adjustedMap.put(reportTime,adjusted+newFactMap.get(reportSection).adjustedMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!adjustedMap.containsKey(reportTime)){
                            adjustedMap.put(reportTime,adjusted);
                        }else{
                            adjustedMap.put(reportTime,adjusted+adjustedMap.get(reportTime));
                        }
                    }
                }
                if(Tax1!=null && (fieldToUse == 'Both' || fieldToUse=='Amount')){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_Percentage_1_Description__c).amountMap.put(reportTime,Tax1);
                    if(!newFactMap.get(mswTax).amountMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax1);
                    }else{
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax1+newFactMap.get(mswTax).amountMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!amountMap.containsKey(reportTime)){
                            amountMap.put(reportTime,Tax1);
                        }else{
                            amountMap.put(reportTime,Tax1+amountMap.get(reportTime));
                        }
                    }
                }
                if(Tax2!=null && (fieldToUse == 'Both' || fieldToUse=='Amount')){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_Percentage_2_Description__c).amountMap.put(reportTime,Tax2);
                    if(!newFactMap.get(mswTax).amountMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax2);
                    }else{
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax2+newFactMap.get(mswTax).amountMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!amountMap.containsKey(reportTime)){
                            amountMap.put(reportTime,Tax2);
                        }else{
                            amountMap.put(reportTime,Tax2+amountMap.get(reportTime));
                        }
                    }
                }
                if(Tax3!=null && (fieldToUse == 'Both' || fieldToUse=='Amount')){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_1_Amount_Description__c).amountMap.put(reportTime,Tax3);
                    if(!newFactMap.get(mswTax).amountMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax3);
                    }else{
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax3+newFactMap.get(mswTax).amountMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!amountMap.containsKey(reportTime)){
                            amountMap.put(reportTime,Tax3);
                        }else{
                            amountMap.put(reportTime,Tax3+amountMap.get(reportTime));
                        }
                    }
                }
                if(Tax4!=null && (fieldToUse == 'Both' || fieldToUse=='Amount')){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_2_Amount_Description__c).amountMap.put(reportTime,Tax4);
                    if(!newFactMap.get(mswTax).amountMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax4);
                    }else{
                        newFactMap.get(mswTax).amountMap.put(reportTime,Tax4+newFactMap.get(mswTax).amountMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!amountMap.containsKey(reportTime)){
                            amountMap.put(reportTime,Tax4);
                        }else{
                            amountMap.put(reportTime,Tax4+amountMap.get(reportTime));
                        }
                    }
                }
                if(Tax1!=null && fieldToUse=='Adjust'){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_Percentage_1_Description__c).adjustedMap.put(reportTime,Tax1);
                    if(!newFactMap.get(mswTax).adjustedMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax1);
                    }else{
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax1+newFactMap.get(mswTax).adjustedMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!adjustedMap.containsKey(reportTime)){
                            adjustedMap.put(reportTime,Tax1);
                        }else{
                            adjustedMap.put(reportTime,Tax1+adjustedMap.get(reportTime));
                        }
                    }
                }
                if(Tax2!=null && fieldToUse=='Adjust'){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_Percentage_2_Description__c).adjustedMap.put(reportTime,Tax2);
                    if(!newFactMap.get(mswTax).adjustedMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax2);
                    }else{
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax2+newFactMap.get(mswTax).adjustedMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!adjustedMap.containsKey(reportTime)){
                            adjustedMap.put(reportTime,Tax2);
                        }else{
                            adjustedMap.put(reportTime,Tax2+adjustedMap.get(reportTime));
                        }
                    }
                }
                if(Tax3!=null && fieldToUse=='Adjust'){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_1_Amount_Description__c).adjustedMap.put(reportTime,Tax3);
                    if(!newFactMap.get(mswTax).adjustedMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax3);
                    }else{
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax3+newFactMap.get(mswTax).adjustedMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!adjustedMap.containsKey(reportTime)){
                            adjustedMap.put(reportTime,Tax3);
                        }else{
                            adjustedMap.put(reportTime,Tax3+adjustedMap.get(reportTime));
                        }
                    }
                }
                if(Tax4!=null && fieldToUse=='Adjust'){
                    newFactMap.get(mswTax).reportSec.get(taxes.club62__Room_Res_Tax_2_Amount_Description__c).adjustedMap.put(reportTime,Tax4);
                    if(!newFactMap.get(mswTax).adjustedMap.containsKey(reportTime)){
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax4);
                    }else{
                        newFactMap.get(mswTax).adjustedMap.put(reportTime,Tax4+newFactMap.get(mswTax).adjustedMap.get(reportTime));
                    }
                    if(isRevenue==true){
                        if(!adjustedMap.containsKey(reportTime)){
                            adjustedMap.put(reportTime,Tax4);
                        }else{
                            adjustedMap.put(reportTime,Tax4+adjustedMap.get(reportTime));
                        }
                    }
                }
                Decimal Amount2 = null;
                Decimal Adjusted2 = null;
                GroupingSection gs2;
                if(levelsDown>=2 && splitString.size()>=2){
                    if(groupMap.containsKey(splitString[0]+'_'+splitString[1])){
                        gs2 = groupMap.get(splitString[0]+'_'+splitString[1]);
                    }else{
                        gs2 = new GroupingSection();
                    }
                    if(splitString.size()==2){
                        Amount2 = ((Decimal)sumVal.getValue()).setScale(2);
                        if(includeTax == true){
                            Amount2 += salesTax;
                        }
                        if(negateAmount==true){
                            Amount2*=-1;
                        }
                        if(sumVal2!=null){
                            Adjusted2 = ((Decimal)sumVal2.getValue()).setScale(2);
                            if(negateAdjustment==true){
                                Adjusted2*=-1;
                            }
                        }
                    }
                    if(!newFactMap.get(reportSection).reportSec.get(gs.value).reportSec.containsKey(gs2.value))
                        newFactMap.get(reportSection).reportSec.get(gs.value).reportSec.put(gs2.value,new ReportSection(gs2,true));

                    if(Amount2!=null){
                        newFactMap.get(reportSection).reportSec.get(gs.value).reportSec.get(gs2.value).amountMap.put(reportTime,amount2);
                    }
                    if(Adjusted2!=null){
                        newFactMap.get(reportSection).reportSec.get(gs.value).reportSec.get(gs2.value).adjustedMap.put(reportTime,adjusted2);
                    }
                }
            }
        }
        return newFactMap;
    }
    public Decimal getYesterdayAmount(){
        if(amountMap.containsKey('Yesterday')){
            return amountMap.get('Yesterday');
        }
        return 0;
    }
    public Decimal getMTDAmount(){
        if(amountMap.containsKey('MTD')){
            return amountMap.get('MTD');
        }
        return 0;
    }
    public Decimal getYTDAmount(){
        if(amountMap.containsKey('YTD')){
            return amountMap.get('YTD');
        }
        return 0;
    }
    public Decimal getYesterdayAdjusted(){
        if(adjustedMap.containsKey('Yesterday')){
            return adjustedMap.get('Yesterday');
        }
        return 0;
    }
    public Decimal getMTDAdjusted(){
        if(adjustedMap.containsKey('MTD')){
            return adjustedMap.get('MTD');
        }
        return 0;
    }
    public Decimal getYTDAdjusted(){
        if(adjustedMap.containsKey('YTD')){
            return adjustedMap.get('YTD');
        }
        return 0;
    }
    public class ReportSection{
        public GroupingSection gs{get;set;}
        public Map<String,Decimal> amountMap{get;set;}
        public Map<String,Decimal> adjustedMap{get;set;}
        public Map<String,ReportSection> reportSec{get;set;}
        public Boolean createReportSection{get;set;}
        public ReportSection(GroupingSection gs,Boolean createReportSec){
            this.gs = gs;
            amountMap = new Map<String,Decimal>();
            adjustedMap = new Map<String,Decimal>();
            if(createReportSec==true){
                reportSec = new Map<String,ReportSection>();
            }
            createReportSection = false;
        }
        public ReportSection(){
            amountMap = new Map<String,Decimal>();
            adjustedMap = new Map<String,Decimal>();
            reportSec = new Map<String,ReportSection>();
            createReportSection = false;
        }
        public Decimal getYesterdayAmount(){
            if(amountMap.containsKey('Yesterday')){
                return amountMap.get('Yesterday');
            }
            return 0;
        }
        public Decimal getMTDAmount(){
            if(amountMap.containsKey('MTD')){
                return amountMap.get('MTD');
            }
            return 0;
        }
        public Decimal getYTDAmount(){
            if(amountMap.containsKey('YTD')){
                return amountMap.get('YTD');
            }
            return 0;
        }
        public Decimal getYesterdayAdjusted(){
            if(adjustedMap.containsKey('Yesterday')){
                return adjustedMap.get('Yesterday');
            }
            return 0;
        }
        public Decimal getMTDAdjusted(){
            if(adjustedMap.containsKey('MTD')){
                return adjustedMap.get('MTD');
            }
            return 0;
        }
        public Decimal getYTDAdjusted(){
            if(adjustedMap.containsKey('YTD')){
                return adjustedMap.get('YTD');
            }
            return 0;
        }

   }
   public class GroupingSection{
       public String name{get;set;}
       public String key{get;set;}
       public String value{get;set;}

       public GroupingSection(String name, String value, String key){
           this.name = name;
           this.key = key;
           this.value = value;
       }
       public GroupingSection(){}
   }
   public class MapSortingWrapper implements Comparable{
        public Integer index{get;set;}
        public String title{get;set;}
        public Integer level{get;set;}
        public MapSortingWrapper(Integer i,String s){
            index = i;
            title = s;
            level = 1;
        }
        public Integer compareTo(Object c){
            MapSortingWrapper comp = (MapSortingWrapper) c;
            if(index == comp.index){
                return 0;
            }else if(index < comp.index){
                return -1;
            }else{
                return 1;
            }
        }
   }

}