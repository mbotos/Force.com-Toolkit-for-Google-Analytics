@isTest
private class AnalyticSettingsController_Test {
    static testMethod void testCancel() {
        AnalyticSettingsController asController = new AnalyticSettingsController();
        PageReference returnedPageRef = asController.cancel();
        System.assertEquals(returnedPageRef.getUrl(), Page.analyticsSettings.getUrl()); 
    }

    static testMethod void testSave() {
        AnalyticSettingsController asController = new AnalyticSettingsController();
        String siteName = 'MySite';
        
        asController.settings = new Site_Metric_Settings__c(Name = siteName, Email__c = 'as@as.com', Password__c = '123', Table_Id__c = 'ga:123456');
        asController.settings.Track_Visitors__c = false;
        asController.settings.Tracking_Visitors__c = true;
        asController.settings.Track_New_Visits__c = false;
        asController.settings.Tracking_New_Visits__c = true;
        asController.settings.Track_Page_Views_Per_Visit__c = false;
        asController.settings.Tracking_Page_Views_Per_Visit__c = true;
        asController.settings.Track_Visit_Bounce_Rate__c = false;
        asController.settings.Tracking_Visit_Bounce_Rate__c = true;
        asController.settings.Average_Time_on_Site__c = false;
        asController.settings.Tracking_Average_Time_on_Site__c = true;
        
        PageReference returnedPageRef = asController.save();
        
        Site_Metric_Settings__c  settings = [Select s.Name, s.Table_Id__c, s.Password__c, 
                               s.Email__c, s.Track_Visitors__c, s.Track_New_Visits__c, s.Track_Page_Views_Per_Visit__c, 
                               s.Track_Visit_Bounce_Rate__c, s.Average_Time_on_Site__c, 
                               s.Tracking_Visitors__c, s.Tracking_New_Visits__c, 
                               s.Tracking_Page_Views_Per_Visit__c, 
                               s.Tracking_Visit_Bounce_Rate__c, s.Tracking_Average_Time_on_Site__c
                          From Site_Metric_Settings__c s where s.Name = :siteName];
                          
        System.assertEquals(settings.Tracking_Visitors__c, false);
        System.assertEquals(settings.Tracking_New_Visits__c, false);
        System.assertEquals(settings.Tracking_Page_Views_Per_Visit__c, false);
        System.assertEquals(settings.Tracking_Visit_Bounce_Rate__c, false);
        System.assertEquals(settings.Tracking_Average_Time_on_Site__c, false);
        System.assertEquals(returnedPageRef.getUrl().contains('/apex/analyticssettings'), true);
    }
    static testMethod void testEditSite() { 
        AnalyticSettingsController asController = new AnalyticSettingsController();
        asController.siteName = 'JunkSite';
        
        PageReference returnedPageRef = asController.editSite();
        
        System.assertEquals(asController.settings.Name, 'JunkSite');
        System.assertEquals(returnedPageRef.getUrl().contains('/apex/editsite'), true);
    }
    
    static testMethod void testGetSiteInfo() { 
        AnalyticSettingsController asController = new AnalyticSettingsController();

        asController.siteName = '';
        PageReference returnedPageRef = asController.getSiteInfo();
        System.assertEquals(asController.settings, null);

        asController.siteName = 'AnotherJunkSite';
        returnedPageRef = asController.getSiteInfo();
        System.assertEquals(asController.settings, null);

        //Temporarily save a site info for testing
        String siteName = 'MySite';
        asController.settings = new Site_Metric_Settings__c(Name = siteName, Email__c = 'as@as.com', Password__c = '123', Table_Id__c = 'ga:123456');
        returnedPageRef = asController.save();
        asController.settings = null;

        //Verify that the settings are retrieved properly
        asController.siteName = 'MySite';
        returnedPageRef = asController.getSiteInfo();
        //System.assertNotEquals(asController.settings, null);
        System.assertNotEquals(null, asController.settings);
        System.assertEquals('123', asController.settings.Password__c);
        
        //Delete the settings record
        Site_Metric_Settings__c tempSettings = asController.settings;
        try {
            delete(tempSettings);
        } catch(System.DMLException e) {
        }
    }
    
    static testMethod void testSearchSites() { 
        AnalyticSettingsController asController = new AnalyticSettingsController();

        //zero value with wrong criteria
        asController.siteName = 'JunkSite';
        PageReference returnedPageRef = asController.searchSites();
        System.assertEquals(0, asController.sites.size());

        //One value with no criteria (as there is only one site defined in the database)
        asController.siteName = '';
        returnedPageRef = asController.searchSites();
        //System.assertEquals(1, asController.sites.size());
        //Temporarily save a site info for testing
        String siteName = 'MyBlog';
        asController.settings = new Site_Metric_Settings__c(Name = siteName, Email__c = 'as@as.com', Password__c = '123', Table_Id__c = 'ga:123456');
        returnedPageRef = asController.save();
        asController.settings = null;

        //One value with correct criteria
        asController.siteName = 'MyBlog';
        returnedPageRef = asController.searchSites();
        //System.assertEquals(1, asController.sites.size());
        System.assertEquals(1, asController.sites.size());
        
        //One value with no criteria (as there is only one site defined in the database)
        asController.siteName = '';
        returnedPageRef = asController.searchSites();
        System.assertEquals(1, asController.sites.size());
    }
}