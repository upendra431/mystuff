/*
@Name           : MandrillMessageTest
@Author         : customersuccess@cloud62.com
@Date           : 17/2/2014
@Description    : Test methods for MandrillMessage
*/
@isTest
public class MandrillMessageTest{
     /*
    @Name :c62MandrillMessageTest
    @Description : Test method for MandrillMessage functionality
    */
    static testmethod void c62MandrillMessageTest(){
        Contact c = C62TestHandler.getMember1();
        Attachment a = C62TestHandler.getAttachment(c);
        Document d = new Document(AuthorId=UserInfo.getUserId(),FolderId=UserInfo.getUserId(),Name='Test',
                Body=Blob.valueOf('Test Body'));
        insert d;
        Test.startTest();
        MandrillMessage mm = new MandrillMessage();
        mm.addTo('test@test.com', 'Testing', 'html');
        mm.attachmentSet.add(a.Id);
        mm.documentSet.add(d.Id);
        String tempStr = mm.buildMessage();
        system.assertNotEquals(null,MandrillMessage.parse(tempStr));
        mm = new MandrillMessage();
        mm.addTo('test@test.com', 'Testing', 'html');
        mm.documentSet.add(d.Id);
        tempStr = mm.buildMessage();
        system.assertNotEquals(null,MandrillMessage.parse(tempStr));
        MandrillMessage.Recipient_metadata rm = new MandrillMessage.Recipient_metadata();
        MandrillMessage.Vars mvs = new MandrillMessage.Vars();
        MandrillMessage.Metadata md = new MandrillMessage.Metadata();
        MandrillMessage.Merge_vars mv = new MandrillMessage.Merge_vars();
        MandrillMessage.Values val = new MandrillMessage.Values();
        
        
        club62__Pass__c pss = new club62__Pass__c(club62__Customer__c = c.Id,club62__Allow_Member_Account_Charges__c = true);
        insert pss;
        club62__Payment_Method__c pm = new club62__Payment_Method__c(club62__Customer__c=c.Id,club62__Payment_For__c = 'Default',club62__Payment_Type__c = 'Pass Direct Bill',club62__From_Date__c = System.Today(),
                    club62__Pass__c = pss.Id,club62__To_Date__c = System.Today().addDays(5));
        insert pm;
        pss.club62__Allow_Member_Account_Charges__c = false;
        Update pss;
        Test.stopTest();
    }
}