public with sharing class C62GeneralLedgerReportController {
    //This is a map of string to ReportSection class (inner class)
    public Map<String,DataRowList> dataRowMap{get;set;}
    public Date openingDate{get;set;}
    public Date closingDate{get;set;}
    public String endDate{get;set;}
    public String startDate{get;set;}
    public Boolean exportExcel{get;set;}
    public String cType{get;set;}
    public Boolean isDiag{get;set;}
    public C62GeneralLedgerReportController(){
        String reportid = ApexPages.currentPage().getparameters().get('rId');
        String reportidsum = ApexPages.currentPage().getparameters().get('Id');
        String openDateString = ApexPages.currentPage().getparameters().get('s');
        endDate = openDateString;
        String closeDateString = ApexPages.currentPage().getparameters().get('e');
        String nOAString =  ApexPages.currentPage().getparameters().get('noa');
        String diag = ApexPages.currentPage().getParameters().get('diag');
        if(diag!=null){
            isDiag = true;
        }
        Integer numOfAccounts = 1;
        if(nOAString!=null && nOAString!=''){
            numOfAccounts = Integer.valueOf(nOAString);
        }
        startDate = closeDateString;

        if(openDateString!=null && openDateString!=''){
            openingDate = Date.valueOf(openDateString);
        }
        if(closeDateString!=null && closeDateString!=''){
            closingDate = Date.valueOf(closeDateString);
        }
        exportExcel = false;
        cType='';
        String exportExcelString = ApexPages.currentPage().getparameters().get('x');
        if(exportExcelString!=null && exportExcelString=='true'){
            exportExcel = true;
            cType= 'application/vnd.ms-excel#GeneralLedger'+DateTime.newInstance(closingDate,datetime.now().time()).format('yyyy-MM-dd')+'.xls';
        }
        if(reportId==null || reportId==''){
            reportid = '00Oo0000002dY5r';
        }
        if(reportidsum==null || reportidsum==''){
            reportidsum = '00Oo0000002dY1e';
        }
        LIST<Reports.ReportInstance> ril = Reports.ReportManager.getReportInstances(reportid);
        Reports.ReportInstance ri;
        if(ril.size()>0 && ril[0].getstatus()=='Success')
            ri = ril[0];
        LIST<Reports.ReportInstance> ril2 = Reports.ReportManager.getReportInstances(reportidsum);
        Reports.ReportInstance ri2;
       if(ril2.size()>0 && ril2[0].getstatus()=='Success')
            ri2 = ril2[0];
       if(ri!=null){
           Map<Id,club62__Financial_Account__c> faMap = new Map<Id,club62__Financial_Account__c>([Select id,Name,club62__Account_Number__c,club62__Category__c,club62__Debit_Credit__c  from club62__Financial_Account__c]);
           Reports.ReportResults res = ri.getReportResults();
           MAP<String,Reports.ReportFact> factMap = res.getFactMap();
           LIST<Reports.GroupingValue> groupDown = res.getGroupingsDown().getGroupings();
           dataRowMap = populateBeginningBalance(datarowmap,ri2.getReportResults().getFactMap(), ri2.getReportResults().getGroupingsDown().getGroupings(),faMap);
           for(Integer i=0;i<numOfAccounts;i++){
            datarowMap = getDataRows(datarowMap,ril[i].getReportResults().getFactMap(),ril[i].getReportResults().getGroupingsDown().getGroupings(),faMap,openingDate);
           }
           system.debug(groupDown);

       }

    }
    public Map<String,DataRowList> populateBeginningBalance(Map<String,DataRowList> drMap, Map<String,Reports.ReportFact> factMap, List<Reports.GroupingValue> groupDown,Map<Id,club62__Financial_Account__c> faMap){
        if(drmap==null){
            drMap = new Map<String,DataRowList>();
        }
        Map<String,GroupingSection> groupMap = new Map<String,GroupingSection>();
        for(Reports.GroupingValue gv : groupDown){
            if(!groupMap.containsKey(gv.getKey())){
                groupMap.put(gv.getKey(),new GroupingSection(gv.getLabel(),(String)gv.getValue(),gv.getKey()));
            }
        }
        system.debug(groupDown);
        system.debug(groupMap);
        system.debug(factMap.values());
        for(Reports.ReportFact fact : factMap.values()){
            String factKey = fact.getKey().substring(0,fact.getKey().indexOf('!'));
            GroupingSection gs = groupMap.get(factKey);
            system.debug(gs);
            system.debug(faMap);
            if(gs!=null && faMap.get(gs.faId)!=null){
                String accNum = faMap.get(gs.faId).club62__Account_Number__c;
                String accName = faMap.get(gs.faId).Name;
                Reports.SummaryValue sumVal = fact.getAggregates()[0];
                Decimal val = ((Decimal)sumVal.getValue()).setScale(2);
                if(faMap.get(gs.faId).club62__Debit_Credit__c == 'Credit'){
                    val *= -1;
                }
                if(!drMap.containsKey(gs.faId)){
                    drMap.put(gs.faId,new DataRowList(gs.faId,accName,accNum));
                    drMap.get(gs.faId).dataRowLst.add(new DataRow());
                }
                if(drMap.containsKey(gs.faId)){
                    drMap.get(gs.faId).startingBalance = val;
                    drMap.get(gs.faid).debit = 0;
                    drMap.get(gs.faId).credit = 0;
                }

            }
        }
        return drMap;
    }
    public Map<String,DataRowList> getDataRows(Map<String,DataRowList> drMap, Map<String,Reports.ReportFact> factMap, List<Reports.GroupingValue> groupDown,Map<Id,club62__Financial_Account__c> faMap,Date sDate){
        Map<String,GroupingSection> groupMap = new Map<String,GroupingSection>();
        for(Reports.GroupingValue gv : groupDown){
            if(!groupMap.containsKey(gv.getKey())){
                groupMap.put(gv.getKey(),new GroupingSection(gv.getLabel(),(String)gv.getValue(),gv.getKey()));
            }
        }
        Map<String,DataRowList> returnedDataRowMap;

        if(drmap==null){
            returnedDataRowMap = new Map<String,DataRowList>();
        }else{
            returnedDataRowMap = drMap;
        }

        for(Reports.ReportFactWithDetails reportFact : (List<Reports.ReportFactWithDetails>)factMap.values()){
            if(reportFact!=null){
                String factKey = reportFact.getKey().substring(0,reportFact.getKey().indexOf('!'));
                Reports.SummaryValue sumVal = reportFact.getAggregates()[1];
                Reports.SummaryValue sumVal2 = reportFact.getAggregates()[2];
                Decimal debit = ((Decimal)sumVal.getValue()).setScale(2);
                Decimal credit = ((Decimal)sumVal2.getValue()).setScale(2);

                club62__Financial_Account__c fa;
                if(groupMap!=null && groupMap.containsKey(factKey) && groupMap.get(factKey).faId!=null && faMap.containsKey(groupMap.get(factKey).faId)){
                    fa = faMap.get(groupMap.get(factKey).faId);
                    if(fa!=null && fa.Id!=null && returnedDataRowMap.containsKey(fa.Id) && returnedDataRowMap.get(fa.Id).dataRowLst!=null){
                        returnedDataRowMap.get(fa.Id).dataRowLst.clear();
                    }
                }
                for(Reports.ReportDetailRow row : reportFact.getRows()){
                    List<Reports.ReportDataCell> rdc = row.getDataCells();
                    Date fjDate = (Date)rdc[1].getValue();
                    if(fjDate>=sDate){
                        DataRow dr = new DataRow();
                        dr.accountNumber = (String)rdc[0].getValue();
                        dr.name = fa.name;
                        dr.faId = fa.Id;
                        if(dr.accountNumber==null && dr.faId!=null && faMap.containsKey(dr.faId)){
                            dr.accountNumber = fa.club62__Account_Number__c;
                        }
                        dr.fjDate = (Date)rdc[1].getValue();
                        dr.fjName = (String)rdc[2].getLabel();
                        dr.fjId = (String)rdc[2].getValue();
                        dr.description = (String)rdc[3].getLabel();
                        Boolean isChitProcessing = (Boolean)rdc[9].getValue();
                        Boolean isManualEntry = (Boolean)rdc[8].getValue();
                        Boolean isFJLMan = false;
                        if(isManualEntry!=null && isManualEntry == true){
                            isFJLMan = true;
                        }
                        if(isChitProcessing!=null && isChitProcessing == true){
                            isFJLMan = false;
                        }
                        dr.isManLine = isFJLMan;
                        if((Reports.ReportCurrency)rdc[5].getValue()!=null)
                            dr.debit = ((Reports.ReportCurrency)rdc[5].getValue()).getAmount();
                        if((Reports.ReportCurrency)rdc[6].getValue()!=null)
                            dr.credit = ((Reports.ReportCurrency)rdc[6].getValue()).getAmount();
                        if(!returnedDataRowMap.containsKey(dr.faId)){
                            returnedDataRowMap.put(dr.faId,new DataRowList(dr.faId,dr.name,dr.accountNumber));
                        }
                        returnedDataRowMap.get(dr.faId).DataRowLst.add(dr);
                        if(returnedDataRowMap.get(dr.faId).debit==null){
                            returnedDataRowMap.get(dr.faId).debit = dr.debit;
                        }else if(dr.debit!=null){
                            returnedDataRowMap.get(dr.faId).debit += dr.debit;
                        }
                        if(returnedDataRowMap.get(dr.faId).credit==null){
                            returnedDataRowMap.get(dr.faId).credit = dr.credit;
                        }else if(dr.credit!=null){
                            returnedDataRowMap.get(dr.faId).credit += dr.credit;
                        }
                        if(returnedDataRowMap.get(dr.faId).accNumber==null){
                            returnedDataRowMap.get(dr.faId).accNumber = dr.accountNumber;
                        }
                    }else{
                        Decimal debitC = 0;
                        Decimal creditC = 0;
                        if(((Reports.ReportCurrency)rdc[5].getValue())!=null){
                            debitC = ((Reports.ReportCurrency)rdc[5].getValue()).getAmount();
                        }
                        if((Reports.ReportCurrency)rdc[6].getValue()!=null){
                            creditC = ((Reports.ReportCurrency)rdc[6].getValue()).getAmount();
                        }
                        Decimal amount = debitC - creditC;
                        String faId = groupMap.get(factKey).faId;
                        if(returnedDataRowMap.containsKey(faid)){
                            if(returnedDataRowMap.get(faId).startingBalance == null){
                                returnedDataRowMap.get(faid).startingBalance = 0;
                            }
                            returnedDataRowMap.get(faid).startingBalance += amount;
                        }
                    }
                }
                if(fa!=null && returnedDataRowMap.containsKey(fa.Id)){
                    if(returnedDataRowMap.get(fa.Id).debit == null){
                        returnedDataRowMap.get(fa.Id).debit = 0;
                    }
                    if(returnedDataRowMap.get(fa.Id).credit == null){
                        returnedDataRowMap.get(fa.Id).credit = 0;
                    }
                }

            }
        }
        return returnedDataRowMap;
    }
   public class GroupingSection{
       public String name{get;set;}
       public String faId{get;set;}
       public String key{get;set;}
       public String accountNumber{get;set;}

       public GroupingSection(String name, String faId, String key){
           this.name = name;
           this.faId = faId;
           this.key = key;
       }
       public GroupingSection(){}
   }
   public class DataRow implements Comparable{
    public String name{get;set;}
    public String accountNumber{get;set;}
    public String faId{get;set;}
    public String fjName{get;set;}
    public String fjId{get;set;}
    public Decimal debit{get;set;}
    public Decimal credit{get;set;}
    public Date fjDate{get;set;}
    public String description{get;set;}
    public Boolean isManLine{get;set;}

    public Integer compareTo(Object toCompare){
        DataRow compare = (DataRow)toCompare;
        if(fjDate!=null){
            if(fjDate == Compare.fjDate){
                return 0;
            }else if(fjDate<compare.fjDate){
                return -1;
            }
            return 1;
        }else{
            return -1;
        }

    }
   }
   public class DataRowList implements Comparable{
    public List<DataRow> dataRowLst{get;set;}
    public Decimal debit{get;set;}
    public Decimal credit{get;set;}
    public Decimal startingBalance{get;set;}
    public String accNumber{get;set;}
    public String faId{get;set;}
    public String name{get;set;}
    public DataRowList(String faId, String name, String accNumber){
        this.faId = faId;
        this.name = name;
        this.accNumber = accNumber;
        dataRowLst = new List<DataRow>();
        startingBalance=0;
    }
    public Integer compareTo(Object c){
        DataRowList compare = (DataRowList)c;
        if(accNumber == compare.accNumber){
            return 0;
        }
        if(accNumber< compare.accNumber){
            return -1;
        }
        else{
            return 1;
        }
    }
    public List<DataRow> getDataRows(){
        dataRowLst.sort();
        return dataRowLst;
    }
   }
public List<DataRowList> getDataRowMapValues(){

    List<DataRowList> drlTemp = new List<DataRowList>();
    if(DataRowMap!=null && DataRowMap.keySet().size()>0){drlTemp = DataRowMap.values();}
    drlTemp.sort();
    return drlTemp;
}
public PageReference getRedirectExcel(){
       PageReference pr = ApexPages.currentPage();
        for(String s : ApexPages.currentPage().getParameters().keySet()){
            pr.getParameters().put(s,ApexPages.currentPage().getParameters().get(s));
        }
        pr.getParameters().put('x','true');
        pr.setRedirect(true);
        return pr;
   }
}