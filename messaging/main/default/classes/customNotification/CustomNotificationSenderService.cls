/**
 * TBD
 * 
 * @author Dannie @ Wynforce
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Messaging_CustomNotification.htm
 */
public inherited sharing class CustomNotificationSenderService {
    public Messaging.CustomNotification notification {private get; set;}
    public Set<String> recipientIds {private get;set;}
    
    public CustomNotificationSenderService(Messaging.CustomNotification notification, Set<String> recipientIds) {
        this.notification = notification;
        this.recipientIds = recipientIds;
    }

    public SendResult send() {
        Boolean isSuccess = false;
        try {
            this.notification.send(this.recipientIds);
            isSuccess = true;
        }
        catch (Exception e) {
            System.debug('Failed to send custom notification: ' + e.getMessage());
        }
        return new SendResult(isSuccess);
    }
}