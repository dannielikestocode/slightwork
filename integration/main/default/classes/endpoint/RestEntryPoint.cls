/**
 * @description Main REST entry point that uses Endpoint Definition metadata to dynamically
 * route requests to appropriate handler classes. Supports dynamic routing with path parameters,
 * query parameter parsing, and header extraction.
 * 
 * @RestResource urlMapping='/api/*'
 */
@RestResource(urlMapping='/api/*')
global without sharing class RestEntryPoint {
    
    /**
     * @description Handle HTTP GET requests
     */
    @HttpGet
    global static void doGet() {
        processRequest('GET');
    }
    
    /**
     * @description Handle HTTP POST requests
     */
    @HttpPost
    global static void doPost() {
        processRequest('POST');
    }
    
    /**
     * @description Handle HTTP PUT requests
     */
    @HttpPut
    global static void doPut() {
        processRequest('PUT');
    }
    
    /**
     * @description Handle HTTP PATCH requests
     */
    @HttpPatch
    global static void doPatch() {
        processRequest('PATCH');
    }
    
    /**
     * @description Handle HTTP DELETE requests
     */
    @HttpDelete
    global static void doDelete() {
        processRequest('DELETE');
    }
    
    /**
     * @description Main request processing logic that routes to appropriate handlers
     * @param httpMethod The HTTP method being invoked
     */
    private static void processRequest(String httpMethod) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            // Extract request information
            String requestUri = req.requestURI;
            Map<String, String> headers = parseHeaders(req.headers);
            Map<String, String> queryParams = parseQueryParameters(req.params);
            String requestBody = req.requestBody?.toString();
            
            // Match the request to an endpoint definition
            EndpointDefinitionMatcher matcher = new EndpointDefinitionMatcher();
            EndpointDefinitionMatcher.MatchResult matchResult = matcher.match(requestUri, httpMethod);
            
            if (matchResult == null) {
                sendError(res, 404, 'Endpoint not found');
                return;
            }
            
            // Create request context
            RequestContext context = new RequestContext(
                headers,
                queryParams,
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
     * @description Parse HTTP headers into a map
     * @param headers Map of header names to lists of values
     * @return Map of header names to single string values (first value if multiple)
     */
    private static Map<String, String> parseHeaders(Map<String, String> headers) {
        Map<String, String> parsedHeaders = new Map<String, String>();
        
        if (headers == null) {
            return parsedHeaders;
        }
        
        for (String headerName : headers.keySet()) {
            String headerValue = headers.get(headerName);
            if (headerValue != null) {
                parsedHeaders.put(headerName.toLowerCase(), headerValue);
            }
        }
        
        return parsedHeaders;
    }
    
    /**
     * @description Parse query parameters into a map
     * @param params Map of parameter names to lists of values
     * @return Map of parameter names to single string values (first value if multiple)
     */
    private static Map<String, String> parseQueryParameters(Map<String, String> params) {
        Map<String, String> parsedParams = new Map<String, String>();
        
        if (params == null) {
            return parsedParams;
        }
        
        for (String paramName : params.keySet()) {
            String paramValue = params.get(paramName);
            if (paramValue != null) {
                parsedParams.put(paramName, paramValue);
            }
        }
        
        return parsedParams;
    }
    
    /**
     * @description Instantiate a handler class by name
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
     * @description Invoke the appropriate handler method based on HTTP verb
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
     * @description Send an error response
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
}