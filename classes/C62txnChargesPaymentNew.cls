/*
@Name               : C62txnChargesPaymentNew 
@Author             : kiran@3embed.com
@Date               : December 12, 2013
@Description        : Controller for charges and payment for txn object
*/
public class C62txnChargesPaymentNew
{
    public string selectedValue { get;set;}
    public boolean isPaymentManuallyApplied{get;set;}
    public string paymentAmount {get;set;}
    public string paymentType {get;set;}
    public string paymentMethod {get;set;}
    public boolean isTypeEnabled{get;set;}
    public boolean isSubTypeEnabled{get;set;}
    public boolean isTaxEnabled{get;set;}
    public List<SelectOption> statusOptions { get;set; }
    public List<SelectOption> sos { get;set; }
    public List<SelectOption> AplicableTaxes { get;set; }
    public String cError{get;set;}
    public String memberId{get;set;}
    public DateTime Dt{get;set;}
    public List<SelectOption> typeOptions{get;set;}
    public String selectedType{get;set;}
    public Map<String,RecordType> tranRecTypeMap;   
    public club62__TXN__c othCharge{get;set;}
    public string ChargeType{get;set;}
    public string vl{set;get;}        
    public C62txnChargesPaymentNew() {
    //get member id
    //profileLst = [Select Id,Name From Profile Where Id =:UserInfo.getProfileId()];
    memberId = Apexpages.currentPage().getParameters().get('memberId');
        
        isTypeEnabled= false;
        isSubTypeEnabled= false;
        isTaxEnabled=false;
        othCharge = new club62__TXN__c(); 
        //othCharge.Type__c=null;
        
        List<RecordType> tranRecTypeLst = [SELECT ID,Name FROM RecordType WHERE sObjectType='club62__TXN__c'];
        tranRecTypeMap = new Map<String,RecordType>();        
        typeOptions = new List<SelectOption>();
        for(RecordType rt : tranRecTypeLst){
            tranRecTypeMap.put(rt.Name,rt);                        
        }       
               
        typeOptions.add(new SelectOption('','--None--'));

    }
    //Club62_FT_TXN_1 : get type and subtype from database
    public void autoRun()
    {
        Schema.DescribeFieldResult statusFieldDescription = club62__TXN__c.club62__Type__c.getDescribe();
        statusOptions = new list<SelectOption>();
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues())
        {
            statusOptions.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
        }
        Schema.DescribeFieldResult statusFieldDescription1 = club62__TXN__c.club62__SubType__c.getDescribe();
        sos = new list<SelectOption>();
        for (Schema.Picklistentry picklistEntry1 : statusFieldDescription1.getPicklistValues())
        {
            sos.add(new SelectOption(picklistEntry1.getValue(),picklistEntry1.getLabel()));
        }
    }
    
    /*club62_FT_TXN
     auther:joshi
     date:22/3/2016
     description:Get all the charges on the member for displaying in the charges table
    */    
    public List<club62__TXN__c> allCharges{
        get{   
            
            List<club62__TXN__c> dat= [SELECT CLUB62__AMOUNT__C,Id, Name ,club62__Description__c ,club62__Date__c,club62__Tax_Amount__c,club62__service_charge__c ,club62__Total_Amount__c,club62__Status__c   FROM club62__TXN__c where CLUB62__MEMBER__C= :memberId and RECORDTYPEID= :'012o000000046WEAAY' ]; 
          return      dat;     
        }
        private set;        
    }
    
    
    
    //Club62_FT_TXN_2 : get total Dues on this customer
    public Double TotalDues {
        get {
             TotalDues=0.00;
            if (TotalDues == 0.00) {
                List<AggregateResult> results = [SELECT SUM(club62__Amount__c) FROM club62__TXN__c where CLUB62__MEMBER__C= :memberId];
                if(results.size()>0){ 
                TotalDues=Double.valueOf(results[0].get('expr0')); 
                if(TotalDues<0){
                    TotalDues=0.00;
                }
                }
            }
            return TotalDues;
        }
        private set;
    }
     //Club62_FT_TXN_3 : get Last payment done by this customer
     public Double LastPayment {
        get {
            LastPayment=0.00;
            if (LastPayment == 0.00) {
                List<club62__TXN__c> results1 = [SELECT club62__DateTime__c FROM club62__TXN__c WHERE club62__Member__c = :memberId  ORDER BY club62__DateTime__c DESC NULLS FIRST LIMIT 1];
                if(results1.size()>0){ 
                    Dt=DateTime.valueOf(results1.get(0).club62__DateTime__c);}
                 List<club62__TXN__c> results = [SELECT CLUB62__AMOUNT__C FROM club62__TXN__c where CLUB62__MEMBER__C= :memberId and RECORDTYPEID= :'012o000000046WJAAY' and club62__DateTime__c =:Dt];
                if(results.size()>0) {  LastPayment=Double.valueOf(results.get(0).CLUB62__AMOUNT__C)*-1;}
            }
            //LastPayment=club62__C62Taxes__c.
            return LastPayment;
        }
        private set;
    }
    
    public PageReference gettypeOptions()
    {                           
         othCharge.RecordTypeId = selectedValue;           
         isTypeEnabled = true;          
    return null;
    }
    
    public PageReference enableSubType()
    {            
        //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,ChargeType)); 
        AplicableTaxes=new list<SelectOption>();
           for(club62__C62TxnChargeToTaxMapping__c sRecordType : [SELECT club62__TaxId__c,club62__tax_on_service_charge__c,club62__Service_Charge_applicable__c  FROM club62__C62TxnChargeToTaxMapping__c WHERE club62__Charge__c  = :selectedValue and club62__ChargeType__c =:ChargeType])
            {
                if(sRecordType.club62__TaxId__c!=null){
                   // string txid=sRecordType.club62__TaxId__c;
                    //string qry='select ' + txid + ' from club62__C62Taxes__c';
                    //List<AggregateResult> results = ['select ' + txid + ' from club62__C62Taxes__c'];
                    //List<AggregateResult> results=Database.query(qry);
                   // club62__C62Taxes__c cp = club62__C62Taxes__c.getOrgDefaults();
                    //if()
                    //string url = cp.txid;
                    //double TaxValue=Double.valueOf(results[0].get('expr0')); 
                    string name=getNameOfTax(sRecordType.club62__TaxId__c);
                    AplicableTaxes.add(new SelectOption(sRecordType.club62__TaxId__c,name));
                }
            }
        if(!AplicableTaxes.isEmpty()){
            isTaxEnabled = true;   
        }else{
            isTaxEnabled = false;   
        }
        isSubTypeEnabled = true;   
   return null;
    }
      public string getNameOfTax(string Id){
       string name='';
        if(Id=='club62__Catering_Bar_Sales_Tax_Percentage__c'){
            name='Catering Bar Sales Tax Percentage';
        }else if(Id=='club62__Catering_Beverage_Sales_Tax_Percentage__c'){
            name='Catering Beverage Sales Tax Percentage';
        }else if(Id=='club62__Catering_Food_Sales_Tax_Percentage__c'){
            name='Catering Food Sales Tax Percentage';
        }else if(Id=='club62__Equipment_Tax_Percentage__c'){
            name='Equipment Tax Percentage';
        }else if(Id=='club62__Reservation_Equipment_Service_Charge__c'){
            name='Reservation Equipment Service Charge';
        }else if(Id=='club62__Room_Rental_Occupancy_Tax_w_out_Room__c'){
            name='Room Rental Occupancy Tax w/out Room';
        }else if(Id=='club62__Room_Res_Tax_1_Amount__c'){
            name='Room Res Occupancy Tax Amount';
        }else if(Id=='club62__Room_Res_Tax_2_Amount__c'){
            name='Room Res Tax 2 Amount';
        }else if(Id=='club62__Room_Res_Tax_3_Amount__c'){
            name='Room Res Tax 3 Amount';
        }else if(Id=='club62__Room_Res_Tax_Percentage_2__c'){
            name='Room Res Tax Occupancy Percentage';
        }else if(Id=='club62__Room_Res_Tax_Percentage_1__c'){
            name='Room Res Tax Percentage 1';
        }else if(Id=='club62__Room_Res_Tax_Percentage_3__c'){
            name='Room Res Tax Percentage 3';
        }else if(Id=='club62__Sales_Tax__c'){
            name='Sales Tax';
        }
        return name;
       
    }
    
     //Club62_FT_TXN_4 : get record type
     public List<SelectOption> getRecordTypeOptions(){
         
        Map<String,Schema.RecordTypeInfo> transactionRecordTypeInfo = club62__TXN__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        List<SelectOption> recordTypesOptions = new List<SelectOption>();
        recordTypesOptions.add(new SelectOption('','--None--')); 
        for(String s : transactionRecordTypeInfo.keySet()){
             if(s!='Master')
                recordTypesOptions.add(new SelectOption(transactionRecordTypeInfo.get(s).getRecordTypeId(),s));
        }                           
        return recordTypesOptions;
    }
     // Club62_FT_TXN_5 :the contact record you are adding values to
  public club62__TXN__c txn {
    get {
      if (txn == null)
        txn = new club62__TXN__c();
      return txn;
    }
      set;
  }
     //Club62_FT_TXN_6 : save data in database
    public void save1(){
        txn.CLUB62__MEMBER__C=memberId;     
        String typex=paymentType;
        String des=othCharge.Description__c;
        Date myDate = date.newinstance(Dt.year(), Dt.month(), Dt.day());
        Double amt=Double.valueOf(paymentAmount);
        txn.RecordTypeId='012o000000046WJAAY';
        txn.club62__Amount__c=amt;
        txn.club62__Type__c=typex;
        txn.club62__Date__c=myDate;
        txn.club62__Description__c=des;
        update txn;
        ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'inserted successfully')); 
    }
}