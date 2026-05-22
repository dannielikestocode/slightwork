/**
 * Custom exception class for HTTP callout errors.
 * Provides detailed error information for callout failures.
 * 
 * @author Agentforce
 * @since v66.0
 * @see CalloutManager
 */
public class CalloutException extends Exception {
    
    /**
     * Default constructor.
     */
    public CalloutException() {
        super();
    }
    
    /**
     * Constructor with error message.
     * 
     * @param message The error message
     */
    public CalloutException(String message) {
        super(message);
    }
    
    /**
     * Constructor with error message and cause.
     * 
     * @param message The error message
     * @param cause The underlying exception
     */
    public CalloutException(String message, Exception cause) {
        super(message, cause);
    }
}