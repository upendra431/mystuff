@isTest
private class PullCharges_Testing {
    static testMethod void testpclass()
    {
        Test.startTest();
          //do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = 'services/apexrest/club62/pullcharges';
        req.params.put('name','hell');
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res; 
       PullCharges.getAllCharges();
       req.requestURI = 'services/apexrest/club62/pullcharges';
        req.params.put('name',null);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res; 
       PullCharges.getAllCharges();
       
           
        Test.stopTest();
    }

}