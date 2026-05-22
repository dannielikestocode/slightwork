/**
 * @description Interface that must be implemented by any class that handles REST requests
 * through the RestEntryPoint. Each HTTP verb has a corresponding handler method that
 * receives a RequestContext containing all request information.
 */
public interface Requestable {
    /**
     * @description Handle HTTP GET requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handleGet(RequestContext context);
    
    /**
     * @description Handle HTTP POST requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handlePost(RequestContext context);
    
    /**
     * @description Handle HTTP PUT requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handlePut(RequestContext context);
    
    /**
     * @description Handle HTTP PATCH requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handlePatch(RequestContext context);
    
    /**
     * @description Handle HTTP DELETE requests
     * @param context The request context containing headers, params, body, and RestContext
     */
    void handleDelete(RequestContext context);
}