public with sharing class AnalyticSettingsController {
    public PageReference cancel() {
       PageReference pageRef = Page.analyticsSettings;
       
       pageRef.setRedirect(true);
       
       return (pageRef);
    }


    public String siteName {get; set;}
    
    public Site_Metric_Settings__c settings {get; set;}

    public List<Site_Metric_Settings__c> sites {get; set;}


    public PageReference save() {
       PageReference pageRef = null;
       
       //Update tracking status to turn off tracking based on any instructions to track off a metric. 
       //Turning on tracking status would be done in the daily job.  
       if (settings.Track_Visitors__c == false && settings.Tracking_Visitors__c == true) {
           settings.Tracking_Visitors__c = false;
       }
       if (settings.Track_New_Visits__c == false && settings.Tracking_New_Visits__c == true) {
           settings.Tracking_New_Visits__c = false;
       }
       if (settings.Track_Page_Views_Per_Visit__c == false && settings.Tracking_Page_Views_Per_Visit__c == true) {
           settings.Tracking_Page_Views_Per_Visit__c = false;
       }
       if (settings.Track_Visit_Bounce_Rate__c == false && settings.Tracking_Visit_Bounce_Rate__c == true) {
           settings.Tracking_Visit_Bounce_Rate__c = false;
       }
       if (settings.Average_Time_on_Site__c == false && settings.Tracking_Average_Time_on_Site__c == true) {
           settings.Tracking_Average_Time_on_Site__c = false;
       }
       
       try {
            upsert(settings);
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }

       pageRef = Page.analyticsSettings;
       pageRef.getParameters().put('siteName', settings.Name);
       
       return (pageRef);
    }

    public PageReference editSite() {
       PageReference pageRef = null;

         settings = null;
         try {
            settings = [Select s.Name, s.Table_Id__c, s.Password__c, 
                               s.Email__c, s.Track_Visitors__c, s.Track_New_Visits__c, s.Track_Page_Views_Per_Visit__c, 
                               s.Track_Visit_Bounce_Rate__c, s.Average_Time_on_Site__c, 
                               s.Tracking_Visitors__c, s.Tracking_New_Visits__c, 
                               s.Tracking_Page_Views_Per_Visit__c, 
                               s.Tracking_Visit_Bounce_Rate__c, s.Tracking_Average_Time_on_Site__c
                          From Site_Metric_Settings__c s where s.Name = :siteName];
         } catch (QueryException ex) {
         }       
         
         if (settings == null) {
            settings = new Site_Metric_Settings__c();
            settings.Name = siteName;
         }
    
         pageRef = Page.editsite;
         pageRef.getParameters().put('siteName', siteName);
       
       return (pageRef);
    }

    public PageReference getSiteInfo() {
       settings = null;
       if (siteName != null && siteName != '') {
         try {
            settings = [Select s.Name, s.Table_Id__c, s.Password__c, 
                               s.Email__c, s.Track_Visitors__c, s.Track_New_Visits__c, s.Track_Page_Views_Per_Visit__c, 
                               s.Track_Visit_Bounce_Rate__c, s.Average_Time_on_Site__c, 
                               s.Tracking_Visitors__c, s.Tracking_New_Visits__c, 
                               s.Tracking_Page_Views_Per_Visit__c, 
                               s.Tracking_Visit_Bounce_Rate__c, s.Tracking_Average_Time_on_Site__c
                          From Site_Metric_Settings__c s where s.Name = :siteName];
         } catch (QueryException ex) {
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Site Metric Settings with Name = ' + siteName);
            ApexPages.addMessage(pageMsg);
         }       
       } else {
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Site Name is asd required');
            ApexPages.addMessage(pageMsg);
       }
       return null;
    }
    
    public PageReference searchSites() {
       sites = null;
       settings = null;
       if (siteName == null || siteName == '') {
         try {
            sites = [Select s.Name
                          From Site_Metric_Settings__c s];
         } catch (QueryException ex) {
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No Site setup with Name = ' + siteName);
            ApexPages.addMessage(pageMsg);
         }       
       } else {
         try {
            sites = [Select s.Name
                          From Site_Metric_Settings__c s where s.Name = :siteName];
         } catch (QueryException ex) {
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No Site setup with Name = ' + siteName);
            ApexPages.addMessage(pageMsg);
         }       
       }
       if (sites == null || sites.size() == 0) {
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No sites for the entered criteria.');
            ApexPages.addMessage(pageMsg);
       }
       return null;
    }

    public AnalyticSettingsController () {
    }
}