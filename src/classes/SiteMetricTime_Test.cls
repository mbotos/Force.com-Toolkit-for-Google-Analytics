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
private class SiteMetricTime_Test {
	static Site_Metric_Date__c metricDate = new Site_Metric_Date__c(Name = 'Test Date', Start_Date__c = Date.today());
	static Site_Metric__c metric = new Site_Metric__c(Name = 'Time Test');
	
	static {
		insert metricDate;
		metric.Site_Metric_Date__c = metricDate.Id;
	}

    static testMethod void secondsOnly() {
        metric.Value__c = 1;
        insert metric;
        System.assertEquals('00:01', getTime());
    }
    
    static testMethod void minutesAndSeconds() {
        metric.Value__c = 62;
        insert metric;
        System.assertEquals('01:02', getTime());
    }
    
    static testMethod void exceedMax() {
        metric.Value__c = 6000;
        insert metric;
        System.assertEquals('99:99', getTime());
    }
    
    static string getTime() {
    	return [select Time__c from Site_Metric__c where Id = :metric.id].Time__c; 
    }
}