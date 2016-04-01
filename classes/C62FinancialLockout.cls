public Class C62FinancialLockout{

    public static Map<Integer, Map<Integer, Set<String>>> exemptUsers;
    
    public C62FinancialLockout(){
    
    }
    
    public static Boolean isEligible(String thisId, Date thisDate){
        Boolean result = true;
        if (exemptUsers == null){
            C62FinancialLockout.getExemptUsers();
        }
        Integer year = thisDate.year();
        Integer month = thisDate.month();
        system.debug(thisDate);
        if (exemptUsers.containsKey(year)){
            if (exemptUsers.get(year).containsKey(month)){
                system.debug('***setsize: ' + exemptUsers.get(year).get(month).size());
                if (exemptUsers.get(year).get(month).size() > 0){
                    if (!exemptUsers.get(year).get(month).contains(UserInfo.getUserId())){
                        result = false;
                    }
                }
            }
        }
        
        return result;
    }
    
    private static void getExemptUsers(){
        exemptUsers = new Map<Integer, Map<Integer, Set<String>>>();
        List<club62__Financial_Closing__c> FLList = [SELECT ID, Club62__Date__c,club62__Closed__c, (SELECT ID, CLUB62__USER__C FROM Financial_Lockout_Users__R)
            FROM club62__Financial_Closing__c where club62__date__c != null ];
        for (club62__Financial_Closing__c fl : FLList){
            if(fl.club62__Closed__c == true){
                Integer year = fl.Club62__Date__c.year();
                Integer month = fl.Club62__Date__c.month();
                if (!exemptUsers.containsKey(year)){
                    exemptUsers.put(year, new Map<Integer, Set<String>>());
                }
                if (!exemptUsers.get(year).containsKey(month)){
                    exemptUsers.get(year).put(month, new Set<String>());
                }
                exemptUsers.get(year).get(month).add('-1');
                continue;
            }else{
                for (Financial_Lockout_User__c FLU : fl.Financial_Lockout_Users__R){
                    Integer year = fl.Club62__Date__c.year();
                    Integer month = fl.Club62__Date__c.month();
                    if (!exemptUsers.containsKey(year)){
                        exemptUsers.put(year, new Map<Integer, Set<String>>());
                    }
                    if (!exemptUsers.get(year).containsKey(month)){
                        exemptUsers.get(year).put(month, new Set<String>());
                    }
                    exemptUsers.get(year).get(month).add(FLU.club62__user__c);
                }
            }
            
        }
    }

}