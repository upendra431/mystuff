/*
@Name            : C62BalanceSheetController
@Author          : customersuccess@cloud62.com
@Date            : February 24, 2014
@Description     : Controller for BalanceSheet visualforce page
*/
public with sharing class C62BalanceSheetController {
    public Boolean batchRunning{get;set;}
    //isAsset->Type->Subtype->Financial Journal
    public Map<Boolean,CurrencyWrapper> balMap{get;set;}

    public Decimal cyAmount{get;set;}
    public club62__Financial_Summary__c sumDate{get;set;}
    public Club62__Financial_Account__c selectedLocation{get;set;}
    public Integer fiscalStartMonth {get;set;}
    public C62BalanceSheetController(ApexPages.StandardController stdController) {
        fiscalStartMonth = [Select FiscalYearStartMonth from Organization limit 1].FiscalYearStartMonth;
        sumDate = new club62__Financial_Summary__c();
        sumDate.club62__Date__c = Date.today();
        selectedLocation = new Club62__Financial_Account__c();
    }
    public void doNothing(){}
    //Load balance sheet based on selected Month and selected year
    public void generateBalanceSheet(){
        Date asOfDate = sumDate.club62__Date__c;
        Date fiscalDate;
        if(fiscalStartMonth<asOfDate.Month()){
            fiscalDate = Date.newInstance(asOfDate.year(), fiscalStartMonth, 1);
        }else{
            fiscalDate = Date.newInstance(asOfDate.year()-1, fiscalStartMonth, 1);
        }
        if(asOfDate!=null){
            String finSumQuery = 'Select Id, Club62__Financial_Account__r.Statement_Of_Activities_Type__c, Club62__Actual__c, Club62__Financial_Account__c, Club62__Financial_Account__r.Club62__Category__c,Club62__Financial_Account__r.Name,Club62__Financial_Account__r.club62__Account_Number__c, Club62__Balance_Sheet_Type__c,Club62__Financial_Account__r.Club62__Balance_Sheet_Sub_Type__c,(Select id,Club62__Financial_Account__r.Statement_Of_Activities_Type__c, Club62__Account_Number__c,Club62__Account_Name__c,Club62__Amount__c,Club62__Financial_Account__c,Club62__Financial_Account__r.Club62__Account_Number__c from Club62__Financial_Journal_Lines__r where Club62__posted__c=true) from Club62__Financial_Summary__c where ((Club62__Date__c>=:fiscalDate or Club62__Yearly_Summary__c = true) and Club62__Date__c<=:asOfDate) and (Club62__Balance_Sheet_Type__c!=null or Club62__Activity_Sheet_Type__c!=null)';
            String fjlSumQuery = 'Select Id, Club62__Financial_Account__r.Statement_Of_Activities_Type__c, Club62__Amount__c, Club62__Financial_Account__c, Club62__Financial_Account__r.Club62__Category__c,Club62__Financial_Account__r.Name,Club62__Financial_Account__r.Club62__Balance_Sheet_Type__c, Club62__Financial_Account__r.Club62__Balance_Sheet_Sub_Type__c,Club62__Account_Number__c,Club62__Account_Name__c,Club62__Financial_Account__r.Club62__Account_Number__c from Club62__Financial_Journal_Line__c where Club62__Posted__c = true and Club62__Transaction_Date__c>=:fiscalDate and Club62__Transaction_Date__c<=:asOfDate and Club62__Financial_Summary__c=null and (Club62__Financial_Account__r.Club62__Balance_Sheet_Type__c != null or Club62__Financial_Account__r.Club62__Statement_Of_Activities_Type__c!=null)';
            if(selectedLocation.Club62__Location__c!=null){
                finSumQuery+=' AND Club62__Location__c=\''+String.escapeSingleQuotes(((String)selectedLocation.Club62__Location__c).left(15))+'\'';
                fjlSumQuery+=' AND Club62__Location__c=\''+String.escapeSingleQuotes(((String)selectedLocation.Club62__Location__c).left(15))+'\'';
            }
            
            List<Club62__Financial_Summary__c> finSumList = database.Query(finSumQuery);
            List<Club62__Financial_Journal_Line__c> fjlSumList = database.Query(fjlSumQuery);
            cyAmount = 0;
            
            balMap = new Map<Boolean,CurrencyWrapper>();
            CurrencyWrapper cw;
            for(club62__Financial_Summary__c fs : finSumList){
                if(fs.club62__Financial_Account__r.club62__Category__c=='Assets' || (fs.club62__Financial_Account__r.club62__Statement_of_Activities_Type__c !=null && fs.club62__Financial_Account__r.club62__Statement_of_Activities_Type__c != 'Revenue'))
                    cyAmount+=fs.club62__Actual__c;
                else
                    cyAmount-=fs.club62__Actual__c;
                    
                Decimal amt = 0;
                if(fs.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c!=null && fs.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c == 'Revenue'){
                    amt = fs.club62__Actual__c;
                }else if(fs.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c!=null){
                    amt = -fs.club62__Actual__c;
                }else{
                    amt = fs.club62__Actual__c;
                }
                if(!balMap.containsKey(fs.club62__Financial_Account__r.club62__Category__c!='Assets')){
                    balMap.put(fs.club62__Financial_Account__r.club62__Category__c!='Assets',new CurrencyWrapper(fs.club62__Financial_Account__r.club62__Category__c!='Assets',fs.club62__Actual__c));
                }else{
                    balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').amount+=fs.club62__Actual__c;
                }
                if(fs.club62__Balance_Sheet_Type__c!=null){
                    if(!balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.containsKey(fs.club62__Balance_Sheet_Type__c)){
                        balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.put(fs.club62__Balance_Sheet_Type__c,new CurrencyWrapper(fs.club62__Balance_Sheet_Type__c,fs.club62__Actual__c));
                    }else{
                        balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fs.club62__Balance_Sheet_Type__c).Amount+=fs.club62__Actual__c;
                    }
                    if(!balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fs.club62__Balance_Sheet_Type__c).cw.containsKey(fs.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c)){
                        balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fs.club62__Balance_Sheet_Type__c).cw.put(fs.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c,new CurrencyWrapper(fs.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c,fs.club62__Actual__c,fs.club62__Financial_Account__r.club62__Category__c=='Assets'));
                    }else{
                        balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fs.club62__Balance_Sheet_Type__c).cw.get(fs.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c).Amount+=fs.club62__Actual__c;
                    }
                    balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fs.club62__Balance_Sheet_Type__c).cw.get(fs.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c).addSummary(fs);
                }else{
                    
                    if(!balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.containsKey('Member\'s Equity')){
                    balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.put('Member\'s Equity',new CurrencyWrapper('Member\'s Equity',amt));
                    }else{
                        balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').Amount+=amt;
                    }
                    if(!balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.containsKey('Current Year Retained Earnings')){
                        balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.put('Current Year Retained Earnings',new CurrencyWrapper('Current Year Retained Earnings',amt,fs.club62__Financial_Account__r.club62__Category__c=='Assets'));
                    }else{
                        balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.get('Current Year Retained Earnings').Amount+=amt;
                    }
                    balMap.get(fs.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.get('Current Year Retained Earnings').addSummary(fs);
                }
            }
            for(club62__Financial_Journal_Line__c fjl : fjlSumList){
                if(fjl.club62__Financial_Account__r.club62__Category__c=='Assets' || (fjl.club62__Financial_Account__r.club62__Statement_of_Activities_Type__c !=null &&fjl.club62__Financial_Account__r.club62__Statement_of_Activities_Type__c != 'Revenue'))
                    cyAmount+=fjl.club62__Amount__c;
                else
                    cyAmount-=fjl.club62__Amount__c;
                    
                Decimal amt = 0;
                if(fjl.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c != null && fjl.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c == 'Revenue'){
                    amt = fjl.club62__Amount__c;
                }else if(fjl.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c!=null){
                    amt = -fjl.club62__Amount__c;
                }else {
                    amt = fjl.club62__Amount__c;
                }
                if(!balMap.containsKey(fjl.club62__Financial_Account__r.club62__Category__c!='Assets')){
                    balMap.put(fjl.club62__Financial_Account__r.club62__Category__c!='Assets',new CurrencyWrapper(fjl.club62__Financial_Account__r.club62__Category__c=='Assets',amt));
                }else{
                    balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').amount+=amt;
                }
                if(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c!=null){
                    if(!balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.containsKey(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c)){
                        balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.put(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c,new CurrencyWrapper(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c,fjl.club62__Amount__c));
                    }else{
                        balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c).Amount+=fjl.club62__Amount__c;
                    }
                    if(!balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c).cw.containsKey(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c)){
                        balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c).cw.put(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c,new CurrencyWrapper(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c,fjl.club62__Amount__c,fjl.club62__Financial_Account__r.club62__Category__c=='Assets'));
                    }else{
                        balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c).cw.get(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c).Amount+=fjl.club62__Amount__c;
                    }
                    balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Type__c).cw.get(fjl.club62__Financial_Account__r.club62__Balance_Sheet_Sub_Type__c).addJournal(fjl);
                }else{
                    
                    if(!balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.containsKey('Member\'s Equity')){
                    balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.put('Member\'s Equity',new CurrencyWrapper('Member\'s Equity',amt));
                    }else{
                        balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').Amount+=amt;
                    }
                    if(!balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.containsKey('Current Year Retained Earnings')){
                        balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.put('Current Year Retained Earnings',new CurrencyWrapper('Current Year Retained Earnings',amt,fjl.club62__Financial_Account__r.club62__Category__c=='Assets'));
                    }else{
                        balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.get('Current Year Retained Earnings').Amount+=amt;
                    }
                    balMap.get(fjl.club62__Financial_Account__r.club62__Category__c!='Assets').cw.get('Member\'s Equity').cw.get('Current Year Retained Earnings').addJournal(fjl);
                }
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR,'As of Date must be selected.'));
            return;
        }
    }
    public class CurrencyWrapper implements Comparable{
        public String name{get;set;}
        public Decimal amount{get;set;}
        public Boolean isAsset{get;set;}
        public Map<String,CurrencyWrapper> cw{get;set;}
        //public List<BalanceSheetWrapper> bsw{get;set;}
        public Map<String,FinancialJournalWrapper> fjMap{get;set;}
        public String smallestGL{get;set;}
        public CurrencyWrapper(String n, Decimal a){
            name = n;
            amount = a;
            cw = new Map<String,CurrencyWrapper>();
        }
        public CurrencyWrapper(Boolean b, Decimal a){
            isAsset = b;
            amount = a;
            cw = new Map<String,CurrencyWrapper>();
        }
        public CurrencyWrapper(String n, Decimal a, Boolean bswEnable){
            this(n,a);
            smallestGL='';
            //bsw = new List<BalanceSheetWrapper>();
            fjMap = new Map<String,FinancialJournalWrapper>();
        }
        public List<CurrencyWrapper> getcwValues(){
            List<CurrencyWrapper> cwList = cw.values();
            cwList.sort();
            return cwList;
        }
        public Integer compareTo(Object compareTo){
            CurrencyWrapper cw = (CurrencyWrapper)compareTo;
            if(isAsset!=null){
                if(isAsset==cw.isAsset){
                    return 0;
                }else if(isAsset==false && cw.isAsset == true){
                    return 1;
                }else{
                    return -1;
                }
            }else if(smallestGL!=null){
                if(smallestGL==cw.smallestGL){
                    return 0;
                }else if(smallestGL > cw.smallestGL){
                    return 1;
                }else{
                    return -1;
                }
            }else{
                if(name==cw.name){
                    return 0;
                }else if(name > cw.name){
                    return 1;
                }else{
                    return -1;
                }
            }
        }
        public void addSummary(club62__Financial_Summary__c fs){
            Decimal amt = 0;
            if(fs.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c != null && fs.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c == 'Revenue'){
                amt = fs.club62__Actual__c;
            }else if(fs.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c!= null){
                amt = -fs.club62__Actual__c;
            }else{
                amt = fs.club62__Actual__c;
            }
            for(club62__Financial_Journal_Line__c fj : fs.club62__Financial_Journal_Lines__r){
                if(!fjMap.containsKey(fj.club62__Financial_Account__c)){
                    fjMap.put(fj.club62__Financial_Account__c,new FinancialJournalWrapper(fj.club62__Account_Name__c,amt,fj.club62__financial_account__c,fj.club62__Account_Number__c));
                }else{
                    fjMap.get(fj.club62__Financial_Account__c).addAmt(amt);
                }
                if(smallestGL=='' || smallestGL>fj.club62__Account_Number__c){
                    smallestGL = fj.club62__Account_Number__c;
                }
            }
            if(fs.club62__Financial_Journal_Lines__r.size()==0){
                if(fjMap.containsKey(fs.club62__Financial_Account__c))
                    fjMap.get(fs.club62__Financial_Account__c).addAmt(fs.club62__Actual__c);
                else
                    fjMap.put(fs.club62__Financial_Account__c, new FinancialJournalWrapper(fs.club62__Financial_Account__r.Name,fs.club62__Actual__c,fs.club62__Financial_Account__c,fs.club62__Financial_Account__r.club62__Account_Number__c));
            }
        }
        public void addJournal(club62__Financial_Journal_Line__c fj){
            Decimal amt = 0;
            if(fj.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c != null && fj.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c == 'Revenue'){
                amt = fj.club62__Amount__c;
            }else if(fj.club62__Financial_Account__r.club62__Statement_Of_Activities_Type__c!= null){
                amt = -fj.club62__Amount__c;
            }else{
                amt = fj.club62__Amount__c;
            }
            if(!fjMap.containsKey(fj.club62__Financial_Account__c)){
                fjMap.put(fj.club62__Financial_Account__c,new FinancialJournalWrapper(fj.club62__Account_Name__c,amt,fj.club62__financial_account__c,fj.club62__Account_Number__c));
            }else{
                fjMap.get(fj.club62__Financial_Account__c).addAmt(amt);
            }
            if(smallestGL=='' || smallestGL>fj.club62__Account_Number__c){
                smallestGL = fj.club62__Account_Number__c;
            }
        }
        public List<FinancialJournalWrapper> getFJMapVal(){
            List<FinancialJournalWrapper> fjltemp = fjMap.values();
            fjltemp.sort();
            return fjltemp;
        }
    }
    public class FinancialJournalWrapper implements Comparable{
        public String name{get;set;}
        public Decimal amount{get;set;}
        public String id{get;set;}
        public String num{get;set;}
        public FinancialJournalWrapper(String n,Decimal a,String id,String num){
            name = n;
            amount = a;
            this.id = id;
            this.num = num;
        }
        public void addAmt(Decimal d){
            amount = amount + d;
        }
        public Integer compareTo(Object compareTo){
            FinancialJournalWrapper cw = (FinancialJournalWrapper)compareTo;

            if(num==cw.num){
                return 0;
            }else if(num > cw.num){
                return 1;
            }else{
                return -1;
            }

        }
    }
}