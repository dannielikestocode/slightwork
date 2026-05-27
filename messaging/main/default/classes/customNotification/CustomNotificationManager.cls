/**
 * Handles managing the lifecycle of a Custom Notification, from
 * creation to sending.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/messaging.html#notification
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_Messaging_CustomNotification.htm
 */
public inherited sharing class CustomNotificationManager {
    /**
     * Core Properties
     */
    private String notificationTypeId {get; set;}
    private String title {get; set;}
    private String body {get; set;}
    private Id targetId {get; set;}
    private final Set<String> recipientIds {get; set;}
    
    /**
     * Default, no-arg constructor
     */
    public CustomNotificationManager() {
        this.recipientIds = new Set<String>();
    }
    
    /**
     * Sets the Custom Notification Type ID or Developer Name.
     * This is required to send the notification.
     * 
     * @param notificationTypeId The 18-character ID or Developer Name of the Custom Notification Type
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if notificationTypeId is blank
     * @example
     * builder.withNotificationTypeId('Custom_Notification_Type');
     */
    public CustomNotificationManager withNotificationTypeId(String notificationTypeId) {
        if (String.isBlank(notificationTypeId)) {
            throw new IllegalArgumentException('Notification Type ID cannot be blank');
        }
        this.notificationTypeId = notificationTypeId;
        return this;
    }
    
    /**
     * Sets the notification title.
     * This is required to send the notification.
     * 
     * @param title The notification title (max 100 characters recommended)
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if title is blank
     * @example
     * builder.withTitle('New Case Assigned');
     */
    public CustomNotificationManager withTitle(String title) {
        if (String.isBlank(title)) {
            throw new IllegalArgumentException('Title cannot be blank');
        }
        this.title = title;
        return this;
    }
    
    /**
     * Sets the notification body text.
     * This is required to send the notification.
     * 
     * @param body The notification body (max 255 characters recommended)
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if body is blank
     * @example
     * builder.withBody('Case #12345 has been assigned to you.');
     */
    public CustomNotificationManager withBody(String body) {
        if (String.isBlank(body)) {
            throw new IllegalArgumentException('Body cannot be blank');
        }
        this.body = body;
        return this;
    }
    
    /**
     * Sets the target record ID for navigation.
     * When users click the notification, they navigate to this record's page.
     * Optional - if not set, notification opens the notification list.
     * 
     * @param targetId The 18-character Salesforce record ID
     * @return This builder instance for method chaining
     * @example
     * builder.withTargetId(caseRecord.Id);
     */
    public CustomNotificationManager withTargetId(Id targetId) {
        this.targetId = targetId;
        return this;
    }
    
    /**
     * Adds a single recipient user ID.
     * At least one recipient is required to send the notification.
     * 
     * @param recipientId The 18-character User ID
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if recipientId is blank
     * @example
     * builder.addRecipient(UserInfo.getUserId());
     */
    public CustomNotificationManager addRecipient(String recipientId) {
        if (String.isBlank(recipientId)) {
            throw new IllegalArgumentException('Recipient ID cannot be blank');
        }
        this.recipientIds.add(recipientId);
        return this;
    }
    
    /**
     * Adds multiple recipient user IDs.
     * At least one recipient is required to send the notification.
     * 
     * @param recipientIds Set of 18-character User IDs
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if recipientIds is null or empty
     * @example
     * builder.addRecipients(new Set<String>{ userId1, userId2 });
     */
    public CustomNotificationManager addRecipients(Set<String> recipientIds) {
        if (recipientIds == null || recipientIds.isEmpty()) {
            throw new IllegalArgumentException('Recipient IDs cannot be null or empty');
        }
        this.recipientIds.addAll(recipientIds);
        return this;
    }
    
    /**
     * Adds multiple recipient user IDs from a list.
     * At least one recipient is required to send the notification.
     * 
     * @param recipientIds List of 18-character User IDs
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if recipientIds is null or empty
     * @example
     * builder.addRecipients(new List<String>{ userId1, userId2 });
     */
    public CustomNotificationManager addRecipients(List<String> recipientIds) {
        if (recipientIds == null || recipientIds.isEmpty()) {
            throw new IllegalArgumentException('Recipient IDs cannot be null or empty');
        }
        this.recipientIds.addAll(recipientIds);
        return this;
    }
    
    // ─── Build & Send Methods ────────────────────────────────────────────
    
    /**
     * Builds and returns the configured CustomNotification instance.
     * Does not send the notification - use send() for that.
     * 
     * @return A configured Messaging.CustomNotification instance
     * @throws IllegalStateException if required fields are missing
     * @example
     * Messaging.CustomNotification notification = builder.build();
     */
    public Messaging.CustomNotification build() {
        validateRequiredFields();
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setNotificationTypeId(this.notificationTypeId);
        notification.setTitle(this.title);
        notification.setBody(this.body);
        
        if (this.targetId != null) {
            notification.setTargetId(this.targetId);
        }
        
        return notification;
    }
    
    /**
     * Builds and immediately sends the notification to all configured recipients.
     * This is a convenience method that combines build() and send().
     * 
     * @throws IllegalStateException if required fields are missing
     * @throws DmlException if the notification send fails
     * @example
     * builder.withNotificationTypeId('Custom_Alert')
     *        .withTitle('Alert')
     *        .withBody('Action required')
     *        .addRecipient(UserInfo.getUserId())
     *        .send();
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
    
    // ─── Validation Methods ──────────────────────────────────────────────
    
    /**
     * Validates that all required fields are set before building/sending.
     * 
     * @throws IllegalStateException if any required field is missing
     */
    private void validateRequiredFields() {
        List<String> missingFields = new List<String>();
        
        if (String.isBlank(this.notificationTypeId)) {
            missingFields.add('notificationTypeId');
        }
        if (String.isBlank(this.title)) {
            missingFields.add('title');
        }
        if (String.isBlank(this.body)) {
            missingFields.add('body');
        }
        if (this.recipientIds.isEmpty()) {
            missingFields.add('recipientIds');
        }
        
        if (!missingFields.isEmpty()) {
            throw new IllegalStateException(
                'Cannot build notification. Missing required fields: ' + 
                String.join(missingFields, ', ')
            );
        }
    }
    
    // ─── Static Factory Methods ──────────────────────────────────────────
    
    /**
     * Creates a new builder instance with the notification type already set.
     * 
     * @param notificationTypeId The Custom Notification Type ID or Developer Name
     * @return A new CustomNotificationManager instance
     * @example
     * CustomNotificationManager builder = CustomNotificationManager.create('Custom_Alert');
     */
    public static CustomNotificationManager create(String notificationTypeId) {
        return new CustomNotificationManager().withNotificationTypeId(notificationTypeId);
    }
}