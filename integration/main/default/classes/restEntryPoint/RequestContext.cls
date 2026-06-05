/**
 * Context object that encapsulates all information about an Apex REST request.
 * This class is passed to Requestable implementations to provide access
 * to headers, parameters, body, and the underlying RestContext.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_restrequest.htm
 */
public without sharing class RequestContext {
    private Map<String, String> headers;
    private Map<String, String> urlParams;
    private String requestBody;
    private Map<String, String> pathVariables;
    
    /**
     * Constructor for RequestContext
     * @param headers Map of HTTP headers
     * @param urlParams Map of query string parameters
     * @param requestBody The raw request body
     * @param restContext Not used - kept for backward compatibility
     */
    public RequestContext(
        Map<String, String> headers,
        Map<String, String> urlParams,
        String requestBody,
        RestContext restContext
    ) {
        this.headers = headers != null ? headers : new Map<String, String>();
        this.urlParams = urlParams != null ? urlParams : new Map<String, String>();
        this.requestBody = requestBody;
        this.pathVariables = new Map<String, String>();
    }
    
    /**
     * Get all HTTP headers
     * @return Map of header names to values
     */
    public Map<String, String> getHeaders() {
        return this.headers;
    }
    
    /**
     * Get a specific header value
     * @param headerName The name of the header
     * @return The header value or null if not found
     */
    public String getHeader(String headerName) {
        return this.headers.get(headerName);
    }
    
    /**
     * Get all query parameters
     * @return Map of parameter names to values
     */
    public Map<String, String> getUrlParams() {
        return this.urlParams;
    }
    
    /**
     * Get a specific query parameter value
     * @param variableName The name of the parameter
     * @return The parameter value or null if not found
     */
    public String getQueryParam(String variableName) {
        return this.urlParams.get(variableName);
    }
    
    /**
     * Get the raw request body
     * @return The request body as a string
     */
    public String getRequestBody() {
        return this.requestBody;
    }
    
    /**
     * Get all path parameters (populated by the matcher)
     * @return Map of path parameter names to values
     */
    public Map<String, String> getPathVariables() {
        return this.pathVariables;
    }
    
    /**
     * Set path parameters (used by the matcher)
     * @param pathVariables Map of path parameter variables to values
     */
    public void setPathVariables(Map<String, String> pathVariables) {
        this.pathVariables = pathVariables != null ? pathVariables : new Map<String, String>();
    }
    
    /**
     * Get a specific path parameter value
     * @param variableName The name of the path variable
     * @return The variable value or null if not found
     */
    public String getPathVariable(String variableName) {
        return this.pathVariables.get(variableName);
    }
}