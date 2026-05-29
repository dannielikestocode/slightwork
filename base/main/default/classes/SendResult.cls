/**
 * Captures the send result of any instances of the Messaging namespace.
 * (E.g., Emails, Custom Notifications, etc.)
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */ 
@NamespaceAccessible
public inherited sharing class SendResult {
    public final Boolean isSuccess {get; private set;}

    public SendResult(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }
}