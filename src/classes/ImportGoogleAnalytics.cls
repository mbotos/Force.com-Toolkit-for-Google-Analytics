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

public with sharing class ImportGoogleAnalytics {
	public static GoogleAnalytics ga;
	public static string singleMetricName = 'Test Single Metric';
	
	public static void importSingleMetric(string siteMetricSettingsName) {
		if(initialize(siteMetricSettingsName)) {	
			
			Site_Metric_Date__c metricDate = new Site_Metric_Date__c(Name = '2011 Q1', Start_Date__c = Date.newInstance(2011,1,1), 
				End_Date__c = Date.newInstance(2011,3,31));
				
			GoogleAnalytics.Entry entry = ga.getEntry(metricDate, new list<String>{GoogleAnalytics.VisitorsMetric});
			
			// only start inserts after all callouts are complete			
			insert metricDate;
			
			Site_Metric__c metric = new Site_Metric__c(Name = singleMetricName, Metric__c = GoogleAnalytics.VisitorsMetric, 
				Value__c = decimal.ValueOf(entry.getMetric(GoogleAnalytics.VisitorsMetric)), Site_Metric_Date__c = metricDate.Id);				
				
			insert metric;
		}		
	}
	
	public static void importDailyMetrics(string siteMetricSettingsName) {
		if(initialize(siteMetricSettingsName)) {		
			Date startDate = Date.newInstance(2011, 8, 19);
			Date endDate = Date.newInstance(2011, 8, 19);
		
			ga.insertDailyMetrics(startDate, endDate, new list<String>{GoogleAnalytics.VisitorsMetric,
										GoogleAnalytics.PageViewsPerVisitMetric,
										GoogleAnalytics.PercentNewVisitsMetric,
										GoogleAnalytics.VisitBounceRateMetric,
										GoogleAnalytics.AverageTimeOnSiteMetric});
		}
	}
	
	public static void importEvents(string siteMetricSettingsName) {
		if(initialize(siteMetricSettingsName)) {		
			Date startDate = Date.newInstance(2011, 2, 1);
			Date endDate = Date.newInstance(2011, 2, 2);
			List<String> metrics = new List<String>{GoogleAnalytics.TotalEventsMetric};			
			List<String> dimensions = new List<String>{GoogleAnalytics.DateDimension, GoogleAnalytics.EventCategoryDimension, 
				GoogleAnalytics.EventActionDimension, GoogleAnalytics.EventLabelDimension};
		
			list<GoogleAnalytics.Entry> entries = ga.getEntries(startDate, endDate, dimensions, metrics);
			list<Site_Event__c> events = new list<Site_Event__c>();
			
			for (GoogleAnalytics.Entry entry : entries) {
				Site_Event__c event = new Site_Event__c(
					Name = entry.getDimension(GoogleAnalytics.EventLabelDimension),
					Category__c = entry.getDimension(GoogleAnalytics.EventCategoryDimension),
					Action__c = entry.getDimension(GoogleAnalytics.EventActionDimension),
					Count__c = decimal.ValueOf(entry.getMetric(GoogleAnalytics.TotalEventsMetric)),
					Date__c = GoogleAnalytics.parseDate(entry.getDimension(GoogleAnalytics.DateDimension))
				);
				events.add(event);
			}
			
			insert events;
		}
	}
	
	static boolean initialize(string siteMetricSettingsName) {
		Site_Metric_Settings__c settings;
		
		try {
			settings = [Select s.Table_Id__c, s.Password__c, s.Email__c From Site_Metric_Settings__c s where s.Name = :siteMetricSettingsName];
		} catch (QueryException ex) {
			System.debug(Logginglevel.WARN, 'No Site Metric Settings with Name = ' + siteMetricSettingsName + '; stopping import');
			return false;
		}		

		ga = new GoogleAnalytics(settings);	
		return true;
	}	
}