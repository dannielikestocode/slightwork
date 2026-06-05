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
     * Intercept and process HTTP POST requests
     */
    @HttpPost
    global static void doPost() {
        processRequest('POST');
    }

    /**
     * Intercept and process HTTP GET requests
     */
    @HttpGet
    global static void doGet() {
        processRequest('GET');
    }
    
    /**
     * Intercept and process HTTP PUT requests
     */
    @HttpPut
    global static void doPut() {
        processRequest('PUT');
    }
    
    /**
     * Intercept and process HTTP PATCH requests
     */
    @HttpPatch
    global static void doPatch() {
        processRequest('PATCH');
    }
    
    /**
     * Intercept and process HTTP DELETE requests
     */
    @HttpDelete
    global static void doDelete() {
        processRequest('DELETE');
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
            Map<String, String> urlParams = req.params;
            String requestBody = req.requestBody?.toString();
            
            // Match the request to an endpoint definition
            EndpointDefinitionMatcher matcher = new EndpointDefinitionMatcher();
            MatchResult matchResult = matcher.match(requestUri, httpMethod);
            
            if (matchResult == null) {
                sendError(res, 404, 'Endpoint not found');
                return;
            }
            
            // Create request context
            RequestContext context = new RequestContext(
                headers,
                urlParams,
                requestBody,
                null
            );
            
            // Set path parameters from the match
            context.setPathParams(matchResult.pathParams);
            
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
            
        } catch (Exception e) {
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
            when 'GET' {
                handler.handleGet(context);
            }
            when 'POST' {
                handler.handlePost(context);
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
     * Matcher class that dynamically routes REST requests to appropriate handlers
     * based on Endpoint Definition metadata. Supports static and dynamic routes with path parameters.
     */
    public without sharing class EndpointDefinitionMatcher {
        private List<Endpoint_Definition__mdt> endpointDefinitions;
        
        /**
         * Constructor that loads all active endpoint definitions
         */
        public EndpointDefinitionMatcher() {
            this.endpointDefinitions = [
                SELECT Id, DeveloperName, Endpoint_Pattern__c, Handler_Class__c,
                    Success_Response_Code__c, 
                    IsActive__c
                FROM Endpoint_Definition__mdt
                WHERE IsActive__c = true
            ];
        }
        
        /**
         * Match an incoming request to an endpoint definition
         * @param requestUri The request URI path
         * @param httpMethod The HTTP method (GET, POST, etc.)
         * @return MatchResult containing the matched definition and path parameters
         */
        public MatchResult match(String requestUri, String httpMethod) {
            if (String.isBlank(requestUri) || String.isBlank(httpMethod)) {
                return null;
            }
            
            // Normalize the URI (remove leading/trailing slashes, query strings)
            String normalizedUri = normalizeUri(requestUri);
            
            for (Endpoint_Definition__mdt definition : endpointDefinitions) {
                // Check if the HTTP method is allowed
                if (!isMethodAllowed(definition, httpMethod)) {
                    continue;
                }
                
                // Try to match the URI pattern
                Map<String, String> pathParams = matchPattern(
                    definition.Endpoint_Pattern__c,
                    normalizedUri
                );
                
                if (pathParams != null) {
                    return new MatchResult(definition, pathParams);
                }
            }
            
            return null;
        }
        
        /**
         * Normalize the URI by removing query strings and extra slashes
         * @param uri The raw URI
         * @return Normalized URI
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
         * Check if the HTTP method is allowed for this endpoint
         * @param definition The endpoint definition
         * @param httpMethod The HTTP method to check
         * @return True if the method is allowed
         */
        private Boolean isMethodAllowed(Endpoint_Definition__mdt definition, String httpMethod) {
            if (String.isBlank(definition.Allowed_Methods__c)) {
                return true; // If not specified, allow all methods
            }
            
            List<String> allowedMethods = definition.Allowed_Methods__c.split('[,;]');
            for (String method : allowedMethods) {
                if (method.trim().equalsIgnoreCase(httpMethod)) {
                    return true;
                }
            }
            
            return false;
        }
        
        /**
         * Match a URI against a pattern and extract path parameters
         * Pattern syntax:
         *   - Static segments: /api/users
         *   - Dynamic segments: /api/users/{id}
         *   - Multiple params: /api/users/{userId}/posts/{postId}
         * @param pattern The endpoint pattern from metadata
         * @param uri The actual request URI
         * @return Map of path parameter names to values, or null if no match
         */
        private Map<String, String> matchPattern(String pattern, String uri) {
            if (String.isBlank(pattern)) {
                return null;
            }
            
            Map<String, String> pathParams = new Map<String, String>();
            
            // Normalize pattern
            pattern = normalizeUri(pattern);
            
            // Split both pattern and URI into segments
            List<String> patternSegments = pattern.split('/');
            List<String> uriSegments = uri.split('/');
            
            // Must have same number of segments to match
            if (patternSegments.size() != uriSegments.size()) {
                return null;
            }
            
            // Match each segment
            for (Integer i = 0; i < patternSegments.size(); i++) {
                String patternSegment = patternSegments[i];
                String uriSegment = uriSegments[i];
                
                // Check if this is a dynamic segment (enclosed in curly braces)
                if (patternSegment.startsWith('{') && patternSegment.endsWith('}')) {
                    // Extract parameter name and store value
                    String paramName = patternSegment.substring(1, patternSegment.length() - 1);
                    pathParams.put(paramName, EncodingUtil.urlDecode(uriSegment, 'UTF-8'));
                } else {
                    // Static segment must match exactly (case-insensitive)
                    if (!patternSegment.equalsIgnoreCase(uriSegment)) {
                        return null;
                    }
                }
            }
            
            return pathParams;
        }
    }

    /**
     * Inner class representing the result of a match operation
     */
    public class MatchResult {
        public Endpoint_Definition__mdt definition { get; private set; }
        public Map<String, String> pathParams { get; private set; }
        
        public MatchResult(Endpoint_Definition__mdt definition, Map<String, String> pathParams) {
            this.definition = definition;
            this.pathParams = pathParams;
        }
    }
}
