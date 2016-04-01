/*
@Name            : C62EmployeeScheduleCalendar
@Author          : customersuccess@cloud62.com
@Date            : Dec 18, 2013
@Description     : Controller for EmployeeScheduleCalendar page
*/
global with sharing class C62EmployeeScheduleCalendarController{
    //Class variables    
    public String selType{get;set;}
    public String employeeId{get;set;}
    public String employeeGroupId{get;set;}
    public Boolean employeeFilters{get;set;}
    public String selectedDepartment{get;set;}
    public club62__Employee_Schedule__c schedule{get;set;} 
    public List<SelectOption> employeesList{get;set;}
    public List<SelectOption> typeSelectionList{get;set;}
    private club62__C62EmployeeCalendarTimes__c cCalOpts{get;set;}
    
    //Variables for Employee Schedule days
    public Boolean rSunday{get;set;}
    public Boolean rMonday{get;set;}
    public Boolean rTuesday{get;set;}
    public Boolean rWednesday{get;set;}
    public Boolean rThursday{get;set;}
    public Boolean rFriday{get;set;}
    public Boolean rSaturday{get;set;}
    public String recurringday{get;set;}
    public Integer removalIndex{get;set;}
    public List<SelectOption> recStartEndTimes{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListSu{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListM{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListTu{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListW{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListTh{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListF{get;set;}
    public List<recurringWrapper> recurringstartEndTimeListSa{get;set;}
    
    //Variables for delete Employee Schedules
    public String selTypeDel{get;set;}
    public String employeeIdDel{get;set;}
    public String employeeGroupIdDel{get;set;}
    public Boolean employeeFiltersDel{get;set;}
    public String selectedDepartmentDel{get;set;}
    public club62__Employee_Schedule__c scheduleDel{get;set;} 
    public List<SelectOption> employeesListDel{get;set;}
    public Boolean rSundayDel{get;set;}
    public Boolean rMondayDel{get;set;}
    public Boolean rTuesdayDel{get;set;}
    public Boolean rWednesdayDel{get;set;}
    public Boolean rThursdayDel{get;set;}
    public Boolean rFridayDel{get;set;}
    public Boolean rSaturdayDel{get;set;}
    public recurringWrapperDel recurringstartEndTimeListSuDel{get;set;}
    public recurringWrapperDel recurringstartEndTimeListMDel{get;set;}
    public recurringWrapperDel recurringstartEndTimeListTuDel{get;set;}
    public recurringWrapperDel recurringstartEndTimeListWDel{get;set;}
    public recurringWrapperDel recurringstartEndTimeListThDel{get;set;}
    public recurringWrapperDel recurringstartEndTimeListFDel{get;set;}
    public recurringWrapperDel recurringstartEndTimeListSaDel{get;set;}

    /*
    @Name   :C62CalendarController
    @Description :Constructor to initalize the page
    */
    public C62EmployeeScheduleCalendarController(){
        //get the custom setting Data
        cCalOpts = club62__C62EmployeeCalendarTimes__c.getInstance('EmployeeCalendarTimes');
        //initialize a schedule to be able to get the fields for it
        schedule = new club62__Employee_Schedule__c();
        scheduleDel = new club62__Employee_Schedule__c();
        //initialize data
        employeesList = new List<SelectOption>();
        employeesList.add(new SelectOption('','--None--')); 
        employeesListDel = new List<SelectOption>();
        employeesListDel.add(new SelectOption('','--None--')); 
        employeeFilters = true; 
        employeeFiltersDel = true;
        recStartEndTimes= new List<SelectOption>();
        getrecSEPLValues();
        recurringstartEndTimeListSu = new List<recurringWrapper>();
        recurringstartEndTimeListM = new List<recurringWrapper>();
        recurringstartEndTimeListTu = new List<recurringWrapper>();
        recurringstartEndTimeListW = new List<recurringWrapper>();
        recurringstartEndTimeListTh = new List<recurringWrapper>();
        recurringstartEndTimeListF = new List<recurringWrapper>();
        recurringstartEndTimeListSa = new List<recurringWrapper>();
        recurringstartEndTimeListSuDel = new recurringWrapperDel();
        recurringstartEndTimeListMDel = new recurringWrapperDel();
        recurringstartEndTimeListTuDel = new recurringWrapperDel();
        recurringstartEndTimeListWDel = new recurringWrapperDel();
        recurringstartEndTimeListThDel = new recurringWrapperDel();
        recurringstartEndTimeListFDel = new recurringWrapperDel();
        recurringstartEndTimeListSaDel = new recurringWrapperDel();
        for(Integer i=0; i<7;i++){
            recurringday=i+'';
            addRecurringRow();
        }
        
        typeSelectionList = new List<SelectOption>();
        typeSelectionList.add(new SelectOption('Employee','Employee')); 
        typeSelectionList.add(new SelectOption('Employee Group','Employee Group')); 
        selType = 'Employee';
        
        String dId = ApexPages.currentPage().getParameters().get('dId');
        String eId = ApexPages.currentPage().getParameters().get('eId');
        String gId = ApexPages.currentPage().getParameters().get('gId');
        
        if(dId!=null && dId!='null' && dId!=''){
            selectedDepartment=dId;
            getEmployees();
        }

        if(eId!=null && eId!='null' && eId!=''){employeeId=eId;}
        if(gId!=null && gId!='null' && gId!=''){
            employeeGroupId =gId;
            selType='Employee Group';
        }

    }
    /*
    @Name :getrecSEPLValues
    @Description :Custom list of picklist values for Status to remove the option value
    */
    public void getrecSEPLValues(){
        Integer maxHour = Integer.valueOf(getEndHour());
        Integer minHour = Integer.valueOf(getStartHour());
        for(Integer i = 0; i < 24; i++){
            if(minHour <= i && i < maxHour && i < 12){
                recStartEndTimes.add(new SelectOption(i + ':00',i + ':00 AM'));
                recStartEndTimes.add(new SelectOption(i + ':30',i + ':30 AM'));
            } else if(minHour <= i && i < maxHour && i == 12){
                recStartEndTimes.add(new SelectOption('12:00','12:00 PM'));
                recStartEndTimes.add(new SelectOption('12:30','12:30 PM'));
            } else if(minHour <= i && i < maxHour && i > 12){
                recStartEndTimes.add(new SelectOption(i + ':00',(i-12) + ':00 PM'));
                recStartEndTimes.add(new SelectOption(i + ':30',(i-12) + ':30 PM'));
            }  
            if(i == maxHour && maxHour < 12){
                recStartEndTimes.add(new SelectOption(i + ':00',i + ':00 AM'));
            } else if(i == maxHour && maxHour == 12){
                recStartEndTimes.add(new SelectOption('12:00','12:00 PM'));
            } else if(i == maxHour && maxHour > 12){
                recStartEndTimes.add(new SelectOption(i + ':00',(i-12) + ':00 PM'));
            }  
        }
    }
    
    /*
    @Name   :addRecurringRow
    @Description :Add a time range
    */
    public PageReference addRecurringRow(){        
        recurringday = recurringday.replace('\'','');
        if(recurringday=='0'){
            recurringstartEndTimeListSu.add(new recurringWrapper(recurringStartEndTimeListSu.size()));
        }else if(recurringday=='1'){
            recurringstartEndTimeListM.add(new recurringWrapper(recurringStartEndTimeListM.size()));
        }else if(recurringday=='2'){
            recurringstartEndTimeListTu.add(new recurringWrapper(recurringStartEndTimeListTu.size()));
        }else if(recurringday=='3'){
            recurringstartEndTimeListW.add(new recurringWrapper(recurringStartEndTimeListW.size()));
        }else if(recurringday=='4'){
            recurringstartEndTimeListTh.add(new recurringWrapper(recurringStartEndTimeListTh.size()));
        }else if(recurringday=='5'){
            recurringstartEndTimeListF.add(new recurringWrapper(recurringStartEndTimeListF.size()));
        }else if(recurringday=='6'){
            recurringstartEndTimeListSa.add(new recurringWrapper(recurringStartEndTimeListSa.size()));
        }
        return null;
    }
    
    /*
    @Name   :removeExpStatDateRow
    @Description :Remove a time range
    */
    public PageReference removeRecurringRow(){
        recurringday = recurringday.replace('\'','');
        try{
            if(recurringday=='0')
                recurringstartEndTimeListSu.remove(removalIndex);
            if(recurringday=='1')
                recurringstartEndTimeListM.remove(removalIndex);
            if(recurringday=='2')
                recurringstartEndTimeListTu.remove(removalIndex);
            if(recurringday=='3')
                recurringstartEndTimeListW.remove(removalIndex);
            if(recurringday=='4')
                recurringstartEndTimeListTh.remove(removalIndex);
            if(recurringday=='5')
                recurringstartEndTimeListF.remove(removalIndex);
            if(recurringday=='6')
                recurringstartEndTimeListSa.remove(removalIndex);
        }catch(Exception e){}
        Integer i =0;
        for(RecurringWrapper rw : recurringstartEndTimeListSu){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListM){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListTu){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListW){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListTh){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListF){
            rw.index=i;
            i++;
        }
        i=0;
        for(RecurringWrapper rw : recurringstartEndTimeListSa){
            rw.index=i;
            i++;
        }
        return null;               
    }
    
    /*
    @Name   :getStartHour
    @Description :Returns the start hour used in the day view
    */
    public Decimal getStartHour(){
         Decimal decSH = 6;
         if(cCalOpts != null && cCalOpts.club62__Start_Hour__c != null && cCalOpts.club62__Start_Hour__c > -1 && cCalOpts.club62__Start_Hour__c < 24){
                decSH = cCalOpts.club62__Start_Hour__c;
         }
         return decSH;
    }
    
    /*
    @Name   :getEndHour
    @Description :Returns the end hour used in the day view
    */
    public Decimal getEndHour(){
         Decimal decEH = 24;
         if(cCalOpts != null && cCalOpts.club62__End_Hour__c != null && cCalOpts.club62__End_Hour__c > -1 && cCalOpts.club62__End_Hour__c < 24){
                decEH = cCalOpts.club62__End_Hour__c ;
         }
         return decEH;
    }
    
    /*
    @Name   :getSlotMinutes
    @Description :Returns the minutes per slot for the day view
    */
    public Decimal getSlotMinutes(){
        Decimal decSM = 30;
        if(cCalOpts != null && cCalOpts.club62__Slot_Minutes__c != null && cCalOpts.club62__Slot_Minutes__c > 0 && cCalOpts.club62__Slot_Minutes__c <= 60){
            decSM = cCalOpts.club62__Slot_Minutes__c;
        }
        return decSM;
    }
    
    /*
    @Name   :getEmployees
    @Description :Prepare the selectoption list for all employees of selected department
    */
    public void getEmployees(){
        employeeId = '';
        employeesList = new List<SelectOption>();
        employeesList.add(new SelectOption('','--None--'));        
        if(selectedDepartment != '--None--'){
            for(club62__Employee__c employ : [SELECT Id,Name,club62__First_Name__c,club62__Middle_Name__c,club62__Last_Name__c FROM club62__Employee__c WHERE club62__Department__c =:selectedDepartment ORDER By Name ASC]){
                String name = '';
                if(employ.club62__First_Name__c!=null && employ.club62__First_Name__c!=''){
                    name += employ.club62__First_Name__c+' ';
                }
                if(employ.club62__Middle_Name__c!=null && employ.club62__Middle_Name__c!=''){
                    name += employ.club62__Middle_Name__c+' ';
                }
                if(employ.club62__Last_Name__c!=null && employ.club62__Last_Name__c!=''){
                    name += employ.club62__Last_Name__c;
                }
                employeesList.add(new SelectOption(employ.Id, name));
            }
        }                 
    }
    
    /*
    @Name   :getEmployeesDel
    @Description :Prepare the selectoption list for all employees of selected department
    */
    public void getEmployeesDel(){
        employeeIdDel = '';
        employeesListDel = new List<SelectOption>();
        employeesListDel.add(new SelectOption('','--None--'));        
        if(selectedDepartmentDel != '--None--'){
            for(club62__Employee__c employ : [SELECT Id,Name,club62__First_Name__c,club62__Middle_Name__c,club62__Last_Name__c FROM club62__Employee__c WHERE club62__Department__c =:selectedDepartmentDel ORDER By Name ASC]){
                String name = '';
                if(employ.club62__First_Name__c!=null && employ.club62__First_Name__c!=''){
                    name += employ.club62__First_Name__c+' ';
                }
                if(employ.club62__Middle_Name__c!=null && employ.club62__Middle_Name__c!=''){
                    name += employ.club62__Middle_Name__c+' ';
                }
                if(employ.club62__Last_Name__c!=null && employ.club62__Last_Name__c!=''){
                    name += employ.club62__Last_Name__c;
                }
                employeesListDel.add(new SelectOption(employ.Id, name));
            }
        }                 
    }
    
    /*
    @Name   :getEmployeeGroups
    @Description :Prepare the selectoption list for all employee groups
    */
    public List<SelectOption> getEmployeeGroups(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));
        for(club62__Employee_Group__c eg : [SELECT Id, Name FROM club62__Employee_Group__c Where Id!=null ORDER By Name ASC]){
            options.add(new SelectOption(eg.Id, eg.Name));
        } 
        return options;            
    }
    
    /*
    @Name   :getDepartments
    @Description :Returns the selectoption list for all departments
    */
    public List<SelectOption> getDepartments(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        Schema.DescribeFieldResult fieldResult = club62__Employee__c.club62__Department__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        options.add(new SelectOption(p.getValue(), p.getValue()));        
        return options;
    }
    
    /*
    @Name   :getTypeFilters
    @Description :Return the filters for selected type
    */
    public PageReference getTypeFilters(){
        if(selType=='Employee'){
            employeeFilters=true;
            employeeGroupId='';
        } else {
            employeeFilters=false;
            selectedDepartment='';
            employeeId='';
        }
        return null;
    }
    
    /*
    @Name   :getTypeFiltersDel
    @Description :Return the filters for selected type for Removal section
    */
    public PageReference getTypeFiltersDel(){
        if(selTypeDel=='Employee'){
            employeeFiltersDel=true;
            employeeGroupIdDel='';
        } else {
            employeeFiltersDel=false;
            selectedDepartmentDel='';
            employeeIdDel='';
        }
        return null;
    }
    
    /*
    @Name   :getSchedules
    @Description :Populates the Grid
    */
    @RemoteAction
    public static String getSchedules(Long startTime,Long endTime,String employeeId,String selType,String employeeGroupId,String department){
        if((employeeId != null && employeeId != '' && selType=='Employee') || (department != null && department != '' && department != '--None--')
               || (employeeGroupId != null && employeeGroupId != '' && selType=='Employee Group')){
            List<String> empIds = new List<String>();
            if(employeeId != null && employeeId != '' && selType=='Employee'){
                empIds.add(employeeId);
            }
            if(employeeGroupId != null && employeeGroupId != '' && selType=='Employee Group'){
                Set<String> empIdSet = new Set<String>();
                List<club62__Employee_Group_Association__c> esaLst = [SELECT club62__Employee__c,club62__Employee_Group__c 
                                        FROM club62__Employee_Group_Association__c WHERE club62__Employee_Group__c=:employeeGroupId];
                for(club62__Employee_Group_Association__c esa : esaLst){
                    empIdSet.add(esa.club62__Employee__c);
                }
                empIds.addAll(empIdSet);
            }
            if(department != null && department != '' && department != '--None--' && selType=='Employee' && (employeeId == null || employeeId == '')){
                Set<String> empIdSet = new Set<String>();
                for(club62__Employee__c employee : [SELECT Id FROM club62__Employee__c WHERE club62__Department__c=:department]){
                    empIdSet.add(employee.Id);
                }
                empIds.addAll(empIdSet);
            }
            
            DateTime startDT = DateTime.newInstance(startTime);
            DateTime endDT = DateTime.newInstance(endTime);
            String startT = startDT.format('yyyy-MM-dd\'T\'HH:mm:ssZ');
            String endT = endDT.format('yyyy-MM-dd\'T\'HH:mm:ssZ');
            //throw new C62Utilities.CustomException('startTime: ' + startTime + 'endTime: ' + endTime);
            List<EmployeeHours> lstGridHours = new List<EmployeeHours>();
            //get the employee schedule information
            String strQueryEmp = 'SELECT Id,Name,club62__Start_Date__c,club62__End_Date__c,club62__Employee__r.Name,club62__Employee__c,'
                                +'club62__Employee__r.club62__First_Name__c,club62__Employee__r.club62__Middle_Name__c,club62__Employee__r.club62__Last_Name__c,'
                                + '(SELECT Id,Name,club62__Start_Time__c,club62__End_Time__c' 
                                    + ' FROM club62__Employee_Schedule_Lines__r '
                                    + ' WHERE ((club62__Start_Time__c >= ' 
                                        + startT + ' AND club62__Start_Time__c < '
                                        + endT + ') OR (club62__End_Time__c > '
                                        + startT + ' AND club62__End_Time__c <= '
                                        + endT + ') OR (club62__Start_Time__c < '
                                        + startT + ' AND club62__End_Time__c > '
                                        + endT + '))) '
                                + 'FROM club62__Employee_Schedule__c '
                                + 'WHERE ((club62__Start_Date__c >= ' 
                                        + String.valueOf(startDT.Date()) + ' AND club62__Start_Date__c < '
                                        + String.valueOf(endDT.Date()) + ') OR (club62__End_Date__c > '
                                        + String.valueOf(startDT.Date()) + ' AND club62__End_Date__c <= '
                                        + String.valueOf(endDT.Date()) + ') OR (club62__Start_Date__c < '
                                        + String.valueOf(startDT.Date()) + ' AND club62__End_Date__c > '
                                        + String.valueOf(endDT.Date()) + ')) ';
            
            strQueryEmp += ' AND club62__Employee__c IN '+ '(\''+ String.join(empIds,'\',\'') + '\')';
            List<club62__Employee_Schedule__c> lstEmpSch = Database.query(strQueryEmp);
            for(club62__Employee_Schedule__c es : lstEmpSch){
                String name = '';
                //Get the full name of employee
                if(es.club62__Employee__r.club62__First_Name__c!=null && es.club62__Employee__r.club62__First_Name__c!=''){
                    name += es.club62__Employee__r.club62__First_Name__c+' ';
                }
                if(es.club62__Employee__r.club62__Middle_Name__c!=null && es.club62__Employee__r.club62__Middle_Name__c!=''){
                    name += es.club62__Employee__r.club62__Middle_Name__c+' ';
                }
                if(es.club62__Employee__r.club62__Last_Name__c!=null && es.club62__Employee__r.club62__Last_Name__c!=''){
                    name += es.club62__Employee__r.club62__Last_Name__c;
                }
                if(name.startsWith('<')){name = name.replace('<','');}
                //Create employee hours with start time and endtime of the employee schedule line.           
                for(club62__Employee_Schedule_Line__c esl : es.club62__Employee_Schedule_Lines__r){
                    EmployeeHours eh = new EmployeeHours();
                    eh.idVAR = esl.Id;
                    eh.titleVAR = name;
                    eh.allDayVAR = false;
                    eh.startVAR = esl.club62__Start_Time__c;
                    eh.endVAR = esl.club62__End_Time__c;
                    eh.resourceVAR = es.club62__Employee__c;
                    eh.urlVAR = '/' + es.Id;
                    eh.tooltipVAR = name+'<br/>('+eh.startVAR.format('h:mm a') + ' - ' + eh.endVAR.format('h:mm a')+')';
                    lstGridHours.add(eh);   
                }
            }
            String jsonGridEvents = JSON.serialize(lstGridHours);
            jsonGridEvents = jsonGridEvents.replaceAll('VAR','');
            return jsonGridEvents;
        } else {
            return '';
        }
    }
   
    /*
    @Name   :doSaveSchedule
    @Description :Inserts the new schedule with all line items
    */
    public PageReference doSaveSchedule() {
        SavePoint sp = Database.setSavePoint();
        try{
            List<club62__Employee_Schedule_Line__c> lines = new List<club62__Employee_Schedule_Line__c>();
            
            //start and end dates validations
            if(schedule.club62__Start_Date__c==null){
                throw new C62Utilities.CustomException('You must select a Start Date.');
            }
            
            if(schedule.club62__End_Date__c==null){
                throw new C62Utilities.CustomException('You must select an End Date.');
            }
            
            if(schedule.club62__Start_Date__c<System.today()){
                throw new C62Utilities.CustomException('Start Date can not be in past.');
            }
            
            if(schedule.club62__End_Date__c<System.today() || schedule.club62__End_Date__c<schedule.club62__Start_Date__c){
                throw new C62Utilities.CustomException('End Date can not be in past.');
            }
            
            //start and end dates validations
            if(schedule.Name==null){
                throw new C62Utilities.CustomException('You must enter a Schedule Name.');
            }
            
            //employee must be selected if employeeFilters are true
            if(employeeFilters==true && employeeId==null){
                throw new C62Utilities.CustomException('You must select an Employee.');
            }
            
            //employee Group must be selected if employeeFilters are false
            if(employeeFilters==false && employeeGroupId==null){
                throw new C62Utilities.CustomException('You must select an Employee Group.');
            }
            
            if(rSunday==False && rMonday==False && rTuesday==False && rWednesday==False && rThursday==False && rFriday==False && rSaturday==False){
                throw new C62Utilities.CustomException('You must select at least one day shift.');
            }
            
            List<club62__Employee_Schedule__c> empScheduleInsert = new List<club62__Employee_Schedule__c>();
            if(selType=='Employee'){
                club62__Employee_Schedule__c empSchedule = new club62__Employee_Schedule__c(Name=schedule.Name,club62__Employee__c=employeeId,
                                    club62__Start_Date__c=schedule.club62__Start_Date__c,club62__End_Date__c=schedule.club62__End_Date__c);
                empScheduleInsert.add(empSchedule);
            }else{
                List<club62__Employee_Group_Association__c> egaLst = [SELECT ID,club62__Employee__c FROM club62__Employee_Group_Association__c 
                                                        WHERE club62__Employee_Group__c=:employeeGroupId];
                for(club62__Employee_Group_Association__c ega : egaLst){
                    club62__Employee_Schedule__c empSchedule = new club62__Employee_Schedule__c(Name=schedule.Name,
                                            club62__Employee__c=ega.club62__Employee__c,club62__Start_Date__c=schedule.club62__Start_Date__c,
                                            club62__End_Date__c=schedule.club62__End_Date__c);
                    empScheduleInsert.add(empSchedule);
                }
            }
            if(Schema.sObjectType.club62__Employee_Schedule__c.isCreateable() && empScheduleInsert.size()>0){insert empScheduleInsert;}
            
            //create the schedule lines
            for(club62__Employee_Schedule__c empSch : empScheduleInsert){
                Integer numOfDays = empSch.club62__Start_Date__c.daysBetween(empSch.club62__End_Date__c);
                for(Integer i=0; i<=numOfDays; i++){
                    String day = getDowName(empSch.club62__Start_Date__c.addDays(i));
                    
                    if(day=='Sunday' && rSunday == TRUE){
                        for(recurringWrapper res : recurringstartEndTimeListSu){
                            //if(res.StartTime != res.EndTime){
                                club62__Employee_Schedule_Line__c line = getEmpSchLine(res,empSch.Id,empSch.club62__Start_Date__c.addDays(i));
                                lines.add(line);
                            //}
                        }
                    }
                    
                    if(day=='Monday' && rMonday == TRUE){
                        for(recurringWrapper res : recurringstartEndTimeListM){
                            //if(res.StartTime != res.EndTime){
                                club62__Employee_Schedule_Line__c line = getEmpSchLine(res,empSch.Id,empSch.club62__Start_Date__c.addDays(i));
                                lines.add(line);
                            //}
                        }
                    }
                    
                    if(day=='Tuesday' && rTuesday == TRUE){
                        for(recurringWrapper res : recurringstartEndTimeListTu){
                            //if(res.StartTime != res.EndTime){
                                club62__Employee_Schedule_Line__c line = getEmpSchLine(res,empSch.Id,empSch.club62__Start_Date__c.addDays(i));
                                lines.add(line);
                            //}
                        }
                    }
                    
                    if(day=='Wednesday' && rWednesday == TRUE){
                        for(recurringWrapper res : recurringstartEndTimeListW){
                            //if(res.StartTime != res.EndTime){
                                club62__Employee_Schedule_Line__c line = getEmpSchLine(res,empSch.Id,empSch.club62__Start_Date__c.addDays(i));
                                lines.add(line);
                            //}
                        }
                    }
                    
                    if(day=='Thursday' && rThursday == TRUE){
                        for(recurringWrapper res : recurringstartEndTimeListTh){
                            //if(res.StartTime != res.EndTime){
                                club62__Employee_Schedule_Line__c line = getEmpSchLine(res,empSch.Id,empSch.club62__Start_Date__c.addDays(i));
                                lines.add(line);
                            //}
                        }
                    }
                    
                    if(day=='Friday' && rFriday == TRUE){
                        for(recurringWrapper res : recurringstartEndTimeListF){
                            //if(res.StartTime != res.EndTime){
                                club62__Employee_Schedule_Line__c line = getEmpSchLine(res,empSch.Id,empSch.club62__Start_Date__c.addDays(i));
                                lines.add(line);
                            //}
                        }
                    }
                    
                    if(day=='Saturday' && rSaturday == TRUE){
                        for(recurringWrapper res : recurringstartEndTimeListSa){
                            //if(res.StartTime != res.EndTime){
                                club62__Employee_Schedule_Line__c line = getEmpSchLine(res,empSch.Id,empSch.club62__Start_Date__c.addDays(i));
                                lines.add(line);
                            //}
                        }
                    }
                }
            }
            
            if(Schema.sObjectType.club62__Employee_Schedule_Line__c.isCreateable()){insert lines;}
            rSunday = false;
            rMonday = false;
            rTuesday = false;
            rWednesday = false;
            rThursday = false;
            rFriday = false;
            rSaturday = false;
            recurringstartEndTimeListSu = new List<recurringWrapper>();
            recurringstartEndTimeListM = new List<recurringWrapper>();
            recurringstartEndTimeListTu = new List<recurringWrapper>();
            recurringstartEndTimeListW = new List<recurringWrapper>();
            recurringstartEndTimeListTh = new List<recurringWrapper>();
            recurringstartEndTimeListF = new List<recurringWrapper>();
            recurringstartEndTimeListSa = new List<recurringWrapper>();
            for(Integer i=0; i<7;i++){
                recurringday=i+'';
                addRecurringRow();
            }
            schedule = new club62__Employee_Schedule__c();
        }catch(Exception e){
            Database.rollBack(sp);
            ApexPages.addMessages(e);
            return null;
        }
        PageReference page = new PageReference('/apex/Employee_Schedule_Calendar?eId='+employeeId+'&dId='+selectedDepartment+'&gId='+employeeGroupId);
        page.setRedirect(true);
        return page;
    }
    
    /*
    @Name   :getDowName
    @Description :Return the day of week name
    */
    public String getDowName(Date d){
        return Datetime.newInstance(d,Time.newInstance(0, 0, 0, 0)).format('EEEE');
    }
    
    /*
    @Name   :getEmpSchLine
    @Description :Return employee schedule lines
    */
    public club62__Employee_Schedule_Line__c getEmpSchLine(recurringWrapper res,String empSchId,Date cDate){
        List<String> sTimeSplit = res.StartTime.Split(':');
        List<String> eTimeSplit = res.EndTime.Split(':');
        club62__Employee_Schedule_Line__c  line = new  club62__Employee_Schedule_Line__c(club62__Employee_Schedule__c=empSchId);
        line.club62__Start_Time__c=DateTime.newInstance(cDate,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
        line.club62__End_Time__c=DateTime.newInstance(cDate,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
        return line;
    }
    
    /*
    @Name   :getResources
    @Description :Returns the Employee as json string to be used for resources
    */
    public String getResources(){
        List<FCResource> lstRes = new List<FCResource>();
        Set<String> empIdsSet = new Set<String>();

        if(selType=='Employee' && employeeId!=null && employeeId!=''){
            empIdsSet.add(employeeId);
        }else if(selType=='Employee' && selectedDepartment!=null && selectedDepartment!='' && selectedDepartment!='--None--' && (employeeId==null || employeeId=='')){
            for(club62__Employee__c employee : [SELECT Id FROM club62__Employee__c WHERE club62__Department__c=:selectedDepartment]){
                empIdsSet.add(employee.Id);
            }
        }else{
            List<club62__Employee_Group_Association__c> egaLst = [SELECT ID,club62__Employee__c FROM club62__Employee_Group_Association__c 
                                                    WHERE club62__Employee_Group__c=:employeeGroupId];
            for(club62__Employee_Group_Association__c ega : egaLst){
                empIdsSet.add(ega.club62__Employee__c);
            }
        }
        
        List<club62__Employee__c> empList = [Select Id,Name,club62__First_Name__c,club62__Middle_Name__c,club62__Last_Name__c From club62__Employee__c where Id IN : empIdsSet Order By Name Asc];
        
        for(club62__Employee__c resource : empList){ 
            String name = '';
            //Getting the name
            if(resource.club62__First_Name__c!=null && resource.club62__First_Name__c!=''){
                name += resource.club62__First_Name__c+' ';
            }
            if(resource.club62__Middle_Name__c!=null && resource.club62__Middle_Name__c!=''){
                name += resource.club62__Middle_Name__c+' ';
            }
            if(resource.club62__Last_Name__c!=null && resource.club62__Last_Name__c!=''){
                name += resource.club62__Last_Name__c;
            }
            if(name.startsWith('<')){name = name.replace('<','');}
            FCResource fcr = new FCResource();
            fcr.idVAR = resource.id;
            if(name.contains('&nbsp;')){
                String strSpaces = '';
                String strName = '';
                strSpaces = name.substring(0,name.lastIndexOf('&nbsp;')+6);
                strName = name.substring(name.lastIndexOf('&nbsp;')+6);
                fcr.nameVAR = strSpaces + '<a href=\'/' + resource.id + '\'>' + strName + '</a>';
            } else {
                fcr.nameVAR = '<a href=\'/' + resource.id + '\'>' + name + '</a>';
            }
            
            fcr.readonlyVAR = false;
            lstRes.add(fcr);
        }
      
        String jsonResources = JSON.serialize(lstRes);
        jsonResources = jsonResources.replaceAll('VAR','');      
        return jsonResources;
    }
    
    /*
    @Name   :EmployeeHours
    @Description :Wrapper Class for calendar
    @Note: Added VAR to end of each class variable as some are reserved words, remove VAR when converting to JSON
    */
    public class EmployeeHours{
        String idVAR {get;set;}
        String titleVAR {get;set;}
        Boolean allDayVAR {get;set;}
        DateTime startVAR {get;set;}
        DateTime endVAR {get;set;}
        String resourceVAR {get;set;}
        String urlVAR {get;set;}
        String tooltipVAR {get;set;}
    } 
    
    /*
    @Name   :FCResource
    @Description :Resource object for the calendar fields gathered from this link: http://arshaw.com/fullcalendar/docs/event_data/Event_Object/
    @Note: Added VAR to end of each class variable as some are reserved words, remove VAR when converting to JSON
    */
    public class FCResource{
        String idVAR {get;set;}
        String nameVAR {get;set;}
        Boolean readonlyVAR {get;set;}
    }  
    
    public class recurringWrapper{
        public String startTime{get;set;}
        public String endTime{get;set;}
        public Integer index{get;set;}
        public recurringWrapper(Integer indexNum){
            index=indexNum;
        }
    }
    
    public class recurringWrapperDel{
        public String startTime{get;set;}
        public String endTime{get;set;}
        public String empScheLineId{get;set;}
        public Integer index{get;set;}
    }
    
    /*-------Code start for Employee Schedule Removal Section------*/
    /*
    @Name   :deleteEmpScheduleLines
    @Description :Delete the Employee Schedule Lines.
    */
    public PageReference deleteEmpScheduleLines(){
        SavePoint sp = Database.setSavePoint();
        try{
            //start and end dates validations
            if(scheduleDel.club62__Start_Date__c==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select a Start Date.'));
                return null;
            }
            
            if(scheduleDel.club62__End_Date__c==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select an End Date.'));
                return null;
            }
            
            if(scheduleDel.club62__Start_Date__c<System.today()){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Start Date can not be in past.'));
                return null;
            }
            
            if(scheduleDel.club62__End_Date__c<System.today() || scheduleDel.club62__End_Date__c<scheduleDel.club62__Start_Date__c){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'End Date can not be in past.'));
                return null;
            }
            
            //employee must be selected if employeeFilters are true
            if(employeeFiltersDel==true && employeeIdDel==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select an Employee.'));
                return null;
            }
            
            //employee Group must be selected if employeeFilters are false
            if(employeeFiltersDel==false && employeeGroupIdDel==null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select an Employee Group.'));
                return null;
            }
            
            //employee and transfer employee can not be same
            if(employeeFiltersDel==true && employeeIdDel !=null && employeeIdDel != '' && scheduleDel.club62__Employee__c != null && employeeIdDel == scheduleDel.club62__Employee__c){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Employee and Transfer To Employee can\'t be same.'));
                return null;
            }
    /*        
            if(rSundayDel==False && rMondayDel==False && rTuesdayDel==False && rWednesdayDel==False && rThursdayDel==False && rFridayDel==False && rSaturdayDel==False){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You must select at least one day shift.'));
                return null;
            }
    */        
            if((employeeIdDel != null && employeeIdDel != '' && selTypeDel =='Employee') || (employeeGroupIdDel != null && employeeGroupIdDel != '' && selTypeDel=='Employee Group')){
                Set<String> empIdSet = new Set<String>();
                String empName = '';
                if(employeeIdDel != null && employeeIdDel != '' && selTypeDel =='Employee'){
                    empIdSet.add(employeeIdDel);
                    List<club62__Employee__c> empLst = [SELECT Name,club62__First_Name__c,club62__Middle_Name__c,club62__Last_Name__c FROM club62__Employee__c WHERE ID=:employeeIdDel];
                    if(empLst.size()>0){
                        String name = '';
                        if(empLst[0].club62__First_Name__c!=null && empLst[0].club62__First_Name__c!=''){
                            name += empLst[0].club62__First_Name__c+' ';
                        }
                        if(empLst[0].club62__Middle_Name__c!=null && empLst[0].club62__Middle_Name__c!=''){
                            name += empLst[0].club62__Middle_Name__c+' ';
                        }
                        if(empLst[0].club62__Last_Name__c!=null && empLst[0].club62__Last_Name__c!=''){
                            name += empLst[0].club62__Last_Name__c;
                        }
                        empName = 'Transferred Schedule - Covering for '+name;
                    }
                }
                if(employeeGroupIdDel != null && employeeGroupIdDel != '' && selTypeDel =='Employee Group'){
                    List<club62__Employee_Group_Association__c> esaLst = [SELECT club62__Employee__c,club62__Employee_Group__c,club62__Employee_Group__r.Name  
                                            FROM club62__Employee_Group_Association__c WHERE club62__Employee_Group__c=:employeeGroupIdDel];
                    for(club62__Employee_Group_Association__c esa : esaLst){
                        empIdSet.add(esa.club62__Employee__c);
                        empName = 'Transferred Schedule - Covering for '+esa.club62__Employee_Group__r.Name;
                        
                    }
                }
                List<String> empIds = new List<String>(empIdSet);
    
                String query = 'SELECT ID,Name,(SELECT Id,Name,club62__Day__c,club62__Start_Time__c,club62__End_Time__c' 
                                + ' FROM club62__Employee_Schedule_Lines__r)' 
                                + ' FROM club62__Employee_Schedule__c '
                                + ' WHERE ((club62__Start_Date__c >= ' 
                                + String.valueOf(scheduleDel.club62__Start_Date__c) + ' AND club62__Start_Date__c < '
                                + String.valueOf(scheduleDel.club62__End_Date__c) + ') OR (club62__End_Date__c > '
                                + String.valueOf(scheduleDel.club62__Start_Date__c) + ' AND club62__End_Date__c <= '
                                + String.valueOf(scheduleDel.club62__End_Date__c) + ') OR (club62__Start_Date__c < '
                                + String.valueOf(scheduleDel.club62__Start_Date__c) + ' AND club62__End_Date__c > '
                                + String.valueOf(scheduleDel.club62__End_Date__c) + ')) ';
                
                if(scheduleDel.club62__Start_Date__c==scheduleDel.club62__End_Date__c){
                    query = query.subString(0,query.length()-2);
                    query += ' OR (club62__Start_Date__c = '
                                + String.valueOf(scheduleDel.club62__Start_Date__c) + ' AND club62__End_Date__c <= '
                                + String.valueOf(scheduleDel.club62__End_Date__c) + ')) ';
                }
                                
                //query += ' AND club62__Employee__c IN '+ '(\''+ String.join(empIds,'\',\'') + '\')';
                query += ' AND club62__Employee__c IN :empIdSet ';
                List<club62__Employee_Schedule__c> lstEmpSch = Database.query(query);

                List<club62__Employee_Schedule_Line__c> delESL = new List<club62__Employee_Schedule_Line__c>();
                Integer numOfDays = scheduleDel.club62__Start_Date__c.daysBetween(scheduleDel.club62__End_Date__c);
                Set<ID> esSet = new Set<ID>();
                for(Integer i=0; i<=numOfDays; i++){
                    Date ctDate = scheduleDel.club62__Start_Date__c.addDays(i);
                    for(club62__Employee_Schedule__c es : lstEmpSch){
                        esSet.add(es.ID);
                        for(club62__Employee_Schedule_Line__c esl : es.club62__Employee_Schedule_Lines__r){
                            if(rSundayDel && esl.club62__Day__c=='Sunday'){
                                if(esl.club62__Start_Time__c>=startTime(ctDate,recurringstartEndTimeListSuDel) && esl.club62__End_Time__c<=endTime(ctDate,recurringstartEndTimeListSuDel)){
                                    delESL.add(esl);
                                }
                            }
                            if(rMondayDel && esl.club62__Day__c=='Monday'){
                                if(esl.club62__Start_Time__c>=startTime(ctDate,recurringstartEndTimeListMDel) && esl.club62__End_Time__c<=endTime(ctDate,recurringstartEndTimeListMDel)){
                                    delESL.add(esl);
                                }
                            }
                            if(rTuesdayDel && esl.club62__Day__c=='Tuesday'){
                                if(esl.club62__Start_Time__c>=startTime(ctDate,recurringstartEndTimeListTuDel) && esl.club62__End_Time__c<=endTime(ctDate,recurringstartEndTimeListTuDel)){
                                    delESL.add(esl);
                                }
                            }
                            if(rWednesdayDel && esl.club62__Day__c=='Wednesday'){
                                if(esl.club62__Start_Time__c>=startTime(ctDate,recurringstartEndTimeListWDel) && esl.club62__End_Time__c<=endTime(ctDate,recurringstartEndTimeListWDel)){
                                    delESL.add(esl);
                                }
                            }
                            if(rThursdayDel && esl.club62__Day__c=='Thursday'){
                                if(esl.club62__Start_Time__c>=startTime(ctDate,recurringstartEndTimeListThDel) && esl.club62__End_Time__c<=endTime(ctDate,recurringstartEndTimeListThDel)){
                                    delESL.add(esl);
                                }
                            }
                            if(rFridayDel && esl.club62__Day__c=='Friday'){
                                if(esl.club62__Start_Time__c>=startTime(ctDate,recurringstartEndTimeListFDel) && esl.club62__End_Time__c<=endTime(ctDate,recurringstartEndTimeListFDel)){
                                    delESL.add(esl);
                                }
                            }
                            if(rSaturdayDel && esl.club62__Day__c=='Saturday'){
                                if(esl.club62__Start_Time__c>=startTime(ctDate,recurringstartEndTimeListSaDel) && esl.club62__End_Time__c<=endTime(ctDate,recurringstartEndTimeListSaDel)){
                                    delESL.add(esl);
                                }
                            }
                            if(!rSundayDel && !rMondayDel && !rTuesdayDel && !rWednesdayDel && !rThursdayDel && !rFridayDel && !rSaturdayDel){
                                if(esl.club62__Start_Time__c.date()==ctDate && esl.club62__End_Time__c.date()==ctDate){
                                    delESL.add(esl);
                                }
                            }
                        }
                    }
                }
                
                if(delESL.size()>0){
                    if(scheduleDel.club62__Employee__c != null){
                        scheduleDel.Name = empName;
                        if(Schema.sObjectType.club62__Employee_Schedule__c.isCreateable()){insert scheduleDel;}
                        List<club62__Employee_Schedule_Line__c> insertESL = new List<club62__Employee_Schedule_Line__c>();
                        for(club62__Employee_Schedule_Line__c esl : delESL){
                            club62__Employee_Schedule_Line__c eslClone = esl.Clone();
                            eslClone.club62__Employee_Schedule__c = scheduleDel.ID;
                            insertESL.add(eslClone);
                        }
                        if(Schema.sObjectType.club62__Employee_Schedule_Line__c.isCreateable()){insert insertESL;}
                    }
                    if(Schema.sObjectType.club62__Employee_Schedule_Line__c.isDeletable()){delete delESL;}
                }
                if(esSet.size()>0){
                    List<club62__Employee_Schedule__c> esLst = [SELECT ID,Name,(SELECT Id,Name,club62__Day__c,club62__Start_Time__c,club62__End_Time__c 
                                                        FROM club62__Employee_Schedule_Lines__r) FROM club62__Employee_Schedule__c 
                                                        WHERE ID IN :esSet];
                    List<club62__Employee_Schedule__c> delES = new List<club62__Employee_Schedule__c>();
                    for(club62__Employee_Schedule__c es : esLst){
                        if(es.club62__Employee_Schedule_Lines__r.size() == null || es.club62__Employee_Schedule_Lines__r.size()==0){
                            delES.add(es);
                        }
                    }
                    if(Schema.sObjectType.club62__Employee_Schedule__c.isDeletable() && delES.size()>0){delete delES;}
                }
                rSundayDel = false;
                rMondayDel = false;
                rTuesdayDel = false;
                rWednesdayDel = false;
                rThursdayDel = false;
                rFridayDel = false;
                rSaturdayDel = false;
                recurringstartEndTimeListSuDel = new recurringWrapperDel();
                recurringstartEndTimeListMDel = new recurringWrapperDel();
                recurringstartEndTimeListTuDel = new recurringWrapperDel();
                recurringstartEndTimeListWDel = new recurringWrapperDel();
                recurringstartEndTimeListThDel = new recurringWrapperDel();
                recurringstartEndTimeListFDel = new recurringWrapperDel();
                recurringstartEndTimeListSaDel = new recurringWrapperDel();
                scheduleDel = new club62__Employee_Schedule__c();
                selectedDepartmentDel = '--None--';
                employeesListDel = new List<SelectOption>();
                employeesListDel.add(new SelectOption('','--None--'));     
                employeeIdDel = '';
                employeeGroupIdDel = '';
            }
        }catch(Exception e){
            Database.rollBack(sp);
            club62__Employee_Schedule__c sDel = scheduleDel;
            scheduleDel = new club62__Employee_Schedule__c();
            scheduleDel.club62__Employee__c = sDel.club62__Employee__c;
            scheduleDel.club62__Start_Date__c = sDel.club62__Start_Date__c;
            scheduleDel.club62__End_Date__c = sDel.club62__End_Date__c;
            ApexPages.addMessages(e);
        }
        return null;
    }
    //Preparing start datetime
    public DateTime startTime(Date ct,recurringWrapperDel rw){
        List<String> sTimeSplit = rw.StartTime.Split(':');
        return DateTime.newInstance(ct,Time.newInstance(Integer.valueOf(sTimeSplit[0]),Integer.valueOf(sTimeSplit[1]),0,0));
    }
    //Preparing end datetime
    public DateTime endTime(Date ct,recurringWrapperDel rw){
        List<String> eTimeSplit = rw.EndTime.Split(':');
        return DateTime.newInstance(ct,Time.newInstance(Integer.valueOf(eTimeSplit[0]),Integer.valueOf(eTimeSplit[1]),0,0));
    }
}