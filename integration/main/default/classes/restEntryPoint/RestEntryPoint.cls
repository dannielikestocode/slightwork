/**
 * Main REST entry point that uses Endpoint Definition metadata to dynamically
 * route requests to appropriate handler classes. Supports dynamic routing 
 * with path parameters, query parameter parsing, and header extraction.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/integration/rest-entry-point.html
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_rest_intro.htm
 */
@RestResource(urlMapping='/*')
global with sharing class RestEntryPoint {
    /**
     * Constants
     */
    public static final String CHARSET_UTF8 = 'UTF-8';

    /**
     * Intercept and process HTTP POST requests
     */
    @HttpPost
    global static void doPost() {
        processRequest(HttpContext.POST_METHOD);
    }

    /**
     * Intercept and process HTTP GET requests
     */
    @HttpGet
    global static void doGet() {
        processRequest(HttpContext.GET_METHOD);
    }
    
    /**
     * Intercept and process HTTP PUT requests
     */
    @HttpPut
    global static void doPut() {
        processRequest(HttpContext.PUT_METHOD);
    }
    
    /**
     * Intercept and process HTTP PATCH requests
     */
    @HttpPatch
    global static void doPatch() {
        processRequest(HttpContext.PATCH_METHOD);
    }
    
    /**
     * Intercept and process HTTP DELETE requests
     */
    @HttpDelete
    global static void doDelete() {
        processRequest(HttpContext.DELETE_METHOD);
    }
    
    /**
     * Main request processing logic that routes to appropriate handlers
     * 
     * @param httpMethod The HTTP method being invoked
     */
    private static void processRequest(String httpMethod) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Extract request information
            String requestUri = req.requestURI;
            Map<String, String> headers = req.headers;
            Map<String, String> queryParams = req.params;
            String requestBody = req.requestBody?.toString();
            
            // Match the request to an endpoint definition
            EndpointDefinitionMatcher matcher = new EndpointDefinitionMatcher();
            EndpointMatchResult matchResult = matcher.match(requestUri, httpMethod);
            
            // Create request context
            RequestContext context = new RequestContext(
                headers,
                queryParams,
                requestBody,
                null
            );
            
            // Set path parameters from the match
            context.setPathVariables(matchResult.pathVariables);
            
            // Instantiate and invoke the handler
            Requestable handler = instantiateHandler(matchResult.definition.Handler_Class__c);
            if (handler == null) {
                sendError(res, 500, 'Handler class not found or invalid: ' + matchResult.definition.Handler_Class__c);
                return;
            }
            
            // Delegate to appropriate handler method based on HTTP verb
            invokeHandler(handler, httpMethod, context);
            
            // Set success response code if not already set by handler
            if (res.statusCode == null) {
                Integer successCode = matchResult.definition.Success_Response_Code__c?.intValue();
                res.statusCode = successCode != null ? successCode : 200;
            }
            
        }
        catch (RestException e) {
            // TODO: Implement
        } 
        catch (Exception e) {
            sendError(res, 500, 'Internal server error: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, 'RestEntryPoint error: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    /**
     * Instantiate a handler class by name
     * @param className The fully qualified class name
     * @return Instance of Requestable or null if instantiation fails
     */
    private static Requestable instantiateHandler(String className) {
        try {
            Type handlerType = Type.forName(className);
            if (handlerType == null) {
                return null;
            }
            
            Object handlerInstance = handlerType.newInstance();
            if (!(handlerInstance instanceof Requestable)) {
                System.debug(LoggingLevel.ERROR, 'Handler class does not implement Requestable: ' + className);
                return null;
            }
            
            return (Requestable) handlerInstance;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error instantiating handler: ' + className + ' - ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * Invoke the appropriate handler method based on HTTP verb
     * @param handler The handler instance
     * @param httpMethod The HTTP method
     * @param context The request context
     */
    private static void invokeHandler(Requestable handler, String httpMethod, RequestContext context) {
        switch on httpMethod.toUpperCase() {
            when 'POST' {
                handler.handlePost(context);
            }
            when 'GET' {
                handler.handleGet(context);
            }
            when 'PUT' {
                handler.handlePut(context);
            }
            when 'PATCH' {
                handler.handlePatch(context);
            }
            when 'DELETE' {
                handler.handleDelete(context);
            }
            when else {
                throw new IllegalArgumentException('Unsupported HTTP method: ' + httpMethod);
            }
        }
    }
    
    /**
     * Send an error response
     * @param res The RestResponse to populate
     * @param statusCode HTTP status code
     * @param message Error message
     */
    private static void sendError(RestResponse res, Integer statusCode, String message) {
        res.statusCode = statusCode;
        res.addHeader('Content-Type', 'application/json');
        
        Map<String, Object> errorResponse = new Map<String, Object>{
            'error' => true,
            'message' => message,
            'statusCode' => statusCode,
            'timestamp' => DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
        };
        
        res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
    }

    /**
     * Inner class that handles matching endpoints from a REST request to an 
     * Endpoint Definition for logic delegation. Supports static and dynamic
     * routes with path parameters.
     */
    public without sharing class EndpointDefinitionMatcher {
        /**
         * Properties
         */
        private final Map<String, Endpoint_Definition__mdt> endpointDefinitions = Endpoint_Definition__mdt.getAll();
        
        /**
         * Matches an incoming request to an endpoint definition
         * 
         * @param requestUri The request URI path
         * @param httpMethod The HTTP method (GET, POST, etc.)
         * @return The result containing the matched definition and path parameters
         */
        public EndpointMatchResult match(String requestUri, String httpMethod) {
            String normalizedRequestUri = normalizeUri(requestUri);
            EndpointMatchResult result;
            for (Endpoint_Definition__mdt endpointDefinition : this.endpointDefinitions.values()) {
                if (endpointDefinition.Is_Active__c != null) {
                    continue;
                }

                // Attempt to find a matching endpoint definition
                result = matchEndpointDefinition(
                    endpointDefinition,
                    normalizedRequestUri
                );

                // Only break when a result is found. Otherwise, continue
                // evaluating other definitions to find a match
                if (result != null) {
                    if (!isMethodAllowed(endpointDefinition, httpMethod)) {
                        throw new RestException('Method not allowed for endpoint', HttpContext.StatusCode.HTTP_METHOD_NOT_ALLOWED);
                    }
                    break;
                }
            }
            
            if (result == null) {
                throw new RestException('Endpoint not found or is invalid', HttpContext.StatusCode.HTTP_NOT_FOUND);
            }
            return result;
        }
        
        /**
         * Normalize the URI by removing query strings and extra slashes
         * 
         * @param uri The raw URI
         * @return Normalized URI (E.g., /resources?key=value => resources)
         */
        private String normalizeUri(String uri) {
            // Remove query string
            Integer queryIndex = uri.indexOf('?');
            if (queryIndex > -1) {
                uri = uri.substring(0, queryIndex);
            }
            
            // Remove leading and trailing slashes
            uri = uri.trim();
            if (uri.startsWith('/')) {
                uri = uri.substring(1);
            }

            if (uri.endsWith('/')) {
                uri = uri.substring(0, uri.length() - 1);
            }
            return uri;
        }

        /**
         * Match a URI against a pattern and extract path parameters
         * Pattern syntax:
         *   - Static segments: /api/users
         *   - Dynamic segments: /api/users/{id}
         *   - Multiple params: /api/users/{userId}/posts/{postId}
         * 
         * @param endpointPattern The endpoint pattern from the definition metadata
         * @param normalizedRequestUri The normalized uri of the request
         * @return Map of path parameter names to values, or null if no match
         */
        private EndpointMatchResult matchEndpointDefinition(Endpoint_Definition__mdt endpointDefinition, String normalizedRequestUri) {
            // Normalize the endpoint pattern
            String normalizedEndpointPattern = normalizeUri(endpointDefinition.Endpoint_Pattern__c);
            
            // Split both pattern and URI into segments
            List<String> endpointDefinitionSegments = normalizedEndpointPattern.split('/');
            List<String> requestUriSegments = normalizedRequestUri.split('/');
            
            // Must have same number of segments to match
            if (endpointDefinitionSegments.size() != requestUriSegments.size()) {
                return null;
            }
            
            // Match each part
            Map<String, String> pathVariables = new Map<String, String>();
            for (Integer i = 0; i < endpointDefinitionSegments.size(); i++) {
                String endpointDefinitionSegment = endpointDefinitionSegments[i];
                String requestUriSegment = requestUriSegments[i];
                
                // Check if this is a dynamic part (enclosed in curly braces)
                if (endpointDefinitionSegment.startsWith('{') && endpointDefinitionSegment.endsWith('}')) {
                    // Extract path variable from segment
                    String pathVariableName = endpointDefinitionSegment.substring(1, endpointDefinitionSegment.length() - 1);
                    pathVariables.put(pathVariableName, EncodingUtil.urlDecode(requestUriSegment, CHARSET_UTF8));
                } else {
                    // Static segment must match exactly (case-insensitive)
                    if (!endpointDefinitionSegment.equalsIgnoreCase(requestUriSegment)) {
                        return null;
                    }
                }
            }
            return new EndpointMatchResult(endpointDefinition, pathVariables);
        }
        
        /**
         * Check if the HTTP method is allowed for this endpoint
         * 
         * @param definition The endpoint definition
         * @param httpMethod The HTTP method to check
         * @return True if the method is allowed
         */
        private Boolean isMethodAllowed(Endpoint_Definition__mdt definition, String httpMethod) {
            if (httpMethod == HttpContext.POST_METHOD && definition.POST_Enabled__c == true) {
                return true;
            }
            else if (httpMethod == HttpContext.GET_METHOD && definition.GET_Enabled__c == true) {
                return true;
            }
            else if (httpMethod == HttpContext.PUT_METHOD && definition.PUT_Enabled__c == true) {
                return true;
            }
            else if (httpMethod == HttpContext.PATCH_METHOD && definition.PATCH_Enabled__c == true) {
                return true;
            }
            else if (httpMethod == HttpContext.DELETE_METHOD && definition.DELETE_Enabled__c == true) {
                return true;
            }
            return false;
        }
    }

    /**
     * Inner class representing the result of an endpoint match operation
     */
    public without sharing class EndpointMatchResult {
        /**
         * Properties
         */
        public final Endpoint_Definition__mdt definition { get; private set; }
        public final Map<String, String> pathVariables { get; private set; }
        
        /**
         * Constructor with args
         * 
         * @param definition The matched endpoint definition record
         * @param pathVariables The variables extracted from the endpoint path
         */
        public EndpointMatchResult(Endpoint_Definition__mdt definition, Map<String, String> pathVariables) {
            this.definition = definition;
            this.pathVariables = pathVariables;
        }
    }
}
