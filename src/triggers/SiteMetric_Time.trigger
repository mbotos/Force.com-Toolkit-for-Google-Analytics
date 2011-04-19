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

trigger SiteMetric_Time on Site_Metric__c (before insert, before update) {
	for (Site_Metric__c metric : Trigger.new) {
		if (metric.Name != null && metric.Name.contains('Time')) {
			if (metric.Value__c >= 6000) {
				metric.Time__c = '99:99';
			} else {
				string minutes = string.valueOf(Math.floor(metric.Value__c/60));
				string seconds = string.valueOf(Math.mod(Math.round(metric.Value__c), 60));
		
				if (minutes.length() < 2) { 
					minutes = '0' + minutes; 
				}
				if (seconds.length() < 2) { 
					seconds = '0' + seconds; 
				}
				
				metric.Time__c = minutes + ':' + seconds;
			}
			
			metric.Display_Value__c = metric.Value__c/60;
		}
	}
}