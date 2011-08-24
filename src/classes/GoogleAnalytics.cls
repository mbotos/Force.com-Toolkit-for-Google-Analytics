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

public with sharing class GoogleAnalytics {
	public static final string LoginUrl = 'https://www.google.com/accounts/ClientLogin';
	public static final integer LagDays = 2;
	public static final integer MockTrendEntries = 2; // number of entries returned in trending mock data

	public static final string PageViewsPerVisitMetric = 'ga:pageviewsPerVisit';
	public static final string VisitorsMetric = 'ga:visitors';
	public static final string PercentNewVisitsMetric = 'ga:percentNewVisits';
	public static final string VisitBounceRateMetric = 'ga:visitBounceRate';
	public static final string AverageTimeOnSiteMetric = 'ga:avgTimeOnSite';

	public static final string DateDimension = 'ga:date';
	public static final string NthWeekDimension = 'ga:nthWeek';
	public static final string CustomVariableValue1Dimension = 'ga:customVarValue1';	
	public static final string CustomVariableValue2Dimension = 'ga:customVarValue2';	

	public static final String TotalEventsMetric = 'ga:totalEvents';
	public static final String EventCategoryDimension = 'ga:eventCategory';
	public static final String EventActionDimension = 'ga:eventAction';
	public static final String EventLabelDimension = 'ga:eventLabel';

	public static final string FilterAnd = ';';	
	public static final string FilterOr = ',';
	// these use non-standard URL encoding
	public static final string FilterNotEqual = '!%3D';	
	public static final string FilterEqual = '%3D%3D';
	public static final string FilterMatchRegex = '%3D~';
		
	public static final decimal TestValue = 1;
	public static final string NotSetValue = '(not%20set)';
	public static final string Missing = 'MISSING';
	
	// specifiy mock values for specific dimensions
	public static map<string, string> mockDimensionValue = new map<string, string>();
	
	static final map<string, string> metricName = new map<string, string>{
		VisitorsMetric => 'Visitors',
		PageViewsPerVisitMetric => 'Page Views Per Visit',
		PercentNewVisitsMetric => 'New Visit Percent',
		VisitBounceRateMetric => 'Bounce Rate',
		AverageTimeOnSiteMetric => 'Average Time on Site'
	};
	
	public class Entry {
		public map<string, string> dimensions { get; private set; }
		public map<string, string> metrics { get; private set;}
		
		public Entry() {
			this.dimensions = new map<string, string>();
			this.metrics = new map<string, string>();
		}
		
		public void setDimension(string name, string value) {
			dimensions.put(name, value);
		}
		
		public string getDimension(string name) {
			return dimensions.get(name);
		}
		
		public void setMetric(string name, string value) {
			metrics.put(name, value);
		}
		
		public string getMetric(string name) {
			return metrics.get(name);
		}
		
		public void invertMetric(string name, string inverseName) {
			setMetric(inverseName, string.ValueOf(100 - decimal.ValueOf(getMetric(name))));
		}
	}
	
	public string email { get; set; }
	public string password { get; set; }
	public string tableId { get; set; }
	
	private string token {
		get {
			if (token == null) {
				token = login(email, password);
			}
		
			return token;
		}
		set;
	}
	
	public GoogleAnalytics(Site_Metric_Settings__c settings) {
		initialize(settings.Email__c, settings.Password__c, settings.Table_Id__c);
	}
	
	public GoogleAnalytics(string email, string password, string tableId) {
		initialize(email, password, tableId);
	}
	
	private void initialize(string email, string password, string tableId) {
		this.email = email;
		this.password = password;
		this.tableId = tableId;
	}
	
	public static HttpRequest createLoginRequest(string email, string password) {
	    HttpRequest req = new HttpRequest();
	    req.setEndpoint(LoginUrl);
	    req.setMethod('POST');
	    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
	    req.setBody('accountType=GOOGLE&Email=' + EncodingUtil.urlEncode(email, 'UTF-8') + 
		    '&Passwd=' + EncodingUtil.urlEncode(password,  'UTF-8') + 
		    '&service=analytics&source=Sunovion-HCPPortal-0.1');
	    req.setHeader('Content-Length', String.valueOf(req.getBody().length()));
	    
	    return req;
	}

	list<Entry> createMockEntries(Date startDate, Date endDate, list<string> dimensions, list<string> metrics) {
		System.debug('createMockEntries for ' + startDate + ' ' + endDate + ' ' + dimensions + ' ' + metrics);
		Entry entry = createMockEntryWithTestValues(dimensions, metrics);
		list<Entry> entries = new list<Entry>{ entry };
		
		if (dimensions != null) {
			set<string> dimensionSet = new set<string>();
			dimensionSet.addAll(dimensions);
			
			if (dimensionSet.contains(CustomVariableValue1Dimension)) {
				Entry notSetEntry = createMockEntryWithTestValues(dimensions, metrics);
				notSetEntry.setDimension(CustomVariableValue1Dimension, NotSetValue);
				System.debug('adding notSetEntry for CustomVariableValue1Dimension');
				entries.add(notSetEntry);				
			}

			if (dimensionSet.contains(DateDimension)) {
				System.debug('Adding data for dates ' + startDate + ' to ' + endDate);
				for (Date d=startDate; d <= endDate; d = d.addDays(1)) {
					System.debug('adding additional trend/date entry for ' + d);
					entries.add(entry); // add entries for trend data	
				}	
			}
		}
		
		System.debug('Getting test entries ' + entries);
		
		return entries;		
	}
	
	Entry createMockEntryWithTestValues(list<string> dimensions, list<string> metrics) {
		Entry entry = new Entry();
		
		for (string metric : metrics) {
			entry.setMetric(metric, string.valueOf(TestValue));
		}
		
		if (dimensions != null) {
			for (string dimension : dimensions) {
				string value;
				if (dimension == DateDimension) {
					value = '20110101';
				} else if (mockDimensionValue.containsKey(dimension)) {
					value = mockDimensionValue.get(dimension);
				} else {
					value = string.valueOf(TestValue);
				}
				entry.setDimension(dimension, value);
			}
		}
		
		return entry;		
	}
	
	public static string formatDate(Date d) {
		Datetime dt = Datetime.newInstance(d, Time.newInstance(0,0,0,0));
		return dt.format('yyyy-MM-dd');
	}
	
	public static string getMetricName(string metric) {
		return metricName.get(metric);
	}

	public static String join(List<string> items, string delimiter) {
	    string s = '';
	    integer i = 0;
	
	    for (string item : items) {
	        if (i++ > 0) { 
	            s += delimiter; 
	        }
	        s += item;
	    }
	
	    return s;
	}
	
	public static Date lastAvailableDate() {
		return Date.today()-lagDays;
	}

	public static string login(string email, string password) {
		HttpRequest req = createLoginRequest(email, password);
	    Http h = new Http();	
	    HttpResponse res = h.send(req);
	    System.debug('Response: ' + res.getBody());	
	    return parseAuthToken(res.getBody());
	}
	
	public static list<Entry> parseEntries(string xml) {
	    System.debug('Response: ' + xml);	
		Dom.document doc = new Dom.Document();
		doc.load(xml);
		
		list<Entry> entries = new list<Entry>();
		
		for (Dom.Xmlnode entryNode : doc.getRootElement().getChildElements()) {
			//System.debug(entry);
			
			if (entryNode.getName() == 'entry') {
				Entry entry = new Entry();
				
				for (Dom.Xmlnode node : entryNode.getChildElements()) {
					string name = node.getAttributeValue('name','');
					string value = node.getAttributeValue('value','');
					
					//System.debug(node);
					//System.debug(name + ' = ' + value);

					if (node.getName() == 'dimension') {
						entry.setDimension(name, value);
					} else if (node.getName() == 'metric') {
						entry.setMetric(name, value);
					}
				}
				
				entries.add(entry);
				//System.debug('\n');
			}
		}
		
		return entries;
	}
	
	public static string parseAuthToken(string loginResponse) {
	    return loginResponse.split('\\n')[2]; // split so we get 'Auth=TOKEN'		
	}
	
	public static HttpRequest createRequest(string token, Date startDate, Date endDate, list<string> dimensions, list<string> metrics, string filter, string id, integer maxResults, integer startIndex) {
		if (dimensions == null) {
			dimensions = new list<string>();
		}
		if (filter == null) {
			filter = '';
		}
		System.debug('filter: ' + filter);
		
	    HttpRequest req = new HttpRequest();
	    string endpoint = 'https://www.google.com/analytics/feeds/data' +
		    '?start-date=' + GoogleAnalytics.formatDate(startDate) + 
		    '&end-date=' + GoogleAnalytics.formatDate(endDate) +
		    '&dimensions=' + join(dimensions, ',') + 
		    '&metrics=' + join(metrics, ',') + 
		    '&filters=' + filter +
		    '&prettyprint=true' +
		    '&ids=' + id;
	    if (maxResults != null) {
	    	endpoint += '&max-results=' + maxResults;
	    }
	    if (startIndex != null) {
	    	endpoint += '&start-index=' + startIndex;
	    }
	    req.setEndpoint(endpoint);
	    req.setMethod('GET');
	    req.setHeader('GData-Version', '2');
	    req.setHeader('Authorization', 'GoogleLogin ' + token);

	    System.debug('Request: ' + req.getEndpoint());
	    return req;
	}
	

	public Entry getEntry(Site_Metric_Date__c metricDate, list<string> metrics) {
		return getEntry(metricDate, metrics, null);
	}
	
	public Entry getEntry(Site_Metric_Date__c metricDate, list<string> metrics, string filter) {
		return getEntry(metricDate.Start_Date__c, metricDate.End_Date__c, null, metrics, filter);
	}
	
	public Entry getEntry(Date startDate, Date endDate, list<string> dimensions, list<string> metrics, string filter) {
		return getEntries(startDate, endDate, dimensions, metrics, filter)[0];
	}
	
	public list<Entry> getEntries(Date startDate, Date endDate, list<string> dimensions, list<string> metrics) {
	 	return getEntries(startDate, endDate, dimensions, metrics, null);
	}
	
	public list<Entry> getEntries(Site_Metric_Date__c metricDate, list<string> dimensions, list<string> metrics) {
	 	return getEntries(metricDate, dimensions, metrics, null);
	}
	
	public list<Entry> getEntries(Site_Metric_Date__c metricDate, list<string> dimensions, list<string> metrics, string filter) {
	 	return getEntries(metricDate.Start_Date__c, metricDate.End_Date__c, dimensions, metrics, filter);
	}
	
	public list<Entry> getEntries(Date startDate, Date endDate, list<string> dimensions, list<string> metrics, string filter) {
		return getEntries(startDate, endDate, dimensions, metrics, filter, null, null);
	}
	
	public list<Entry> getEntries(Date startDate, Date endDate, list<string> dimensions, list<string> metrics, string filter, integer maxResults, integer startIndex) {
		if (Test.isRunningTest()) {
			return createMockEntries(startDate, endDate, dimensions, metrics);
		} else {
			return parseEntries(send(createRequest(token, startDate, endDate, dimensions, metrics, filter, tableId, maxResults, startIndex)).getBody());
		}
	}
	
	public void insertDailyMetrics(Date startDate, Date endDate, list<string> metrics) {
		
		list<GoogleAnalytics.Entry> entries = getEntries(
				startDate, 
				endDate, 
				new list<string>{DateDimension}, 
				metrics
			);
			
		map<Date, Site_Metric_Date__c> metricDates = new map<Date, Site_Metric_Date__c>();
		map<Date, list<Site_Metric__c>> metricsMap = new map<Date, list<Site_Metric__c>>();
		
		for (GoogleAnalytics.Entry entry : entries) {
			Date metricDate = GoogleAnalytics.parseDate(entry.getDimension(DateDimension));
			metricDates.put(metricDate, new Site_Metric_Date__c(Start_Date__c = metricDate));
			
			if (!metricsMap.containsKey(metricDate)) {
				metricsMap.put(metricDate, new list<Site_Metric__c>());
			}
			
			for (string gaMetric : metrics) {
				Site_Metric__c metric = new Site_Metric__c(Name = gaMetric, Metric__c = gaMetric, Value__c = decimal.ValueOf(entry.getMetric(gaMetric)));				
				metricsMap.get(metricDate).add(metric);
			}
		}
		
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
	}

	/* This method returns metrics which will be accumulated in the client for insertion
	*/
	public MetricsData getMetrics(Date startDate, Date endDate, list<string> metrics) {
		MetricsData metricsData;
		list<GoogleAnalytics.Entry> entries = getEntries(
				startDate, 
				endDate, 
				new list<string>{DateDimension}, 
				metrics
			);
			
		map<Date, Site_Metric_Date__c> metricDates = new map<Date, Site_Metric_Date__c>();
		map<Date, list<Site_Metric__c>> metricsMap = new map<Date, list<Site_Metric__c>>();
		
		for (GoogleAnalytics.Entry entry : entries) {
			Date metricDate = GoogleAnalytics.parseDate(entry.getDimension(DateDimension));
			metricDates.put(metricDate, new Site_Metric_Date__c(Start_Date__c = metricDate));
			
			if (!metricsMap.containsKey(metricDate)) {
				metricsMap.put(metricDate, new list<Site_Metric__c>());
			}
			
			for (string gaMetric : metrics) {
				Site_Metric__c metric = new Site_Metric__c(Name = gaMetric, Metric__c = gaMetric, Value__c = decimal.ValueOf(entry.getMetric(gaMetric)));				
				metricsMap.get(metricDate).add(metric);
			}
		}

		if (metricsMap != null) {	
			metricsData = new MetricsData();
			metricsData.metricDates = metricDates;
			metricsData.metricsMap = metricsMap;
		}
		
		return (metricsData);
	}

	public static Date parseDate(string dt) {			
		if(dt != null && dt.length() == 8){
			return Date.newInstance(
										Integer.valueOf(dt.substring(0,4)), 
										Integer.valueOf(dt.substring(4,6)),
										Integer.valueOf(dt.substring(6,8))
									);
		} else {
			throw new GoogleAnalyticsException('Invalid date: ' + dt);
		}
	}
	
	
	public static HttpResponse send(HttpRequest req) {
	    Http h = new Http();	
	    HttpResponse response = h.send(req);
	    
	    if (response.getStatusCode() != 200) {
	    	throw new GoogleAnalyticsException('Request Error: ' + response.getBody());
	    }
	    
	    return response;
	}

	
	public class GoogleAnalyticsException extends Exception {}
}