/**
 * Provides a robust utility for logging messages both synchronously
 * and asynchronously.
 * 
 * Log Level Ordinal values (The higher the severity, the higher the ordinal value):
 * 
 * LoggingLevel.ERROR: 8
 * LoggingLevel.WARN: 7
 * LoggingLevel.INFO: 6
 * LoggingLevel.DEBUG: 5
 * LoggingLevel.FINE: 4
 * LoggingLevel.FINER: 3
 * LoggingLevel.FINEST: 2
 * LoggingLevel.NONE: 0 => (FINEST to NONE skips 1 and goes straight to 0)
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/observability/logger.html
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_LoggingLevel.htm For available log levels
 * @see https://help.salesforce.com/s/articleView?id=platform.code_setting_debug_log_levels.htm&type=5 For debug log types
 */
public inherited sharing class Logger {
    /**
     * Constants
     */
    @TestVisible private static final LoggingLevel DEFAULT_LOG_LEVEL = LoggingLevel.WARN;
    @TestVisible private static final LogTarget DEFAULT_LOG_TARGET = LogTarget.ALL;
    public static final String DEFAULT_CONFIGURATION_NAME = 'Default';

    /**
     * Properties
     */
    private final List<LogRecord> logQueue {get; set;}
    public final LoggingLevel currentLogLevel {get; private set;}
    public final LogTarget currentLogTarget {get; private set;}

    /**
     * Enums
     */
    public enum LogTarget {
        SYSTEM_DEBUG,
        PLATFORM_EVENT,
        ALL
    }

    /**
     * Default, no-arg constructor
     */
    public Logger() {
        this.logQueue = new List<LogRecord>();
        this.currentLogLevel = DEFAULT_LOG_LEVEL;
        this.currentLogTarget = DEFAULT_LOG_TARGET;
    }

    /**
     * Constructor with configuration instance argument
     * 
     * @param config The logger configuration record
     */
    public Logger(Logger_Configuration__mdt config) {
        if (config == null) {
            throw new IllegalArgumentException('Logger Configuration must be provided');
        }
        
        // Set properties
        this.logQueue = new List<LogRecord>();
        this.currentLogLevel = mapLogLevel(config.Default_Log_Level__c);
        this.currentLogTarget = mapLogTarget(config.Default_Log_Target__c);
    }

    /**
     * Determines if a message at the given log level should be logged.
     * Uses ordinal comparison to check if the level meets or exceeds the current threshold.
     * 
     * @param targetLogLevel The log level to check
     * @return true if the level should be logged, false otherwise
     */
    private Boolean shouldLog(LoggingLevel targetLogLevel) {
        if (targetLogLevel == LoggingLevel.NONE) {
            return false;
        }
        else {
            return this.currentLogLevel.ordinal() <= targetLogLevel.ordinal();
        }
    }

    /**
     * Converts an object to a string representation for logging.
     * Handles exceptions with detailed formatting including stack traces.
     * 
     * @param obj The object to convert (can be any type including Exception)
     * @return String representation of the object, 'null' for null values
     */
    private String objectToString(Object obj) {
        if (obj == null) {
            return 'null';
        }

        // Check if object is an exception
        if (obj instanceof Exception) {
            return formatException((Exception) obj);
        }

        // For all other objects, use String.valueOf
        return String.valueOf(obj);
    }

    /**
     * Formats an exception with detailed information including type, message, line number, and stack trace.
     * 
     * @param ex The exception to format
     * @return Formatted string containing exception details
     */
    private String formatException(Exception ex) {
        Map<String, Object> exceptionMap = new Map<String, Object>();
        exceptionMap.put('exceptionType', ex.getTypeName());
        exceptionMap.put('message', ex.getMessage());
        exceptionMap.put('lineNumber', ex.getLineNumber());
        exceptionMap.put('stackTrace', ex.getStackTraceString());
        return JSON.serialize(exceptionMap);
    }

    /**
     * Adds a log record to the appropriate target(s) based on current configuration.
     * Sends to System.debug and/or adds to the platform event queue.
     * 
     * @param targetLoglevel The log level as a string
     * @param obj The object to log (will be converted to string)
     */
    private void addLogRecord(LoggingLevel targetLoglevel, Object obj) {
        String message = objectToString(obj);
        
        // Handle System.debug(). Logs added via the System class are always published immediately
        // without explicitly calling flush().
        if (this.currentLogTarget == LogTarget.ALL || this.currentLogTarget == LogTarget.SYSTEM_DEBUG) {
            System.debug(targetLogLevel, message);
        }

        // Handle Platform Event queue
        if (this.currentLogTarget == LogTarget.ALL || this.currentLogTarget == LogTarget.PLATFORM_EVENT) {
            this.logQueue.add(new LogRecord(targetLoglevel.name().toUpperCase(), message));
        }
    }
    
    /**
     * Logs a message at ERROR level.
     * Only logs if current log level is ERROR or higher.
     * 
     * @param obj The object to log
     */
    public void error(Object obj) {
        if (shouldLog(LoggingLevel.ERROR)) {
            addLogRecord(LoggingLevel.ERROR, obj);
        }
    }

    /**
     * Logs a message at WARN level.
     * Only logs if current log level is WARN or higher.
     * 
     * @param obj The object to log
     */
    public void warn(Object obj) {
        if (shouldLog(LoggingLevel.WARN)) {
            addLogRecord(LoggingLevel.WARN, obj);
        }
    }

    /**
     * Logs a message at INFO level.
     * Only logs if current log level is INFO or higher.
     * 
     * @param obj The object to log
     */
    public void info(Object obj) {
        if (shouldLog(LoggingLevel.INFO)) {
            addLogRecord(LoggingLevel.INFO, obj);
        }
    }

    /**
     * Logs a message at DEBUG level.
     * Only logs if current log level is DEBUG or higher.
     * 
     * @param obj The object to log
     */
    public void debug(Object obj) {
        if (shouldLog(LoggingLevel.DEBUG)) {
            addLogRecord(LoggingLevel.DEBUG, obj);
        }
    }

    /**
     * Logs a message at FINE level.
     * Only logs if current log level is FINE or higher.
     * 
     * @param obj The object to log
     */
    public void fine(Object obj) {
        if (shouldLog(LoggingLevel.FINE)) {
            addLogRecord(LoggingLevel.FINE, obj);
        }
    }

    /**
     * Logs a message at FINER level.
     * Only logs if current log level is FINER or higher.
     * 
     * @param obj The object to log
     */
    public void finer(Object obj) {
        if (shouldLog(LoggingLevel.FINER)) {
            addLogRecord(LoggingLevel.FINER, obj);
        }
    }

    /**
     * Logs a message at FINEST level.
     * Only logs if current log level is FINEST or higher.
     * 
     * @param obj The object to log
     */
    public void finest(Object obj) {
        if (shouldLog(LoggingLevel.FINEST)) {
            addLogRecord(LoggingLevel.FINEST, obj);
        }
    }

    /**
     * Logs a message using the default config options.
     * 
     * @param obj The object to log
     */
    public void log(Object obj) {
        addLogRecord(this.currentLogLevel, obj);
    }

    /**
     * Logs a message at the provided log level
     * 
     * @param obj The object to log
     * @param targetLogLevel The target log level
     */
    public void log(Object obj, LoggingLevel targetLogLevel) {
        if (targetLogLevel == LoggingLevel.NONE) {
            return;
        }
        addLogRecord(targetLogLevel, obj);
    }

    /**
     * Publishes all queued log records as platform events and clears the queue.
     * Logs any publish errors to System.debug at ERROR level.
     * 
     * @return List of Database.SaveResult for each published event
     */
    public List<Database.SaveResult> flush() {
        if (this.logQueue.isEmpty()) {
            return new List<Database.SaveResult>();
        }

        List<Log_Event__e> events = new List<Log_Event__e>();
        for (LogRecord record : this.logQueue) {
            Log_Event__e event = new Log_Event__e(
                Log_Level__c = record.logLevel,
                Message__c = record.message,
                User_Id__c = record.userId,
                Timezone_Id__c = record.timezoneId,
                Quiddity__c = record.quiddity,
                Request_Id__c = record.requestId,
                Timestamp__c = record.timestamp
            );
            events.add(event);
        }

        // Publish events
        List<Database.SaveResult> results = EventBus.publish(events);

        // Check for errors (optional - you may want to handle publish errors)
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    System.debug(LoggingLevel.ERROR, 'Error publishing log event: ' + err.getMessage());
                }
            }
        }

        // Clear the queue after publishing
        this.clearQueue();
        return results;
    }

    /**
     * Returns the number of log records currently in the queue waiting to be published.
     * 
     * @return The size of the log queue
     */
    public Integer getQueueSize() {
        return this.logQueue.size();
    }

    /**
     * Clears all log records from the queue without publishing them.
     * Useful for discarding logs in error scenarios or testing.
     */
    public void clearQueue() {
        this.logQueue.clear();
    }

    /**
     * Maps the log level to the corresponding enum value.
     * 
     * @param targetLogLevel The target log level to be mapped
     */
    @TestVisible
    private LoggingLevel mapLogLevel(String targetLogLevel) {
        if (String.isBlank(targetLogLevel)) {
            throw new IllegalArgumentException('Log Level for logger configuration must be provided');
        }

        LoggingLevel newLoggingLevel; 
        switch on targetLogLevel.toUpperCase() {
            when 'NONE' {
                newLoggingLevel = LoggingLevel.NONE;
            }
            when 'ERROR' {
                newLoggingLevel = LoggingLevel.ERROR;
            }
            when 'WARN' {
                newLoggingLevel = LoggingLevel.WARN;
            }
            when 'INFO' {
                newLoggingLevel = LoggingLevel.INFO;
            }
            when 'DEBUG' {
                newLoggingLevel = LoggingLevel.DEBUG;
            }
            when 'FINE' {
                newLoggingLevel = LoggingLevel.FINE;
            }
            when 'FINER' {
                newLoggingLevel = LoggingLevel.FINER;
            }
            when 'FINEST' {
                newLoggingLevel = LoggingLevel.FINEST;
            }
            when else {
                newLoggingLevel = DEFAULT_LOG_LEVEL;
            }
        }
        return newLoggingLevel;
    }

    /**
     * Maps the log target to the corresponding enum value.
     * 
     * @param targetLogTarget The String value of the log target
     */
    @TestVisible
    private LogTarget mapLogTarget(String targetLogTarget) {
        if (String.isBlank(targetLogTarget)) {
            throw new IllegalArgumentException('Log Target for logger configuration must be provided');
        }

        LogTarget newLogTarget; 
        switch on targetLogTarget.toUpperCase() {
            when 'ALL' {
                newLogTarget = LogTarget.ALL;
            }
            when 'PLATFORM_EVENT' {
                newLogTarget = LogTarget.PLATFORM_EVENT;
            }
            when 'SYSTEM_DEBUG' {
                newLogTarget = LogTarget.SYSTEM_DEBUG;
            }
            when else {
                newLogTarget = DEFAULT_LOG_TARGET;
            }
        }
        return newLogTarget;
    }

    /**
     * Helper method to retrieve the default logger configuration record.
     * 
     * @return The default logger configuration record
     */
    public static Logger_Configuration__mdt getDefaultConfiguration() {
        return Logger_Configuration__mdt.getInstance(Logger.DEFAULT_CONFIGURATION_NAME);
    }

    /**
     * Inner class to represent a log record
     */
    public class LogRecord {
        public final DateTime timestamp;
        public final String timezoneId;
        public final String logLevel;
        public final String message;
        public final String userId;
        public final String quiddity;
        public final String requestId;

        /**
         * Constructor with args
         * 
         * @param logLevel The log level of the message
         * @param message The body of the message
         */
        public LogRecord(String logLevel, String message) {
            this.timestamp = DateTime.now();
            this.logLevel = logLevel;
            this.message = message;
            this.userId = UserInfo.getUserId();
            this.timezoneId = UserInfo.getTimeZone().getID();
            this.quiddity = Request.getCurrent().getQuiddity()?.name();
            this.requestId = Request.getCurrent().getRequestId();
        }
    }
}