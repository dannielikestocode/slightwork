/**
 * Interface that must be implemented by any class that handles Apex REST requests
 * through the RestEntryPoint. Each HTTP verb has a corresponding handler method 
 * that receives a RequestContext containing all request information.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
public interface Requestable {
    /**
     * Handle HTTP POST requests
     * @param context The request context containing headers, params, body, and RestContext
     * @return The response context to be returned for a request
     */
    ResponseContext handlePost(RequestContext context);

    /**
     * Handle HTTP GET requests
     * @param context The request context containing headers, params, body, and RestContext
     * @return The response context to be returned for a request
     */
    ResponseContext handleGet(RequestContext context);
    
    /**
     * Handle HTTP PUT requests
     * @param context The request context containing headers, params, body, and RestContext
     * @return The response context to be returned for a request
     */
    ResponseContext handlePut(RequestContext context);
    
    /**
     * Handle HTTP PATCH requests
     * @param context The request context containing headers, params, body, and RestContext
     * @return The response context to be returned for a request
     */
    ResponseContext handlePatch(RequestContext context);
    
    /**
     * Handle HTTP DELETE requests
     * @param context The request context containing headers, params, body, and RestContext
     * @return The response context to be returned for a request
     */
    ResponseContext handleDelete(RequestContext context);
}