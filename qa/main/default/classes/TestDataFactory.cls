/**
 * Centralized factory for creating test data with sensible defaults.
 * All methods accept a doInsert flag for flexibility.
 * Bulk methods create multiple records; single-record methods delegate to bulk.
 * 
 * @author Agentforce
 * @since v66.0
 */
@isTest
public class TestDataFactory {

    // ─── Users ────────────────────────────────────────────────────────────

    /**
     * Creates test users with the specified profile.
     * 
     * @param profileName The profile name (e.g., 'Standard User')
     * @param count The number of users to create
     * @param doInsert Whether to insert the records
     * @return List of created User records
     */
    public static List<User> createUsers(String profileName, Integer count, Boolean doInsert) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        List<User> users = new List<User>();
        
        for (Integer i = 0; i < count; i++) {
            String uniqueKey = String.valueOf(DateTime.now().getTime()) + i;
            users.add(new User(
                FirstName = 'Test',
                LastName = 'User ' + i,
                Email = 'testuser' + uniqueKey + '@example.com',
                Username = 'testuser' + uniqueKey + '@example.com.test',
                Alias = 'tuser' + Math.mod(i, 8),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id
            ));
        }
        
        if (doInsert) {
            insert users;
        }
        return users;
    }

    /**
     * Creates a single test user with the specified profile.
     * 
     * @param profileName The profile name (e.g., 'Standard User')
     * @param doInsert Whether to insert the record
     * @return The created User record
     */
    public static User createUser(String profileName, Boolean doInsert) {
        return createUsers(profileName, 1, doInsert)[0];
    }
}