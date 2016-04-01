public with sharing class C62PayGateEVO implements IC62Pay{
    // Class Variables
    private String cBaseURI;
    private Boolean cIsTest;
    private String cAccessToken;
    private String cClientId;
    private String cSecret;
    
    C62PayGateEVOModel model;

    /*
    @Name :C62PayGateEVO
    @Description :Constructor
    */
    public C62PayGateEVO(Boolean cIsTest){
        // Get the Base URI
        club62__Payment_Gateway__c pg = Database.query('SELECT ' + C62Utilities.getFields('club62__Payment_Gateway__c')
                                + ' FROM club62__Payment_Gateway__c'
                                + ' WHERE Name = \'EVO\'');

        cClientId = pg.club62__Login_Encrypted__c;
        cSecret = pg.club62__Password_Encrypted__c;

        this.cIsTest = cIsTest;
        if (this.cIsTest){
            cBaseURI = pg.club62__Test_URL__c;
        }
        else {
            cBaseURI = pg.club62__Production_URL__c;
        }

        model = new C62PayGateEVOModel(cCLientID, cSecret, cBaseURI);
    }

    /*
    @Name: makePayment
    @Description: makes a payment for a certain amount, sends back information about the transaction.  
    */
    public Map<String, String> makePayment(club62__Payment_Method__c paymeth, Decimal amount, String param1, String param2){
        return model.doSale(amount, paymeth);
    }

    /*
    @Name: authorize
    @Description: sends a request to check whether a payment can be made for a certain amount.
     DOES NOT actually make a payment!
    */
    public Map<String, String> authorize(club62__Payment_Method__c paymeth, Decimal amount, string Param1, string Param2){
        return model.doAuthorize(amount, paymeth);
    }

    /*
    @Name: refund
    @Description: refunds a certain amount of a given transaction
    */
    public Map<String, String> refund(club62__Payment_Method__c paymeth, Decimal amount, String param1, String param2){
        return model.doRefund(param2, amount, paymeth);
    }
    
    public Map<String, String> doValidate(club62__Payment_Method__C paymeth){
        return model.doValidate(paymeth);
    }

    /*
    @Name: voidAuth
    @Description: voids the authorization for a payment that has already been made
    */
    public String voidAuth(String param1){
        Map<String, String> ret = model.doVoidTransaction(param1);

        if(ret.get('responsetext').Equals('Transaction Void Successful'))
            return 'Success';
        return ret.get('responsetext');
    }
}