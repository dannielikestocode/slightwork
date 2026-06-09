/**
 * Test suite for the CustomNotificationSelector class.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see CustomNotificationSelector.cls
 */
@IsTest
private without sharing class CustomNotificationSelectorTests {
    
    @IsTest
    private static void testSelectByIdValid() {
        CustomNotificationType existingType = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        CustomNotificationType result = selector.selectById(existingType.Id);
        Test.stopTest();

        Assert.isNotNull(result, 'Should return a CustomNotificationType');
        Assert.areEqual(existingType.Id, result.Id, 'Should return the correct notification type');
    }

    @IsTest
    private static void testSelectByIdNull() {
        CustomNotificationSelector selector = new CustomNotificationSelector();

        try {
            Test.startTest();
            CustomNotificationType result = selector.selectById(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Record Id cannot be blank'), 
                'Exception message should indicate blank record Id');
        }
    }

    @IsTest
    private static void testSelectByIdNotFound() {
        CustomNotificationSelector selector = new CustomNotificationSelector();
        Id fakeId = '0ML000000000000AAA';

        try {
            Test.startTest();
            CustomNotificationType result = selector.selectById(fakeId);
            Test.stopTest();
            Assert.fail('Should have thrown QueryException');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('Custom Notification not found'), 
                'Exception message should indicate notification not found');
        }
    }

    @IsTest
    private static void testSelectByDeveloperNameValid() {
        CustomNotificationType existingType = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        CustomNotificationType result = selector.selectByDeveloperName(existingType.DeveloperName);
        Test.stopTest();

        Assert.isNotNull(result, 'Should return a CustomNotificationType');
        Assert.areEqual(existingType.Id, result.Id, 'Should return the correct notification type');
        Assert.areEqual(existingType.DeveloperName, result.DeveloperName, 'Developer name should match');
    }

    @IsTest
    private static void testSelectByDeveloperNameNotFound() {
        CustomNotificationSelector selector = new CustomNotificationSelector();
        String nonExistentName = 'NonExistent_Notification_Type_999';

        try {
            Test.startTest();
            CustomNotificationType result = selector.selectByDeveloperName(nonExistentName);
            Test.stopTest();
            Assert.fail('Should have thrown QueryException');
        } catch (QueryException e) {
            Assert.isTrue(e.getMessage().contains('Custom Notification not found'), 
                'Exception message should indicate notification not found');
        }
    }

    @IsTest
    private static void testSelectByDeveloperNameNull() {
        CustomNotificationSelector selector = new CustomNotificationSelector();

        try {
            Test.startTest();
            CustomNotificationType result = selector.selectByDeveloperName(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Developer Name cannot be blank'), 
                'Exception message should indicate blank developer name');
        }
    }

    @IsTest
    private static void testSelectByDeveloperNameEmpty() {
        CustomNotificationSelector selector = new CustomNotificationSelector();

        try {
            Test.startTest();
            CustomNotificationType result = selector.selectByDeveloperName('');
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Developer Name cannot be blank'), 
                'Exception message should indicate blank developer name');
        }
    }

    @IsTest
    private static void testSelectByDeveloperNameBlank() {
        CustomNotificationSelector selector = new CustomNotificationSelector();

        try {
            Test.startTest();
            CustomNotificationType result = selector.selectByDeveloperName('   ');
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Developer Name cannot be blank'), 
                'Exception message should indicate blank developer name');
        }
    }

    @IsTest
    private static void testSelectByDeveloperNameCaseSensitivity() {
        CustomNotificationType existingType = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        CustomNotificationSelector selector = new CustomNotificationSelector();
        
        String lowerCaseName = existingType.DeveloperName.toLowerCase();
        String upperCaseName = existingType.DeveloperName.toUpperCase();

        Test.startTest();
        CustomNotificationType lowerResult;
        CustomNotificationType upperResult;
        
        try {
            lowerResult = selector.selectByDeveloperName(lowerCaseName);
        } catch (QueryException e) {
            lowerResult = null;
        }
        
        try {
            upperResult = selector.selectByDeveloperName(upperCaseName);
        } catch (QueryException e) {
            upperResult = null;
        }
        Test.stopTest();

        Assert.isNotNull(lowerResult, 'Should handle lowercase developer name');
        Assert.isNotNull(upperResult, 'Should handle uppercase developer name');
    }

    @IsTest
    private static void testSelectByDeveloperNameReturnsExpectedFields() {
        CustomNotificationType existingType = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        CustomNotificationType result = selector.selectByDeveloperName(existingType.DeveloperName);
        Test.stopTest();

        Assert.isNotNull(result.Id, 'Id should be populated');
        Assert.isNotNull(result.DeveloperName, 'DeveloperName should be populated');
        Assert.isNotNull(result.MasterLabel, 'MasterLabel should be populated');
        Assert.isFalse(String.isBlank(result.DeveloperName), 'DeveloperName should not be blank');
    }

    @IsTest
    private static void testSelectByDeveloperNameQueryPerformance() {
        CustomNotificationType existingType = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        CustomNotificationType result = selector.selectByDeveloperName(existingType.DeveloperName);
        Integer queriesUsed = Limits.getQueries();
        Test.stopTest();

        Assert.isNotNull(result, 'Should return a result');
        Assert.areEqual(1, queriesUsed, 'Should use exactly one SOQL query');
    }

    @IsTest
    private static void testSelectAll() {
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        List<CustomNotificationType> results = selector.selectAll();
        Test.stopTest();

        Assert.isNotNull(results, 'Should return a list');
        Assert.isTrue(results.size() > 0, 'Should return at least one notification type');
        
        for (CustomNotificationType notifType : results) {
            Assert.isNotNull(notifType.Id, 'Each record should have an Id');
            Assert.isNotNull(notifType.DeveloperName, 'Each record should have a DeveloperName');
            Assert.isFalse(notifType.IsDeleted, 'All records should be non-deleted');
        }
    }

    @IsTest
    private static void testSelectAllOrdering() {
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        List<CustomNotificationType> results = selector.selectAll();
        Test.stopTest();

        if (results.size() > 1) {
            for (Integer i = 0; i < results.size() - 1; i++) {
                String currentName = results[i].DeveloperName;
                String nextName = results[i + 1].DeveloperName;
                Assert.isTrue(currentName <= nextName, 
                    'Results should be ordered by DeveloperName ascending');
            }
        }
    }

    @IsTest
    private static void testSelectAllQueryPerformance() {
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        List<CustomNotificationType> results = selector.selectAll();
        Integer queriesUsed = Limits.getQueries();
        Test.stopTest();

        Assert.isNotNull(results, 'Should return a list');
        Assert.areEqual(1, queriesUsed, 'Should use exactly one SOQL query');
    }

    @IsTest
    private static void testMultipleSelectCalls() {
        CustomNotificationType existingType = [SELECT Id, DeveloperName FROM CustomNotificationType LIMIT 1];
        CustomNotificationSelector selector = new CustomNotificationSelector();

        Test.startTest();
        CustomNotificationType result1 = selector.selectById(existingType.Id);
        CustomNotificationType result2 = selector.selectByDeveloperName(existingType.DeveloperName);
        List<CustomNotificationType> result3 = selector.selectAll();
        Test.stopTest();

        Assert.isNotNull(result1, 'selectById should return result');
        Assert.isNotNull(result2, 'selectByDeveloperName should return result');
        Assert.isNotNull(result3, 'selectAll should return results');
        Assert.areEqual(result1.Id, result2.Id, 'Both methods should return same record');
    }
}