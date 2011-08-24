global with sharing class GoogleAnalyticsImporter implements Schedulable {
    global void execute(SchedulableContext SC) {
        System.debug('Starting Scheduled job @ ' + Date.today());
        DataImportWorker diw = new DataImportWorker();
        DataImportWorker.importData();
        System.debug('Finished Scheduled job @ ' + Date.today()); 
    }
}