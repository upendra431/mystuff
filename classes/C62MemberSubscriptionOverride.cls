//To override the subscriptions
public with sharing class C62MemberSubscriptionOverride {
    
    //Variables
    public Integer timelineExtraRows {get;set;}
    public Integer timelineSize {get;set;}
    public Integer timelineSize2 {get;set;}
    public Boolean showTimeline {get;set;}
    public Boolean showTimeline2 {get;set;}
    public String jsString {get;set;}
    public String jsString2 {get;set;}
    public List<DataTableRows> jsStringList1{get;set;}
    public List<DataTableRows> jsStringList2{get;set;}
    
    //Constructor
    public C62MemberSubscriptionOverride(ApexPages.StandardController sc) {
        String msId = sc.getId();
        
        jsStringList1 = new List<DataTableRows>();
        jsStringList2 = new List<DataTableRows>();
        if(msId != null){
            //Query subscriptions with subscription lines
            String strQuery = 'SELECT ' + C62Utilities.getFields('club62__Subscription__c')
                                + ',(SELECT club62__Category__r.Name,' + C62Utilities.getFields('club62__Subscription_Line__c') 
                                    + ' FROM club62__Subscription_Lines__r WHERE club62__Type__c != \'Voluntary Dues\')'
                                + ' FROM club62__Subscription__c'
                                + ' WHERE Id = :msId';
            club62__Subscription__c ms = Database.query(strQuery);
            
            Set<String> totalCategories = new Set<String>();
            for(Integer i = 0; i < ms.club62__Subscription_Lines__r.size(); i++){
                club62__Subscription_Line__c msl = ms.club62__Subscription_Lines__r.get(i);
                totalCategories.add(msl.club62__Category__r.Name);
                if(msl.club62__Cycle_Start_Date__c==null){msl.club62__Cycle_Start_Date__c=Date.today();}
                if(msl.club62__Cycle_End_Date__c==null){msl.club62__Cycle_End_Date__c=Date.today();}
                jsStringList1.add(new DataTableRows('\''+msl.club62__Category__r.Name+'\'','\' $'+ String.valueof(msl.club62__Total_Amount__c)+'\'','new Date(\'' + msl.club62__Cycle_Start_Date__c.format()+'\')',
                            'new Date(\'' + msl.club62__Cycle_End_Date__c.format()+'\')'));
                
            }
            if (totalCategories.size() > 0) {
                timeLineExtraRows = totalCategories.size()-1;
            } else {
                timeLineExtraRows = 0;
            }
            
            // Second timeline stuff begins
            String str2Query = 'SELECT ' + C62Utilities.getFields('club62__Subscription__c')
                                + ',(SELECT club62__Category__r.Name,' + C62Utilities.getFields('club62__Subscription_Line__c') 
                                    + ' FROM club62__Subscription_Lines__r WHERE club62__Type__c = \'Voluntary Dues\')'
                                + ' FROM club62__Subscription__c'
                                + ' WHERE Id = :msId';
            club62__Subscription__c ms2 = Database.query(str2Query);
            
            timelineSize2 = 0;
            if (ms2 != null) {
                showTimeline2 = false;
                for(Integer i = 0; i < ms2.club62__Subscription_Lines__r.size(); i++){
                    timelineSize2 = 100;
                    showTimeline2 = true;
                    club62__Subscription_Line__c msl2 = ms2.club62__Subscription_Lines__r.get(i);
                    if(msl2.club62__Cycle_Start_Date__c==null){msl2.club62__Cycle_Start_Date__c=Date.today();}
                    if(msl2.club62__Cycle_End_Date__c==null){msl2.club62__Cycle_End_Date__c=Date.today();}
                    jsStringList2.add(new DataTableRows('\''+msl2.club62__Type__c+'\'','\' $'+ String.valueof(msl2.club62__Total_Amount__c)+'\'','new Date(\'' + msl2.club62__Cycle_Start_Date__c.format()+'\')',
                            'new Date(\'' + msl2.club62__Cycle_End_Date__c.format()+'\')'));
                }
            // Second timeline stuff ends
                
            }
            if(ms.club62__Subscription_Lines__r != null && ms.club62__Subscription_Lines__r.size()>0){
                    showTimeline = true;
                }
        }
        
        // The size needed to display one row of the visualization timeline
        timelineSize = 100 + ((timeLineExtraRows) * 40);
        
    }
    //Wrapper class to bind values
    public class DataTableRows{
        public String name{get;set;}
        public String status{get;set;}
        public String startDate{get;set;}
        public String endDate{get;set;}
        public DataTableRows(String name,String status,String startDate,String endDate){
            this.name = name;
            this.status = status;
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }
}