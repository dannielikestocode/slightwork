/**
 * Test suite for the CustomNotificationManager class.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see CustomNotificationManager.cls
 */
@IsTest
private without sharing class CustomNotificationManagerTests {
    @TestSetup
    private static void setupTestData() {
        // Create test user for recipient testing
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'NotificationUser',
            Email = 'testnotificationuser@example.com',
            Username = 'testnotificationuser@slightwork.test.com',
            Alias = 'tnuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = standardProfile.Id
        );
        insert testUser;
    }

    @IsTest
    private static void testConstructorWithValidNotificationTypeId() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];

        // Execute
        Test.startTest();
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        Test.stopTest();

        // Assert
        Assert.isNotNull(manager, 'Manager should be instantiated');
    }

    @IsTest
    private static void testConstructorWithNullNotificationTypeId() {
        // Execute & Assert
        try {
            Test.startTest();
            CustomNotificationManager manager = new CustomNotificationManager(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Notification Type Id cannot be blank'), 
                'Exception message should indicate blank notification type Id');
        }
    }

    @IsTest
    private static void testConstructorWithBlankNotificationTypeId() {
        // Execute & Assert
        try {
            Test.startTest();
            CustomNotificationManager manager = new CustomNotificationManager('');
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Notification Type Id cannot be blank'), 
                'Exception message should indicate blank notification type Id');
        }
    }
    
    @IsTest
    private static void testWithNotificationTypeIdValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.withNotificationTypeId(notifType.Id);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testWithNotificationTypeIdNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute & Assert
        try {
            Test.startTest();
            manager.withNotificationTypeId(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Notification Type Id cannot be blank'), 
                'Exception message should indicate blank notification type Id');
        }
    }

    @IsTest
    private static void testWithSenderIdNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute & Assert
        try {
            Test.startTest();
            manager.withSenderId(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Sender Id cannot be blank'), 
                'Exception message should indicate blank sender Id');
        }
    }

    @IsTest
    private static void testWithTitleValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        String title = 'Test Notification Title';

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.withTitle(title);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testWithTitleNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute & Assert
        try {
            Test.startTest();
            manager.withTitle(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Title cannot be blank'), 
                'Exception message should indicate blank title');
        }
    }

    @IsTest
    private static void testWithTitleMaxLength() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        String title = 'A'.repeat(250);

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.withTitle(title);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should accept title at max length');
    }

    @IsTest
    private static void testWithBodyValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        String body = 'Test notification body content';

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.withBody(body);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testWithBodyNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute & Assert
        try {
            Test.startTest();
            manager.withBody(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Body cannot be blank'), 
                'Exception message should indicate blank body');
        }
    }

    @IsTest
    private static void testWithBodyMaxLength() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        String body = 'A'.repeat(750);

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.withBody(body);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should accept body at max length');
    }

    @IsTest
    private static void testWithBodyExceedsMaxLength() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        String body = 'A'.repeat(751);

        // Execute & Assert
        try {
            Test.startTest();
            manager.withBody(body);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Body length cannot exceed 750 characters'), 
                'Exception message should indicate body exceeds max length');
        }
    }

    @IsTest
    private static void testWithTargetRecordIdValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.withTargetRecordId(testUser.Id);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testWithTargetRecordIdNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute & Assert
        try {
            Test.startTest();
            manager.withTargetRecordId(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Target Record Id cannot be blank'), 
                'Exception message should indicate blank target record Id');
        }
    }

    @IsTest
    private static void testWithTargetPageReferenceValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        String pageRef = '{"type":"standard__objectPage"}';

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.withTargetPageReference(pageRef);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testWithTargetPageReferenceNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute & Assert
        try {
            Test.startTest();
            manager.withTargetPageReference(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Target Page Reference cannot be blank'), 
                'Exception message should indicate blank target page reference');
        }
    }

    @IsTest
    private static void testAddRecipientValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.addRecipient(testUser.Id);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testAddRecipientNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute & Assert
        try {
            Test.startTest();
            manager.addRecipient(null);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Recipient Id cannot be blank'), 
                'Exception message should indicate blank recipient Id');
        }
    }

    @IsTest
    private static void testAddRecipientMultipleTimes() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute
        Test.startTest();
        manager.addRecipient(testUser.Id).addRecipient(currentUser.Id);
        Test.stopTest();

        // Assert
        Assert.isNotNull(manager, 'Manager should still be valid after adding multiple recipients');
    }

    @IsTest
    private static void testAddRecipientsSetValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Set<String> recipientIds = new Set<String>{ testUser.Id, currentUser.Id };
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.addRecipients(recipientIds);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testAddRecipientsSetNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        Set<String> recipientIds = null;

        // Execute & Assert
        try {
            Test.startTest();
            manager.addRecipients(recipientIds);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('The set of Recipient Ids cannot be null or empty'), 
                'Exception message should indicate null/empty recipient set');
        }
    }

    @IsTest
    private static void testAddRecipientsSetEmpty() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        Set<String> recipientIds = new Set<String>();

        // Execute & Assert
        try {
            Test.startTest();
            manager.addRecipients(recipientIds);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('The set of Recipient Ids cannot be null or empty'), 
                'Exception message should indicate null/empty recipient set');
        }
    }

    @IsTest
    private static void testAddRecipientsListValid() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        List<String> recipientIds = new List<String>{ testUser.Id, currentUser.Id };
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);

        // Execute
        Test.startTest();
        CustomNotificationManager result = manager.addRecipients(recipientIds);
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'Should return instance for chaining');
        Assert.areEqual(manager, result, 'Should return same instance for method chaining');
    }

    @IsTest
    private static void testAddRecipientsListNull() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        List<String> recipientIds = null;

        // Execute & Assert
        try {
            Test.startTest();
            manager.addRecipients(recipientIds);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('The list of Recipient Ids cannot be null or empty'), 
                'Exception message should indicate null/empty recipient list');
        }
    }

    @IsTest
    private static void testAddRecipientsListEmpty() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        List<String> recipientIds = new List<String>();

        // Execute & Assert
        try {
            Test.startTest();
            manager.addRecipients(recipientIds);
            Test.stopTest();
            Assert.fail('Should have thrown IllegalArgumentException');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('The list of Recipient Ids cannot be null or empty'), 
                'Exception message should indicate null/empty recipient list');
        }
    }

    @IsTest
    private static void testBuildWithTargetRecordId() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        manager.withNotificationTypeId(notifType.Id)
               .withTitle('Test Title')
               .withBody('Test Body')
               .withTargetRecordId(testUser.Id)
               .addRecipient(testUser.Id);

        // Execute
        Test.startTest();
        Messaging.CustomNotification notification = manager.build();
        Test.stopTest();

        // Assert
        Assert.isNotNull(notification, 'Build should return a CustomNotification instance');
    }

    @IsTest
    private static void testBuildWithTargetPageReference() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        String pageRef = '{"type":"standard__objectPage"}';
        
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        manager.withNotificationTypeId(notifType.Id)
               .withTitle('Test Title')
               .withBody('Test Body')
               .withTargetPageReference(pageRef)
               .addRecipient(testUser.Id);

        // Execute
        Test.startTest();
        Messaging.CustomNotification notification = manager.build();
        Test.stopTest();

        // Assert
        Assert.isNotNull(notification, 'Build should return a CustomNotification instance');
    }

    @IsTest
    private static void testBuildWithSenderId() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        manager.withNotificationTypeId(notifType.Id)
               .withSenderId(currentUser.Id)
               .withTitle('Test Title')
               .withBody('Test Body')
               .withTargetRecordId(testUser.Id)
               .addRecipient(testUser.Id);

        // Execute
        Test.startTest();
        Messaging.CustomNotification notification = manager.build();
        Test.stopTest();

        // Assert
        Assert.isNotNull(notification, 'Build should return a CustomNotification instance with senderId');
    }

    @IsTest
    private static void testSendSuccess() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        manager.withNotificationTypeId(notifType.Id)
               .withTitle('Test Notification')
               .withBody('This is a test notification')
               .withTargetRecordId(testUser.Id)
               .addRecipient(testUser.Id);

        // Execute
        Test.startTest();
        SendResult result = manager.send();
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'SendResult should not be null');
        Assert.isTrue(result.isSuccess, 'Send should be successful');
    }

    @IsTest
    private static void testCompleteMethodChaining() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];

        // Execute
        Test.startTest();
        SendResult result = new CustomNotificationManager(notifType.Id)
            .withNotificationTypeId(notifType.Id)
            .withTitle('Chained Notification')
            .withBody('Testing complete method chaining')
            .withTargetRecordId(testUser.Id)
            .addRecipient(testUser.Id)
            .send();
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'SendResult should not be null');
        Assert.isTrue(result.isSuccess, 'Send should be successful with complete chaining');
    }

    @IsTest
    private static void testSendWithMultipleRecipients() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
        manager.withNotificationTypeId(notifType.Id)
               .withTitle('Multiple Recipients')
               .withBody('This goes to multiple users')
               .withTargetRecordId(testUser.Id)
               .addRecipient(testUser.Id)
               .addRecipient(currentUser.Id);

        // Execute
        Test.startTest();
        SendResult result = manager.send();
        Test.stopTest();

        // Assert
        Assert.isNotNull(result, 'SendResult should not be null');
        Assert.isTrue(result.isSuccess, 'Send should be successful with multiple recipients');
    }

    @IsTest
    private static void testValidateStateMissingNotificationTypeId() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        
        // Execute & Assert
        try {
            CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
            manager.withTitle('Test Title')
                   .withBody('Test Body')
                   .withTargetRecordId(testUser.Id)
                   .addRecipient(testUser.Id);
            
            // Set notificationTypeId to null via withNotificationTypeId would throw before build
            // So we test by not setting it after construction
            Test.startTest();
            Messaging.CustomNotification notification = manager.build();
            Test.stopTest();
            
            Assert.fail('Should have thrown IllegalStateException');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('Notification Type Id is required'), 
                'Exception message should indicate notification type Id is required');
        }
    }

    @IsTest
    private static void testValidateStateMissingTitle() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        
        // Execute & Assert
        try {
            CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
            manager.withNotificationTypeId(notifType.Id)
                   .withBody('Test Body')
                   .withTargetRecordId(testUser.Id)
                   .addRecipient(testUser.Id);
            
            Test.startTest();
            Messaging.CustomNotification notification = manager.build();
            Test.stopTest();
            
            Assert.fail('Should have thrown IllegalStateException');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('Title is required'), 
                'Exception message should indicate title is required');
        }
    }

    @IsTest
    private static void testValidateStateMissingBody() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        
        // Execute & Assert
        try {
            CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
            manager.withNotificationTypeId(notifType.Id)
                   .withTitle('Test Title')
                   .withTargetRecordId(testUser.Id)
                   .addRecipient(testUser.Id);
            
            Test.startTest();
            Messaging.CustomNotification notification = manager.build();
            Test.stopTest();
            
            Assert.fail('Should have thrown IllegalStateException');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('Body is required'), 
                'Exception message should indicate body is required');
        }
    }

    @IsTest
    private static void testValidateStateMissingTargetRecordIdAndPageReference() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        
        // Execute & Assert
        try {
            CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
            manager.withNotificationTypeId(notifType.Id)
                   .withTitle('Test Title')
                   .withBody('Test Body')
                   .addRecipient(testUser.Id);
            
            Test.startTest();
            Messaging.CustomNotification notification = manager.build();
            Test.stopTest();
            
            Assert.fail('Should have thrown IllegalStateException');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('Target Record Id or Target Page Reference must be set'), 
                'Exception message should indicate target is required');
        }
    }

    @IsTest
    private static void testValidateStateBothTargetRecordIdAndPageReference() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        String pageRef = '{"type":"standard__objectPage"}';
        
        // Execute & Assert
        try {
            CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
            manager.withNotificationTypeId(notifType.Id)
                   .withTitle('Test Title')
                   .withBody('Test Body')
                   .withTargetRecordId(testUser.Id)
                   .withTargetPageReference(pageRef)
                   .addRecipient(testUser.Id);
            
            Test.startTest();
            Messaging.CustomNotification notification = manager.build();
            Test.stopTest();
            
            Assert.fail('Should have thrown IllegalStateException');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('Either Target Record Id or Target Page Reference must be set, not both'), 
                'Exception message should indicate only one target should be set');
        }
    }

    @IsTest
    private static void testValidateStateNoRecipients() {
        // Setup
        CustomNotificationType notifType = [SELECT Id FROM CustomNotificationType LIMIT 1];
        User testUser = [SELECT Id FROM User WHERE Username = 'testnotificationuser@slightwork.test.com' LIMIT 1];
        
        // Execute & Assert
        try {
            CustomNotificationManager manager = new CustomNotificationManager(notifType.Id);
            manager.withNotificationTypeId(notifType.Id)
                   .withTitle('Test Title')
                   .withBody('Test Body')
                   .withTargetRecordId(testUser.Id);
            
            Test.startTest();
            Messaging.CustomNotification notification = manager.build();
            Test.stopTest();
            
            Assert.fail('Should have thrown IllegalStateException');
        } catch (IllegalStateException e) {
            Assert.isTrue(e.getMessage().contains('At least 1 recipient is required'), 
                'Exception message should indicate at least one recipient is required');
        }
    }
}
