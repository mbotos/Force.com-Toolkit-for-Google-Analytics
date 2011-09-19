@isTest
private class DataImportWorker_Test {
	static {
		insert new Site_Metric_Settings__c(Name='Test', Email__c='test@test.com', Password__c='test', Table_Id__c='test');
	}
	
	/* Since database update cannot be done before a callout, the testing for each metric will need to be done step by step */ 
	static testMethod void testImportData() {
		DataImportWorker.importData();                          

		Site_Metric_Settings__c settings = [Select s.Name, s.Table_Id__c, s.Password__c, s.Email__c,
                               s.Track_Visitors__c, s.Track_New_Visits__c, 
                               s.Track_Page_Views_Per_Visit__c, 
                               s.Track_Visit_Bounce_Rate__c, s.Average_Time_on_Site__c, 
                               s.Tracking_Visitors__c, s.Tracking_New_Visits__c, 
                               s.Tracking_Page_Views_Per_Visit__c, 
                               s.Tracking_Visit_Bounce_Rate__c, s.Tracking_Average_Time_on_Site__c
                          From Site_Metric_Settings__c s where s.Name = 'Test'];
	
		System.assertEquals(false, settings.Tracking_Visitors__c);
	} 
}