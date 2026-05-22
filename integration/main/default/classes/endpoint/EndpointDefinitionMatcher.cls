/**
 * @description Matcher class that dynamically routes REST requests to appropriate handlers
 * based on Endpoint Definition metadata. Supports static and dynamic routes with path parameters.
 */
public class EndpointDefinitionMatcher {
    private List<Endpoint_Definition__mdt> endpointDefinitions;
    
    /**
     * @description Constructor that loads all active endpoint definitions
     */
    public EndpointDefinitionMatcher() {
        this.endpointDefinitions = [
            SELECT Id, DeveloperName, Endpoint_Pattern__c, Handler_Class__c,
                   Allowed_Methods__c, Success_Response_Code__c, 
                   Requires_Authentication__c, IsActive__c
            FROM Endpoint_Definition__mdt
            WHERE IsActive__c = true
            ORDER BY Priority__c ASC NULLS LAST
        ];
    }
    
    /**
     * @description Match an incoming request to an endpoint definition
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
     * @description Normalize the URI by removing query strings and extra slashes
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
     * @description Check if the HTTP method is allowed for this endpoint
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
     * @description Match a URI against a pattern and extract path parameters
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
    
    /**
     * @description Inner class representing the result of a match operation
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