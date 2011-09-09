@isTest
private class MetricsData_Test {
  static Date yesterdayDate = Date.TODAY() - 1;
  static Date todayDate = Date.TODAY();
  
  static Site_Metric_Date__c metricDateYesterday = new Site_Metric_Date__c(Name = 'Yesterday', Start_Date__c = yesterdayDate);
  static Site_Metric_Date__c metricDateToday = new Site_Metric_Date__c(Name = 'Today', Start_Date__c = todayDate);
  
  static testMethod void testEmptyMapsCreated() { 
  	MetricsData md = new MetricsData();
  	System.assert(md.metricDates.size() == 0);
  	System.assert(md.metricsMap.size() == 0);
  }
  
  static testMethod void testMetricDatesAccumulation() {
  	MetricsData mdMaster = new MetricsData();
  	MetricsData dataToBeAdded = new MetricsData();
  	
  	//Add one date record
  	dataToBeAdded.metricDates.put(yesterdayDate, metricDateYesterday);
  	mdMaster.accumulateData(dataToBeAdded);
  	System.assert(mdMaster.metricDates.size() == 1);

  	//Add one more date record with same date - size should not increase
  	mdMaster.accumulateData(dataToBeAdded);
  	System.assert(mdMaster.metricDates.size() == 1);

  	//Add one more date record with different date - size should increase by 1
  	dataToBeAdded = new MetricsData();
  	dataToBeAdded.metricDates.put(todayDate, metricDateToday);
  	mdMaster.accumulateData(dataToBeAdded);
  	System.assert(mdMaster.metricDates.size() == 2);

  }
  static testMethod void testMetricsAccumulation() {
  	MetricsData mdMaster = new MetricsData();
  	MetricsData dataToBeAdded = new MetricsData();
  	
  	Site_Metric__c siteMetricYesterdayVisitors = new Site_Metric__c(Name = 'Yesterday-visitors', 
  																	value__c = 4);
  	Site_Metric__c siteMetricTodayVisitors = new Site_Metric__c(Name = 'Today-visitors', 
  																	value__c = 2);
  	Site_Metric__c siteMetricYesterdayPageViews = new Site_Metric__c(Name = 'Yesterday-pageViews', 
  																	value__c = 10);
  	Site_Metric__c siteMetricTodayPageViews = new Site_Metric__c(Name = 'Today-pageViews', 
  																	value__c = 8);
  	
  	//Add one date record & one metric record for the same date
  	dataToBeAdded.metricDates.put(yesterdayDate, metricDateYesterday);
  	dataToBeAdded.metricsMap.put(yesterdayDate, new List<Site_Metric__c>{siteMetricYesterdayVisitors});
  	mdMaster.accumulateData(dataToBeAdded);
  	
  	//Assert only one record in metricsMap and only one record in the list for the single metricsMap Record
  	System.assert(mdMaster.metricsMap.size() == 1);
  	System.assert(mdMaster.metricsMap.get(yesterdayDate).size() == 1);

  	//Add another metric record for the same date
  	dataToBeAdded = new MetricsData();
  	dataToBeAdded.metricDates.put(yesterdayDate, metricDateYesterday);
  	dataToBeAdded.metricsMap.put(yesterdayDate, new List<Site_Metric__c>{siteMetricYesterdayPageViews});
  	mdMaster.accumulateData(dataToBeAdded);
  	
  	//Assert only one record in metricsMap and two records in the list for the single metricsMap Record
  	System.assert(mdMaster.metricsMap.size() == 1);
  	System.assert(mdMaster.metricsMap.get(yesterdayDate).size() == 2);

  	
  	//Add another date record & one metric record for the new date
  	dataToBeAdded = new MetricsData();
  	dataToBeAdded.metricDates.put(todayDate, metricDateToday);
  	dataToBeAdded.metricsMap.put(todayDate, new List<Site_Metric__c>{siteMetricTodayVisitors});
  	mdMaster.accumulateData(dataToBeAdded);
  	
  	//Assert two records in metricsMap and only one record in the list for the newly inserted metricsMap Record. 
  	//The old metricsMap record will have 2 records in the list as per before
  	System.assert(mdMaster.metricsMap.size() == 2);
  	System.assert(mdMaster.metricsMap.get(todayDate).size() == 1);
  	System.assert(mdMaster.metricsMap.get(yesterdayDate).size() == 2);

  	//Add another metric record for the same date
  	dataToBeAdded = new MetricsData();
  	dataToBeAdded.metricDates.put(todayDate, metricDateToday);
  	dataToBeAdded.metricsMap.put(todayDate, new List<Site_Metric__c>{siteMetricTodayPageViews});
  	mdMaster.accumulateData(dataToBeAdded);
  	
  	//Assert two records in metricsMap and two records in the list for the new metricsMap Record
  	//The old metricsMap record will have 2 records in the list as per before
  	System.assert(mdMaster.metricsMap.size() == 2);
  	System.assert(mdMaster.metricsMap.get(todayDate).size() == 2);
  	System.assert(mdMaster.metricsMap.get(yesterdayDate).size() == 2);
  }
}