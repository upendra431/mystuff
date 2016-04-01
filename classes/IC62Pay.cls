/*
@Name           : IC62Pay
@Author         : customersuccess@cloud62.com
@Date           : 
@Description    : C62Pay interface
*/
public interface IC62Pay {
     /*
    @Name: voidAuth
    @Description: voids the authorization for a payment that has already been made
    */
    String voidAuth(String param1);
    
     /*
    @Name: makePayment
    @Description: makes a payment for a certain amount, sends back information about the transaction.  
    */
    Map<String, String> makePayment(club62__Payment_Method__c paymeth, Decimal amount, String param1, String param2);
    
    
     /*
    @Name: authorize
    @Description: sends a request to check whether a payment can be made for a certain amount.
     DOES NOT actually make a payment!
    */
    Map<String, String> authorize(club62__Payment_Method__c paymeth, Decimal amount, String param1, String param2);
    
    
    /*
    @Name: refund
    @Description: refunds a certain amount of a given transaction
    */
    Map<String, String> refund(club62__Payment_Method__c paymeth, Decimal amount, String param1, String param2);
    
}