/*
@Name               : C62Dedupe
@Author             : customersuccess@cloud62.com
@Date               : December 11, 2013
@Description        : Class that will handle deduping Member and person records based on a list from trigger.new
*/
public with sharing class C62Dedupe{
    public static List<PossibleDuplicate> findDuplicate(sObject s, Boolean isInsert){
        return null;
    }

    public static List<PossibleDuplicate> findDuplicate(List<sObject> listIn,Boolean isInsert){
        List<sObject> tempList = new List<sObject>();
        //Don't include leads that have been marked as overriden
        for(sObject s : listIn){
            if(s.getsObjectType().getDescribe().getName()=='Contact'){
                if(!((Contact)s).club62__Possible_Duplicate_Override__c){
                    tempList.add(s);
                }
            }else if(s.getsObjectType().getDescribe().getName()=='club62__Person__c'){
                if(!((club62__Person__c)s).club62__Possible_Duplicate_Override__c){
                    tempList.add(s);
                }
            }
        }
        listIn = tempList;
        /*
            Rules for Duplication
            1.EMAIL, if Email is available, FirstName, LastName, Email
            2.SSN, if SSN is available, FirstName, LastName, SSN
            3.FirstName, LastName, Address Zip, any Last 4 digits of phone
        */
        List<Id> sObjectIds = new List<Id>();
        //FirstNames
        Set<String> fstringFieldList = new Set<String>();
        //LastNames
        Set<String> lstringFieldList = new Set<String>();
        //Emails
        Set<String> estringFieldList= new Set<String>();
        //SSNs
        Set<String> ssnStringFieldList = new Set<String>();
        //Loop and put all fields in a List
        for(sObject s : listIn){
            if(s.getsObjectType().getDescribe().getName()=='Contact'){
                Contact m = (Contact)s;
                sObjectIds.add(m.id);
                //Email Check
                if(m.FirstName!=null && m.FirstName!='' && m.LastName!=null && m.LastName!='' && m.Email!=null && m.Email!=''){
                    fstringFieldList.add(m.FirstName.toLowerCase());
                    lstringFieldList.add(m.LastName.toLowerCase());
                    estringFieldList.add(m.Email);
                }
            }else if(s.getsObjectType().getDescribe().getName()=='club62__Person__c'){
                club62__Person__c p = (club62__Person__c)s;
                sObjectIds.add(p.id);
                //Email Check
                if(p.club62__First_Name__c!=null && p.club62__First_Name__c!='' && p.club62__Last_Name__c!=null && p.club62__Last_Name__c!='' && p.club62__Email__c!=null && p.club62__Email__c!=''){
                    fstringFieldList.add(p.club62__First_Name__c.toLowerCase());
                    lstringFieldList.add(p.club62__Last_Name__c.toLowerCase());
                    estringFieldList.add(p.club62__Email__c);
                }
            }
        }

        String strMemQry = 'SELECT club62__Possible_Duplicate_Override__c,club62__Possible_Duplicate__c, club62__Master_Duplicate_Customer__c, club62__Master_Duplicate_Person__c,Birthdate,club62__SSN__c,FirstName,Email,LastName,HomePhone,Fax,MobilePhone FROM ';
        String endQuery = ' WHERE ID NOT IN :sObjectIds AND club62__Possible_Duplicate_Override__c=false AND club62__Master_Duplicate_Customer__c=null AND club62__Master_Duplicate_Person__c=null ';
        Map<Id,sObject> sObjectList = new Map<Id,sObject>();
        String memQuery = strMemQry+'Contact'+endQuery;
        String queryMemEmailCheck = memQuery+' AND FirstName like:fstringFieldList AND LastName like:lstringFieldlist AND Email like:estringFieldList';

        //Email Check Member
        for(Contact m :(List<Contact>)Database.query(queryMemEmailCheck )){
            if(listin.get(0).getsObjectType().getDescribe().getName()=='Contact'){
                for(Contact newMem : (List<Contact>)ListIn){
                    if(m.FirstName!=null && newMem.FirstName!=null && m.FirstName.toLowerCase() == newMem.FirstName.toLowerCase() & m.LastName.toLowerCase() == newMem.LastName.toLowerCase() && m.Email!=null && newMem.Email!=null && m.Email.toLowerCase() == newMem.Email.toLowerCase()){
                        Contact newMemCopy = new Contact(id=newmem.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Customer__c = m.id);
                        if(m.club62__Possible_Duplicate__c==false && m.club62__Master_Duplicate_Customer__c==null && m.club62__Master_Duplicate_Person__c==null){
                            sObjectList.put(newMem.id,newMemCopy);
                        }
                    }
                }
            }else if(listin.get(0).getsObjectType().getDescribe().getName()=='club62__Person__c'){
                for(club62__Person__c newPer : (List<club62__Person__c>)ListIn){
                    if(m.FirstName!=null && newPer.club62__First_Name__c!=null && m.FirstName.toLowerCase() == newPer.club62__First_Name__c.toLowerCase() & m.LastName.toLowerCase() == newPer.club62__Last_Name__c.toLowerCase() && m.Email!=null && newPer.club62__Email__c!=null && m.Email.toLowerCase() == newPer.club62__Email__c.toLowerCase()){
                        club62__Person__c newPerCopy = new club62__Person__c(id=newPer.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Customer__c=m.id);
                        if(m.club62__Possible_Duplicate__c==false && m.club62__Master_Duplicate_Customer__c==null && m.club62__Master_Duplicate_Person__c==null){
                            sObjectList.put(newPer.id,newPerCopy);
                        }
                    }
                }
            }

        }

        String strPerQry = 'SELECT club62__Possible_Duplicate_Override__c,club62__Possible_Duplicate__c, club62__Master_Duplicate_Customer__c, club62__Master_Duplicate_Person__c,club62__Birthdate__c,club62__Email__c,club62__SSN__c,club62__First_Name__c,club62__Last_Name__c,club62__Home_Phone__c,club62__Fax__c,club62__Mobile_Phone__c FROM ';
        String perQuery = strPerQry+'club62__Person__c'+endQuery;
        String queryPerEmailCheck = perQuery+ 'AND club62__First_Name__c like:fstringFieldList AND club62__Last_Name__c like:lstringFieldList AND club62__Email__c like:estringFieldList';

        //Email Check Person
        for(club62__Person__c p :(List<club62__Person__c>)Database.query(queryPerEmailCheck )){
            if(listin.get(0).getsObjectType().getDescribe().getName()=='Contact'){
                for(Contact newMem : (List<Contact>)ListIn){
                    if(p.club62__First_Name__c!=null && newMem.FirstName !=null && p.club62__First_Name__c.toLowerCase() == newMem.FirstName.toLowerCase() & p.club62__Last_Name__c.toLowerCase() == newMem.LastName.toLowerCase() && p.club62__Email__c!=null && newMem.Email !=null && p.club62__Email__c.toLowerCase() == newMem.Email.toLowerCase()){
                        Contact newMemCopy = new Contact(id=newmem.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Person__c=p.id);
                        if(p.club62__Possible_Duplicate__c==false && p.club62__Master_Duplicate_Customer__c==null && p.club62__Master_Duplicate_Person__c==null){
                            sObjectList.put(newMem.id,newMemCopy);
                        }
                    }
                }
            }else if(listin.get(0).getsObjectType().getDescribe().getName()=='club62__Person__c'){
                for(club62__Person__c newPer : (List<club62__Person__c>)ListIn){
                    if(p.club62__First_Name__c!=null && newPer.club62__First_Name__c !=null && p.club62__First_Name__c.toLowerCase() == newPer.club62__First_Name__c.toLowerCase() & p.club62__Last_Name__c.toLowerCase() == newPer.club62__Last_Name__c.toLowerCase() && p.club62__Email__c!=null && newPer.club62__Email__c !=null && p.club62__Email__c.toLowerCase() == newPer.club62__Email__c.toLowerCase()){
                        club62__Person__c newPerCopy = new club62__Person__c(id=newPer.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Person__c=p.id);
                        if(p.club62__Possible_Duplicate__c==false && p.club62__Master_Duplicate_Customer__c==null && p.club62__Master_Duplicate_Person__c==null){
                            sObjectList.put(newPer.id,newPerCopy);
                        }
                    }
                }
            }
        }

        //Dedupe against trigger.New. Store all non Dupes
        Map<String,sObject> cleanMap = new Map<String,sObject>();
        for(sObject s : trigger.New){
            if(s.getsObjectType().getDescribe().getName()=='Contact'){
                Contact mem = (Contact)s;

                //Email Check
                if(mem.FirstName!=null && mem.FirstName!='' && mem.LastName!=null && mem.LastName!='' && mem.Email!=null && mem.Email!=''){
                    String hash = mem.FirstName+':'+mem.LastName+':'+mem.Email;
                    if(cleanMap.containsKey(hash)){
                        //DUPE. if we haven't already dealt with it
                        if(!sObjectList.containsKey(mem.id)){
                            sObject master = cleanMap.get(hash);
                            if(master.getsObjectType().getDescribe().getName()=='Contact'){
                                sObjectList.put(mem.id,new Contact(id=mem.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Customer__c = master.id));
                            }else if(master.getsObjectType().getDescribe().getName()=='club62__Person__c'){
                                sObjectList.put(mem.id,new Contact(id=mem.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Person__c = master.id));
                            }
                        }
                    }else{
                        cleanMap.put(hash,mem);
                    }
                }

            }else if(s.getsObjectType().getDescribe().getName()=='club62__Person__c'){
                club62__Person__c per = (club62__Person__c)s;

                //Email Check
                if(per.club62__First_Name__c!=null && per.club62__First_Name__c!='' && per.club62__Last_Name__c!=null && per.club62__Last_Name__c!='' && per.club62__Email__c!=null && per.club62__Email__c!=''){
                    String hash = per.club62__First_Name__c+':'+per.club62__Last_Name__c+':'+per.club62__Email__c;
                    if(cleanMap.containsKey(hash)){
                        //DUPE. if we haven't already dealt with it
                        if(!sObjectList.containsKey(per.id)){
                            sObject master = cleanMap.get(hash);
                            if(master.getsObjectType().getDescribe().getName()=='Contact'){
                                sObjectList.put(per.id,new club62__Person__c(id=per.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Customer__c = master.id));
                            }else if(master.getsObjectType().getDescribe().getName()=='club62__Person__c'){
                                sObjectList.put(per.id,new club62__Person__c(id=per.id,club62__Possible_Duplicate__c=true,club62__Master_Duplicate_Person__c = master.id));
                            }

                        }
                    }else{
                        cleanMap.put(hash,per);
                    }
                }
            }
        }

        List<PossibleDuplicate> pDupeList = new List<PossibleDuplicate>();
        for(sObject s : sObjectList.values())
        {
            pDupeList.add(new PossibleDuplicate(s));
        }
        return pDupeList;
    }

    /*
    @Name    :Possible Duplicate
    @Description    :Wrapper class to hold possible dupes
    */
    public class PossibleDuplicate{
        public Contact mem;
        public club62__Person__c per;
        public PossibleDuplicate(sObject s){
            if(s.getsObjectType().getDescribe().getName()=='Contact'){
                mem=(Contact)s;
            }else if(s.getsObjectType().getDescribe().getName()=='club62__Person__c'){
                per=(club62__Person__c)s;
            }
        }
    }
}