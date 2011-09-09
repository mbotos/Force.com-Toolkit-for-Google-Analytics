public with sharing class MetricsData {
	public map<Date, Site_Metric_Date__c> metricDates {get; set;}
	public map<Date, list<Site_Metric__c>> metricsMap {get; set;}
	
	public MetricsData() {
		metricDates = new map<Date, Site_Metric_Date__c>();
		metricsMap = new map<Date, list<Site_Metric__c>>();
	}
	
	public void accumulateData(MetricsData metricsData) {
		for (Date metricsDate : metricsData.metricDates.keySet()) {
			System.debug('Date in MetricsData.accumulateData - metricDates: ' + metricsDate);
			metricDates.put(metricsDate, metricsData.metricDates.get(metricsDate));
		}
		for (Date metricsDate : metricsData.metricsMap.keySet()) {
			System.debug('Date in MetricsData.accumulateData - metricsMap: ' + metricsDate);
			
			list<Site_Metric__c> allMetrics = metricsMap.get(metricsDate);
			list<Site_Metric__c> metricsToBeAdded = metricsData.metricsMap.get(metricsDate);
			
			if (allMetrics != null) {
				//Metrics exist so add to the metrics
				for (Site_Metric__c siteMetric : metricsToBeAdded) {
					allMetrics.add(siteMetric);
				}
				metricsMap.put(metricsDate, allMetrics);
			} else {
				//Adding metrics for the first time
				metricsMap.put(metricsDate, metricsToBeAdded);
			}
		}
	}
}