/**
 * TBD
 * 
 * @author Dannie @ Wynforce
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Messaging_CustomNotification.htm
 */
public without sharing class CustomNotificationSenderService implements Sendable {
    public CustomNotification notification {private get; set;}
    public Set<Id> recipientIds {private get;set;}
    
    public CustomNotificationSenderService(CustomNotification notification, Set<Id> recipientsIds) {
        this.notification = notification;
        this.recipientIds = recipientsIds;
    }

    public SendResult send() {
        Boolean isSuccess = false;
        try {
            this.notification.send(this.recipientsIds);
            isSuccess = true;
        }
        catch (Exception e) {
            System.debug('Failed to send custom notification: ' + e.getMessage());
        }
        return new SendResult(isSuccess);
    }
}