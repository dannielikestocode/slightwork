/**
 * Test class for Logger.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see Logger.cls
 * @see LogEventTrigger.trigger
 */
@IsTest
private without sharing class LoggerTests {

    @IsTest
    private static void testDefaultConstructor() {
        Test.startTest();
        Logger testLogger = new Logger();
        Test.stopTest();

        Assert.isNotNull(testLogger, 'Logger instance should not be null');
        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty after initialization');
    }

    @IsTest
    private static void testConstructorWithConfigInstance() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        
        Test.startTest();
        Logger testLogger = new Logger(config);
        Test.stopTest();

        Assert.isNotNull(testLogger, 'Logger instance should not be null');
        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty after initialization');
    }

    @IsTest
    private static void testErrorLogging_PlatformEvent() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);
        String testMessage = 'Test error message';

        Test.startTest();
        testLogger.error(testMessage);
        Test.stopTest();

        Assert.areEqual(1, testLogger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testWarnLogging() {
        Logger testLogger = new Logger();
        String testMessage = 'Test warning message';

        Test.startTest();
        testLogger.warn(testMessage);
        Test.stopTest();

        Assert.areEqual(1, testLogger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testInfoLogging() {
        Logger testLogger = new Logger();
        String testMessage = 'Test info message';

        Test.startTest();
        testLogger.info(testMessage);
        Test.stopTest();

        Assert.areEqual(0, testLogger.getQueueSize(), 'No log records should be in queue');
    }

    @IsTest
    private static void testDebugLogging() {
        Logger testLogger = new Logger();
        String testMessage = 'Test debug message';

        Test.startTest();
        testLogger.debug(testMessage);
        Test.stopTest();

        // Debug level might not log depending on default config (WARN)
        // With default WARN level, DEBUG won't log
        Assert.areEqual(0, testLogger.getQueueSize(), 'Debug should not log with default WARN level');
    }

    @IsTest
    private static void testFineLogging() {
        Logger testLogger = new Logger();
        String testMessage = 'Test fine message';

        Test.startTest();
        testLogger.fine(testMessage);
        Test.stopTest();

        Assert.areEqual(0, testLogger.getQueueSize(), 'Fine should not log with default WARN level');
    }

    @IsTest
    private static void testFinerLogging() {
        Logger testLogger = new Logger();
        String testMessage = 'Test finer message';

        Test.startTest();
        testLogger.finer(testMessage);
        Test.stopTest();

        Assert.areEqual(0, testLogger.getQueueSize(), 'Finer should not log with default WARN level');
    }

    @IsTest
    private static void testFinestLogging() {
        Logger testLogger = new Logger();
        String testMessage = 'Test finest message';

        Test.startTest();
        testLogger.finest(testMessage);
        Test.stopTest();

        Assert.areEqual(0, testLogger.getQueueSize(), 'Finest should not log with default WARN level');
    }

    @IsTest
    private static void testLogWithDefaultLevel() {
        Logger testLogger = new Logger();
        String testMessage = 'Test log message';

        Test.startTest();
        testLogger.log(testMessage);
        Test.stopTest();

        Assert.areEqual(1, testLogger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testLogWithSpecifiedLevel() {
        Logger testLogger = new Logger();
        String testMessage = 'Test log message with level';

        Test.startTest();
        testLogger.log(testMessage, LoggingLevel.ERROR);
        Test.stopTest();

        Assert.areEqual(1, testLogger.getQueueSize(), 'One log record should be in queue');
    }

    @IsTest
    private static void testLoggingNullObject() {
        Logger testLogger = new Logger();

        Test.startTest();
        testLogger.error(null);
        Test.stopTest();

        Assert.areEqual(1, testLogger.getQueueSize(), 'Null object should be logged as "null"');
    }

    @IsTest
    private static void testLoggingException() {
        Logger testLogger = new Logger();
        Exception testException = new DmlException('Test DML exception');

        Test.startTest();
        testLogger.error(testException);
        Test.stopTest();

        Assert.areEqual(1, testLogger.getQueueSize(), 'Exception should be logged');
    }

    @IsTest
    private static void testFlush_PublishesEvents() {
        Logger testLogger = new Logger();
        testLogger.error('Error message 1');
        testLogger.warn('Warning message 2');
        testLogger.error('Error message 3');

        Assert.areEqual(3, testLogger.getQueueSize(), 'Three messages should be queued');

        Test.startTest();
        List<Database.SaveResult> results = testLogger.flush();
        Test.stopTest();

        Assert.areEqual(3, results.size(), 'Should return 3 save results');
        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty after flush');
    }

    @IsTest
    private static void testFlush_EmptyQueue() {
        Logger testLogger = new Logger();

        Test.startTest();
        List<Database.SaveResult> results = testLogger.flush();
        Test.stopTest();

        Assert.areEqual(0, results.size(), 'Should return empty list for empty queue');
        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should remain empty');
    }

    @IsTest
    private static void testGetQueueSize() {
        Logger testLogger = new Logger();

        Assert.areEqual(0, testLogger.getQueueSize(), 'Initial queue size should be 0');

        testLogger.error('Message 1');
        Assert.areEqual(1, testLogger.getQueueSize(), 'Queue size should be 1');

        testLogger.warn('Message 2');
        Assert.areEqual(2, testLogger.getQueueSize(), 'Queue size should be 2');

        testLogger.error('Message 3');
        Assert.areEqual(3, testLogger.getQueueSize(), 'Queue size should be 3');
    }

    @IsTest
    private static void testClearQueue() {
        Logger testLogger = new Logger();
        testLogger.error('Message 1');
        testLogger.warn('Message 2');

        Assert.areEqual(2, testLogger.getQueueSize(), 'Queue should have 2 messages');

        Test.startTest();
        testLogger.clearQueue();
        Test.stopTest();

        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty after clear');
    }

    @IsTest
    private static void testMultipleLogsAndFlush() {
        Logger testLogger = new Logger();

        Test.startTest();
        for (Integer i = 0; i < 10; i++) {
            testLogger.error('Error message ' + i);
        }
        Assert.areEqual(10, testLogger.getQueueSize(), 'Queue should have 10 messages');

        List<Database.SaveResult> results = testLogger.flush();
        Test.stopTest();

        Assert.areEqual(10, results.size(), 'Should publish 10 events');
        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty after flush');
    }

    @IsTest
    private static void testLoggerConfiguration_DefaultConstants() {
        // Verify the DEFAULT_LOG_LEVEL and DEFAULT_LOG_TARGET constants and that the default ctor uses them
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);

        // Access TestVisible constants via a new instance
        Assert.areEqual(LoggingLevel.WARN, Logger.DEFAULT_LOG_LEVEL, 'DEFAULT_LOG_LEVEL constant should be WARN');
        Assert.areEqual(Logger.LogTarget.ALL, Logger.DEFAULT_LOG_TARGET, 'DEFAULT_LOG_TARGET constant should be ALL');

        // Ensure current properties match the constants
        Assert.areEqual(Logger.DEFAULT_LOG_LEVEL, testLogger.currentLogLevel, 'currentLogLevel should equal DEFAULT_LOG_LEVEL');
        Assert.areEqual(Logger.DEFAULT_LOG_TARGET, testLogger.currentLogTarget, 'currentLogTarget should equal DEFAULT_LOG_TARGET');
    }

    @IsTest
    private static void testInstantiateLoggerWithDefaultConfigName() {
        Test.startTest();
        try {
            Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
            Logger testLogger = new Logger(config);
            Assert.isNotNull(testLogger, 'Logger instance should be created using default configuration');
            // Default config should be applied; queue should start empty
            Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty after initialization');
        } catch (Exception ex) {
            // If metadata isn't present in the test context, ensure we fail with a QueryException as a known fallback
            Assert.isInstanceOfType(ex, QueryException.class, 'Missing metadata should result in QueryException when using default config');
        }
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogLevel_ValidLevels() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);

        Test.startTest();
        Assert.areEqual(LoggingLevel.NONE, testLogger.mapLogLevel('NONE'), 'Should map NONE');
        Assert.areEqual(LoggingLevel.ERROR, testLogger.mapLogLevel('ERROR'), 'Should map ERROR');
        Assert.areEqual(LoggingLevel.WARN, testLogger.mapLogLevel('WARN'), 'Should map WARN');
        Assert.areEqual(LoggingLevel.INFO, testLogger.mapLogLevel('INFO'), 'Should map INFO');
        Assert.areEqual(LoggingLevel.DEBUG, testLogger.mapLogLevel('DEBUG'), 'Should map DEBUG');
        Assert.areEqual(LoggingLevel.FINE, testLogger.mapLogLevel('FINE'), 'Should map FINE');
        Assert.areEqual(LoggingLevel.FINER, testLogger.mapLogLevel('FINER'), 'Should map FINER');
        Assert.areEqual(LoggingLevel.FINEST, testLogger.mapLogLevel('FINEST'), 'Should map FINEST');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogLevel_CaseInsensitive() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);

        Test.startTest();
        Assert.areEqual(LoggingLevel.ERROR, testLogger.mapLogLevel('error'), 'Should handle lowercase');
        Assert.areEqual(LoggingLevel.WARN, testLogger.mapLogLevel('WaRn'), 'Should handle mixed case');
        Assert.areEqual(LoggingLevel.INFO, testLogger.mapLogLevel('INFO'), 'Should handle uppercase');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogLevel_InvalidLevel() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);

        Test.startTest();
        LoggingLevel result = testLogger.mapLogLevel('INVALID_LEVEL');
        Test.stopTest();

        Assert.areEqual(LoggingLevel.WARN, result, 'Invalid level should return default WARN');
    }

    @IsTest
    private static void testMapLogLevel_BlankThrowsException() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            testLogger.mapLogLevel('');
        } catch (IllegalArgumentException ex) {
            exceptionThrown = true;
            Assert.isTrue(ex.getMessage().contains('Log Level'), 'Exception should mention log level');
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'IllegalArgumentException should be thrown for blank log level');
    }

    @IsTest
    private static void testMapLogTarget_ValidTargets() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);

        Test.startTest();
        Assert.areEqual(Logger.LogTarget.ALL, testLogger.mapLogTarget('ALL'), 'Should map ALL');
        Assert.areEqual(Logger.LogTarget.PLATFORM_EVENT, testLogger.mapLogTarget('PLATFORM_EVENT'), 'Should map PLATFORM_EVENT');
        Assert.areEqual(Logger.LogTarget.SYSTEM_DEBUG, testLogger.mapLogTarget('SYSTEM_DEBUG'), 'Should map SYSTEM_DEBUG');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogTarget_CaseInsensitive() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);

        Test.startTest();
        Assert.areEqual(Logger.LogTarget.ALL, testLogger.mapLogTarget('all'), 'Should handle lowercase');
        Assert.areEqual(Logger.LogTarget.PLATFORM_EVENT, testLogger.mapLogTarget('platform_event'), 'Should handle lowercase');
        Assert.areEqual(Logger.LogTarget.SYSTEM_DEBUG, testLogger.mapLogTarget('SyStEm_DeBuG'), 'Should handle mixed case');
        Test.stopTest();
    }

    @IsTest
    private static void testMapLogTarget_InvalidTarget() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);

        Test.startTest();
        Logger.LogTarget result = testLogger.mapLogTarget('INVALID_TARGET');
        Test.stopTest();

        Assert.areEqual(Logger.LogTarget.ALL, result, 'Invalid target should return default ALL');
    }

    @IsTest
    private static void testMapLogTarget_BlankThrowsException() {
        Logger_Configuration__mdt config = Logger.getDefaultConfiguration();
        Logger testLogger = new Logger(config);
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            testLogger.mapLogTarget('');
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

        Assert.areEqual(testLevel, record.LogLevel, 'Log Level should match');
        Assert.areEqual(testMessage, record.message, 'Message should match');
        Assert.isNotNull(record.timestamp, 'Timestamp should be set');
        Assert.isNotNull(record.userId, 'User ID should be set');
        Assert.isNotNull(record.timezoneId, 'Timezone ID should be set');
        Assert.isNotNull(record.requestId, 'Request ID should be set');
    }

    @IsTest
    private static void testShouldLog_NoneLevel() {
        Logger testLogger = new Logger();

        Test.startTest();
        // NONE level should never log
        testLogger.log('Test', LoggingLevel.NONE);
        Test.stopTest();

        Assert.areEqual(0, testLogger.getQueueSize(), 'NONE level should not create log records');
    }

    @IsTest
    private static void testLogging_DifferentObjectTypes() {
        Logger testLogger = new Logger();

        Test.startTest();
        testLogger.error('String message');
        testLogger.error(123);
        testLogger.error(true);
        testLogger.error(new List<String>{'item1', 'item2'});
        testLogger.error(new Map<String, String>{'key' => 'value'});
        Test.stopTest();

        Assert.areEqual(5, testLogger.getQueueSize(), 'All object types should be logged');
    }

    @IsTest
    private static void testExceptionFormatting() {
        Logger testLogger = new Logger();
        
        try {
            // Generate a real exception with stack trace
            Integer result = 1 / 0;
        } catch (Exception ex) {
            Test.startTest();
            testLogger.error(ex);
            Test.stopTest();

            Assert.areEqual(1, testLogger.getQueueSize(), 'Exception should be logged');
        }
    }

    @IsTest
    private static void testFlush_SuccessfulPublish() {
        Logger testLogger = new Logger();
        testLogger.error('Test message');

        Test.startTest();
        List<Database.SaveResult> results = testLogger.flush();
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one result');
        for (Database.SaveResult result : results) {
            Assert.isTrue(result.isSuccess(), 'Publish should be successful in test context');
        }
    }

    @IsTest
    private static void testCompleteLoggingWorkflow() {
        Logger testLogger = new Logger();

        Test.startTest();
        // Log various messages
        testLogger.error('Critical error occurred');
        testLogger.warn('Warning: Resource limit approaching');
        testLogger.info('Process completed successfully');
        
        // Check queue
        Integer queueSize = testLogger.getQueueSize();
        Assert.areEqual(2, queueSize, 'Should have 2 messages queued');
        
        // Flush logs
        List<Database.SaveResult> results = testLogger.flush();
        
        // Verify flush
        Assert.areEqual(2, results.size(), 'Should publish 2 events');
        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty');
        
        // Log again after flush
        testLogger.error('New error after flush');
        Assert.areEqual(1, testLogger.getQueueSize(), 'Should have 1 new message');
        Test.stopTest();
    }

    @IsTest
    private static void testBulkLogging() {
        Logger testLogger = new Logger();

        Test.startTest();
        for (Integer i = 0; i < 100; i++) {
            testLogger.error('Bulk message ' + i);
        }
        
        Assert.areEqual(100, testLogger.getQueueSize(), 'Should queue 100 messages');
        
        List<Database.SaveResult> results = testLogger.flush();
        Test.stopTest();

        Assert.areEqual(100, results.size(), 'Should publish 100 events');
        Assert.areEqual(0, testLogger.getQueueSize(), 'Queue should be empty after bulk flush');
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

    @IsTest
    private static void testLogEventTrigger_PersistSingleRecord() {
        // Publish a small number of events
        Logger logger = new Logger();
        logger.warn('Trigger persistence test - single 1');
        logger.info('Trigger persistence test - single 2');

        // Flush to publish platform events (handled by trigger to persist Log__c)
        Test.startTest();
        logger.flush();
        Test.stopTest();

        // Query persisted log records
        List<Log__c> persisted = [
            SELECT Id, Log_Level__c, Message__c 
            FROM Log__c
        ];

        // Assert persisted size. There should only be 1 log record due to
        // the default WARN log level (ignoring the INFO log)
        Assert.areEqual(1, persisted.size(), 'There should be 1 log record created');
    }

    @IsTest
    private static void testLogEventTrigger_PersistBulkRecords() {
        // Publish a bulk set of events
        Logger logger = new Logger();
        for (Integer i = 0; i < 25; i++) {
            logger.warn('Trigger bulk persistence test - ' + i);
        }

        Test.startTest();
        logger.flush();
        Test.stopTest();

        List<Log__c> persisted = [
            SELECT Id, Log_Level__c, Message__c 
            FROM Log__c
        ];

        // Assertions
        Assert.areEqual(25, persisted.size(), 'There should be 25 log records created');
    }
}