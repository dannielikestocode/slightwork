/**
 * Test class for Logger.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see Logger.cls
 */
@IsTest
private without sharing class LoggerTests {
    
    @IsTest
    private static void testDefaultConstructor() {
        Test.startTest();
        Logger logger = new Logger();
        Test.stopTest();

        Assert.isNotNull(logger, 'Logger instance should not be null');
        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be empty after initialization');
    }

    @IsTest
    private static void testConstructorWithConfigName_ValidConfig() {
        Test.startTest();
        try {
            Logger logger = new Logger(Logger.DEFAULT_CONFIGURATION_NAME);
            Assert.isNotNull(logger, 'Logger instance should not be null');
        } catch (Exception ex) {
            // Expected if metadata record doesn't exist in test context
            Assert.isInstanceOfType(ex, QueryException.class, 'Should throw QueryException if config not found');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testConstructorWithConfigInstance() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();
        
        Test.startTest();
        Logger logger = new Logger(config);
        Test.stopTest();

        Assert.isNotNull(logger, 'Logger instance should not be null');
        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be empty after initialization');
    }

    @IsTest
    private static void testErrorLogging_PlatformEvent() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();
        Logger logger = new Logger(config);
        String testMessage = 'Test error message';

        Test.startTest();
        logger.error(testMessage);
        Test.stopTest();

        Assert.areEqual(1, logger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testWarnLogging() {
        Logger logger = new Logger();
        String testMessage = 'Test warning message';

        Test.startTest();
        logger.warn(testMessage);
        Test.stopTest();

        Assert.areEqual(1, logger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testInfoLogging() {
        Logger logger = new Logger();
        String testMessage = 'Test info message';

        Test.startTest();
        logger.info(testMessage);
        Test.stopTest();

        Assert.areEqual(0, logger.getQueueSize(), 'No log records should be in queue');
    }

    @IsTest
    private static void testDebugLogging() {
        Logger logger = new Logger();
        String testMessage = 'Test debug message';

        Test.startTest();
        logger.debug(testMessage);
        Test.stopTest();

        // Debug level might not log depending on default config (WARN)
        // With default WARN level, DEBUG won't log
        Assert.areEqual(0, logger.getQueueSize(), 'Debug should not log with default WARN level');
    }

    @IsTest
    private static void testFineLogging() {
        Logger logger = new Logger();
        String testMessage = 'Test fine message';

        Test.startTest();
        logger.fine(testMessage);
        Test.stopTest();

        Assert.areEqual(0, logger.getQueueSize(), 'Fine should not log with default WARN level');
    }

    @IsTest
    private static void testFinerLogging() {
        Logger logger = new Logger();
        String testMessage = 'Test finer message';

        Test.startTest();
        logger.finer(testMessage);
        Test.stopTest();

        Assert.areEqual(0, logger.getQueueSize(), 'Finer should not log with default WARN level');
    }

    @IsTest
    private static void testFinestLogging() {
        Logger logger = new Logger();
        String testMessage = 'Test finest message';

        Test.startTest();
        logger.finest(testMessage);
        Test.stopTest();

        Assert.areEqual(0, logger.getQueueSize(), 'Finest should not log with default WARN level');
    }

    @IsTest
    private static void testLogWithDefaultLevel() {
        Logger logger = new Logger();
        String testMessage = 'Test log message';

        Test.startTest();
        logger.log(testMessage);
        Test.stopTest();

        Assert.areEqual(1, logger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testLogWithSpecifiedLevel() {
        Logger logger = new Logger();
        String testMessage = 'Test log message with level';

        Test.startTest();
        logger.log(testMessage, LoggingLevel.ERROR);
        Test.stopTest();

        Assert.areEqual(1, logger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testLoggingNullObject() {
        Logger logger = new Logger();

        Test.startTest();
        logger.error(null);
        Test.stopTest();

        Assert.areEqual(1, logger.getQueueSize(), 'Null object should be logged as "null"');
    }

    @IsTest
    private static void testLoggingException() {
        Logger logger = new Logger();
        Exception testException = new DmlException('Test DML exception');

        Test.startTest();
        logger.error(testException);
        Test.stopTest();

        Assert.areEqual(1, logger.getQueueSize(), 'Exception should be logged');
    }

    @IsTest
    private static void testFlush_PublishesEvents() {
        Logger logger = new Logger();
        logger.error('Error message 1');
        logger.warn('Warning message 2');
        logger.error('Error message 3');

        Assert.areEqual(3, logger.getQueueSize(), 'Three messages should be queued');

        Test.startTest();
        List<Database.SaveResult> results = logger.flush();
        Test.stopTest();

        Assert.areEqual(3, results.size(), 'Should return 3 save results');
        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be empty after flush');
    }

    @IsTest
    private static void testFlush_EmptyQueue() {
        Logger logger = new Logger();

        Test.startTest();
        List<Database.SaveResult> results = logger.flush();
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'Should return empty list for empty queue');
        Assert.areEqual(0, logger.getQueueSize(), 'Queue should remain empty');
    }

    @IsTest
    private static void testGetQueueSize() {
        Logger logger = new Logger();

        Assert.areEqual(0, logger.getQueueSize(), 'Initial queue size should be 0');

        logger.error('Message 1');
        Assert.areEqual(1, logger.getQueueSize(), 'Queue size should be 1');

        logger.warn('Message 2');
        Assert.areEqual(2, logger.getQueueSize(), 'Queue size should be 2');

        logger.error('Message 3');
        Assert.areEqual(3, logger.getQueueSize(), 'Queue size should be 3');
    }

    @IsTest
    private static void testClearQueue() {
        Logger logger = new Logger();
        logger.error('Message 1');
        logger.warn('Message 2');

        Assert.areEqual(2, logger.getQueueSize(), 'Queue should have 2 messages');

        Test.startTest();
        logger.clearQueue();
        Test.stopTest();

        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be empty after clear');
    }

    @IsTest
    private static void testMultipleLogsAndFlush() {
        Logger logger = new Logger();

        Test.startTest();
        for (Integer i = 0; i < 10; i++) {
            logger.error('Error message ' + i);
        }
        Assert.areEqual(10, logger.getQueueSize(), 'Queue should have 10 messages');

        List<Database.SaveResult> results = logger.flush();
        Test.stopTest();

        Assert.areEqual(10, results.size(), 'Should publish 10 events');
        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be empty after flush');
    }

    @IsTest
    private static void testLoggerConfiguration_DefaultConstants() {
        // Verify the DEFAULT_LOG_LEVEL and DEFAULT_LOG_TARGET constants and that the default ctor uses them
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();

        // Access TestVisible constants via a new instance
        Assert.areEqual(LoggingLevel.WARN, config.DEFAULT_LOG_LEVEL, 'DEFAULT_LOG_LEVEL constant should be WARN');
        Assert.areEqual(Logger.LogTarget.ALL, config.DEFAULT_LOG_TARGET, 'DEFAULT_LOG_TARGET constant should be ALL');

        // Ensure current properties match the constants
        Assert.areEqual(config.DEFAULT_LOG_LEVEL, config.currentLogLevel, 'currentLogLevel should equal DEFAULT_LOG_LEVEL');
        Assert.areEqual(config.DEFAULT_LOG_TARGET, config.currentLogTarget, 'currentLogTarget should equal DEFAULT_LOG_TARGET');
    }

    @IsTest
    private static void testLoggerConfiguration_BlankConfigName() {
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            Logger.LoggerConfiguration config = new Logger.LoggerConfiguration('');
        } catch (IllegalArgumentException ex) {
            exceptionThrown = true;
            Assert.isTrue(ex.getMessage().contains('Config Name'), 'Exception should mention config name');
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'IllegalArgumentException should be thrown for blank config name');
    }

    @IsTest
    private static void testMapLogLevel_ValidLevels() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();

        Test.startTest();
        Assert.areEqual(LoggingLevel.NONE, config.mapLogLevel('NONE'), 'Should map NONE');
        Assert.areEqual(LoggingLevel.ERROR, config.mapLogLevel('ERROR'), 'Should map ERROR');
        Assert.areEqual(LoggingLevel.WARN, config.mapLogLevel('WARN'), 'Should map WARN');
        Assert.areEqual(LoggingLevel.INFO, config.mapLogLevel('INFO'), 'Should map INFO');
        Assert.areEqual(LoggingLevel.DEBUG, config.mapLogLevel('DEBUG'), 'Should map DEBUG');
        Assert.areEqual(LoggingLevel.FINE, config.mapLogLevel('FINE'), 'Should map FINE');
        Assert.areEqual(LoggingLevel.FINER, config.mapLogLevel('FINER'), 'Should map FINER');
        Assert.areEqual(LoggingLevel.FINEST, config.mapLogLevel('FINEST'), 'Should map FINEST');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogLevel_CaseInsensitive() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();

        Test.startTest();
        Assert.areEqual(LoggingLevel.ERROR, config.mapLogLevel('error'), 'Should handle lowercase');
        Assert.areEqual(LoggingLevel.WARN, config.mapLogLevel('WaRn'), 'Should handle mixed case');
        Assert.areEqual(LoggingLevel.INFO, config.mapLogLevel('INFO'), 'Should handle uppercase');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogLevel_InvalidLevel() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();

        Test.startTest();
        LoggingLevel result = config.mapLogLevel('INVALID_LEVEL');
        Test.stopTest();

        Assert.areEqual(LoggingLevel.WARN, result, 'Invalid level should return default WARN');
    }

    @IsTest
    private static void testMapLogLevel_BlankThrowsException() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            config.mapLogLevel('');
        } catch (IllegalArgumentException ex) {
            exceptionThrown = true;
            Assert.isTrue(ex.getMessage().contains('Log Level'), 'Exception should mention log level');
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'IllegalArgumentException should be thrown for blank log level');
    }

    @IsTest
    private static void testMapLogTarget_ValidTargets() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();

        Test.startTest();
        Assert.areEqual(Logger.LogTarget.ALL, config.mapLogTarget('ALL'), 'Should map ALL');
        Assert.areEqual(Logger.LogTarget.PLATFORM_EVENT, config.mapLogTarget('PLATFORM_EVENT'), 'Should map PLATFORM_EVENT');
        Assert.areEqual(Logger.LogTarget.SYSTEM_DEBUG, config.mapLogTarget('SYSTEM_DEBUG'), 'Should map SYSTEM_DEBUG');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogTarget_CaseInsensitive() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();

        Test.startTest();
        Assert.areEqual(Logger.LogTarget.ALL, config.mapLogTarget('all'), 'Should handle lowercase');
        Assert.areEqual(Logger.LogTarget.PLATFORM_EVENT, config.mapLogTarget('platform_event'), 'Should handle lowercase');
        Assert.areEqual(Logger.LogTarget.SYSTEM_DEBUG, config.mapLogTarget('SyStEm_DeBuG'), 'Should handle mixed case');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogTarget_InvalidTarget() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();

        Test.startTest();
        Logger.LogTarget result = config.mapLogTarget('INVALID_TARGET');
        Test.stopTest();

        Assert.areEqual(Logger.LogTarget.ALL, result, 'Invalid target should return default ALL');
    }

    @IsTest
    private static void testMapLogTarget_BlankThrowsException() {
        Logger.LoggerConfiguration config = new Logger.LoggerConfiguration();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            config.mapLogTarget('');
        } catch (IllegalArgumentException ex) {
            exceptionThrown = true;
            Assert.isTrue(ex.getMessage().contains('Log Target'), 'Exception should mention log target');
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'IllegalArgumentException should be thrown for blank log target');
    }

    @IsTest
    private static void testLogRecord_Creation() {
        String testLevel = 'ERROR';
        String testMessage = 'Test error message';

        Test.startTest();
        Logger.LogRecord record = new Logger.LogRecord(testLevel, testMessage);
        Test.stopTest();

        Assert.areEqual(testLevel, record.level, 'Level should match');
        Assert.areEqual(testMessage, record.message, 'Message should match');
        Assert.isNotNull(record.timestamp, 'Timestamp should be set');
        Assert.isNotNull(record.userId, 'User ID should be set');
        Assert.isNotNull(record.timezoneId, 'Timezone ID should be set');
        Assert.isNotNull(record.requestId, 'Request ID should be set');
    }

    @IsTest
    private static void testShouldLog_NoneLevel() {
        Logger logger = new Logger();

        Test.startTest();
        // NONE level should never log
        logger.log('Test', LoggingLevel.NONE);
        Test.stopTest();

        Assert.areEqual(0, logger.getQueueSize(), 'NONE level should not create log records');
    }

    @IsTest
    private static void testLogging_DifferentObjectTypes() {
        Logger logger = new Logger();

        Test.startTest();
        logger.error('String message');
        logger.error(123);
        logger.error(true);
        logger.error(new List<String>{'item1', 'item2'});
        logger.error(new Map<String, String>{'key' => 'value'});
        Test.stopTest();

        Assert.areEqual(5, logger.getQueueSize(), 'All object types should be logged');
    }

    @IsTest
    private static void testExceptionFormatting() {
        Logger logger = new Logger();
        
        try {
            // Generate a real exception with stack trace
            Integer result = 1 / 0;
        } catch (Exception ex) {
            Test.startTest();
            logger.error(ex);
            Test.stopTest();

            Assert.areEqual(1, logger.getQueueSize(), 'Exception should be logged');
        }
    }

    @IsTest
    private static void testFlush_SuccessfulPublish() {
        Logger logger = new Logger();
        logger.error('Test message');

        Test.startTest();
        List<Database.SaveResult> results = logger.flush();
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one result');
        for (Database.SaveResult result : results) {
            Assert.isTrue(result.isSuccess(), 'Publish should be successful in test context');
        }
    }

    @IsTest
    private static void testCompleteLoggingWorkflow() {
        Logger logger = new Logger();

        Test.startTest();
        // Log various messages
        logger.error('Critical error occurred');
        logger.warn('Warning: Resource limit approaching');
        logger.info('Process completed successfully');
        
        // Check queue
        Integer queueSize = logger.getQueueSize();
        Assert.areEqual(2, queueSize, 'Should have 2 messages queued');
        
        // Flush logs
        List<Database.SaveResult> results = logger.flush();
        
        // Verify flush
        Assert.areEqual(2, results.size(), 'Should publish 2 events');
        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be empty');
        
        // Log again after flush
        logger.error('New error after flush');
        Assert.areEqual(1, logger.getQueueSize(), 'Should have 1 new message');
        Test.stopTest();
    }

    @IsTest
    private static void testBulkLogging() {
        Logger logger = new Logger();

        Test.startTest();
        for (Integer i = 0; i < 100; i++) {
            logger.error('Bulk message ' + i);
        }
        
        Assert.areEqual(100, logger.getQueueSize(), 'Should queue 100 messages');
        
        List<Database.SaveResult> results = logger.flush();
        Test.stopTest();

        Assert.areEqual(100, results.size(), 'Should publish 100 events');
        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be empty after bulk flush');
    }

    @IsTest
    private static void testClearQueue_WithoutFlush() {
        Logger logger = new Logger();
        logger.error('Message 1');
        logger.warn('Message 2');
        logger.error('Message 3');

        Assert.areEqual(3, logger.getQueueSize(), 'Should have 3 messages');

        Test.startTest();
        logger.clearQueue();
        Test.stopTest();

        Assert.areEqual(0, logger.getQueueSize(), 'Queue should be cleared');
        
        // Verify we can still log after clearing
        logger.error('New message after clear');
        Assert.areEqual(1, logger.getQueueSize(), 'Should be able to log after clear');
    }
}