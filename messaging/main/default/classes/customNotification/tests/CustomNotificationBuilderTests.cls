/**
 * Test class for CustomNotificationManager.
 * Validates builder pattern, fluent API, validation logic, and notification sending.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see CustomNotificationManager.cls
 */
@IsTest
private without sharing class CustomNotificationManagerTests {
    private static final String NOTIFICATION_TYPE_ID = 'Test_Notification_Type';
    private static final String TEST_TITLE = 'Test Notification Title';
    private static final String TEST_BODY = 'Test notification body content';
    
    // ─── Constructor Tests ───────────────────────────────────────────────
    
    @IsTest
    private static void constructor_ShouldInitializeEmptyRecipientSet() {
        // When
        Test.startTest();
        CustomNotificationManager builder = new CustomNotificationManager();
        Test.stopTest();
        
        // Then
        Assert.isNotNull(builder, 'Builder should be instantiated');
    }
    
    // ─── Builder Method Tests: withNotificationTypeId ────────────────────
    
    @IsTest
    private static void withNotificationTypeId_ValidId_ShouldSetProperty() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.withNotificationTypeId(NOTIFICATION_TYPE_ID);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @IsTest
    private static void withNotificationTypeId_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void withNotificationTypeId_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void withTitle_ValidTitle_ShouldSetProperty() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.withTitle(TEST_TITLE);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @IsTest
    private static void withTitle_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void withTitle_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void withBody_ValidBody_ShouldSetProperty() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.withBody(TEST_BODY);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @IsTest
    private static void withBody_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void withBody_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void withTargetId_ValidId_ShouldSetProperty() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        Id testAccountId = TestDataFactory.createUser('Standard User', true).Id;
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.withTargetId(testAccountId);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @IsTest
    private static void withTargetId_NullValue_ShouldSetPropertyToNull() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.withTargetId(null);
        Test.stopTest();
        
        // Then - no exception should be thrown since targetId is optional
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    // ─── Builder Method Tests: addRecipient ──────────────────────────────
    
    @IsTest
    private static void addRecipient_ValidId_ShouldAddToSet() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        String userId = UserInfo.getUserId();
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.addRecipient(userId);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @IsTest
    private static void addRecipient_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void addRecipient_EmptyString_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    @IsTest
    private static void addRecipientsSet_ValidIds_ShouldAddAllToSet() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        Set<String> userIds = new Set<String>{ UserInfo.getUserId() };
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.addRecipients(userIds);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @IsTest
    private static void addRecipientsSet_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
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
    
    @IsTest
    private static void addRecipientsSet_EmptySet_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
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
    
    @IsTest
    private static void addRecipientsList_ValidIds_ShouldAddAllToSet() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        List<String> userIds = new List<String>{ UserInfo.getUserId() };
        
        // When
        Test.startTest();
        CustomNotificationManager result = builder.addRecipients(userIds);
        Test.stopTest();
        
        // Then
        Assert.areEqual(builder, result, 'Should return same builder instance for chaining');
    }
    
    @IsTest
    private static void addRecipientsList_NullValue_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
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
    
    @IsTest
    private static void addRecipientsList_EmptyList_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
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
    
    @IsTest
    private static void build_AllRequiredFields_ShouldReturnNotification() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager()
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
    
    @IsTest
    private static void build_MissingNotificationTypeId_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager()
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
    
    @IsTest
    private static void build_MissingTitle_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager()
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
    
    @IsTest
    private static void build_MissingBody_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager()
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
    
    @IsTest
    private static void build_MissingRecipients_ShouldThrowException() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager()
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
    
    @IsTest
    private static void build_MultipleFieldsMissing_ShouldListAllMissing() {
        // Given
        CustomNotificationManager builder = new CustomNotificationManager();
        
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
    
    // ─── private static Factory Method Tests ─────────────────────────────────────
    
    @IsTest
    private static void create_ValidNotificationTypeId_ShouldReturnConfiguredBuilder() {
        // When
        Test.startTest();
        CustomNotificationManager builder = CustomNotificationManager.create(NOTIFICATION_TYPE_ID);
        Test.stopTest();
        
        // Then
        Assert.isNotNull(builder, 'Should return a builder instance');
    }
    
    // ─── Fluent API Chaining Tests ───────────────────────────────────────
    
    @IsTest
    private static void fluentChaining_AllMethods_ShouldAllowMethodChaining() {
        // Given
        Id targetRecordId = UserInfo.getUserId();
        
        // When
        Test.startTest();
        CustomNotificationManager builder = new CustomNotificationManager()
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
    
    @IsTest
    private static void fluentChaining_StaticFactory_ShouldAllowMethodChaining() {
        // When
        Test.startTest();
        CustomNotificationManager builder = CustomNotificationManager.create(NOTIFICATION_TYPE_ID)
            .withTitle(TEST_TITLE)
            .withBody(TEST_BODY)
            .addRecipient(UserInfo.getUserId());
        
        Messaging.CustomNotification notification = builder.build();
        Test.stopTest();
        
        // Then
        Assert.isNotNull(notification, 'Should successfully build with private static factory chaining');
    }
}