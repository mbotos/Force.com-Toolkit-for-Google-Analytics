@isTest
private class GoogleAnalyticsImporter_Test {
	static testMethod void testShceduledJob()
   {
       Test.startTest();
       GoogleAnalyticsImporter gai = new GoogleAnalyticsImporter();
        Datetime dt = Datetime.now().addMinutes(1);
        String sch = '0 '+dt.minute()+' * '+dt.day()+' '+dt.month()+' '+' ? '+dt.year();
        
       System.schedule('Schedule', sch, gai);
       test.stoptest();
   }
}