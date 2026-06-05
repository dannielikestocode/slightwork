/**
 * Interface that must be implemented by any class that handles Apex REST requests
 * through the RestEntryPoint. 
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
public interface Requestable {
    /**
     * Handle HTTP POST requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param pathVariables The path variables extracted from the endpoint path
     */
    void handlePost(RestRequest request, RestResponse response, Map<String, String> pathVariables);

    /**
     * Handle HTTP GET requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param pathVariables The path variables extracted from the endpoint path
     */
    void handleGet(RestRequest request, RestResponse response, Map<String, String> pathVariables);
    
    /**
     * Handle HTTP PUT requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param pathVariables The path variables extracted from the endpoint path
     */
    void handlePut(RestRequest request, RestResponse response, Map<String, String> pathVariables);
    
    /**
     * Handle HTTP PATCH requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param pathVariables The path variables extracted from the endpoint path
     */
    void handlePatch(RestRequest request, RestResponse response, Map<String, String> pathVariables);
    
    /**
     * Handle HTTP DELETE requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param pathVariables The path variables extracted from the endpoint path
     */
    void handleDelete(RestRequest request, RestResponse response, Map<String, String> pathVariables);
}