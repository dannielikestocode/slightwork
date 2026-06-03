/**
 * Handles processing the Log Event type for published logs.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
trigger LogEventTrigger on Log_Event__e (after insert) {
    List<Log__c> logsToInsert = new List<Log__c>();

    for (Log_Event__e event : Trigger.new) {
        Log__c logRecord = new Log__c(
            Log_Level__c = event.Log_Level__c,
            Message__c = event.Message__c,
            User_Id__c = event.User_Id__c,
            Timezone_Id__c = event.Timezone_Id__c,
            Quiddity__c = event.Quiddity__c,
            Request_Id__c = event.Request_Id__c,
            Timestamp__c = event.Timestamp__c
        );
        logsToInsert.add(logRecord);
    }

    if (!logsToInsert.isEmpty()) {
        Database.insert(logsToInsert, true, AccessLevel.SYSTEM_MODE);
    }
}