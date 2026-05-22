@IsTest
private class LoggerTest {
    @IsTest
    static void testLoggerInstantiation() {
        Test.startTest();
        Logger logger1 = new Logger();
        Logger logger2 = new Logger();
        Test.stopTest();

        System.assertNotEquals(null, logger1, 'Logger instance should not be null');
        System.assertNotEquals(null, logger2, 'Logger instance should not be null');
        System.assertNotEquals(logger1, logger2, 'Each Logger should be a separate instance');
    }

    @IsTest
    static void testErrorLogging() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.error('Test error message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(1, queueSize, 'Queue should contain 1 log record');
    }

    @IsTest
    static void testWarnLogging() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.warn('Test warning message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(1, queueSize, 'Queue should contain 1 log record');
    }

    @IsTest
    static void testInfoLogging() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.info('Test info message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(1, queueSize, 'Queue should contain 1 log record');
    }

    @IsTest
    static void testDebugLogging() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.debug('Test debug message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(1, queueSize, 'Queue should contain 1 log record');
    }

    @IsTest
    static void testFineLogging() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.fine('Test fine message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(1, queueSize, 'Queue should contain 1 log record');
    }

    @IsTest
    static void testMultipleLogEntries() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.error('Error message');
        testLogger.warn('Warning message');
        testLogger.info('Info message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(3, queueSize, 'Queue should contain 3 log records');
    }

    @IsTest
    static void testFlush() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.error('Error message');
        testLogger.warn('Warning message');
        testLogger.info('Info message');
        testLogger.flush();
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(0, queueSize, 'Queue should be empty after flush');
    }

    @IsTest
    static void testClearQueue() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.error('Error message');
        testLogger.warn('Warning message');
        testLogger.clearQueue();
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(0, queueSize, 'Queue should be empty after clear');
    }

    @IsTest
    static void testLogLevelFiltering() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        // Set log level to WARN - should only log ERROR and WARN
        testLogger.setLogLevel(Logger.LogLevel.WARN);
        testLogger.error('Error message');
        testLogger.warn('Warning message');
        testLogger.info('Info message'); // Should not be logged
        testLogger.debug('Debug message'); // Should not be logged
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(2, queueSize, 'Queue should contain only ERROR and WARN messages');
    }

    @IsTest
    static void testSetAndGetLogLevel() {
        Logger testLogger = new Logger();
        
        Test.startTest();
        testLogger.setLogLevel(Logger.LogLevel.ERROR);
        Logger.LogLevel currentLevel = testLogger.getLogLevel();
        Test.stopTest();

        System.assertEquals(Logger.LogLevel.ERROR, currentLevel, 'Log level should be ERROR');
    }

    @IsTest
    static void testSetAndGetLogTarget() {
        Logger testLogger = new Logger();
        
        Test.startTest();
        testLogger.setLogTarget(Logger.LogTarget.SYSTEM_DEBUG);
        Logger.LogTarget currentTarget = testLogger.getLogTarget();
        Test.stopTest();

        System.assertEquals(Logger.LogTarget.SYSTEM_DEBUG, currentTarget, 'Log target should be SYSTEM_DEBUG');
    }

    @IsTest
    static void testLogTargetSystemDebugOnly() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.SYSTEM_DEBUG);
        
        Test.startTest();
        testLogger.error('Error message');
        testLogger.warn('Warning message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(0, queueSize, 'Queue should be empty when using SYSTEM_DEBUG only');
    }

    @IsTest
    static void testLogTargetPlatformEventOnly() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.error('Error message');
        testLogger.warn('Warning message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(2, queueSize, 'Queue should contain 2 records when using PLATFORM_EVENT only');
    }

    @IsTest
    static void testLogTargetBoth() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.BOTH);
        
        Test.startTest();
        testLogger.error('Error message');
        testLogger.warn('Warning message');
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(2, queueSize, 'Queue should contain 2 records when using BOTH');
    }

    @IsTest
    static void testPlatformEventPublishing() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.error('Test error for platform event');
        testLogger.warn('Test warning for platform event');
        testLogger.flush();
        Test.stopTest();

        // Query Log__c records created by the trigger
        List<Log__c> logs = [SELECT Id, Level__c, Message__c FROM Log__c];
        
        System.assertEquals(2, logs.size(), 'Should have 2 log records persisted');
        
        Boolean hasError = false;
        Boolean hasWarn = false;
        
        for (Log__c log : logs) {
            if (log.Level__c == 'ERROR' && log.Message__c == 'Test error for platform event') {
                hasError = true;
            }
            if (log.Level__c == 'WARN' && log.Message__c == 'Test warning for platform event') {
                hasWarn = true;
            }
        }
        
        System.assert(hasError, 'Should have ERROR log persisted');
        System.assert(hasWarn, 'Should have WARN log persisted');
    }

    @IsTest
    static void testLoggingWithObjectParameter() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        // Test with various object types
        testLogger.info(123);
        testLogger.info(true);
        testLogger.info(new List<String>{'test', 'list'});
        Integer queueSize = testLogger.getQueueSize();
        Test.stopTest();

        System.assertEquals(3, queueSize, 'Queue should contain 3 log records for different object types');
    }

    @IsTest
    static void testLoggingWithNullParameter() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.info(null);
        testLogger.flush();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Message__c FROM Log__c WHERE Level__c = 'INFO'];
        System.assertEquals(1, logs.size(), 'Should have 1 log record');
        System.assertEquals('null', logs[0].Message__c, 'Message should be "null"');
    }

    @IsTest
    static void testLoggingWithException() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        try {
            Integer x = 1 / 0; // Force divide by zero exception
        } catch (Exception ex) {
            testLogger.error(ex);
        }
        testLogger.flush();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Message__c FROM Log__c WHERE Level__c = 'ERROR'];
        System.assertEquals(1, logs.size(), 'Should have 1 error log');
        System.assert(logs[0].Message__c.contains('Exception Type:'), 'Message should contain exception type');
        System.assert(logs[0].Message__c.contains('Message:'), 'Message should contain exception message');
        System.assert(logs[0].Message__c.contains('Line Number:'), 'Message should contain line number');
        System.assert(logs[0].Message__c.contains('Stack Trace:'), 'Message should contain stack trace');
    }

    @IsTest
    static void testCustomException() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        try {
            throw new IllegalArgumentException('Test custom exception');
        } catch (Exception ex) {
            testLogger.error(ex);
        }
        testLogger.flush();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id, Message__c FROM Log__c WHERE Level__c = 'ERROR'];
        System.assertEquals(1, logs.size(), 'Should have 1 error log');
        System.assert(logs[0].Message__c.contains('IllegalArgumentException'), 'Message should contain exception type');
        System.assert(logs[0].Message__c.contains('Test custom exception'), 'Message should contain exception message');
    }

    @IsTest
    static void testLogRecordFieldsPopulated() {
        Logger testLogger = new Logger();
        testLogger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
        
        Test.startTest();
        testLogger.info('Test info message with all fields');
        testLogger.flush();
        Test.stopTest();

        List<Log__c> logs = [
            SELECT Id, Level__c, Message__c, User_Id__c, Timezone_Id__c, 
                   Quiddity__c, Request_Id__c, Timestamp__c
            FROM Log__c
            LIMIT 1
        ];
        
        System.assertEquals(1, logs.size(), 'Should have 1 log record');
        
        Log__c log = logs[0];
        System.assertEquals('INFO', log.Level__c, 'Level should be INFO');
        System.assertEquals('Test info message with all fields', log.Message__c, 'Message should match');
        System.assertNotEquals(null, log.User_Id__c, 'User Id should be populated');
        System.assertNotEquals(null, log.Timezone_Id__c, 'Timezone Id should be populated');
        System.assertNotEquals(null, log.Timestamp__c, 'Timestamp should be populated');
    }

    @IsTest
    static void testLoggerWithCustomConfiguration() {
        Test.startTest();
        Logger testLogger = new Logger('Default');
        Test.stopTest();

        System.assertNotEquals(null, testLogger, 'Logger with custom config should not be null');
    }
}