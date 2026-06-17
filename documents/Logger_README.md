# Logger Framework

A comprehensive logging framework for Salesforce that provides structured logging with flexible output targets and exception handling.

## Features

- **Multiple Log Levels**: ERROR, WARN, INFO, DEBUG, FINE
- **Instance-Based**: Each logger is an independent instance (no singleton pattern)
- **Flexible Log Targets**: System.debug, Platform Events, or Both
- **In-Memory Queue**: Logs are captured in memory and flushed on demand for platform events
- **Platform Events**: Uses Log_Event__e platform event with PublishImmediately behavior
- **Persistent Storage**: Automatically persists logs to Log__c custom object via trigger
- **Contextual Data**: Captures timestamp, user timezone, user ID, quiddity, and request ID
- **Object Parameter Support**: Log methods accept any Object type
- **Enhanced Exception Formatting**: Automatically formats exceptions with type, message, line number, and stack trace
- **Configurable**: Uses Logger_Configuration__mdt for default log level and target configuration

## Usage Examples

### Basic Logging

```apex
// Create a logger instance
Logger logger = new Logger();

// Log at different levels with strings
logger.error('An error occurred');
logger.warn('This is a warning');
logger.info('Informational message');
logger.debug('Debug information');
logger.fine('Fine-grained details');

// Flush logs to persist them (only needed for Platform Event or Both targets)
logger.flush();
```

### Logging with Object Parameters

```apex
Logger logger = new Logger();

// Log different object types
logger.info(123);
logger.info(true);
logger.info(new List<String>{'item1', 'item2'});
logger.info(new Account(Name='Test Account'));

// Log null values
logger.info(null); // Logs as "null"

logger.flush();
```

### Exception Logging

```apex
Logger logger = new Logger();

try {
    // Some code that might throw an exception
    Account acc = [SELECT Id FROM Account WHERE Id = 'invalid'];
} catch (Exception ex) {
    // Log the exception - automatically formatted with details
    logger.error(ex);
    logger.flush();
}

// Exception log format includes:
// - Exception Type: QueryException
// - Message: List has no rows for assignment to SObject
// - Line Number: 5
// - Stack Trace: [full stack trace]
```

### Configuring Log Target

```apex
Logger logger = new Logger();

// Log to System.debug only (no platform events)
logger.setLogTarget(Logger.LogTarget.SYSTEM_DEBUG);
logger.info('This goes to debug logs only');

// Log to Platform Events only (for persistence)
logger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);
logger.info('This goes to platform events only');
logger.flush();

// Log to both System.debug and Platform Events (default)
logger.setLogTarget(Logger.LogTarget.BOTH);
logger.info('This goes to both');
logger.flush();
```

### Log Level Filtering

```apex
Logger logger = new Logger();
logger.setLogTarget(Logger.LogTarget.PLATFORM_EVENT);

// Set log level to WARN - only ERROR and WARN will be logged
logger.setLogLevel(Logger.LogLevel.WARN);

logger.error('This will be logged');
logger.warn('This will be logged');
logger.info('This will NOT be logged');
logger.debug('This will NOT be logged');

logger.flush();
```

### Example in a Service Class

```apex
public class AccountService {
    private Logger logger = new Logger();
    
    public void processAccounts(List<Account> accounts) {
        logger.info('Starting account processing: ' + accounts.size() + ' records');
        
        try {
            // Business logic here
            update accounts;
            logger.info('Successfully processed accounts');
        } catch (DmlException ex) {
            logger.error(ex);
            throw ex;
        } finally {
            // Flush logs at the end
            logger.flush();
        }
    }
}
```

### Example in a Batch Apex

```apex
public class AccountBatch implements Database.Batchable<SObject> {
    private Logger logger = new Logger();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        logger.info('Batch job started: ' + bc.getJobId());
        logger.flush();
        return Database.getQueryLocator('SELECT Id, Name FROM Account');
    }
    
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        logger.info('Processing batch: ' + scope.size() + ' records');
        
        try {
            // Process records
            update scope;
            logger.info('Batch processed successfully');
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        logger.info('Batch job completed: ' + bc.getJobId());
        logger.flush();
    }
}
```

### Using Custom Configuration

```apex
// Use a custom logger configuration
Logger logger = new Logger('CustomConfig');

// This logger will use the settings from the CustomConfig metadata record
logger.info('Using custom configuration');
logger.flush();
```

### Querying Logs

```apex
// Query recent error logs
List<Log__c> errorLogs = [
    SELECT Id, Level__c, Message__c, Timestamp__c, User_Id__c, Request_Id__c
    FROM Log__c
    WHERE Level__c = 'ERROR'
    ORDER BY Timestamp__c DESC
    LIMIT 100
];

// Query logs for specific user
List<Log__c> userLogs = [
    SELECT Id, Level__c, Message__c, Timestamp__c
    FROM Log__c
    WHERE User_Id__c = :UserInfo.getUserId()
    ORDER BY Timestamp__c DESC
];

// Query logs by request correlation
List<Log__c> requestLogs = [
    SELECT Id, Level__c, Message__c, Timestamp__c
    FROM Log__c
    WHERE Request_Id__c = :someRequestId
    ORDER BY Timestamp__c ASC
];

// Query exception logs (messages contain "Exception Type:")
List<Log__c> exceptionLogs = [
    SELECT Id, Level__c, Message__c, Timestamp__c
    FROM Log__c
    WHERE Message__c LIKE '%Exception Type:%'
    ORDER BY Timestamp__c DESC
];
```

## Configuration

### Setting Default Log Level and Target

1. Navigate to **Setup > Custom Metadata Types**
2. Click **Manage Records** next to **Logger Configuration**
3. Create or edit a record with **Developer Name** = `Default`
4. Set **Default Log Level** to your desired level (ERROR, WARN, INFO, DEBUG, or FINE)
5. Set **Log Target** to your desired target:
   - **System Debug**: Logs only to System.debug (no persistence)
   - **Platform Event**: Logs only to platform events (persisted to Log__c)
   - **Both**: Logs to both System.debug and platform events (default)

### Creating Custom Configurations

You can create multiple logger configurations for different contexts:

1. Create a new Logger_Configuration__mdt record
2. Set a unique **Developer Name** (e.g., `Integration`, `BatchJob`, `Production`)
3. Configure **Default Log Level** and **Log Target**
4. Use in code: `Logger logger = new Logger('Integration');`

## Architecture

### Components

1. **Logger.cls**: Main logger class
   - Instance-based (create with `new Logger()`)
   - Manages in-memory log queue
   - Provides methods for each log level
   - Handles platform event publishing and System.debug
   - Formats exceptions automatically

2. **Log_Event__e**: Platform event for log transmission
   - Uses PublishImmediately behavior for real-time processing
   - Contains all log context fields

3. **LogEventTrigger**: Trigger on Log_Event__e
   - Automatically persists platform events to Log__c

4. **Log__c**: Custom object for persistent log storage
   - Stores all log records for reporting and analysis
   - Supports field history tracking

5. **Logger_Configuration__mdt**: Custom metadata for configuration
   - Stores default log level and log target settings
   - Supports multiple configurations for different contexts

### Data Flow

**When Log Target = PLATFORM_EVENT or BOTH:**
```
Application Code
    ↓
Logger.error/warn/info/debug/fine(Object)
    ↓
objectToString() / formatException()
    ↓
In-Memory Queue (LogRecord objects)
    ↓
Logger.flush()
    ↓
Log_Event__e Platform Events (PublishImmediately)
    ↓
LogEventTrigger (after insert)
    ↓
Log__c Records (DML insert)
```

**When Log Target = SYSTEM_DEBUG or BOTH:**
```
Application Code
    ↓
Logger.error/warn/info/debug/fine(Object)
    ↓
objectToString() / formatException()
    ↓
System.debug(LoggingLevel, message)
```

## Best Practices

1. **Create Logger Instances**: Each class should have its own logger instance
   ```apex
   private Logger logger = new Logger();
   ```

2. **Flush Strategically**: Call `flush()` at the end of your transaction or in exception handlers when using PLATFORM_EVENT or BOTH targets

3. **Use Appropriate Log Levels**: 
   - ERROR: Exceptions and critical failures (always log exceptions here)
   - WARN: Potential issues or degraded functionality
   - INFO: Key business events and milestones
   - DEBUG: Detailed debugging information
   - FINE: Very detailed trace information

4. **Log Exceptions Directly**: Pass exception objects to logger methods for automatic formatting
   ```apex
   try {
       // code
   } catch (Exception ex) {
       logger.error(ex); // Automatically formats with all details
       logger.flush();
   }
   ```

5. **Choose the Right Log Target**:
   - **Development**: Use SYSTEM_DEBUG or BOTH for immediate feedback
   - **Production**: Use PLATFORM_EVENT for persistence and analysis
   - **Testing**: Use PLATFORM_EVENT to verify logs are created correctly

6. **Include Context**: When logging strings, add relevant information (IDs, counts, etc.)
   ```apex
   logger.info('Processing ' + accounts.size() + ' accounts for region: ' + region);
   ```

7. **Governor Limits**: Platform events count toward limits (100 events per transaction)

## Testing

The framework includes comprehensive test coverage in `LoggerTest.cls`:
- Instance creation and independence
- All log level methods
- Object parameter handling
- Null value handling
- Exception formatting
- Queue management
- Platform event publishing
- Data persistence
- Log level filtering
- Log target switching

Run tests with:
```bash
sf apex run test --class-names LoggerTest --target-org your-org-alias
```

## Exception Formatting

When you log an Exception object, the logger automatically formats it with:

```
Exception Type: <TypeName>
Message: <Exception Message>
Line Number: <Line Number>
Stack Trace:
<Full Stack Trace>
```

Example output:
```
Exception Type: System.QueryException
Message: List has no rows for assignment to SObject
Line Number: 12
Stack Trace:
Class.AccountService.getAccount: line 12, column 1
Class.AccountController.init: line 5, column 1
```

## Monitoring and Maintenance

### Monitoring Logs

Create custom reports on Log__c to monitor:
- Error trends over time
- Most active users
- Request correlation patterns
- Timezone distribution
- Exception types and frequencies

### Data Retention

Consider implementing a scheduled batch job to archive or delete old logs:

```apex
public class LogCleanupBatch implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Delete logs older than 90 days
        DateTime cutoffDate = DateTime.now().addDays(-90);
        return Database.getQueryLocator(
            'SELECT Id FROM Log__c WHERE Timestamp__c < :cutoffDate'
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Log__c> scope) {
        delete scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        // Optional: Log completion
    }
}
```

## Support and Troubleshooting

### Common Issues

1. **Logs not appearing in Log__c**: 
   - Ensure `flush()` is called
   - Verify Log Target is set to PLATFORM_EVENT or BOTH
   - Check that LogEventTrigger is active

2. **Too many platform events**: 
   - Batch logs and flush periodically
   - Consider using SYSTEM_DEBUG target for high-volume logs

3. **Missing log data**: 
   - Check trigger is active and Log__c fields exist
   - Verify platform event fields match Log__c fields

4. **Exception not formatted**: 
   - Ensure you're passing the Exception object, not ex.getMessage()
   - Correct: `logger.error(ex)`
   - Incorrect: `logger.error(ex.getMessage())`

### Debug Mode

For development, you can temporarily increase log verbosity:

```apex
Logger logger = new Logger();
logger.setLogLevel(Logger.LogLevel.FINE);
logger.setLogTarget(Logger.LogTarget.BOTH);
```

## Migration from Singleton Pattern

If upgrading from the singleton pattern version:

**Old approach:**
```apex
Logger logger = Logger.getInstance();
```

**New approach:**
```apex
Logger logger = new Logger();
```

Each class/method should create its own logger instance. This provides better isolation and testability.