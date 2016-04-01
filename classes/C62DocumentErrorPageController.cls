//To send error logs to email address
public with sharing class C62DocumentErrorPageController {

    public String objectId{get;set;}
    //Constructor
    public C62DocumentErrorPageController(){
        objectId = ApexPages.currentPage().getParameters().get('objectId');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'club62@cloud62.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Club62 Heroku Document Generation Failure');
        mail.setPlainTextBody('One of the Club62 Heroku document generation apps has failed.  The ID of the object it failed on is ' +
        objectId+'.  Please check the error logs.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    //Go back
    public pageReference goBack(){
        return new pageReference('/'+objectId);
    }    
}