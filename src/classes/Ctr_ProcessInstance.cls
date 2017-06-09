//public class Ctr_ProcessInstance {
//    public String processId;
//    public String leadId;
//    public ProcessInstance objProcessInstance;
//    public Lead objLead {get; set;}
//    public PageReference redirectPage;
//    public Ctr_ProcessInstance(ApexPages.StandardController stdController){


//        processId = ApexPages.currentPage().getParameters().get('id');
//        leadId = stdController.getId();//ApexPages.currentPage().getParameters().get('leadId');
//        objLead = [select Name,Owner.Name from Lead where id =:leadId];
//        redirectPage = new PageReference('/'+leadId);
//    }
   
//    public PageReference Approve(){
//        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
//        req.setAction('Approve');
//        req.setWorkitemId(processId);
//        Approval.ProcessResult result =  Approval.process(req);
//        update objLead;
//        return redirectPage ;
//    }
   
//    public PageReference Reject(){
//        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
//        req.setAction('Reject');
//        req.setWorkitemId(processId);
//        Approval.ProcessResult result =  Approval.process(req);
//        update objLead;
//        return redirectPage ;      
//    }
   
//     public PageReference Cancel(){
//     return redirectPage ;
//    }
//}


public with sharing class Ctr_ProcessInstance {  
    //Protected Members 
    private static final DescribeSObjectResult oSomeObjectSchema = Schema.SObjectType.LeadHistory;
    private static final Map<string, Schema.SObjectField> mapFields = oSomeObjectSchema.fields.getMap();

    //Properties
    public Id SomeObjectId {get;set;}
    public integer PageSize {get;set;}
    public boolean AllowShowMore {get;set;}

    public List<SomeObjectHistory> SomeObjectHistories {
        get { return getSomeObjectHistory(SomeObjectId); }
    }

    //Constructors

    /**
     * Default Constructor
     */
    public Ctr_ProcessInstance() {
        PageSize = 5;   
        AllowShowMore = true;
    }

    //Public Methods
    public void showMore() {
        PageSize += 5;
    }

    //Private Methods

    /**
     * Returns SomeObject History records associated to the current SomeObject
     *
     * @param   SomeObjectId     the SomeObject__c record id to retrieve
     * @return  a list of SomeObjectHistory objects
     */
    private List<SomeObjectHistory> getSomeObjectHistory(Id SomeObjectId) {
        List<SomeObjectHistory> listSomeObjectHistory = new List<SomeObjectHistory>();

        if (SomeObjectId != null) {
            DateTime dLastCreatedDate = null;

            integer limitPlusOne = PageSize + 1;

            List<LeadHistory> listEntityHistory = [SELECT Id, Field, NewValue, OldValue, CreatedDate, CreatedById, CreatedBy.Name FROM LeadHistory WHERE LeadId = :SomeObjectId ORDER BY CreatedDate DESC, Id DESC LIMIT :limitPlusOne];
            AllowShowMore = (listEntityHistory.size() == limitPlusOne);

            for (LeadHistory oHistory : listEntityHistory) { 
                SomeObjectHistory oSomeObjectHistory = new SomeObjectHistory(oHistory);

                if (mapFields.containsKey(oHistory.Field)) {
                    oSomeObjectHistory.FieldLabel = mapFields.get(oHistory.Field).getDescribe().Label;
                }

                if (dLastCreatedDate == oHistory.CreatedDate) {
                    oSomeObjectHistory.ShowDateAndUser = false;
                }
                else {
                    oSomeObjectHistory.ShowDateAndUser = true;
                }

                listSomeObjectHistory.add(oSomeObjectHistory);
                dLastCreatedDate = oHistory.CreatedDate;

                if (listSomeObjectHistory.size() == PageSize) break;
            }
        }

        return listSomeObjectHistory;
    }

    //Internal Classes

    /**
     * Data structure representing a SomeObject History record for display
     */
    public class SomeObjectHistory {
        //Properties
        public boolean ShowDateAndUser {get;set;}
        public string FieldLabel {get;set;}
        public LeadHistory History {get; private set;}

        public string ActionFormat {
            get { return getActionFormat(); }
        }

        public SomeObjectHistory(LeadHistory oHistory) {
            History = oHistory;
        }

        //Constructors
        public SomeObjectHistory() {
            showDateAndUser = true;
        }

        //Private Methods
        private string getActionFormat() {
            string sActionFormat = '';

            if (History != null) {
                sActionFormat = 'Record {0}.';

                if (History.newValue != null && History.oldValue == null) {
                    sActionFormat = 'Changed <strong>{1}</strong> to <strong>{3}</strong>.';    
                }
                else if (History.newValue != null && History.oldValue != null) {
                    sActionFormat = 'Changed <strong>{1}</strong> from {2} to <strong>{3}</strong>.';   
                }
                else if (History.Field != null && History.Field.equalsIgnoreCase('created')) {
                    sActionFormat = 'Created.';
                }
            }
 
            return sActionFormat;
        }
    }
}