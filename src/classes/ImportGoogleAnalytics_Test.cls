/*
   Copyright 2011 Mavens Consulting, Inc.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/   

@isTest
private class ImportGoogleAnalytics_Test {
	static string siteMetricSettingsName = 'Test';
	
	static {
		insert new Site_Metric_Settings__c(Name='Test', Email__c='test@test.com', Password__c='test', Table_Id__c='test');
	}
	
	static testMethod void importSingleMetricSavesMetrics() {
        //Temporarily save a site info for testing
   	    AnalyticSettingsController asController = new AnalyticSettingsController();
        asController.settings = new Site_Metric_Settings__c(Name = siteMetricSettingsName, Email__c = 'as@as.com', Password__c = '123', Table_Id__c = 'ga:123456');
        PageReference returnedPageRef = asController.save();
        asController.settings = null;

		ImportGoogleAnalytics.importSingleMetric(siteMetricSettingsName);
		System.assert([select count() from Site_Metric__c where Name = :ImportGoogleAnalytics.singleMetricName] > 0);
	}

	static testMethod void importDailyMetricsSavesMetrics() {
        //Temporarily save a site info for testing
   	    AnalyticSettingsController asController = new AnalyticSettingsController();
        asController.settings = new Site_Metric_Settings__c(Name = siteMetricSettingsName, Email__c = 'as@as.com', Password__c = '123', Table_Id__c = 'ga:123456');
        PageReference returnedPageRef = asController.save();
        asController.settings = null;

		ImportGoogleAnalytics.importDailyMetrics(siteMetricSettingsName);
		System.assert([select count() from Site_Metric__c] > 0);
	}
	
	static testMethod void importEventsSavesEvents() {
        //Temporarily save a site info for testing
   	    AnalyticSettingsController asController = new AnalyticSettingsController();
        asController.settings = new Site_Metric_Settings__c(Name = siteMetricSettingsName, Email__c = 'as@as.com', Password__c = '123', Table_Id__c = 'ga:123456');
        PageReference returnedPageRef = asController.save();
        asController.settings = null;

		ImportGoogleAnalytics.importEvents(siteMetricSettingsName);
		System.assert([select count() from Site_Event__c] > 0);		
	}
	
}