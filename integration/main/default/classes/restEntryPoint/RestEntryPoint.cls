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
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        try {
            // Match the request to an endpoint definition
            EndpointDefinitionMatcher matcher = new EndpointDefinitionMatcher();
            EndpointMatchResult matchResult = matcher.match(request.requestURI, httpMethod);
            
            // Instantiate and invoke the handler
            Requestable handler = instantiateHandler(matchResult.definition.Handler_Class__c);
            invokeHandler(handler, httpMethod, request, response, matchResult);
        }
        catch(JSONException e) {
            setErrorResponse(response, 400, e.getMessage());
            System.debug(LoggingLevel.ERROR, 'JSON deserialization error: ' + e.getMessage());
        }
        catch(RestException e) {
            setErrorResponse(response, e.statusCode, e.getMessage());
            System.debug(LoggingLevel.ERROR, 'RestEntryPoint error: ' + e.getMessage());
        } 
        catch(Exception e) {
            setErrorResponse(response, 500, 'Internal Server Error');
            System.debug(LoggingLevel.ERROR, 'RestEntryPoint error: ' + e.getMessage());
        }
    }
    
    /**
     * Instantiates a handler class of the Requestable interface
     * 
     * @param className The fully qualified class name
     * @return Instance of Requestable
     * @throws RestException when an invalid class is provided
     */
    private static Requestable instantiateHandler(String className) {
        Type handlerType = Type.forName(String.isNotBlank(className) ? className : '');
        if (handlerType == null) {
            // NHF = No Handler Found
            throw new RestException('Internal Server Error (NHF)', HttpContext.StatusCode.HTTP_INTERNAL_SERVER_ERROR);
        }
        
        Object handlerInstance = handlerType.newInstance();
        if (!(handlerInstance instanceof Requestable)) {
            // INH = Invalid Handler
            throw new RestException('Internal Server Error (INH)', HttpContext.StatusCode.HTTP_INTERNAL_SERVER_ERROR);
        }
        return (Requestable)handlerInstance;
    }
    
    /**
     * Invoke the appropriate handler method based on HTTP verb
     * 
     * @param handler The handler instance
     * @param httpMethod The HTTP method
     * @param request The REST request context
     * @param response The REST response context
     * @param pathVariables The path variables extracted from the endpoint path
     * @throws IllegalArgumentException when an invalid HTTP method is provided
     */
    private static void invokeHandler(
        Requestable handler, 
        String httpMethod,
        RestRequest request,
        RestResponse response,
        EndpointMatchResult matchResult
    ) {
        switch on httpMethod.toUpperCase() {
            when 'POST' {
                handler.handlePost(request, response, matchResult.definition, matchResult.pathVariables);
            }
            when 'GET' {
                handler.handleGet(request, response, matchResult.definition, matchResult.pathVariables);
            }
            when 'PUT' {
                handler.handlePut(request, response, matchResult.definition, matchResult.pathVariables);
            }
            when 'PATCH' {
                handler.handlePatch(request, response, matchResult.definition, matchResult.pathVariables);
            }
            when 'DELETE' {
                handler.handleDelete(request, response, matchResult.definition, matchResult.pathVariables);
            }
            when else {
                throw new IllegalArgumentException('Unsupported HTTP method: ' + httpMethod);
            }
        }
    }
    
    /**
     * Sends an error response as a collection of objects,
     * following the Salesforce format.
     * 
     * @param response The RestResponse to populate
     * @param statusCode HTTP status code
     * @param message Error message
     */
    private static void setErrorResponse(RestResponse response, Integer statusCode, String message) {
        response.statusCode = statusCode == null ? 500 : statusCode;
        response.addHeader('Content-Type', 'application/json');
        Map<String, Object> errorResponse = new Map<String, Object>{
            'error' => message
        };
        response.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
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
         * @throws RestException for an unsupported HTTP method or an endpoint definition cannot be matched
         */
        public EndpointMatchResult match(String requestUri, String httpMethod) {
            String normalizedRequestUri = normalizeUri(requestUri);
            List<EndpointMatchResult> matchedEndpoints = new List<EndpointMatchResult>();
            for (Endpoint_Definition__mdt endpointDefinition : this.endpointDefinitions.values()) {
                // Active endpoints only
                if (endpointDefinition.Is_Active__c != true) {
                    continue;
                }

                // Attempt to find a all matching endpoint definitions and add
                // them to the collection
                EndpointMatchResult matchedEndpoint = matchEndpointDefinition(endpointDefinition, normalizedRequestUri);
                if (matchedEndpoint != null) {
                    matchedEndpoints.add(matchedEndpoint);
                }
            }
            
            // Final endpoint resolution is based on the
            // HTTP method, which means there cannot be
            // multiple endpoints with the same pattern
            // and HTTP method
            EndpointMatchResult finalEndpoint;
            if (matchedEndpoints.isEmpty()) {
                throw new RestException('Endpoint not found or is invalid', HttpContext.StatusCode.HTTP_NOT_FOUND);
            }
            else {
                for (EndpointMatchResult matchedEndpoint: matchedEndpoints) {
                    if (httpMethod.equalsIgnoreCase(matchedEndpoint.definition.Http_Method__c)) {
                        finalEndpoint = matchedEndpoint;
                        break;
                    }
                }
            }

            if (finalEndpoint == null) {
                throw new RestException('Method not allowed for endpoint', HttpContext.StatusCode.HTTP_METHOD_NOT_ALLOWED);
            }
            return finalEndpoint;
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
