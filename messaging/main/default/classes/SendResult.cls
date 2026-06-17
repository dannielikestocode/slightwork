/**
 * Captures the send result of any instances of the Messaging namespace.
 * (E.g., Emails, Custom Notifications, etc.)
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */ 
public inherited sharing class SendResult {
    /**
     * Properties
     */
    public final Boolean isSuccess {get; private set;}

    /**
     * Constructor with args
     * 
     * @param isSuccess Indicates if the send result was successful
     */
    public SendResult(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }
}