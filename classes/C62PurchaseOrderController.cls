public with sharing class C62PurchaseOrderController {
    public club62__Vendor_Invoice__c purchaseOrder{get;set;}
    public User curUser{get;set;}
    public String vendor{get;set;}
    public Map<Integer,PurchaseOrderLine> vilList{get;set;}
    public Map<Id,GLLine> glLines{get;set;}
    public Integer nextIndex{get;set;}
    public String pageMode{get;set;}
    //Store Selected Enrtry for AutoComplete Financial Account & Vendor
    public String cObjId{get;set;}
    public String cObjIndex{get;set;}
    public String cObjLabel{get;set;}
    public String cObjName{get;set;}
    public String cObjAccNum{get;set;}
    public RecordType poRT{get;set;}
    public club62__C62Taxes__c taxes{get;set;}

    public C62PurchaseOrderController(ApexPages.StandardController stdController) {
        poRT = [Select id from RecordTYpe where sObjectType='club62__Vendor_Invoice__c' and Name='Purchase Order' limit 1];
        pageMode = 'Choose';
        Id curUID = UserInfo.getUserId();
        curUser = [Select id,Name from User where Id=:curUID];
        taxes = club62__C62Taxes__c.getOrgDefaults();

        vilList = new Map<Integer,PurchaseOrderLine>();
        glLines = new Map<Id,GLLine>();

    }
    public void createNewPO(){
        purchaseOrder = new club62__Vendor_Invoice__c();
        purchaseOrder.club62__Tax__c = taxes.club62__Sales_Tax__c;
        purchaseOrder.recordTypeId = poRt.Id;
        purchaseOrder.club62__Ordered_By__c = curUser.Id;
        nextIndex = 0;
        vilList.clear();
        glLines.clear();
        for(Integer i=0;i<=5;i++){
            vilList.put(nextIndex,new PurchaseOrderLine(nextIndex));
            nextIndex++;
        }
    }
    public void addPOLines(){
        for(Integer i=0;i<10;i++){
            vilList.put(nextIndex,new PurchaseOrderLine(nextIndex));
            nextIndex++;
        }
    }
    public void changePageMode(){
        cObjId = '';
        purchaseOrder = null;
        villist.clear();
        glLines.clear();
        nextIndex = 0;
        if(pageMode == 'New'){
            createNewPO();
            pageMode = 'Edit';
        }else if(pageMode =='Existing'){
        }else if(pageMode == 'Rec'){
            
        }
    }
    public void setLstChoosePO(){
        if(cObjId!=null && cObjId!=''){
            List<club62__Vendor_Invoice__c> polst = database.query('Select '+C62Utilities.getFields('club62__Vendor_Invoice__c')
                                                        +   ',club62__Vendor__r.Name, (Select '+C62Utilities.getFields('club62__Vendor_Invoice_Line__c')+',club62__Inventory_Item__r.Name,club62__Financial_Account__r.Name,club62__Financial_Account__r.club62__Account_Number__c From club62__Vendor_Invoice_Lines__r) FROM club62__Vendor_Invoice__c where id=\''+String.escapeSingleQuotes(cObjId)+'\' limit 1');
            if(polst.size()>0){
                purchaseOrder = polst[0];
                for(club62__Vendor_Invoice_Line__c vil : purchaseOrder.club62__Vendor_Invoice_Lines__r){
                    vilList.put(nextIndex,new PurchaseOrderLine(vil,nextIndex));
                    nextIndex++;
                }
                vendor=purchaseOrder.club62__Vendor__r.name;
                if(pageMode != 'Rec'){
                    pageMode = 'Edit';
                } else {
                    pageMode = 'EditRec';
                }
            }
        }
    }
    
    public void createInvIn(){
        try{
            List<club62__Inventory_In_Out__c> insertList = new List<club62__Inventory_In_Out__c>();
            for(PurchaseOrderLine pol : vilList.values()){
                club62__Inventory_In_Out__c ioc = new club62__Inventory_In_Out__c();
                ioc.club62__Date__c = pol.pol.club62__Post_Date__c;
                ioc.club62__Inventory_In_Out__c = 'In';
                ioc.club62__Inventory_Item__c = pol.pol.club62__Inventory_Item__c;
                //TODO: Location?
                ioc.club62__Quantity__c = pol.recQty;
                ioc.club62__Type__c = 'Acquired';
                insertList.add(ioc);
            }
            if(Schema.sObjectType.club62__Inventory_In_Out__c.isCreateable()){insert insertList;}
            Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.Confirm,'Inventory In Saved Successfully'));
        } catch(Exception e){
            Apexpages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal,e.getMessage()));
        }
    }
    
    public void savePO(){
        if(purchaseOrder.club62__Location__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal,'Missing Fields:Location'));
            return;
        }else if(purchaseOrder.club62__Vendor__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal,'Missing Fields:Vendor'));
            return;
        }
        try{
            if(purchaseOrder.club62__PO_Number__c==null){

                club62__C62PurchaseOrder__c poSetting = club62__C62PurchaseOrder__c.getOrgDefaults();
                Decimal poNumber = 0;
                if(poSetting.club62__Next_PO_Number__c!=null){
                    poNumber = poSetting.club62__Next_PO_Number__c;
                }
                poSetting.club62__Next_PO_Number__c = poNumber+1;
                if(Schema.sObjectType.club62__C62PurchaseOrder__c.isUpdateable()){update poSetting;}
                String poNumString = poNumber+'';
                for(Integer i=0; poNumString.length()<=8;i++){
                    poNumString = '0'+poNumString;
                }
                purchaseOrder.club62__PO_Number__c = poNumString+'';
            }
            if(Schema.sObjectType.club62__Inventory_In_Out__c.isCreateable() && Schema.sObjectType.club62__Inventory_In_Out__c.isUpdateable()){upsert purchaseOrder;}
            List<club62__Vendor_Invoice_Line__c> vilsupdate = new List<club62__Vendor_Invoice_Line__c>();
            for(PurchaseOrderLine pol : vilList.values()){
                if(pol.pol.club62__Financial_Account__c!=null && pol.pol.club62__Inventory_Item__c!=null){
                    if(pol.pol.club62__Vendor_Invoice__c==null) pol.pol.club62__Vendor_Invoice__c = purchaseOrder.Id;
                    vilsupdate.add(pol.pol);
                }
            }
            if(Schema.sObjectType.club62__Vendor_Invoice_Line__c.isCreateable() && Schema.sObjectType.club62__Vendor_Invoice_Line__c.isUpdateable()){upsert vilsupdate;}
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Confirm, 'Purchase Order Saved Successfully!'));
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.Fatal,e.getMessage()));
            return;
        }
    }
    public void recalcGLS(){
        /*glLines.clear();
        Set<Id> glids = new Set<Id>();
        for(PurchaseOrderLine pol : vilList.values()){
            if(pol.pol.club62__Financial_Account__c!=null){
                glids.add(pol.pol.club62__Financial_Account__c);
            }
        }
        Map<Id,club62__Financial_Account__c> faMap = new Map<Id,club62__Financial_Account__c>([Select id, club62__Account_Number__c,Name, club62__Journal_Amount__c,])
        */
    }
    public List<PurchaseOrderLine> getvilListItems(){
        return vilList.values();
    }
    public List<GLLine> getGLLineValues(){
        return glLines.values();
    }
    public class PurchaseOrderLine{
        public club62__Vendor_Invoice_Line__c pol{get;set;}
        public String invItem{get;set;}
        public String FAAccount{get;set;}
        public Integer index{get;set;}
        public Integer recQty{get;set;}
        //public Date recDate{get;set;} I'm using a field on Vendor_Invoice_Line for received date instead.  don't worry, it's okay.
        
        public PurchaseOrderLine(club62__Vendor_Invoice_Line__c vil,Integer idx){
            pol = vil;
            if(pol.club62__Inventory_Item__c!=null){
                invItem = vil.club62__Inventory_Item__r.Name;
            }
            if(vil.club62__Financial_Account__c!=null){
                FAAccount = vil.club62__Financial_Account__r.club62__Account_Number__c+ ' - ' + vil.club62__Financial_Account__r.Name;
            }
        }
        public PurchaseOrderLine(Integer idx){
            index = idx;
            pol = new club62__Vendor_Invoice_Line__c();
        }
    }
    //AF to set the Financial Account for this Line
    public void setLstChoosePFA(){
        if(cObjIndex!=''){
            Integer idx = Integer.valueOf(cObjIndex);
            vilList.get(idx).pol.club62__Financial_Account__c=cObjId;
            vilList.get(idx).FAAccount = cObjLabel;
        }
        recalcGLS();
    }
    public void setLstChooseV(){
        if(cObjId!=''){
            purchaseOrder.club62__Vendor__c = cObjId;
            vendor = cObjLabel;
        }
    }
    public void setLstChooseII(){
        if(cObjIndex!=''){
            Integer idx = Integer.valueOf(cObjIndex);
            vilList.get(idx).pol.club62__Inventory_Item__c=cObjId;
            vilList.get(idx).invItem = cObjLabel;
        }
    }
    /*
    @Name   :JSONObject
    @Description :Object
    */
    public class JSONObject{
        public String accnum{get;set;}
        public String id {get;set;}
        public String label {get;set;}
        public String accname {get;set;}
        public Integer vendorterms{get;set;}
    }
    //Get all of our financial accounts for autocomplete
    @RemoteAction
    public static List<JSONObject> getFinancialAccounts(String strName){
        List<JSONObject> lstReturn = new List<JSONObject>();

        String query = 'SELECT Id,Name,club62__Account_Number__c FROM club62__Financial_Account__c';
        Pattern isnumbers = Pattern.Compile('^[0-9]+$');
        Matcher intMatch = isnumbers.matcher(strName);
        strName = '%' + strName + '%';
        if(intMatch.Matches()){
            query+=' WHERE club62__Account_Number__c LIKE \''+strName+'\' ORDER BY club62__Account_Number__c ASC ';
        }else{
            query+=' WHERE Name LIKE \''+strName+'\' ORDER BY Name ASC ';
        }
        query += ' LIMIT 10';

        List<club62__Financial_Account__c> lstFAs = Database.Query(query);
        for(club62__Financial_Account__c fa : lstFAs){
            JSONObject jso = new JSONObject();
            jso.id = fa.id;
            jso.label = fa.club62__Account_Number__c+ ' - ' +fa.Name;
            jso.accnum = fa.club62__Account_Number__c;
            jso.accname = fa.Name;
            lstReturn.add(jso);
        }
        return lstReturn;
    }
    @RemoteAction
    public static List<JSONObject> getVendors(String strName){
        List<JSONObject> lstReturn = new List<JSONObject>();

        String query = 'SELECT Id,Name FROM club62__Vendor__c';
        strName = '%' + strName + '%';
        query+=' WHERE Name LIKE \''+strName+'\' ORDER BY Name ASC ';
        query += ' LIMIT 10';

        List<club62__Vendor__c> lstFAs = Database.Query(query);
        for(club62__Vendor__c fa : lstFAs){
            JSONObject jso = new JSONObject();
            jso.id = fa.id;
            jso.label = fa.Name;
            lstReturn.add(jso);
        }
        return lstReturn;
    }
    @RemoteAction
    public static List<JSONObject> getInventoryItems(String strName, String location){
        List<JSONObject> lstReturn = new List<JSONObject>();
        if(location!=null && location!=''){
            String query = 'SELECT Id,Name FROM club62__Inventory_Item__c';
            strName = '%' + strName + '%';
            query+=' WHERE Name LIKE \''+strName+'\' and club62__Location__c=\''+String.escapeSingleQuotes(location)+'\' ORDER BY Name ASC ';
            query += ' LIMIT 10';

            List<club62__Inventory_Item__c> lstFAs = Database.Query(query);
            for(club62__Inventory_Item__c fa : lstFAs){
                JSONObject jso = new JSONObject();
                jso.id = fa.id;
                jso.label = fa.Name;
                lstReturn.add(jso);
            }
        }
        return lstReturn;
    }
    @RemoteAction
    public static List<JSONObject> getExistingPOS(String strName){
        List<JSONObject> lstReturn = new List<JSONObject>();

        String query = 'SELECT Id,club62__PO_Number__c FROM club62__Vendor_Invoice__c where RecordType.Name=\'Purchase Order\'';
        strName = '%' + strName + '%';
        query+=' and club62__PO_Number__c LIKE \''+strName+'\' ORDER BY club62__PO_Number__c ASC ';

        query += ' LIMIT 10';

        List<club62__Vendor_Invoice__c> lstFAs = Database.Query(query);
        for(club62__Vendor_Invoice__c fa : lstFAs){
            JSONObject jso = new JSONObject();
            jso.id = fa.id;
            jso.label = fa.club62__PO_Number__c;
            lstReturn.add(jso);
        }
        return lstReturn;
    }
    public class GLLine{
        public Id accId{get;set;}
        public String accName{get;set;}
        public String accNum{get;set;}
        public Decimal begBalance{get;set;}
        public Decimal balance{get;set;}
        public Decimal endBalance{get;set;}
    }
}