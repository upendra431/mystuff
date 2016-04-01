public with sharing class C62RunFinancialReportController {
    public String reportType{get;set;}
    public club62__Financial_Summary__c sDate{get;set;}
    public club62__Financial_Summary__c eDate{get;set;}
    public club62__Financial_Account__c financialScheduleDepartmentFilter{get;set;}
    public String d1{get;set;}
    public String d2{get;set;}
    public Boolean showDetails{get;set;}
    public Id reportId{get;set;}
    public Id reportId2{get;set;}
    public Map<String,String> reportTypeToNameMap{get;set;}
    public Map<String,String> reportTypeToReportNameMap{get;set;}
    public Map<String,String> reportTypeToReportPageMap{get;set;}
    public String dateTimeString{get;set;}
    public Integer apexRunNumber{get;set;}
    public Integer numMonths{get;set;}
    public String selectedFAFilter{get;set;}
    public List<SelectOption> financialAccountSO{get;set;}
    public List<SelectOption> financialAccountFilterSO{get;set;}
    public List<SelectOption> locationSO{get;set;}
    public String blank0{get;set;}
    public String blank1{get;set;}
    public String blank2{get;set;}
    public String locationFilter{get;set;}

    //Based on html Parameter get rport id
    public C62RunFinancialReportController(){
        reportType = ApexPages.currentPage().getParameters().get('rt');
        financialScheduleDepartmentFilter = new club62__Financial_Account__c();
        String numMonthsStr = ApexPages.currentPage().getParameters().get('nmonth');
        if(numMonthsStr==null || numMonthsStr==''){
            numMonths = 1;
        }else{
            numMonths = Integer.valueOf(numMonthsStr);
        }
        reportTypeToNameMap = new Map<String,String>{'balsheet' => 'Balance Sheet', 'actsheet'=> 'Activity Sheet', 'fsched'=> 'Financial Schedules', 'genledge'=> 'General Ledger', 'trialbal'=> 'Trial Balance','actsheetann'=>'Annual Activity Sheet','budgetonly'=> 'Budget Only Report'};
        reportTypeToReportNameMap = new Map<String,String>{'balsheet'=> 'Financial_Summaries_BalSheet', 'actsheet'=>'Financial_Summaries_IS', 'fsched'=>'Financial_Summaries_FS', 'genledge'=>'Financial_Summaries', 'trialbal'=>'Financial_Summaries_TB', 'actsheetann'=>'Financial_Summaries_IS_Annual','budgetonly'=>'Financial_Summaries_IS_Annual'};
        apexRunNumber = 0;

        if(reportType!=null && reportType!='' && reportTypeToNameMap.containsKey(reportType)){
            sDate = new club62__Financial_Summary__c();
            eDate = new club62__Financial_Summary__c();

            showDetails = true;
            String rEscape = String.escapeSingleQuotes(reportTypeToReportNameMap.get(reportType));
            List<Report> rLst = [select id, name from Report where DeveloperName =:rEscape];
            if(rLst.size()>0){
                reportId = rLst[0].Id;
                Datetime lastRanDate = getLastTimeRan();
                if(lastRanDate!=null){
                    dateTimeString = lastRanDate.format('MM-dd-yyyy hh:mm');
                }
            }
            if(reportType=='genledge'){
                String reportName2 = 'Financial_Journal_Lines_GenLedge';
                List<Report> rLst2 = [Select id,name from Report where DeveloperName =:reportName2];
                if(rLst2.size()>0){
                    reportId2 = rlst2[0].Id;
                }
            }else if(reportType=='trialbal'){
                String reportName2 = 'Financial_Journal_Lines_TB';
                List<Report> rLst2 = [Select id,name from Report where DeveloperName =:reportName2];
                if(rLst2.size()>0){
                    reportId2 = rlst2[0].Id;
                }
            }else if(reportType=='balsheet'){
                String reportName2 = 'Financial_Journal_Lines_BalSheet';
                List<Report> rLst2 = [Select id,name from Report where DeveloperName =:reportName2];
                if(rLst2.size()>0){
                    reportId2 = rlst2[0].Id;
                }
            }else if(reportType=='actsheet'){
                String reportName2 = 'Financial_Journal_Lines_ActSheet';
                List<Report> rLst2 = [Select id,name from Report where DeveloperName =:reportName2];
                if(rLst2.size()>0){
                    reportId2 = rlst2[0].Id;
                }
            }else if(reportType=='fsched'){
                String reportName2 = 'Financial_Journal_Lines_FSched';
                List<Report> rLst2 = [Select id,name from Report where DeveloperName =:reportName2];
                if(rLst2.size()>0){
                    reportId2 = rlst2[0].Id;
                }
            }else if(reportType=='actsheetann'  || reportType=='budgetonly'){
                String reportName2 = 'Financial_Journal_Lines_AnnActSheet';
                List<Report> rLst2 = [Select id,name from Report where DeveloperName =:reportName2];
                if(rLst2.size()>0){
                    reportId2 = rlst2[0].Id;
                }
            }
            if(eDate.club62__Date__c == null){
                eDate.club62__Date__c = Date.today();
            }

        }else{
            reportType = null;
        }
        if((reportType=='genledge' || reportType == 'trialbal')&& sDate.club62__Date__c == null){
                sDate.club62__Date__c = eDate.club62__Date__c.addMonths(-1).addDays(1);
            }
        createFASOList();
        createLocationSOList();
    }
    //Generate location selectoption list
    public void createLocationSOList(){
        List<club62__Location__c> locList = [select id,Name from club62__Location__c order by Name];
        locationSO = new List<SelectOption>();
        locationSO.add(new SelectOption('','--None--'));
        for(club62__Location__c loc : locList){
            locationSO.add(new SelectOption(loc.Id+'',loc.Name));
        }
    }
    //Generate Financial Account SelectOption List
    public void createFASOList(){
        List<club62__Financial_Account__c> faList = [select id, Name, club62__Account_Number__c from club62__Financial_Account__c order by club62__Account_Number__c ASC];
        financialAccountSO = new List<SelectOption>();
        financialAccountFilterSO = new List<SelectOption>();
        financialAccountSO.add(new SelectOption('','--None--'));
        financialAccountFilterSO.add(new SelectOption('','--None--'));
        for(club62__Financial_Account__c fa : faList){
            financialAccountSO.add(new SelectOption(fa.Id,fa.club62__Account_Number__c+' - '+fa.Name));
            financialAccountFilterSO.add(new SelectOption(fa.club62__Account_Number__c,fa.club62__Account_Number__c+' - '+fa.Name));
        }

    }
    //Get last time this report was run from custom setting.
    public DateTime getLastTimeRan(){
        if(reportType!=null){
            club62__C62FinancialReportRuns__c frr = club62__C62FinancialReportRuns__c.getInstance(reportType);
            if(frr!=null){
                eDate.club62__Date__c = frr.club62__LastRunEndDate__c;
                sDate.club62__Date__c = frr.club62__LastRunStartDate__c;
            }
        }
        if(reportId!=null){
            try{
                List<Reports.ReportInstance> rilList = Reports.ReportManager.getReportInstances(reportId);
                if(rilList.size()>0){

                    return rilList[0].getcompletionDate();
                }
            }catch(NoDataFoundException ex){
                return null;
            }
        }
        return null;
    }
    //Takes report Id and any parameters from the page. Calculates start/end dates and runs the specified report x number of times to get the data needed for the VF page corresponding to the report.
    @RemoteAction
    public static Boolean runReport(Date eDate,Date sDate2, Id reportId,Id reportId2,String reportType,Integer runNumber,Integer maxRunNumber,String filter1,String filter2,String filter3,String locationFilter){
        Date sDate;
        Date sDate3;
        eDate = Date.newInstance(eDate.year(),eDate.month(),eDate.day());
        Date asOfDate = Date.newInstance(eDate.year(),eDate.month(),eDate.day());
        if(eDate!=null){
            eDate = eDate.addDays(-1);
            List<Organization> org = [Select id,FiscalYearStartMonth from Organization limit 1];
            String eDateMonth = eDate.month()+'';
            String eDateYear = eDate.year()+'';
            List<club62__Financial_Closing__c> fcloseList = [Select id,club62__FiscalStartMonth__c, club62__FiscalEndMonth__c from club62__Financial_Closing__c where club62__year_string__c = :eDateYear and club62__month__c = :eDateMonth];
            Integer fiscalStart;
            Integer fiscalEnd;
            if(fcloseList!=null &&fcloseList.size()>0){
                fiscalStart = Integer.valueOf(fcloseList[0].club62__FiscalStartMonth__c);
                fiscalEnd = Integer.valueOf(fcloseList[0].club62__FiscalEndMonth__c);
            }
            Integer month;
            if(fiscalStart!=null){
                month = fiscalStart;
            }else if(org.size()>0){
                month = org[0].FiscalYearStartMonth;
            }
            if(month!=null){
                if(eDate.month()<month){
                    sDate = Date.newInstance(eDate.addYears(-1).year(),month,1);
                }else{
                    sDate = Date.newInstance(eDate.year(),month,1);
                }
                if(reportType=='trialbal' || reportType == 'genledge'){
                    sDate3 = eDate.addMonths(-1).addDays(1);
                }
                if(reportType=='actsheetann' || reportType=='budgetonly'){
                    eDate = sDate.addYears(1).addDays(-1);
                    if(fiscalEnd!=null){
                        eDate = Date.newInstance(eDate.year(),fiscalEnd,1).addMonths(1).addDays(-1);
                    }
                }else{
                    edate = eDate.addDays(1);
                }
            }else{
                edate = eDate.addDays(1);
            }

        }else{
            sDate = Date.today();
        }
        system.debug(sDate);
        system.debug(eDate);
        Boolean runThisRun = false;
        if(reportType!=null && reportId!=null && reportType!='' && sDate!=null && eDate!=null){
            if(reportType=='balsheet'){
                Reports.ReportFilter fil;
                Reports.ReportFilter fil2;
                Reports.ReportFilter fil3;
                Reports.ReportFilter fil4;
                Reports.ReportFilter fil5;
                Reports.ReportFilter fil6;
                String booleanFilter = '';
                List<Reports.ReportFilter> filList = new List<Reports.ReportFilter>();
                if(runNumber == -1){
                    fil = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Posted__c','equals','true');
                    fil2 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','greaterOrEqual',sDate.year()+'-'+sDate.month()+'-'+sDate.day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','lessOrEqual',eDate.year()+'-'+eDate.month()+'-'+eDate.day());
                    //fil4 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Balance_Sheet_Type__c','notEqual','');
                    fil5 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Financial_Summary__c.Name','equals','');
                    booleanFilter = '1 AND 2 AND 3 AND 4';
                    runThisRun = true;
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    //filList.add(fil4);
                    filList.add(fil5);
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Account__c.club62__Location__c.Id','equals',locationFilter.left(15)));
                        booleanFilter += ' AND '+filList.size();
                    }
                }else if(runNumber==0){
                    club62__C62FinancialReportRuns__c frr = club62__C62FinancialReportRuns__c.getInstance(reportType);
                    if(frr!=null){
                        frr.club62__LastRunEndDate__c = eDate;
                    }else{
                        frr = new club62__C62FinancialReportRuns__c(Name=reportType,club62__LastRunEndDate__c=eDate);
                    }
                    upsert frr;

                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDate.year()+'-'+sDate.month()+'-'+sDate.day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessOrEqual',eDate.year()+'-'+eDate.month()+'-'+eDate.day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',sDate.year()+'-'+sDate.month()+'-'+sDate.day());
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    fil5 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','true');
                    fil6 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Balance_Sheet_Type__c','notEqual','');
                    booleanFilter = '((1 AND 2 AND 4) OR (3 AND 5 AND 6))';
                    runThisRun = true;
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    filList.add(fil4);
                    filList.add(fil5);
                    filList.add(fil6);
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                        booleanFilter += ' AND '+filList.size();
                    }
                }else if(runNumber>0){
                    Date correctedStartDate;
                    if(eDate.addMonths(-1*runNumber)>=sDate){
                        correctedStartDate = sDate;
                    }else{
                        correctedStartDate = sDate.addYears(-1);
                    }
                    String sDateYear = correctedStartDate.year()+'';
                    String sDateMonth = correctedStartDate.month()+'';
                    List<club62__Financial_Closing__c> fcloseList = [Select id,club62__FiscalStartMonth__c, club62__FiscalEndMonth__c from club62__Financial_Closing__c where club62__year_string__c = :sDateYear and club62__month__c = :sDateMonth];
                    Integer fiscalStart;
                    Integer fiscalEnd;
                    if(fcloseList!=null &&fcloseList.size()>0){
                        fiscalStart = Integer.valueOf(fcloseList[0].club62__FiscalStartMonth__c);
                        fiscalEnd = Integer.valueOf(fcloseList[0].club62__FiscalEndMonth__c);
                        correctedStartDate = Date.newInstance(correctedStartDate.year(),fiscalStart,1);
                    }
                    //if(eDate.addMonths(-1*runNumber)>=sDate){
                        fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',correctedStartDate .year()+'-'+correctedStartDate .month()+'-'+correctedStartDate .day());
                        fil3 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',correctedStartDate .year()+'-'+correctedStartDate .month()+'-'+correctedStartDate .day());
                    /*}else{
                        fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',correctedStartDate .addYears(-1).year()+'-'+correctedStartDate .addYears(-1).month()+'-'+correctedStartDate .addYears(-1).day());
                        fil3 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',correctedStartDate .addYears(-1).year()+'-'+correctedStartDate .addYears(-1).month()+'-'+correctedStartDate .addYears(-1).day());
                    }*/
                    Date correctedEndDate = Date.newInstance(eDate.addMonths(-1*runNumber).year(),eDate.addMonths(-1*runNumber).month(),1).addMonths(1).addDays(-1);

                    system.debug(correctedStartDate+':'+correctedEndDate);
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessOrEqual',correctedEndDate.year()+'-'+correctedEndDate.month()+'-'+correctedEndDate.day());

                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    fil5 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','true');
                    fil6 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Balance_Sheet_Type__c','notEqual','');
                    booleanFilter = '((1 AND 2 AND 4) OR (3 AND 5 AND 6))';
                    runThisRun = true;
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    filList.add(fil4);
                    filList.add(fil5);
                    filList.add(fil6);
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                        booleanFilter += ' AND '+filList.size();
                    }
                }
                if(runThisRun==true){

                    Reports.ReportMetadata meta = new Reports.ReportMetadata();
                    meta.setReportFilters(filList);
                    meta.setReportBooleanFilter(booleanFilter);
                    if(runNumber != -1){
                        meta.setHasRecordCount(true);
                        meta.setAggregates(new List<String>{'s!club62__Financial_Summary__c.club62__Actual__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('club62__Financial_Account__c.club62__Balance_Sheet_Type__c');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);
                        Reports.GroupingInfo gi2 = new Reports.GroupingInfo();
                        gi2.setName('club62__Financial_Account__c.club62__Balance_Sheet_Sub_Type__c');
                        gi2.setSortOrder('ASCENDING');
                        gi2.setDateGranularity('NONE');
                        Reports.GroupingInfo gi3 = new Reports.GroupingInfo();
                        gi3.setName('CUST_ID');
                        gi3.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi3.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        gil.add(gi2);
                        gil.add(gi3);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Summary__c.club62__Actual__c'});
                    }else{
                        meta.setHasRecordCount(true);
                        meta.setAggregates(new List<String>{'s!club62__Financial_Journal_Line__c.club62__Debit__c','s!club62__Financial_Journal_Line__c.club62__Credit__c','s!club62__Financial_Journal_Line__c.club62__Amount__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('club62__Financial_Account__c.Id');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Journal_Line__c.club62__Account_Number__c','club62__Financial_Journal_Line__c.club62__Transaction_Date__c','club62__Financial_Journal_Line__c.Name','club62__Financial_Journal_Line__c.club62__Description__c','club62__Financial_Journal_Line__c.club62__Debit__c','club62__Financial_Journal_Line__c.club62__Credit__c','club62__Financial_Journal_Line__c.club62__Amount__c','club62__Financial_Account__c.club62__Balance_Sheet_Type__c','club62__Financial_Account__c.club62__Balance_Sheet_Sub_Type__c'});
                    }
                    if(runNumber==-1){
                        Reports.ReportManager.runAsyncReport(reportId2,meta);
                    }else{
                        Reports.ReportManager.runAsyncReport(reportId,meta);
                    }
                }
                if(runNumber<maxRunNumber){
                    return true;
                }else{
                    return false;
                }
            }else if(reportType=='actsheet' || reportType=='fsched'){
                Reports.ReportFilter fil;
                Reports.ReportFilter fil2;
                Reports.ReportFilter fil3;
                Reports.ReportFilter fil4;
                List<Reports.ReportFilter> filList = new List<Reports.ReportFilter>();
                Date startOfMonth = eDate.toStartOfMonth();
                if(runNumber == -1){
                    fil = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','greaterOrEqual',startOfMonth.year()+'-'+startOfMonth.month()+'-'+startOfMonth.day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','lessOrEqual',eDate.year()+'-'+eDate.month()+'-'+eDate.day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Financial_Summary__c.Name','equals','');
                    filList.add(new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Posted__c','equals','true'));
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Account__c.club62__Location__c.Id','equals',locationFilter.left(15)));
                    }
                    runThisRun = true;
                //LYYTD
                }else if(runNumber==0){
                    club62__C62FinancialReportRuns__c frr = club62__C62FinancialReportRuns__c.getInstance(reportType);
                    if(frr!=null){
                        frr.club62__LastRunEndDate__c = eDate;
                    }else{
                        frr = new club62__C62FinancialReportRuns__c(Name=reportType,club62__LastRunEndDate__c=eDate);
                    }
                    upsert frr;
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDate.addYears(-1).year()+'-'+sDate.addYears(-1).month()+'-'+sDate.addYears(-1).day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',eDate.addYears(-1).year()+'-'+eDate.addYears(-1).month()+'-'+eDate.addYears(-1).day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                    }
                    runThisRun=true;
                }else if(runNumber==1){
                    //LY Month
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',startOfMonth.addYears(-1).year()+'-'+startOfMonth.addYears(-1).month()+'-'+startOfMonth.addYears(-1).day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',eDate.addYears(-1).year()+'-'+eDate.addYears(-1).month()+'-'+eDate.addYears(-1).day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    runThisRun=true;
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                    }
                }else if(runNumber==2){
                    //YTD
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDate.year()+'-'+sDate.month()+'-'+sDate.day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',eDate.year()+'-'+eDate.month()+'-'+eDate.day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    runThisRun=true;
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                    }
                }else if(runNumber==3){
                    //Current
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',startOfMonth.year()+'-'+startOfMonth.month()+'-'+startOfMonth.day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',eDate.year()+'-'+eDate.month()+'-'+eDate.day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                    }
                    runThisRun=true;
                }
                if(runThisRun==true){
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    filList.add(fil4);
                    if(reportType == 'fsched' && filter1!='' && filter1!=null){
                        filList.add(new Reports.ReportFilter('club62__Financial_Account__c.club62__Type__c','equals',filter1));
                    }
                    Reports.ReportMetadata meta = new Reports.ReportMetadata();
                    meta.setReportFilters(filList);
                    if(runNumber==-1){
                        meta.setHasRecordCount(true);
                        meta.setAggregates(new List<String>{'s!club62__Financial_Journal_Line__c.club62__Debit__c','s!club62__Financial_Journal_Line__c.club62__Credit__c','s!club62__Financial_Journal_Line__c.club62__Amount__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('club62__Financial_Account__c.Id');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Journal_Line__c.club62__Account_Number__c','club62__Financial_Journal_Line__c.club62__Transaction_Date__c','club62__Financial_Journal_Line__c.Name','club62__Financial_Journal_Line__c.club62__Description__c','club62__Financial_Journal_Line__c.club62__Debit__c','club62__Financial_Journal_Line__c.club62__Credit__c','club62__Financial_Journal_Line__c.club62__Amount__c','club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','club62__Financial_Account__c.club62__Statement_of_Activities_Sub_Type__c'});
                        Reports.ReportManager.runAsyncReport(reportId2,meta);
                    }else{
                        meta.setHasRecordCount(true);
                        meta.setAggregates(new List<String>{'s!club62__Financial_Summary__c.club62__Actual__c','s!club62__Financial_Summary__c.club62__Budget__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);
                        Reports.GroupingInfo gi2 = new Reports.GroupingInfo();
                        gi2.setName('club62__Financial_Account__c.club62__Statement_of_Activities_Sub_Type__c');
                        gi2.setSortOrder('ASCENDING');
                        gi2.setDateGranularity('NONE');
                        Reports.GroupingInfo gi3 = new Reports.GroupingInfo();
                        gi3.setName('CUST_ID');
                        gi3.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi3.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        gil.add(gi2);
                        gil.add(gi3);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Summary__c.club62__Actual__c','club62__Financial_Summary__c.club62__Budget__c'});
                        Reports.ReportManager.runAsyncReport(reportId,meta);
                    }
                }
                if(runNumber>=-1 && runNumber<=2){
                    return true;
                }else{
                    return false;
                }
            }else if(reportType=='genledge'){
                Reports.ReportFilter fil;
                Reports.ReportFilter fil2;
                Reports.ReportFilter fil3;
                Reports.ReportFilter fil4;
                Reports.ReportFilter fil5;
                Reports.ReportFilter fil6;
                Reports.ReportFilter fil7;
                String booleanFilter = '';
                String faQuery = 'select id from club62__Financial_Account__c ';
                if((filter2!=null && filter2!='') || (filter3!=null && filter3!='') || (LocationFilter!=null && locationFilter!='')){
                    faQuery += 'WHERE ';
                }
                Boolean firstFilter = true;
                if(filter2!=null && filter2!=''){
                    faQuery += 'club62__Account_Number__c>= :filter2';
                    firstFilter = false;
                }
                if(filter3!=null && filter3!=''){
                    if(!firstFilter){
                        faQuery += ' AND ';
                    }
                    faQuery += ' club62__Account_Number__c<= :filter3';
                }
                if(locationFilter!=null && locationFilter!= ''){
                    if(!firstFilter){
                        faQuery += ' AND ';
                    }
                    faQuery += ' club62__Location__c=:locationFilter';
                }
                List<club62__Financial_Account__c> faList = database.query(faQuery);
                List<Reports.ReportFilter> filList = new List<Reports.ReportFilter>();
                if(runNumber>0){
                    club62__C62FinancialReportRuns__c frr = club62__C62FinancialReportRuns__c.getInstance(reportType);
                    if(frr!=null){
                        frr.club62__LastRunEndDate__c = eDate;
                        frr.club62__LastRunStartDate__c = sDate2;
                    }else{
                        frr = new club62__C62FinancialReportRuns__c(Name=reportType,club62__LastRunEndDate__c=eDate);
                    }
                    upsert frr;
                    List<AggregateResult> lastSummary = [Select max(club62__Date__c) from club62__Financial_Summary__c where club62__Date__c<=:sDate2 and club62__Yearly_Summary__c = false and club62__Actual__c != 0 and club62__Actual__c !=null];

                    Date lastSummaryDate;
                    if(lastSummary!=null && lastSummary.size()>0){
                        Object temp = lastSummary[0].get('expr0');
                        if(temp!=null){
                            lastSummaryDate = (Date)temp;
                        }
                    }
                    if(lastSummaryDate!=null){
                        fil = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','greaterOrEqual',lastSummaryDate.year()+'-'+lastSummaryDate.month()+'-'+1);
                    }else{
                        fil = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','notEqual','');
                    }
                    fil2 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','lessOrEqual',eDate.year()+'-'+eDate.month()+'-'+eDate.day());
                    fil3 = new Reports.ReportFIlter('club62__Financial_Journal_Line__c.club62__Posted__c','equals','true');
                    //fil4 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Financial_Summary__c.Name','equals','');
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    //filList.add(fil4);
                    Boolean usingFilter = false;
                    if(filter1!= null && filter1!=''){
                        fil7 = new Reports.ReportFilter('club62__Financial_Account__c.Id','equals',filter1);
                        filList.add(fil7);
                        usingFilter = true;
                    }
                    if(filter2!=null && filter2!=''){
                        Reports.ReportFilter filGLS = new Reports.ReportFilter('club62__Financial_Account__c.club62__Account_Number__c','greaterOrEqual',filter2);
                        filList.add(filGLS);
                    }
                    if(filter3!=null && filter3 != ''){
                        Reports.ReportFilter filGLS = new Reports.ReportFilter('club62__Financial_Account__c.club62__Account_Number__c','lessOrEqual',filter3);
                        filList.add(filGLS);
                    }
                    if(!usingFilter){
                        filList.add(new Reports.ReportFilter('club62__Financial_Account__c.Id','equals',(faList[runNumber-1].id+'').substring(0,15)));
                    }
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Account__c.club62__Location__c.Id','equals',locationFilter.left(15)));
                    }
                    runThisRun = true;
                }else if(runNumber==0){
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDate.addDays(-1).year()+'-'+sDate.addDays(-1).month()+'-'+sDate.addDays(-1).day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',sDate2.toStartOfMonth().year()+'-'+sDate2.toStartOfMonth().month()+'-'+sDate2.toStartOfMonth().day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessOrEqual',sDate.addDays(-1).year()+'-'+sDate.addDays(-1).month()+'-'+sDate.addDays(-1).day());
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    fil5 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','true');
                    fil6 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Balance_Sheet_Type__c','notEqual','');
                    booleanFilter = '((1 AND 2 AND 4) OR (3 AND 5 AND 6))';
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    filList.add(fil4);
                    filList.add(fil5);
                    filList.add(fil6);

                    if(filter1!= null && filter1!=''){
                        fil7 = new Reports.ReportFilter('CUST_ID','equals',filter1);
                        filList.add(fil7);
                        booleanFilter += ' AND '+filList.size();

                    }
                    if(filter2!=null && filter2!=''){
                        Reports.ReportFilter filGLS = new Reports.ReportFilter('club62__Financial_Account__c.club62__Account_Number__c','greaterOrEqual',filter2);
                        filList.add(filGLS);
                        booleanFilter += ' AND '+filList.size();
                    }
                    if(filter3!=null && filter3!= ''){
                        Reports.ReportFilter filGLS = new Reports.ReportFilter('club62__Financial_Account__c.club62__Account_Number__c','lessOrEqual',filter3);
                        filList.add(filGLS);
                        booleanFilter += ' AND '+filList.size();
                    }
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                        booleanFilter += ' AND '+filList.size();
                    }
                    runThisRun = true;
                }

                Reports.ReportMetadata meta = new Reports.ReportMetadata();
                meta.setReportFilters(filList);
                meta.setReportBooleanFilter(booleanFilter);
                system.debug(faList.size());
                if(runNumber>0){
                    meta.setHasRecordCount(true);
                    meta.setAggregates(new List<String>{'s!club62__Financial_Journal_Line__c.club62__Amount__c','s!club62__Financial_Journal_Line__c.club62__Debit__c','s!club62__Financial_Journal_Line__c.club62__Credit__c','RowCount'});
                    Reports.GroupingInfo gi = new Reports.GroupingInfo();
                    gi.setName('club62__Financial_Account__c.Id');
                    gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                    gi.setDateGranularity(Reports.DateGranularity.NONE);

                    List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                    gil.add(gi);
                    
                    meta.setGroupingsDown(gil);

                    meta.setHasDetailRows(true);
                    meta.setDetailColumns(new List<String>{'club62__Financial_Journal_Line__c.club62__Account_Number__c','club62__Financial_Journal_Line__c.club62__Transaction_Date__c','club62__Financial_Journal_Line__c.Name','club62__Financial_Journal_Line__c.club62__Description__c','club62__Financial_Journal_Line__c.club62__Amount__c','club62__Financial_Journal_Line__c.club62__Debit__c','club62__Financial_Journal_Line__c.club62__Credit__c','club62__Financial_Journal_Line__c.club62__Financial_Summary__c.Id','club62__Financial_Journal_Line__c.club62__Manual_Journal__c','club62__Financial_Journal_Line__c.club62__Chit_Processing__c'});
                    
                    Reports.ReportManager.runAsyncReport(reportId2,meta,true);
                    if((filter1!=null && filter1!='')){
                        updateNOA(reportType,1);
                        return false;
                    }else if(faList.size()>runNumber){
                        return true;
                    }else{
                        updateNOA(reportType,faList.size());
                        return false;
                    }
                }else if(runNumber==0){
                        meta.setHasRecordCount(true);
                        meta.setAggregates(new List<String>{'s!club62__Financial_Summary__c.club62__Actual__c','s!club62__Financial_Summary__c.club62__Debit__c','s!club62__Financial_Summary__c.club62__Credit__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('CUST_ID');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Summary__c.club62__Actual__c','club62__Financial_Account__c.club62__Account_Number__c','club62__Financial_Summary__c.club62__Debit__c','club62__Financial_Summary__c.club62__Credit__c'});
                        

                    Reports.ReportManager.runAsyncReport(reportId,meta);
                    return true;
                }else{
                    return true;
                }
            }else if(reportType=='trialbal'){
                Reports.ReportFilter fil;
                Reports.ReportFilter fil2;
                Reports.ReportFilter fil3;
                Reports.ReportFilter fil4;
                Reports.ReportFilter fil5;
                Reports.ReportFilter fil6;
                Reports.ReportFilter fil7;
                String booleanFilter = '';
                List<Reports.ReportFilter> filList = new List<Reports.ReportFilter>();
                Date edateMinOne = Date.newInstance(eDate.year(), eDate.month(), 1).addDays(-1);
                if(runNumber==0){
                    club62__C62FinancialReportRuns__c frr = club62__C62FinancialReportRuns__c.getInstance(reportType);
                    if(frr!=null){
                        frr.club62__LastRunEndDate__c = eDate;
                    }else{
                        frr = new club62__C62FinancialReportRuns__c(Name=reportType,club62__LastRunEndDate__c=eDate);
                    }
                    upsert frr;
                    fil = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','lessOrEqual',eDate.year()+'-'+eDate.month()+'-'+eDate.day());
                    fil2 = new Reports.ReportFIlter('club62__Financial_Journal_Line__c.club62__Posted__c','equals','true');
                    fil3 = new Reports.ReportFIlter('club62__Financial_Journal_Line__c.club62__Financial_Summary__c.Name','equals','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','greaterOrEqual',edate.year()+'-'+edate.month()+'-1');
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    if(eDate.isSameDay(eDate.toStartOfmonth().addMonths(1).addDays(-1))){
                        booleanFilter = '1 and 2 and 3';
                    }else{
                        filList.add(fil4);
                        booleanFilter = '((1 AND 2 AND 3) OR (1 AND 2 AND 4))';
                    }
                    if(filter1!='' && filter1!=null){
                        fil7 = new Reports.ReportFilter('club62__Financial_Account__c.Id','equals',filter1);
                        if(eDate.isSameDay(eDate.toStartOfmonth().addMonths(1).addDays(-1))){
                            booleanFilter = '1 and 2 and 3 and 4';
                        }else{
                            booleanFilter = '((1 AND 2 AND 3) OR (1 AND 2 AND 4)) AND 5';
                        }
                        filList.add(fil7);
                    }
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Account__c.club62__Location__c.Id','equals',locationFilter.left(15)));
                        booleanFilter += ' AND '+filList.size();
                    }
                    runThisRun = true;
                }else if(runNumber>0){
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDate.addDays(-1).year()+'-'+sDate.addDays(-1).month()+'-'+sDate.addDays(-1).day());
                    system.debug(eDate);
                    system.debug(eDate.toStartOfmonth().addMonths(1).addDays(-1));
                    if(eDate.isSameDay(eDate.toStartOfmonth().addMonths(1).addDays(-1))){
                        fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessOrEqual',edate.year()+'-'+edate.month()+'-1');
                    }else{
                        fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessOrEqual',edateMinOne.year()+'-'+edateMinOne.month()+'-'+edateMinOne.day());
                    }

                    fil3 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessOrEqual',sDate.addDays(-1).year()+'-'+sDate.addDays(-1).month()+'-'+sDate.addDays(-1).day());
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','False');
                    fil5 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','True');
                    fil6 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Balance_Sheet_Type__c','notEqual','');
                    booleanFilter = '((1 AND 2 AND 4) OR (3 AND 5 AND 6))';
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    filList.add(fil4);
                    filList.add(fil5);
                    filList.add(fil6);
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                        booleanFilter += ' AND '+filList.size();
                    }
                    runThisRun = true;
                }

                Reports.ReportMetadata meta = new Reports.ReportMetadata();
                meta.setReportFilters(filList);
                meta.setReportBooleanFilter(booleanFilter);
                if(runNumber==0){
                    meta.setHasRecordCount(true);
                    meta.setAggregates(new List<String>{'s!club62__Financial_Journal_Line__c.club62__Amount__c','s!club62__Financial_Journal_Line__c.club62__Debit__c','s!club62__Financial_Journal_Line__c.club62__Credit__c','RowCount'}) ;       
                    Reports.GroupingInfo gi = new Reports.GroupingInfo();
                    gi.setName('club62__Financial_Account__c.Id');
                    gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                    gi.setDateGranularity(Reports.DateGranularity.NONE);

                    List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                    gil.add(gi);
                    
                    meta.setGroupingsDown(gil);

                    meta.setDetailColumns(new List<String>{'club62__Financial_Journal_Line__c.club62__Account_Number__c','club62__Financial_Journal_Line__c.club62__Transaction_Date__c','club62__Financial_Journal_Line__c.Name','club62__Financial_Journal_Line__c.club62__Description__c','club62__Financial_Journal_Line__c.club62__Amount__c','club62__Financial_Journal_Line__c.club62__Debit__c','club62__Financial_Journal_Line__c.club62__Credit__c'});
                    
                    Reports.ReportManager.runAsyncReport(reportId2,meta);
                    return true;
                }else if(runNumber>0){
                    meta.setHasRecordCount(true);
                    meta.setAggregates(new List<String>{'s!club62__Financial_Summary__c.club62__Actual__c','s!club62__Financial_Summary__c.club62__Debit__c','s!club62__Financial_Summary__c.club62__Credit__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('CUST_ID');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Summary__c.club62__Actual__c','club62__Financial_Account__c.club62__Account_Number__c','club62__Financial_Summary__c.club62__Debit__c','club62__Financial_Summary__c.club62__Credit__c'});
                        

                    Reports.ReportManager.runAsyncReport(reportId,meta);
                    return false;
                }else{
                    return true;
                }
            }else if(reportType=='actsheetann' || reportType=='budgetonly'){
                Reports.ReportFilter fil;
                Reports.ReportFilter fil2;
                Reports.ReportFilter fil3;
                Reports.ReportFilter fil4;
                Date eDateLY = sDate.addDays(-1);
                Date sDateLY;
                if(runNumber==12){
                    ///////////////
                    String eDateMonthLY = eDateLY.month()+'';
                    String eDateYearLY = eDateLY.year()+'';
                    List<club62__Financial_Closing__c> fcloseListLY = [Select id,club62__FiscalStartMonth__c, club62__FiscalEndMonth__c from club62__Financial_Closing__c where club62__year_string__c = :eDateYearLY and club62__month__c = :eDateMonthLY];
                    Integer fiscalStartLY;
                    Integer fiscalEndLY;
                    if(fcloseListLY!=null &&fcloseListLY.size()>0){
                        fiscalStartLY = Integer.valueOf(fcloseListLY[0].club62__FiscalStartMonth__c);
                        fiscalEndLY = Integer.valueOf(fcloseListLY[0].club62__FiscalEndMonth__c);
                    }
                    Integer monthLY;
                    if(fiscalStartLY!=null){
                        monthLY = fiscalStartLY;
                    }else{
                        monthLY = sDate.month();
                    }
                    if(monthLY!=null){
                        if(eDateLY.month()<monthLY){
                            sDateLY = Date.newInstance(eDateLY.addYears(-1).year(),monthLY,1);
                        }else{
                            sDateLY = Date.newInstance(eDateLY.year(),monthLY,1);
                        }
                        eDateLY = sDateLY.addYears(1).addDays(-1);
                        if(fiscalEndLY!=null){
                            eDateLY = Date.newInstance(eDateLY.year(),fiscalEndLY,1).addMonths(1).addDays(-1);
                        }
                    }

                    //////////////
                    runThisRun = true;
                }
                List<Reports.ReportFilter> filList = new List<Reports.ReportFilter>();
                if(runNumber==0){
                    club62__C62FinancialReportRuns__c frr = club62__C62FinancialReportRuns__c.getInstance(reportType);
                    if(frr!=null){
                        frr.club62__LastRunEndDate__c = eDate;
                    }else{
                        frr = new club62__C62FinancialReportRuns__c(Name=reportType,club62__LastRunEndDate__c=eDate);
                    }
                    upsert frr;
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDate.year()+'-'+sDate.month()+'-'+sDate.day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',sDate.addMonths(1).addDays(-1).year()+'-'+sDate.addMonths(1).addDays(-1).month()+'-'+sDate.addMonths(1).addDays(-1).day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                    }
                    runThisRun = true;
                }else if(runNumber<=11 && runNumber!=-1){
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDate.addMonths(runNumber).year()+'-'+sDate.addMonths(runNumber).month()+'-'+sDate.addMonths(runNumber).day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',sDate.addMonths(runNumber+1).addDays(-1).year()+'-'+sDate.addMonths(runNumber+1).addDays(-1).month()+'-'+sDate.addMonths(runNumber+1).addDays(-1).day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                    }
                    runThisRun = true;
                }else if(runNumber>0){
                    fil = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','greaterOrEqual',sDateLY.year()+'-'+sDateLY.month()+'-'+sDateLY.day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Date__c','lessThan',eDateLY.year()+'-'+eDateLY.month()+'-'+eDateLY.day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Summary__c.club62__Yearly_Summary__c','equals','false');
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Summary__c.club62__Financial_Account_Location__c','equals',locationFilter.left(15)));
                    }
                    system.debug(fil);
                    system.debug(fil2);
                    runThisRun = true;
                }else if(runNumber == -1){
                    Integer currentMonth = asOfDate.month();
                    Date sDateFJ = sDate;
                    Boolean foundMonth = false;
                    while(!foundMonth){
                        if(sDateFJ.month()==currentMonth){
                            foundMonth = true;
                        }else{
                            sDateFJ = sDateFj.addMonths(1);
                        }
                    }
                    fil = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','greaterOrEqual',sDateFj.year()+'-'+sDateFj.month()+'-'+sDateFj.day());
                    fil2 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Transaction_Date__c','lessThan',sDateFj.addMonths(1).addDays(-1).year()+'-'+sDateFj.addMonths(1).addDays(-1).month()+'-'+sDateFj.addMonths(1).addDays(-1).day());
                    fil3 = new Reports.ReportFilter('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','notEqual','');
                    fil4 = new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Financial_Summary__c.Name','equals','');
                    filList.add(new Reports.ReportFilter('club62__Financial_Journal_Line__c.club62__Posted__c','equals','true'));
                    if(locationFilter!=null && locationFilter!=''){
                        filList.add(new Reports.ReportFilter('club62__Financial_Account__c.club62__Location__c.Id','equals',locationFilter.left(15)));
                    }
                    runThisRun = true;
                }
                if(runThisRun==true){
                    filList.add(fil);
                    filList.add(fil2);
                    filList.add(fil3);
                    filList.add(fil4);
                    Reports.ReportMetadata meta = new Reports.ReportMetadata();
                    meta.setReportFilters(filList);
                    if(runNumber==-1){
                        meta.setHasRecordCount(true);
                        meta.setAggregates(new List<String>{'s!club62__Financial_Journal_Line__c.club62__Debit__c','s!club62__Financial_Journal_Line__c.club62__Credit__c','s!club62__Financial_Journal_Line__c.club62__Amount__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('club62__Financial_Account__c.Id');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Journal_Line__c.club62__Account_Number__c','club62__Financial_Journal_Line__c.club62__Transaction_Date__c','club62__Financial_Journal_Line__c.Name','club62__Financial_Journal_Line__c.club62__Description__c','club62__Financial_Journal_Line__c.club62__Debit__c','club62__Financial_Journal_Line__c.club62__Credit__c','club62__Financial_Journal_Line__c.club62__Amount__c','club62__Financial_Account__c.club62__Statement_of_Activities_Type__c','club62__Financial_Account__c.club62__Statement_of_Activities_Sub_Type__c'});
                        
                        Reports.ReportManager.runAsyncReport(reportId2,meta);
                    }else{
                        meta.setHasRecordCount(true);
                        meta.setAggregates(new List<String>{'s!club62__Financial_Summary__c.club62__Actual__c','s!club62__Financial_Summary__c.club62__Budget__c','RowCount'});
                        Reports.GroupingInfo gi = new Reports.GroupingInfo();
                        gi.setName('club62__Financial_Account__c.club62__Statement_of_Activities_Type__c');
                        gi.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi.setDateGranularity(Reports.DateGranularity.NONE);
                        Reports.GroupingInfo gi2 = new Reports.GroupingInfo();
                        gi2.setName('club62__Financial_Account__c.club62__Statement_of_Activities_Sub_Type__c');
                        gi2.setSortOrder('ASCENDING');
                        gi2.setDateGranularity('NONE');
                        Reports.GroupingInfo gi3 = new Reports.GroupingInfo();
                        gi3.setName('CUST_ID');
                        gi3.setsortOrder(Reports.ColumnSortOrder.ASCENDING);
                        gi3.setDateGranularity(Reports.DateGranularity.NONE);

                        List<Reports.GroupingInfo> gil = new List<Reports.groupinginfo>();
                        gil.add(gi);
                        gil.add(gi2);
                        gil.add(gi3);
                        
                        meta.setGroupingsDown(gil);
                        meta.setDetailColumns(new List<String>{'club62__Financial_Summary__c.club62__Actual__c','club62__Financial_Summary__c.club62__Budget__c'});
                        
                        Reports.ReportManager.runAsyncReport(reportId,meta);
                    }
                }
                if(runNumber>=-1 && runNumber<=11){
                    return true;
                }else{
                    return false;
                }
            }
        }
        return false;
    }
    //Update custom setting for GL report with how many accounts were run
    public static void updateNOA(String reportType, Integer noa){
        club62__C62FinancialReportRuns__c frr = club62__C62FinancialReportRuns__c.getInstance(reportType);
        frr.club62__Number_of_Accounts__c = noa;
        update frr;
    }
    //Redirects user to the VF page for the selected report.
    public PageReference viewReport(){
        PageReference pr;
        Date sDated;
        Date asOfDate = eDate.club62__Date__c;
        Integer fiscalEnd;
        if(eDate!=null){
            List<Organization> org = [Select id,FiscalYearStartMonth from Organization limit 1];
            String eDateMonth = eDate.club62__Date__c.month()+'';
            String eDateYear = eDate.club62__Date__c.year()+'';
            List<club62__Financial_Closing__c> fcloseList = [Select id,club62__FiscalStartMonth__c, club62__FiscalEndMonth__c from club62__Financial_Closing__c where club62__year_string__c = :eDateYear and club62__month__c = :eDateMonth];
            Integer fiscalStart;
            if(fcloseList!=null &&fcloseList.size()>0){
                fiscalStart = Integer.valueOf(fcloseList[0].club62__FiscalStartMonth__c);
                fiscalEnd = Integer.valueOf(fcloseList[0].club62__FiscalEndMonth__c);
            }
            Integer month;
            if(fiscalStart!=null){
                month = fiscalStart;
            }else if(org.size()>0){
                 month = org[0].FiscalYearStartMonth;
            }
            if(month!=null){
                if(eDate.club62__Date__c.month()<month){
                    sDated = Date.newInstance(eDate.club62__Date__c.addYears(-1).year(),month,1);
                }else{
                    sDated = Date.newInstance(eDate.club62__Date__c.year(),month,1);
                }
            }
        }else{
            sDated = Date.today();
        }
        if(reportType=='genledge' || reportType=='trialbal'){
            //sDated = eDate.club62__Date__c.addMonths(-1).addDays(1);
            sDated = sDate.club62__Date__c;
        }
        if(reportType=='actsheetann' || reportType=='budgetonly'){
            eDate.club62__Date__c = sDated.addYears(1).addDays(-1);
            if(fiscalEnd!=null){
                eDate.club62__Date__c = Date.newInstance(eDate.club62__Date__c.year(),fiscalEnd,1).addMonths(1).addDays(-1);
            }
        }
        if(reportType!=null && reportType!=''){
            if(reportType=='balsheet'){
                pr = Page.club62__C62BalanceSheetReport;
                pr.getparameters().put('details',showDetails+'');
                pr.getparameters().put('nmonth',numMonths+'');
            }else if(reportType=='actsheet'){
                pr = Page.club62__C62ActivitySheetReport;
            }else if(reportType=='fsched'){
                pr = Page.club62__C62FinancialScheduleReport;
            }else if(reportType=='genledge'){
                pr = Page.club62__C62GeneralLedgerReport;
                pr.getParameters().put('noa',club62__C62FinancialReportRuns__c.getInstance(reportType).club62__Number_of_Accounts__c+'');

            }else if(reportType=='trialbal'){
                pr = Page.club62__C62TrialBalanceReport;
            }else if(reportType=='actsheetann' || reportType=='budgetonly'){
                pr = Page.club62__C62AnnualActivitySheetReport;
                pr.getparameters().put('a',asOfDate.year()+'-'+asOfDate.month()+'-'+asOfDate.day());
                if(reportType=='budgetonly'){
                    pr.getparameters().put('budget','1');
                }
            }
            pr.getparameters().put('s',sDated.year()+'-'+sDated.month()+'-'+sDated.day());
            pr.getparameters().put('e',eDate.club62__Date__c.year()+'-'+eDate.club62__Date__c.month()+'-'+eDate.club62__Date__c.day());
            pr.getparameters().put('Id',reportId);
            pr.getparameters().put('rId',reportId2);
            pr.setRedirect(true);
        }
        return pr;
    }

}