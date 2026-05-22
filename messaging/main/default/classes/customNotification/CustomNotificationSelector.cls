/**
 * Selector class for querying CustomNotificationType records.
 * Provides methods to retrieve custom notification type metadata with all available fields.
 * 
 * CustomNotificationType is a standard Salesforce object that defines notification types
 * used with the Messaging.CustomNotification API.
 * 
 * @author Agentforce
 * @since v66.0
 * @see Messaging.CustomNotification
 */
public without sharing class CustomNotificationSelector {
    /**
     * Queries a single CustomNotificationType by its record Id.
     * Returns all available fields for the notification type.
     * 
     * @param notificationTypeId The 18-character CustomNotificationType record Id
     * @return The CustomNotificationType record, or null if not found
     * @throws QueryException if the query fails
     * @example
     * CustomNotificationSelector selector = new CustomNotificationSelector();
     * CustomNotificationType notifType = selector.selectById('0MLxx000000000x');
     */
    public CustomNotificationType selectById(Id notificationTypeId) {
        if (String.isBlank(notificationTypeId)) {
            throw new IllegalArgumentException('Notification Type Id cannot be blank');
        }
        
        List<CustomNotificationType> results = [
            SELECT Id, DeveloperName, MasterLabel, CustomNotifTypeName, Description, 
                   Desktop, Mobile, NamespacePrefix, IsDeleted, CreatedDate, 
                   CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp
            FROM CustomNotificationType
            WHERE Id = :notificationTypeId
            LIMIT 1
        ];
        
        if (results.isEmpty()) {
            throw new QueryException('Custom Notification not found for Id: ' + notificationTypeId);
        }
        return results[0];
    }
    
    /**
     * Queries a single CustomNotificationType by its DeveloperName.
     * Returns all available fields for the notification type.
     * 
     * @param developerName The API name/developer name of the notification type
     * @return The CustomNotificationType record, or null if not found
     * @throws QueryException if the query fails
     * @example
     * CustomNotificationSelector selector = new CustomNotificationSelector();
     * CustomNotificationType notifType = selector.selectByDeveloperName('Custom_Alert');
     */
    public CustomNotificationType selectByDeveloperName(String developerName) {
        if (String.isBlank(developerName)) {
            throw new IllegalArgumentException('Notification Type Developer Name cannot be blank');
        }
        
        List<CustomNotificationType> results = [
            SELECT Id, DeveloperName, MasterLabel, CustomNotifTypeName, Description, 
                   Desktop, Mobile, NamespacePrefix, IsDeleted, CreatedDate, 
                   CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp
            FROM CustomNotificationType
            WHERE DeveloperName = :developerName
            LIMIT 1
        ];
        
        if (results.isEmpty()) {
            throw new QueryException('Custom Notification not found for Developer Name: ' + developerName);
        }
        return results[0];
    }
    
    /**
     * Queries all active (non-deleted) CustomNotificationType records.
     * Returns all available fields for each notification type.
     * Use with caution in orgs with many notification types.
     * 
     * @return List of all active CustomNotificationType records
     * @throws QueryException if the query fails
     * @example
     * CustomNotificationSelector selector = new CustomNotificationSelector();
     * List<CustomNotificationType> allTypes = selector.selectAll();
     */
    public List<CustomNotificationType> selectAll() {
        return [
            SELECT Id, DeveloperName, MasterLabel, CustomNotifTypeName, Description, 
                   Desktop, Mobile, NamespacePrefix, IsDeleted, CreatedDate, 
                   CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp
            FROM CustomNotificationType
            WHERE IsDeleted = false
            ORDER BY DeveloperName
        ];
    }
}
