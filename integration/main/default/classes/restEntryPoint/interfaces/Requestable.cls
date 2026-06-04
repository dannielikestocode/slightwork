/**
 * Interface that must be implemented by any class that handles REST requests
 * through the RestEntryPoint. Each HTTP verb has a corresponding handler method that
 * receives a RequestContext containing all request information.
 */
public interface Requestable {
    /**
     * Handle HTTP GET requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handleGet(RequestContext context);
    
    /**
     * Handle HTTP POST requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handlePost(RequestContext context);
    
    /**
     * Handle HTTP PUT requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handlePut(RequestContext context);
    
    /**
     * Handle HTTP PATCH requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handlePatch(RequestContext context);
    
    /**
     * Handle HTTP DELETE requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handleDelete(RequestContext context);
}