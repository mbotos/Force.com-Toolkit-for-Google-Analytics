public with sharing class UtilityClass {
	public static void deleteSiteMetricDates() {
		List<Site_Metric_Date__c> dates = [select name from Site_Metric_Date__c];
		delete dates;
	}
	public static void getOneSiteSetting() {
		List<Site_Metric_Settings__c> sites = [Select s.Name From Site_Metric_Settings__c s];
		String siteName = sites[0].Name;
		System.debug('Site Name: ' + siteName);
	}
}