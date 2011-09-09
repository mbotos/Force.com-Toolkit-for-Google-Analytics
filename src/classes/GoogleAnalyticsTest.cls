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
private class GoogleAnalyticsTest {
	static Site_Metric_Settings__c settings;
	static GoogleAnalytics ga;
	
	static {
		settings = new Site_Metric_Settings__c(Email__c = 'test@test.com', Password__c = 'password', Table_Id__c = 'ga:123456');
		ga = new GoogleAnalytics(settings);	
	}
	
	static testMethod void constructorInitializesPropertiesWithSettings() {
		System.assertEquals(settings.Email__c, ga.email);
		System.assertEquals(settings.Password__c, ga.password);
		System.assertEquals(settings.Table_Id__c, ga.tableId);
	}
	
	static testMethod void getEntryReturnsTestData() {
		Site_Metric_Date__c metricDate = new Site_Metric_Date__c();
		string metric = GoogleAnalytics.VisitorsMetric;
		list<string> metrics = new list<string>{metric};
		
		// these cascade through remaining methods
		assertEntryHasTestData(ga.getEntry(metricDate, metrics), metric);
		assertEntryHasTestData(ga.getEntries(metricDate, new list<string>{GoogleAnalytics.NthWeekDimension}, metrics)[0], metric);
	}
	
	static void assertEntryHasTestData(GoogleAnalytics.Entry entry, string metric) {
		System.assertEquals('1', entry.getMetric(metric));		
	}
	
	static testMethod void loginRequestHasCorrectEndpoint() {
		System.assertEquals(GoogleAnalytics.LoginUrl, GoogleAnalytics.createLoginRequest('user','password').getEndpoint());
	}
	
	static testMethod void parseAuthToken() {
		string authToken = 'Auth=DQAAAIAAAAC1ikjaInXJYXCTND1zxdkz__RSYAp4Ld4H-yAGou6b8QZ7fi4rzgebTZ-f5KqmL7uSb3ihGQhv3Ettedi_MIRg-piRfbVIWraidqUAm0IhiinSy5b31E88if58jCv-yTiHT1onByjEFPVq7KxU7KX-QTeZ8X57KTKhzJkzEXw90Q';
		string loginResponse = 'SID=DQAAAH8AAAC9K-4yEMQfEkXQQcB0wpZ_H8XEMsWoDdTN82Fb92tWE2eQ71N0KPJA3tC-XFryuvgiGDqyVEA4-kAngTCHfpD2rbZ8jZC8u_N5vecgznyGUyGGhVZJDkG-tyZ-AeGjn0qnbwsr6MwjFsSppwBCpMjcw9rtE-YrjtmlYrrFiWndtA\n' +
			'LSID=DQAAAIIAAAC1ikjaInXJYXCTND1zxdkz__RSYAp4Ld4H-yAGou6b8QZ7fi4rzgebTZ-f5KqmL7s2KYNOqC9mG3AzcSAdVNkDkg6Nry2i4lO69iIgDLya8tLdvBluIfjsEXEVczWSjo6cda3Xib5P2y1WuyVsSC92OrajGqTe9sGR7_w8DtCTICcNhgrjjXzYXdiJatzfCz0\n' +
			authToken;
		System.assertEquals(authToken, GoogleAnalytics.parseAuthToken(loginResponse));
	}
	
	static testMethod void createRequest() {
		Date startDate = Date.today();
		Date endDate = Date.today().addDays(1);
		list<string> dimensions = new list<string>{'ga:pageTitle','ga:pagePath','ga:customVarValue2'};
		list<string> metrics = new list<string>{'ga:pageviews'};
		
		HttpRequest req = GoogleAnalytics.createRequest('token', startDate, endDate, dimensions, metrics, '-ga:pageviews', 'ga:123456', null, null);

		System.assert(req.getEndpoint().contains('start-date=' + GoogleAnalytics.formatDate(startDate)));
		System.assert(req.getEndpoint().contains('end-date=' + GoogleAnalytics.formatDate(endDate)));
		System.assert(req.getEndpoint().contains('dimensions=' + GoogleAnalytics.join(dimensions, ',')));
		System.assert(req.getEndpoint().contains('metrics=' + GoogleAnalytics.join(metrics, ',')));
	}

    static testMethod void parseEntries() {
     	string entriesXml = '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:dxp="http://schemas.google.com/analytics/2009" xmlns:openSearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:gd="http://schemas.google.com/g/2005" gd:etag="W/&quot;CEANSHcycSp7I2A9Wx9VEUo.&quot;" gd:kind="analytics#data"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;dimensions=ga:pagePath,ga:pageTitle&amp;metrics=ga:pageviews&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-27T15:59:59.999-08:00</updated><title>Google Analytics Data for Profile 41510670</title><link rel="self" type="application/atom+xml" href="https://www.google.com/analytics/feeds/data?max-results=10&amp;sort=-ga%3Apageviews&amp;end-date=2011-01-27&amp;start-date=2011-01-01&amp;metrics=ga%3Apageviews&amp;ids=ga%3A41510670&amp;dimensions=ga%3ApageTitle%2Cga%3ApagePath"/><author><name>Google Analytics</name></author><generator version="1.0">Google Analytics</generator><openSearch:totalResults>10</openSearch:totalResults><openSearch:startIndex>1</openSearch:startIndex><openSearch:itemsPerPage>10</openSearch:itemsPerPage><dxp:aggregates><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="16"/></dxp:aggregates><dxp:containsSampledData>false</dxp:containsSampledData><dxp:dataSource><dxp:property name="ga:profileId" value="41510670"/><dxp:property name="ga:webPropertyId" value="UA-20974577-1"/><dxp:property name="ga:accountName" value="Sunovion Tracking Sandbox"/><dxp:tableId>ga:41510670</dxp:tableId><dxp:tableName>sunovion.tracking.cs1.force.com/</dxp:tableName></dxp:dataSource><dxp:endDate>2011-01-27</dxp:endDate><dxp:startDate>2011-01-01</dxp:startDate><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpHome&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Home&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Home &#124; ga:pagePath=/hcpHome</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Home"/><dxp:dimension name="ga:pagePath" value="/hcpHome"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="6"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Home&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Home &#124; ga:pagePath=/</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Home"/><dxp:dimension name="ga:pagePath" value="/"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="2"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpMedicalRequest&amp;ga:pageTitle=Sunovion%20ProFile&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile &#124; ga:pagePath=/hcpMedicalRequest</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile"/><dxp:dimension name="ga:pagePath" value="/hcpMedicalRequest"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpDosing&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Dosing%20Information&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Dosing Information &#124; ga:pagePath=/hcpDosing</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Dosing Information"/><dxp:dimension name="ga:pagePath" value="/hcpDosing"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/apex/hcphome&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Home&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Home &#124; ga:pagePath=/apex/hcphome</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Home"/><dxp:dimension name="ga:pagePath" value="/apex/hcphome"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpMedicalRequest&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Medical%20Inquiry&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Medical Inquiry &#124; ga:pagePath=/hcpMedicalRequest</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Medical Inquiry"/><dxp:dimension name="ga:pagePath" value="/hcpMedicalRequest"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpPatientGuides&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Medication%20Guides&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Medication Guides &#124; ga:pagePath=/hcpPatientGuides</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Medication Guides"/><dxp:dimension name="ga:pagePath" value="/hcpPatientGuides"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpPI&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Prescribing%20Information&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Prescribing Information &#124; ga:pagePath=/hcpPI</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Prescribing Information"/><dxp:dimension name="ga:pagePath" value="/hcpPI"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpRequestSamples&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Request%20Samples&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Request Samples &#124; ga:pagePath=/hcpRequestSamples</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Request Samples"/><dxp:dimension name="ga:pagePath" value="/hcpRequestSamples"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry><entry gd:etag="W/&quot;DEMEQX47eSp7I2A9Wx9VEEU.&quot;" gd:kind="analytics#datarow"><id>http://www.google.com/analytics/feeds/data?ids=ga:41510670&amp;ga:pagePath=/hcpRequestSamples?voucher%3D1&amp;ga:pageTitle=Sunovion%20ProFile%20-%20Request%20Savings&amp;start-date=2011-01-01&amp;end-date=2011-01-27</id><updated>2011-01-26T16:00:00.001-08:00</updated><title>ga:pageTitle=Sunovion ProFile - Request Savings &#124; ga:pagePath=/hcpRequestSamples?voucher=1</title><link rel="alternate" type="text/html" href="http://www.google.com/analytics"/><dxp:dimension name="ga:pageTitle" value="Sunovion ProFile - Request Savings"/><dxp:dimension name="ga:pagePath" value="/hcpRequestSamples?voucher=1"/><dxp:metric confidenceInterval="0.0" name="ga:pageviews" type="integer" value="1"/></entry></feed>';
        list<GoogleAnalytics.Entry> entries = GoogleAnalytics.parseEntries(entriesXml);
        System.assert(entries.size() > 0);
        System.assertEquals('/hcpHome', entries[0].getDimension('ga:pagePath'));
        System.assertEquals('6', entries[0].getMetric('ga:pageviews'));
    }    
    
    static testMethod void testParseDate() {
		Date dt = GoogleAnalytics.parseDate('20110824');
		System.assertEquals(2011, dt.year());    	
		System.assertEquals(8, dt.month());    	
		System.assertEquals(24, dt.day());    	
    }
    
    static testMethod void testGetMetrics() {
    	List<String> metrics = new List<String>();
    	metrics.add('ga:Visitors');
    	MetricsData md = ga.getMetrics(Date.today() - 100, Date.today()-99, metrics);
    }

    static testMethod void insertDailyMetrics() {
    	List<String> metrics = new List<String>();
    	metrics.add('ga:Visitors');
    	ga.insertDailyMetrics(Date.today() - 100, Date.today()-99, metrics);
    }
}