/**
 * Handles managing the lifecycle of a Custom Notification, from
 * creation to sending.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/messaging/custom-notification-manager
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Messaging_CustomNotification.htm
 */
public inherited sharing class CustomNotificationManager {
    /**
     * Constants
     */
    private static final Integer MAX_TITLE_LENGTH = 250;
    private static final Integer MAX_BODY_LENGTH = 750;

    /**
     * Properties
     */
    private String notificationTypeId {get;set;}
    private String senderId {get;set;}
    private String title {get;set;}
    private String body {get;set;}
    private String targetRecordId {get;set;}
    private String targetPageReference {get;set;}
    private final Set<String> recipientIds {get;set;}
    
    /**
     * Constructor with notification type Id
     * 
     * @param notificationTypeId The Id of the notification type to send
     */
    public CustomNotificationManager(String notificationTypeId) {
        if (String.isBlank(notificationTypeId)) {
            throw new IllegalArgumentException('Notification Type Id cannot be blank');
        }
        this.recipientIds = new Set<String>();
    }
    
    /**
     * Sets the Custom Notification Type Id.
     * Required to send the notification.
     * 
     * @param notificationTypeId The Id of the Custom Notification Type
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if notificationTypeId is blank
     */
    public CustomNotificationManager withNotificationTypeId(String notificationTypeId) {
        if (String.isBlank(notificationTypeId)) {
            throw new IllegalArgumentException('Notification Type Id cannot be blank');
        }
        this.notificationTypeId = notificationTypeId;
        return this;
    }

    /**
     * Sets the Sender Id of the user sending the notification. 
     * This is an optional property.
     * 
     * @param senderId The user Id of the sender of the notification
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if senderId is blank
     */
    public CustomNotificationManager withSenderId(String senderId) {
        if (String.isBlank(senderId)) {
            throw new IllegalArgumentException('Sender Id cannot be blank');
        }
        this.senderId = senderId;
        return this;
    }
    
    /**
     * Sets the notification title. Max 250 characters.
     * Required to send the notification.
     * 
     * @param title The notification title (max 100 characters recommended)
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if title is blank
     */
    public CustomNotificationManager withTitle(String title) {
        if (String.isBlank(title)) {
            throw new IllegalArgumentException('Title cannot be blank');
        }

        if (body.length() > MAX_TITLE_LENGTH) {
            throw new IllegalArgumentException('Title length cannot exceed 750 characters');
        }
        this.title = title;
        return this;
    }
    
    /**
     * Sets the notification body text. Max 750 characters.
     * Required to send the notification.
     * 
     * @param body The notification body
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if body is blank
     */
    public CustomNotificationManager withBody(String body) {
        if (String.isBlank(body)) {
            throw new IllegalArgumentException('Body cannot be blank');
        }

        if (body.length() > MAX_BODY_LENGTH) {
            throw new IllegalArgumentException('Body length cannot exceed 750 characters');
        }
        this.body = body;
        return this;
    }
    
    /**
     * Sets the target record Id for the navigation target of the notification.
     * Required if "targetPageRef/targetPageReference" is not provided.
     * 
     * @param targetRecordId The targeted record Id for a navigation
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if targetRecordId is blank
     */
    public CustomNotificationManager withTargetRecordId(String targetRecordId) {
        if (String.isBlank(targetRecordId)) {
            throw new IllegalArgumentException('Target Record Id cannot be blank');
        }
        this.targetRecordId = targetRecordId;
        return this;
    }

    /**
     * Sets the PageReference for the navigation target of the notification.
     * Required if "targetId/targetRecordId" is not provided.
     * 
     * @param targetPageReference The Id of the Custom Notification Type
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if notificationTypeId is blank
     */
    public CustomNotificationManager withTargetPageReference(String targetPageReference) {
        if (String.isBlank(targetPageReference)) {
            throw new IllegalArgumentException('Target Page Reference cannot be blank');
        }
        this.targetPageReference = targetPageReference;
        return this;
    }
    
    /**
     * Adds a single recipient Id.
     * 
     * @param recipientId The recipient Id
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if recipientId is blank
     */
    public CustomNotificationManager addRecipient(String recipientId) {
        if (String.isBlank(recipientId)) {
            throw new IllegalArgumentException('Recipient Id cannot be blank');
        }
        this.recipientIds.add(recipientId);
        return this;
    }
    
    /**
     * Adds multiple recipient Ids from a set. At least one recipient
     * is required to send the notification.
     * 
     * @param recipientIds Set of Ids for all applicable recipient types
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if recipientIds is null or empty
     */
    public CustomNotificationManager addRecipients(Set<String> recipientIds) {
        if (recipientIds == null || recipientIds.isEmpty()) {
            throw new IllegalArgumentException('The set of Recipient Ids cannot be null or empty');
        }
        this.recipientIds.addAll(recipientIds);
        return this;
    }
    
    /**
     * Adds multiple recipient Ids from a list. At least one recipient
     * is required to send the notification.
     * 
     * @param recipientIds List of Ids for all applicable recipient types
     * @return Instance of this class for method chaining
     * @throws IllegalArgumentException if recipientIds is null or empty
     */
    public CustomNotificationManager addRecipients(List<String> recipientIds) {
        if (recipientIds == null || recipientIds.isEmpty()) {
            throw new IllegalArgumentException('The list of Recipient Ids cannot be null or empty');
        }
        this.recipientIds.addAll(recipientIds);
        return this;
    }
    
    /**
     * Builds and returns the configured CustomNotification instance.
     * 
     * @return A configured Messaging.CustomNotification instance
     */
    public Messaging.CustomNotification build() {
        validateState();

        // Set required properties
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(this.notificationTypeId);
        notification.setTitle(this.title);
        notification.setBody(this.body);
        if (String.isNotBlank(this.targetRecordId)) {
            notification.setTargetId(this.targetRecordId);
        }
        else if (String.isNotBlank(this.targetPageReference)) {
            notification.setTargetPageRef(this.targetPageReference);
        }
        
        // Set optional properties
        if (String.isNotBlank(this.senderId)) {
            notification.setSenderId(this.senderId);
        }
        return notification;
    }
    
    /**
     * Sends the notification to the specified recipients.
     * 
     * @return The result of sending the notification
     */
    public SendResult send() {
        Boolean isSuccess = false;
        try {
            Messaging.CustomNotification notification = build();
            notification.send(this.recipientIds);
            isSuccess = true;
        }
        catch (Exception e) {
            System.debug('Failed to send custom notification: ' + e.getMessage());
        }
        return new SendResult(isSuccess);
    }

    /**
     * Validates the logical state of notification properties
     * before the notification can be sent.
     */
    @TestVisible
    private void validateState() {
        if (String.isBlank(this.notificationTypeId)) {
            throw new IllegalStateException('Notification Type Id is required');
        }

        if (String.isBlank(this.title)) {
            throw new IllegalStateException('Title is required to send notification');
        }

        if (String.isBlank(this.body)) {
            throw new IllegalStateException('Body is required to send notification');
        }

        if (String.isBlank(this.targetRecordId) && String.isBlank(this.targetPageReference)) {
            throw new IllegalStateException('Target Record Id or Target Page Reference must be set');
        }
        else if (String.isNotBlank(this.targetRecordId) && String.isNotBlank(this.targetPageReference)) {
            throw new IllegalStateException('Either Target Record Id or Target Page Reference must be set, not both');
        }

        if (this.recipientIds.isEmpty()) {
            throw new IllegalStateException('At least 1 recipient is required to send a notification');
        }
    }
}