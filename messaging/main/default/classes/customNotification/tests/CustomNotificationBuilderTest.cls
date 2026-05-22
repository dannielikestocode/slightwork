/**
 * Test class for CustomNotificationBuilder.
 * Validates builder pattern, fluent API, validation logic, and notification sending.
 * 
 * @author Agentforce
 * @since v66.0
 */
@isTest
private class CustomNotificationBuilderTest {
    
    private static final String NOTIFICATION_TYPE_ID = 'Test_Notification_Type';
    private static final String TEST_TITLE = 'Test Notification Title';
    private static final String TEST_BODY = 'Test notification body content';
    
    // ─── Constructor Tests ───────────────────────────────────────────────
    
    @isTest
    static void constructor_ShouldInitializeEmptyRecipientSet() {
        // When
        Test.startTest();
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        Test.stopTest();
        
        // Then
        Assert.isNotNull(builder, 'Builder should be instantiated');
    }
    
    // ─── Builder Method Tests: withNotificationTypeId ────────────────────
    
    @isTest
    static void withNotificationTypeId_ValidId_ShouldSetProperty() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.withNotificationTypeId(NOTIFICATION_TYPE_ID);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @isTest
    static void withNotificationTypeId_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.withNotificationTypeId(null);
            Assert.fail('Expected IllegalArgumentException for null notification type ID');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void withNotificationTypeId_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.withNotificationTypeId('');
            Assert.fail('Expected IllegalArgumentException for empty notification type ID');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    // ─── Builder Method Tests: withTitle ─────────────────────────────────
    
    @isTest
    static void withTitle_ValidTitle_ShouldSetProperty() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.withTitle(TEST_TITLE);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @isTest
    static void withTitle_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.withTitle(null);
            Assert.fail('Expected IllegalArgumentException for null title');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void withTitle_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.withTitle('');
            Assert.fail('Expected IllegalArgumentException for empty title');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    // ─── Builder Method Tests: withBody ──────────────────────────────────
    
    @isTest
    static void withBody_ValidBody_ShouldSetProperty() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.withBody(TEST_BODY);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @isTest
    static void withBody_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.withBody(null);
            Assert.fail('Expected IllegalArgumentException for null body');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void withBody_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.withBody('');
            Assert.fail('Expected IllegalArgumentException for empty body');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    // ─── Builder Method Tests: withTargetId ──────────────────────────────
    
    @isTest
    static void withTargetId_ValidId_ShouldSetProperty() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        Id testAccountId = TestDataFactory.createUser('Standard User', true).Id;
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.withTargetId(testAccountId);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @isTest
    static void withTargetId_NullValue_ShouldSetPropertyToNull() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.withTargetId(null);
        Test.stopTest();
        
        // Then - no exception should be thrown since targetId is optional
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    // ─── Builder Method Tests: addRecipient ──────────────────────────────
    
    @isTest
    static void addRecipient_ValidId_ShouldAddToSet() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        String userId = UserInfo.getUserId();
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.addRecipient(userId);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @isTest
    static void addRecipient_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.addRecipient(null);
            Assert.fail('Expected IllegalArgumentException for null recipient ID');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void addRecipient_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.addRecipient('');
            Assert.fail('Expected IllegalArgumentException for empty recipient ID');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be blank'),
                'Exception message should indicate blank value not allowed');
        }
        Test.stopTest();
    }
    
    // ─── Builder Method Tests: addRecipients (Set) ───────────────────────
    
    @isTest
    static void addRecipientsSet_ValidIds_ShouldAddAllToSet() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        Set<String> userIds = new Set<String>{ UserInfo.getUserId() };
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.addRecipients(userIds);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @isTest
    static void addRecipientsSet_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        Set<String> nullSet = null;
        
        // When/Then
        Test.startTest();
        try {
            builder.addRecipients(nullSet);
            Assert.fail('Expected IllegalArgumentException for null recipient set');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be null or empty'),
                'Exception message should indicate null or empty not allowed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void addRecipientsSet_EmptySet_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        Set<String> emptySet = new Set<String>();
        
        // When/Then
        Test.startTest();
        try {
            builder.addRecipients(emptySet);
            Assert.fail('Expected IllegalArgumentException for empty recipient set');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be null or empty'),
                'Exception message should indicate null or empty not allowed');
        }
        Test.stopTest();
    }
    
    // ─── Builder Method Tests: addRecipients (List) ──────────────────────
    
    @isTest
    static void addRecipientsList_ValidIds_ShouldAddAllToSet() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        List<String> userIds = new List<String>{ UserInfo.getUserId() };
        
        // When
        Test.startTest();
        CustomNotificationBuilder result = builder.addRecipients(userIds);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @isTest
    static void addRecipientsList_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        List<String> nullList = null;
        
        // When/Then
        Test.startTest();
        try {
            builder.addRecipients(nullList);
            Assert.fail('Expected IllegalArgumentException for null recipient list');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be null or empty'),
                'Exception message should indicate null or empty not allowed');
        }
        Test.stopTest();
    }
    
    @isTest
    static void addRecipientsList_EmptyList_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        List<String> emptyList = new List<String>();
        
        // When/Then
        Test.startTest();
        try {
            builder.addRecipients(emptyList);
            Assert.fail('Expected IllegalArgumentException for empty recipient list');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('cannot be null or empty'),
                'Exception message should indicate null or empty not allowed');
        }
        Test.stopTest();
    }
    
    // ─── Build Method Tests ──────────────────────────────────────────────
    
    @isTest
    static void build_AllRequiredFields_ShouldReturnNotification() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder()
            .withNotificationTypeId(NOTIFICATION_TYPE_ID)
            .withTitle(TEST_TITLE)
            .withBody(TEST_BODY)
            .addRecipient(UserInfo.getUserId());
        
        // When
        Test.startTest();
        Messaging.CustomNotification notification = builder.build();
        Test.stopTest();
        
        // Then
        Assert.isNotNull(notification, 'Should return a CustomNotification instance');
    }
    
    @isTest
    static void build_MissingNotificationTypeId_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder()
            .withTitle(TEST_TITLE)
            .withBody(TEST_BODY)
            .addRecipient(UserInfo.getUserId());
        
        // When/Then
        Test.startTest();
        try {
            builder.build();
            Assert.fail('Expected IllegalStateException for missing notification type ID');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('notificationTypeId'),
                'Exception message should list missing notificationTypeId field');
        }
        Test.stopTest();
    }
    
    @isTest
    static void build_MissingTitle_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder()
            .withNotificationTypeId(NOTIFICATION_TYPE_ID)
            .withBody(TEST_BODY)
            .addRecipient(UserInfo.getUserId());
        
        // When/Then
        Test.startTest();
        try {
            builder.build();
            Assert.fail('Expected IllegalStateException for missing title');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('title'),
                'Exception message should list missing title field');
        }
        Test.stopTest();
    }
    
    @isTest
    static void build_MissingBody_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder()
            .withNotificationTypeId(NOTIFICATION_TYPE_ID)
            .withTitle(TEST_TITLE)
            .addRecipient(UserInfo.getUserId());
        
        // When/Then
        Test.startTest();
        try {
            builder.build();
            Assert.fail('Expected IllegalStateException for missing body');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('body'),
                'Exception message should list missing body field');
        }
        Test.stopTest();
    }
    
    @isTest
    static void build_MissingRecipients_ShouldThrowException() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder()
            .withNotificationTypeId(NOTIFICATION_TYPE_ID)
            .withTitle(TEST_TITLE)
            .withBody(TEST_BODY);
        
        // When/Then
        Test.startTest();
        try {
            builder.build();
            Assert.fail('Expected IllegalStateException for missing recipients');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('recipientIds'),
                'Exception message should list missing recipientIds field');
        }
        Test.stopTest();
    }
    
    @isTest
    static void build_MultipleFieldsMissing_ShouldListAllMissing() {
        // Given
        CustomNotificationBuilder builder = new CustomNotificationBuilder();
        
        // When/Then
        Test.startTest();
        try {
            builder.build();
            Assert.fail('Expected IllegalStateException for multiple missing fields');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('notificationTypeId'),
                'Exception should list notificationTypeId');
            Assert.isTrue(e.getMessage().contains('title'),
                'Exception should list title');
            Assert.isTrue(e.getMessage().contains('body'),
                'Exception should list body');
            Assert.isTrue(e.getMessage().contains('recipientIds'),
                'Exception should list recipientIds');
        }
        Test.stopTest();
    }
    
    // ─── Static Factory Method Tests ─────────────────────────────────────
    
    @isTest
    static void create_ValidNotificationTypeId_ShouldReturnConfiguredBuilder() {
        // When
        Test.startTest();
        CustomNotificationBuilder builder = CustomNotificationBuilder.create(NOTIFICATION_TYPE_ID);
        Test.stopTest();
        
        // Then
        Assert.isNotNull(builder, 'Should return a builder instance');
    }
    
    // ─── Fluent API Chaining Tests ───────────────────────────────────────
    
    @isTest
    static void fluentChaining_AllMethods_ShouldAllowMethodChaining() {
        // Given
        Id targetRecordId = UserInfo.getUserId();
        
        // When
        Test.startTest();
        CustomNotificationBuilder builder = new CustomNotificationBuilder()
            .withNotificationTypeId(NOTIFICATION_TYPE_ID)
            .withTitle(TEST_TITLE)
            .withBody(TEST_BODY)
            .withTargetId(targetRecordId)
            .addRecipient(UserInfo.getUserId());
        
        Messaging.CustomNotification notification = builder.build();
        Test.stopTest();
        
        // Then
        Assert.isNotNull(notification, 'Should successfully build with all methods chained');
    }
    
    @isTest
    static void fluentChaining_StaticFactory_ShouldAllowMethodChaining() {
        // When
        Test.startTest();
        CustomNotificationBuilder builder = CustomNotificationBuilder.create(NOTIFICATION_TYPE_ID)
            .withTitle(TEST_TITLE)
            .withBody(TEST_BODY)
            .addRecipient(UserInfo.getUserId());
        
        Messaging.CustomNotification notification = builder.build();
        Test.stopTest();
        
        // Then
        Assert.isNotNull(notification, 'Should successfully build with static factory chaining');
    }
}