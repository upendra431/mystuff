/*
@Name            : C62MemberRosterController 
@Author          : customersuccess@cloud62.com
@Date            : May 20, 2015
@Description     : Controller that drives C62MemberRoster
*/

public class C62MemberRosterController {
    public List<Contact> conList {get;set;}
    public Contact tmpCon {get;set;}
    public String strQuery {get;set;}
    public String lName {get;set;}
    public List<SelectOption> lstSO {get;set;}
    public List<Id> lstSel {get;set;}
    Public string renderType {get;set;}
    Public string contentType {get;set;}
    Public Boolean isExcel {get;set;}
    
    //Constructor
    public C62MemberRosterController(){
        conList = new List<Contact>();
        tmpCon = new Contact();
        lstSO = new List<SelectOption>();
        lstSel = new List<Id>();
        renderType = '';
        isExcel = false;
        //Query Category
        List<Category__C> tmpLstCat = [SELECT Id, Name FROM club62__Category__c];
        for(club62__Category__c cat : tmpLstCat){
            lstSO.add(new SelectOption(cat.Id,cat.Name));
        }
    }
    //To search members
    public void searchMembers(){
        strQuery = 'SELECT Id, AccountId, Account.Name, FirstName, LastName, Name, Phone, MobilePhone, HomePhone, OtherPhone, Email, club62__Search_Detail__c, '+
                 'MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingAddress ' +
                 'FROM Contact WHERE club62__Status__c IN ( \'Active\', \'Reinstated\' ) ';
        if (tmpCon.FirstName != null || (lName != null && lName != '') || tmpCon.Phone != null || tmpCon.EMail != null || lstSel.size() > 0){
            strQuery += ' AND ';
            if (lName != null && lName != '') { 
              strQuery += 'LastName LIKE \''+string.escapeSingleQuotes(lName)+'%\'';
                if (tmpCon.FirstName != null || tmpCon.Phone != null || tmpCon.EMail != null || lstSel.size() > 0){
                    strQuery += ' AND ';
                }
            }
            if (tmpCon.FirstName != null) {
                strQuery += 'FirstName LIKE \''+string.escapeSingleQuotes(tmpCon.FirstName)+'%\' ';
                if (tmpCon.Phone != null || tmpCon.EMail != null || lstSel.size() > 0){
                    strQuery += ' AND ';
                }
            }
            if (tmpCon.Phone != null) {
                strQuery += ' ( Phone LIKE \'%'+tmpCon.Phone+'%\' OR MobilePhone LIKE \'%'+tmpCon.Phone+'%\' OR HomePhone LIKE \'%'+tmpCon.Phone+'%\' OR OtherPhone LIKE \'%'+tmpCon.Phone+'%\' ) ';
                if(tmpCon.EMail != null || lstSel.size() > 0){
                    strQuery += ' AND ';
                }
            }
            if (tmpCon.Email != null) {
                strQuery += ' Email LIKE \'%'+tmpCon.Email+'%\'';
                if(lstSel.size() > 0){
                    strQuery += ' AND ';
                }
            }
            if (lstSel.size() > 0){
                system.debug('lstSel: '+lstSel);
                strQuery += 'club62__Category__c IN :lstSEL';
            }
        }
        system.debug('strQuery: '+strQuery);
        
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator(strQuery));
        conList = Database.query(strQuery);
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                strQuery = 'SELECT Id, AccountId, Account.Name, FirstName, LastName, Name, Phone, MobilePhone, HomePhone, OtherPhone, Email, club62__Search_Detail__c, '+
                           'MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, MailingAddress ' +
                           'FROM Contact WHERE LastName LIKE \''+tmpCon.LastName+'\' ';
                if (tmpCon.FirstName != null && tmpCon.FirstName != '') {strQuery += 'AND FirstName LIKE \'%'+tmpCon.FirstName+'%\' ';}
                if (tmpCon.Phone != null && tmpCon.Phone != '') {strQuery += 'AND ( Phone LIKE \'%'+tmpCon.Phone+'%\' OR MobilePhone LIKE \'%'+tmpCon.Phone+'%\' OR HomePhone LIKE \'%'+tmpCon.Phone+'%\' OR OtherPhone LIKE \'%'+tmpCon.Phone+'%\' ) ';}
                if (tmpCon.Email != null && tmpCon.Email != '') {strQuery += 'AND Email LIKE \'%'+tmpCon.Email+'%\'';}
                //List<Contact> contacts = Database.query(strQuery);
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(strQuery));
            }
            return setCon;
        }
        set;
   }
    
    public List<Contact> getList() {
         setCon.setpagesize(20);
         return (List<Contact>) setCon.getRecords();
   }
    
    public PageReference convertPDF(){
        renderType = 'pdf';
        return new PageReference('/apex/c62memberroster');
    }
    
    public PageReference convertExcel(){
        renderType = '';
        isExcel = true;
        contentType = 'application/vnd.ms-excel#SalesForceExport.xls';
        return new PageReference('/apex/c62memberroster');
    }
    
}