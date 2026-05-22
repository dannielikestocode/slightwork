public inherited sharing class Logger {
    // Log levels enum
    public enum LogLevel {
        ERROR,
        WARN,
        INFO,
        DEBUG,
        FINE
    }

    // Log target enum
    public enum LogTarget {
        SYSTEM_DEBUG,
        PLATFORM_EVENT,
        BOTH
    }

    // Inner class to represent a log record
    private class LogRecord {
        public DateTime timestamp;
        public String timezoneId;
        public String level;
        public String message;
        public String userId;
        public String quiddity;
        public String requestId;

        public LogRecord(String level, String message) {
            this.timestamp = DateTime.now();
            this.level = level;
            this.message = message;
            this.userId = UserInfo.getUserId();
            this.timezoneId = UserInfo.getTimeZone().getID();
            this.quiddity = Request.getCurrent().getQuiddity()?.name();
            this.requestId = Request.getCurrent().getRequestId();
        }
    }

    // Instance variables
    private List<LogRecord> logQueue;
    private LogLevel currentLogLevel;
    private LogTarget currentLogTarget;

    // Constructor
    public Logger() {
        this.logQueue = new List<LogRecord>();
        Logger_Configuration__mdt config = getConfiguration();
        this.currentLogLevel = getDefaultLogLevel(config);
        this.currentLogTarget = getDefaultLogTarget(config);
    }

    // Constructor with custom configuration name
    public Logger(String configName) {
        this.logQueue = new List<LogRecord>();
        Logger_Configuration__mdt config = getConfiguration(configName);
        this.currentLogLevel = getDefaultLogLevel(config);
        this.currentLogTarget = getDefaultLogTarget(config);
    }

    // Get configuration from custom metadata
    private Logger_Configuration__mdt getConfiguration() {
        return getConfiguration('Default');
    }

    private Logger_Configuration__mdt getConfiguration(String configName) {
        try {
            return [
                SELECT Default_Log_Level__c, Log_Target__c
                FROM Logger_Configuration__mdt
                WHERE DeveloperName = :configName
                LIMIT 1
            ];
        } catch (Exception e) {
            return null;
        }
    }

    // Get default log level from custom metadata
    private LogLevel getDefaultLogLevel(Logger_Configuration__mdt config) {
        if (config != null && config.Default_Log_Level__c != null) {
            try {
                return LogLevel.valueOf(config.Default_Log_Level__c);
            } catch (Exception e) {
                // Invalid value, use default
            }
        }
        return LogLevel.INFO;
    }

    // Get default log target from custom metadata
    private LogTarget getDefaultLogTarget(Logger_Configuration__mdt config) {
        if (config != null && config.Log_Target__c != null) {
            if (config.Log_Target__c == 'System Debug') {
                return LogTarget.SYSTEM_DEBUG;
            } else if (config.Log_Target__c == 'Platform Event') {
                return LogTarget.PLATFORM_EVENT;
            } else if (config.Log_Target__c == 'Both') {
                return LogTarget.BOTH;
            }
        }
        return LogTarget.BOTH;
    }

    // Set the current log level
    public void setLogLevel(LogLevel level) {
        this.currentLogLevel = level;
    }

    // Get the current log level
    public LogLevel getLogLevel() {
        return this.currentLogLevel;
    }

    // Set the current log target
    public void setLogTarget(LogTarget target) {
        this.currentLogTarget = target;
    }

    // Get the current log target
    public LogTarget getLogTarget() {
        return this.currentLogTarget;
    }

    // Check if a log level should be logged
    private Boolean shouldLog(LogLevel level) {
        return level.ordinal() <= this.currentLogLevel.ordinal();
    }

    // Convert object to string message
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

    // Format exception with detailed information
    private String formatException(Exception ex) {
        StringBuilder sb = new StringBuilder();
        sb.append('Exception Type: ').append(ex.getTypeName()).append('\n');
        sb.append('Message: ').append(ex.getMessage()).append('\n');
        sb.append('Line Number: ').append(ex.getLineNumber()).append('\n');
        sb.append('Stack Trace:\n').append(ex.getStackTraceString());
        return sb.toString();
    }

    // Add a log record to the queue or System.debug
    private void addLogRecord(String level, Object obj) {
        String message = objectToString(obj);
        
        // Handle System.debug
        if (this.currentLogTarget == LogTarget.SYSTEM_DEBUG || this.currentLogTarget == LogTarget.BOTH) {
            LoggingLevel loggingLevelEnum;
            switch on level {
                when 'ERROR' {
                    loggingLevelEnum = LoggingLevel.ERROR;
                }
                when 'WARN' {
                    loggingLevelEnum = LoggingLevel.WARN;
                }
                when 'INFO' {
                    loggingLevelEnum = LoggingLevel.INFO;
                }
                when 'DEBUG' {
                    loggingLevelEnum = LoggingLevel.DEBUG;
                }
                when 'FINE' {
                    loggingLevelEnum = LoggingLevel.FINE;
                }
                when else {
                    loggingLevelEnum = LoggingLevel.INFO;
                }
            }
            System.debug(loggingLevelEnum, message);
        }

        // Handle Platform Event queue
        if (this.currentLogTarget == LogTarget.PLATFORM_EVENT || this.currentLogTarget == LogTarget.BOTH) {
            LogRecord record = new LogRecord(level, message);
            this.logQueue.add(record);
        }
    }

    // ERROR level logging
    public void error(Object obj) {
        if (shouldLog(LogLevel.ERROR)) {
            addLogRecord('ERROR', obj);
        }
    }

    // WARN level logging
    public void warn(Object obj) {
        if (shouldLog(LogLevel.WARN)) {
            addLogRecord('WARN', obj);
        }
    }

    // INFO level logging
    public void info(Object obj) {
        if (shouldLog(LogLevel.INFO)) {
            addLogRecord('INFO', obj);
        }
    }

    // DEBUG level logging
    public void debug(Object obj) {
        if (shouldLog(LogLevel.DEBUG)) {
            addLogRecord('DEBUG', obj);
        }
    }

    // FINE level logging
    public void fine(Object obj) {
        if (shouldLog(LogLevel.FINE)) {
            addLogRecord('FINE', obj);
        }
    }

    // Flush all log records by publishing platform events
    public List<Database.SaveResult> flush() {
        if (this.logQueue.isEmpty()) {
            return new List<Database.SaveResult>();
        }

        List<Log_Event__e> events = new List<Log_Event__e>();

        for (LogRecord record : this.logQueue) {
            Log_Event__e event = new Log_Event__e(
                Level__c = record.level,
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
        this.logQueue.clear();
        
        return results;
    }

    // Get the current queue size
    public Integer getQueueSize() {
        return this.logQueue.size();
    }

    // Clear the queue without publishing
    public void clearQueue() {
        this.logQueue.clear();
    }
}