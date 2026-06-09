/**
 * Selector class for querying CustomNotificationType records.
 * 
 * CustomNotificationType is a standard Salesforce object that defines notification types
 * used with the Messaging.CustomNotification API.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see CustomNotificationManager.cls
 */
public inherited sharing class CustomNotificationSelector {
    /**
     * Queries a single CustomNotificationType by its record Id.
     * Returns all available fields for the notification type.
     * 
     * @param recordId The record Id of the CustomNotificationType
     * @return The CustomNotificationType record
     * @throws IllegalArgumentException if the provided record Id is invalid
     * @throws QueryException if the query does not return any results
     */
    public CustomNotificationType selectById(Id recordId) {
        if (String.isBlank(recordId)) {
            throw new IllegalArgumentException('Record Id cannot be blank');
        }
        
        List<CustomNotificationType> results = [
            SELECT Id, DeveloperName, MasterLabel, CustomNotifTypeName, Description, 
                   Desktop, Mobile, NamespacePrefix, IsDeleted, CreatedDate, 
                   CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp
            FROM CustomNotificationType
            WHERE Id = :recordId
            WITH USER_MODE
        ];
        
        if (results.isEmpty()) {
            throw new QueryException('Custom Notification not found for record Id: ' + recordId);
        }
        return results[0];
    }
    
    /**
     * Queries a single CustomNotificationType by its DeveloperName.
     * Returns all available fields for the notification type.
     * 
     * @param developerName The API name/developer name of the notification type
     * @return The CustomNotificationType record
     * @throws IllegalArgumentException if the provided developer name is invalid
     * @throws QueryException if the query does not return any results
     */
    public CustomNotificationType selectByDeveloperName(String developerName) {
        if (String.isBlank(developerName)) {
            throw new IllegalArgumentException('Developer Name cannot be blank');
        }
        
        List<CustomNotificationType> results = [
            SELECT Id, DeveloperName, MasterLabel, CustomNotifTypeName, Description, 
                   Desktop, Mobile, NamespacePrefix, IsDeleted, CreatedDate, 
                   CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp
            FROM CustomNotificationType
            WHERE DeveloperName = :developerName
            WITH USER_MODE
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
     */
    public List<CustomNotificationType> selectAll() {
        return [
            SELECT Id, DeveloperName, MasterLabel, CustomNotifTypeName, Description, 
                   Desktop, Mobile, NamespacePrefix, IsDeleted, CreatedDate, 
                   CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp
            FROM CustomNotificationType
            WHERE IsDeleted = false
            WITH USER_MODE
            ORDER BY DeveloperName
        ];
    }
}
