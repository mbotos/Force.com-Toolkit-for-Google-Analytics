/*
This class queries the custom settings: Site_Metric_Settings__c to determine
the metrics to be pulled from Google Analytics as well as the dates for which the
metrics need to be pulled. 

The detailed logic is as follows: 
1. Query Site_Metric_Settings__c to retrieve the metrics to be pulled.  
*/
public with sharing class DataImportWorker {
	private static MetricsData metricsData = new MetricsData();
	private static Site_Metric_Settings__c settings {get; set;}
	
	/* Currently data can be imported only for one site */
	private static List<Site_Metric_Settings__c> sites = [Select s.Name From Site_Metric_Settings__c s];
	private static String siteName = sites[0].Name;

    public static GoogleAnalytics ga;
    
    private static List<String> regularMetrics = new list<String>();
    private static Date regularImportDate = Date.Today() - 2; //Data available after 2 days so pick up data for 2 days before. 
    private static Integer firstTimeDaysToBeImported = 30;
    
	public DataImportWorker() {
		System.debug('Beginning Google Analytics data import. Date being imported: ' + regularImportDate);
	}
	
	@future(callout=true)
	public static void importData() {
		System.debug('Starting Import. Date being imported: ' + regularImportDate);
		 try {
            settings = [Select s.Name, s.Table_Id__c, s.Password__c, s.Email__c,
                               s.Track_Visitors__c, s.Track_New_Visits__c, 
                               s.Track_Page_Views_Per_Visit__c, 
                               s.Track_Visit_Bounce_Rate__c, s.Average_Time_on_Site__c, 
                               s.Tracking_Visitors__c, s.Tracking_New_Visits__c, 
                               s.Tracking_Page_Views_Per_Visit__c, 
                               s.Tracking_Visit_Bounce_Rate__c, s.Tracking_Average_Time_on_Site__c
                          From Site_Metric_Settings__c s where s.Name = :siteName];
         } catch (QueryException ex) {
            System.debug('Error getting settings' + ex);
         }       
		
		 //Get data into local variables
 	 	 String name = settings.Name;
 	 	 Boolean trackVisitors = settings.Track_Visitors__c;
 	 	 Boolean trackNewVisits = settings.Track_New_Visits__c;
 	 	 Boolean trackPageViewsPerVisit = settings.Track_Page_Views_Per_Visit__c;
 	 	 Boolean trackAverageTimeOnSite = settings.Average_Time_on_Site__c;
 	 	 Boolean trackVisitBounceRate = settings.Track_Visit_Bounce_Rate__c;
 	 	 Boolean trackingVisitors = settings.Tracking_Visitors__c;
 	 	 Boolean trackingNewVisits = settings.Tracking_New_Visits__c;
 	 	 Boolean trackingPageViewsPerVisit = settings.Tracking_Page_Views_Per_Visit__c;
 	 	 Boolean trackingAverageTimeOnSite = settings.Tracking_Average_Time_on_Site__c;
 	 	 Boolean trackingVisitBounceRate = settings.Tracking_Visit_Bounce_Rate__c;
 	
 		 // Initialize & setup connection to Google Analytics
 	     ga = new GoogleAnalytics(settings); 	 
 	     
 	     //Manage Visitors Metric
 	     if (trackVisitors == true) {
 	     	if (trackingVisitors == false) {
 	     		//First time tracking so need to get 30 days worth of data
 	     		MetricsData md = ga.getMetrics(regularImportDate - firstTimeDaysToBeImported + 1, regularImportDate, 
 	     								new list<String>{GoogleAnalytics.VisitorsMetric});
 	     		
 	     		//Accumalate metrics data for later database save
 	     		metricsData.accumulateData(md);
 	     		
 	     		//Update site metric settings to indicate we have started tracking this metric
 	     		settings.Tracking_Visitors__c = true;
 	     	} else {
 	     		// We will just do a regular import of one day's data for this metric so just add this metric to the list. 
 	     		regularMetrics.add(GoogleAnalytics.VisitorsMetric);
 	     	}
 	     }
 	     
 	     //Manage New Visits % Metric
 	     if (trackNewVisits == true) {
 	     	if (trackingNewVisits == false) {
 	     		//First time tracking so need to get 30 days worth of data
 	     		MetricsData md = ga.getMetrics(regularImportDate - firstTimeDaysToBeImported, regularImportDate, 
 	     								new list<String>{GoogleAnalytics.PercentNewVisitsMetric});
 	     		
 	     		//Accumalate metrics data for later database save
 	     		metricsData.accumulateData(md);
 	     		
 	     		//Update site metric settings to indicate we have started tracking this metric
 	     		settings.Tracking_New_Visits__c = true;
 	     	} else {
 	     		// We will just do a regular import of one day's data for this metric so just add this metric to the list. 
 	     		regularMetrics.add(GoogleAnalytics.PercentNewVisitsMetric);
 	     	}
 	     }
 	     
 	     //Manage Page Views per Visit Metric
 	     if (trackPageViewsPerVisit == true) {
 	     	if (trackingPageViewsPerVisit == false) {
 	     		//First time tracking so need to get 30 days worth of data
 	     		MetricsData md = ga.getMetrics(regularImportDate - firstTimeDaysToBeImported, regularImportDate, 
 	     								new list<String>{GoogleAnalytics.PageViewsPerVisitMetric});
 	     		
 	     		//Accumalate metrics data for later database save
 	     		metricsData.accumulateData(md);
 	     		
 	     		//Update site metric settings to indicate we have started tracking this metric
 	     		settings.Tracking_Page_Views_Per_Visit__c = true;
 	     	} else {
 	     		// We will just do a regular import of one day's data for this metric so just add this metric to the list. 
 	     		regularMetrics.add(GoogleAnalytics.PageViewsPerVisitMetric);
 	     	}
 	     }
 	     
 	     //Manage Average Time on Site Metric
 	     if (trackAverageTimeOnSite == true) {
 	     	if (trackingAverageTimeOnSite == false) {
 	     		//First time tracking so need to get 30 days worth of data
 	     		MetricsData md = ga.getMetrics(regularImportDate - firstTimeDaysToBeImported, regularImportDate, 
 	     								new list<String>{GoogleAnalytics.AverageTimeOnSiteMetric});
 	     		
 	     		//Accumalate metrics data for later database save
 	     		metricsData.accumulateData(md);
 	     		
 	     		//Update site metric settings to indicate we have started tracking this metric
 	     		settings.Tracking_Average_Time_on_Site__c = true;
 	     	} else {
 	     		// We will just do a regular import of one day's data for this metric so just add this metric to the list. 
 	     		regularMetrics.add(GoogleAnalytics.AverageTimeOnSiteMetric);
 	     	}
 	     }
 	     
 	     //Manage Visit Bounce Rate Metric
 	     if (trackVisitBounceRate == true) {
 	     	if (trackingVisitBounceRate == false) {
 	     		//First time tracking so need to get 30 days worth of data
 	     		MetricsData md = ga.getMetrics(regularImportDate - firstTimeDaysToBeImported, regularImportDate, 
 	     								new list<String>{GoogleAnalytics.VisitBounceRateMetric});
 	     		
 	     		//Accumalate metrics data for later database save
 	     		metricsData.accumulateData(md);
 	     		
 	     		//Update site metric settings to indicate we have started tracking this metric
 	     		settings.Tracking_Visit_Bounce_Rate__c = true;
 	     	} else {
 	     		// We will just do a regular import of one day's data for this metric so just add this metric to the list. 
 	     		regularMetrics.add(GoogleAnalytics.VisitBounceRateMetric);
 	     	}
 	     }
 	     
 	     if (regularMetrics.size() > 0) {
 	     	System.debug('Importing single day data for: ' + regularMetrics + ', Date: ' + regularImportDate);
	 	     // Now that we have handled the individual exceptions to the regular daily import, let's get the regulars
	 	     MetricsData md = ga.getMetrics(regularImportDate, regularImportDate, regularMetrics);
 	     		
     		 //Accumalate metrics data for later database save
 	     	 metricsData.accumulateData(md);
		 }

		//Now save the metrics data to the database
		map<Date, Site_Metric_Date__c> metricDates = metricsData.metricDates;
	    map<Date, list<Site_Metric__c>> metricsMap = metricsData.metricsMap;
		
		System.debug('inserting ' + metricsMap);
		
		if (metricsMap != null) {	
			insert metricDates.values();

			list<Site_Metric__c> metricList = new list<Site_Metric__c>();
			
			for (Site_Metric_Date__c metricDate : metricDates.values()) {
				System.debug('assigning date ' + metricDate + ' to ' + metricsMap.get(metricDate.Start_Date__c));
				
				for (Site_Metric__c metric : metricsMap.get(metricDate.Start_Date__c)) {
					metric.Site_Metric_Date__c = metricDate.Id;
					metricList.add(metric);
				}
			}

			insert metricList;
		}

		//Update metrics tracking settings
 	    try {
 	    	update(settings);
 	    } catch (DMLException dmle) {
 	    	System.debug('Error updating settings' + dmle);
 	    }
	}
}