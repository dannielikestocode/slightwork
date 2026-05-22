/**
 * Fluent API manager for building and executing HTTP callouts in Salesforce.
 * Provides a builder pattern for constructing HttpRequest instances with support for:
 * - Named Credentials
 * - Custom Metadata Configuration
 * - Query Parameters
 * - Request/Response Capture
 * 
 * @author Agentforce
 * @since v66.0
 * @see HttpRequest
 * @see HttpResponse
 */
public inherited sharing class CalloutManager {
    
    // ─── Core Properties ─────────────────────────────────────────────────
    
    private String endpoint;
    private String method;
    private String body;
    private Map<String, String> headers;
    private Map<String, String> queryParams;
    private Integer timeout;
    private Boolean compressed;
    private String clientCertificateName;
    private Boolean captureRequestData;
    private String namedCredential;
    
    // ─── Constants ───────────────────────────────────────────────────────
    
    private static final Integer DEFAULT_TIMEOUT = 120000; // 120 seconds
    private static final String NAMED_CREDENTIAL_PREFIX = 'callout:';
    
    // ─── Constructor ─────────────────────────────────────────────────────
    
    /**
     * Creates a new CalloutManager instance.
     * All configuration is performed via the fluent builder methods.
     */
    public CalloutManager() {
        this.headers = new Map<String, String>();
        this.queryParams = new Map<String, String>();
        this.timeout = DEFAULT_TIMEOUT;
        this.compressed = false;
        this.captureRequestData = false;
        this.method = 'GET';
    }
    
    // ─── Builder Methods: Core Configuration ────────────────────────────
    
    /**
     * Sets the endpoint URL for the callout.
     * Can be a full URL or a path when using Named Credentials.
     * 
     * @param endpoint The endpoint URL or path
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if endpoint is blank
     * @example
     * manager.withEndpoint('https://api.example.com/v1/users');
     */
    public CalloutManager withEndpoint(String endpoint) {
        if (String.isBlank(endpoint)) {
            throw new IllegalArgumentException('Endpoint cannot be blank');
        }
        this.endpoint = endpoint;
        return this;
    }
    
    /**
     * Sets the HTTP method for the request.
     * 
     * @param method The HTTP method (GET, POST, PUT, PATCH, DELETE, etc.)
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if method is blank
     * @example
     * manager.withMethod('POST');
     */
    public CalloutManager withMethod(String method) {
        if (String.isBlank(method)) {
            throw new IllegalArgumentException('Method cannot be blank');
        }
        this.method = method.toUpperCase();
        return this;
    }
    
    /**
     * Sets the request body.
     * 
     * @param body The request body (JSON, XML, or other format)
     * @return This builder instance for method chaining
     * @example
     * manager.withBody('{"name": "John Doe"}');
     */
    public CalloutManager withBody(String body) {
        this.body = body;
        return this;
    }
    
    /**
     * Sets the timeout in milliseconds.
     * Maximum allowed is 120,000 milliseconds (120 seconds).
     * 
     * @param timeout Timeout in milliseconds
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if timeout is invalid
     * @example
     * manager.withTimeout(60000); // 60 seconds
     */
    public CalloutManager withTimeout(Integer timeout) {
        if (timeout == null || timeout <= 0 || timeout > 120000) {
            throw new IllegalArgumentException('Timeout must be between 1 and 120000 milliseconds');
        }
        this.timeout = timeout;
        return this;
    }
    
    /**
     * Enables or disables GZIP compression for the request.
     * 
     * @param compressed True to enable compression
     * @return This builder instance for method chaining
     * @example
     * manager.withCompression(true);
     */
    public CalloutManager withCompression(Boolean compressed) {
        this.compressed = compressed != null ? compressed : false;
        return this;
    }
    
    /**
     * Sets the client certificate name for mutual SSL authentication.
     * 
     * @param certificateName The name of the certificate in Salesforce
     * @return This builder instance for method chaining
     * @example
     * manager.withClientCertificate('MyCertificate');
     */
    public CalloutManager withClientCertificate(String certificateName) {
        this.clientCertificateName = certificateName;
        return this;
    }
    
    // ─── Builder Methods: Headers ────────────────────────────────────────
    
    /**
     * Adds a single HTTP header to the request.
     * 
     * @param name The header name
     * @param value The header value
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if name or value is blank
     * @example
     * manager.withHeader('Content-Type', 'application/json');
     */
    public CalloutManager withHeader(String name, String value) {
        if (String.isBlank(name)) {
            throw new IllegalArgumentException('Header name cannot be blank');
        }
        if (String.isBlank(value)) {
            throw new IllegalArgumentException('Header value cannot be blank');
        }
        this.headers.put(name, value);
        return this;
    }
    
    /**
     * Adds multiple HTTP headers to the request.
     * 
     * @param headers Map of header names to values
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if headers is null or empty
     * @example
     * manager.withHeaders(new Map<String, String>{
     *     'Content-Type' => 'application/json',
     *     'Accept' => 'application/json'
     * });
     */
    public CalloutManager withHeaders(Map<String, String> headers) {
        if (headers == null || headers.isEmpty()) {
            throw new IllegalArgumentException('Headers cannot be null or empty');
        }
        this.headers.putAll(headers);
        return this;
    }
    
    /**
     * Convenience method to set Content-Type header.
     * 
     * @param contentType The content type value
     * @return This builder instance for method chaining
     * @example
     * manager.withContentType('application/json');
     */
    public CalloutManager withContentType(String contentType) {
        return withHeader('Content-Type', contentType);
    }
    
    /**
     * Convenience method to set Accept header.
     * 
     * @param accept The accept value
     * @return This builder instance for method chaining
     * @example
     * manager.withAccept('application/json');
     */
    public CalloutManager withAccept(String accept) {
        return withHeader('Accept', accept);
    }
    
    /**
     * Convenience method to set Authorization header.
     * 
     * @param token The authorization token (Bearer, Basic, etc.)
     * @return This builder instance for method chaining
     * @example
     * manager.withAuthorization('Bearer abc123token');
     */
    public CalloutManager withAuthorization(String token) {
        return withHeader('Authorization', token);
    }
    
    // ─── Builder Methods: Query Parameters ───────────────────────────────
    
    /**
     * Adds a single query parameter to the endpoint URL.
     * Parameters are automatically URL-encoded.
     * 
     * @param name The parameter name
     * @param value The parameter value
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if name is blank
     * @example
     * manager.withQueryParam('page', '1');
     */
    public CalloutManager withQueryParam(String name, String value) {
        if (String.isBlank(name)) {
            throw new IllegalArgumentException('Query parameter name cannot be blank');
        }
        if (value != null) {
            this.queryParams.put(name, value);
        }
        return this;
    }
    
    /**
     * Adds multiple query parameters to the endpoint URL.
     * Parameters are automatically URL-encoded.
     * 
     * @param params Map of parameter names to values
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if params is null or empty
     * @example
     * manager.withQueryParams(new Map<String, String>{
     *     'page' => '1',
     *     'limit' => '50',
     *     'sort' => 'name'
     * });
     */
    public CalloutManager withQueryParams(Map<String, String> params) {
        if (params == null || params.isEmpty()) {
            throw new IllegalArgumentException('Query parameters cannot be null or empty');
        }
        this.queryParams.putAll(params);
        return this;
    }
    
    // ─── Builder Methods: Named Credentials ──────────────────────────────
    
    /**
     * Configures the callout to use a Named Credential.
     * The Named Credential handles authentication and base URL.
     * 
     * @param credentialName The developer name of the Named Credential
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if credentialName is blank
     * @example
     * manager.withNamedCredential('MyAPICredential')
     *        .withEndpoint('/users/123');
     */
    public CalloutManager withNamedCredential(String credentialName) {
        if (String.isBlank(credentialName)) {
            throw new IllegalArgumentException('Named credential name cannot be blank');
        }
        this.namedCredential = credentialName;
        return this;
    }
    
    // ─── Builder Methods: Custom Metadata Configuration ──────────────────
    
    /**
     * Configures the callout using a Callout_Configuration__mdt record.
     * This allows for externalized configuration management.
     * 
     * @param configName The developer name of the custom metadata record
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if configName is blank or record not found
     * @example
     * manager.withConfiguration('UserAPI_GetUser')
     *        .withQueryParam('id', '123');
     */
    public CalloutManager withConfiguration(String configName) {
        if (String.isBlank(configName)) {
            throw new IllegalArgumentException('Configuration name cannot be blank');
        }
        
        List<Callout_Configuration__mdt> configs = [
            SELECT Id, DeveloperName, Endpoint__c, Method__c, Timeout__c, 
                   Named_Credential__c, Content_Type__c, Accept__c,
                   Compressed__c, Client_Certificate__c
            FROM Callout_Configuration__mdt
            WHERE DeveloperName = :configName
            LIMIT 1
        ];
        
        if (configs.isEmpty()) {
            throw new IllegalArgumentException('Configuration not found: ' + configName);
        }
        
        Callout_Configuration__mdt config = configs[0];
        
        // Apply configuration settings
        if (String.isNotBlank(config.Endpoint__c)) {
            this.endpoint = config.Endpoint__c;
        }
        if (String.isNotBlank(config.Method__c)) {
            this.method = config.Method__c.toUpperCase();
        }
        if (config.Timeout__c != null) {
            this.timeout = Integer.valueOf(config.Timeout__c);
        }
        if (String.isNotBlank(config.Named_Credential__c)) {
            this.namedCredential = config.Named_Credential__c;
        }
        if (String.isNotBlank(config.Content_Type__c)) {
            withHeader('Content-Type', config.Content_Type__c);
        }
        if (String.isNotBlank(config.Accept__c)) {
            withHeader('Accept', config.Accept__c);
        }
        if (config.Compressed__c != null) {
            this.compressed = config.Compressed__c;
        }
        if (String.isNotBlank(config.Client_Certificate__c)) {
            this.clientCertificateName = config.Client_Certificate__c;
        }
        
        return this;
    }
    
    // ─── Builder Methods: Request Capture ────────────────────────────────
    
    /**
     * Enables capturing of request data in the CalloutResult.
     * When enabled, the result will include request details for debugging/logging.
     * 
     * @param capture True to enable request capture
     * @return This builder instance for method chaining
     * @example
     * manager.withRequestCapture(true);
     */
    public CalloutManager withRequestCapture(Boolean capture) {
        this.captureRequestData = capture != null ? capture : false;
        return this;
    }
    
    // ─── Build & Execute Methods ─────────────────────────────────────────
    
    /**
     * Builds and returns the configured HttpRequest instance.
     * Does not execute the callout - use execute() for that.
     * 
     * @return A configured HttpRequest instance
     * @throws IllegalStateException if required fields are missing
     * @example
     * HttpRequest request = manager.build();
     */
    public HttpRequest build() {
        validateRequiredFields();
        
        HttpRequest request = new HttpRequest();
        
        // Set endpoint with Named Credential prefix if applicable
        String finalEndpoint = buildFinalEndpoint();
        request.setEndpoint(finalEndpoint);
        
        // Set method and timeout
        request.setMethod(this.method);
        request.setTimeout(this.timeout);
        
        // Set body if provided
        if (String.isNotBlank(this.body)) {
            request.setBody(this.body);
        }
        
        // Set compression
        request.setCompressed(this.compressed);
        
        // Set client certificate if provided
        if (String.isNotBlank(this.clientCertificateName)) {
            request.setClientCertificateName(this.clientCertificateName);
        }
        
        // Set headers
        for (String headerName : this.headers.keySet()) {
            request.setHeader(headerName, this.headers.get(headerName));
        }
        
        return request;
    }
    
    /**
     * Builds and executes the HTTP callout, returning a CalloutResult.
     * The result includes response data and optionally request data if capture is enabled.
     * 
     * @return A CalloutResult containing the response and optional request data
     * @throws CalloutException if the HTTP callout fails
     * @example
     * CalloutResult result = manager
     *     .withNamedCredential('MyAPI')
     *     .withEndpoint('/users')
     *     .withMethod('GET')
     *     .withRequestCapture(true)
     *     .execute();
     */
    public CalloutResult execute() {
        HttpRequest request = build();
        
        Http http = new Http();
        HttpResponse response;
        
        try {
            response = http.send(request);
        } catch (Exception e) {
            throw new CalloutException('Callout failed: ' + e.getMessage(), e);
        }
        
        return new CalloutResult(request, response, this.captureRequestData);
    }
    
    // ─── Validation & Helper Methods ─────────────────────────────────────
    
    /**
     * Validates that all required fields are set before building.
     * 
     * @throws IllegalStateException if any required field is missing
     */
    private void validateRequiredFields() {
        List<String> missingFields = new List<String>();
        
        if (String.isBlank(this.endpoint)) {
            missingFields.add('endpoint');
        }
        if (String.isBlank(this.method)) {
            missingFields.add('method');
        }
        
        if (!missingFields.isEmpty()) {
            throw new IllegalStateException(
                'Cannot build request. Missing required fields: ' + 
                String.join(missingFields, ', ')
            );
        }
    }
    
    /**
     * Builds the final endpoint URL with Named Credential prefix and query parameters.
     * 
     * @return The complete endpoint URL
     */
    private String buildFinalEndpoint() {
        String finalEndpoint = this.endpoint;
        
        // Add Named Credential prefix if specified
        if (String.isNotBlank(this.namedCredential)) {
            if (!finalEndpoint.startsWith(NAMED_CREDENTIAL_PREFIX)) {
                finalEndpoint = NAMED_CREDENTIAL_PREFIX + this.namedCredential + finalEndpoint;
            }
        }
        
        // Add query parameters if any
        if (!this.queryParams.isEmpty()) {
            String queryString = buildQueryString();
            String separator = finalEndpoint.contains('?') ? '&' : '?';
            finalEndpoint += separator + queryString;
        }
        
        return finalEndpoint;
    }
    
    /**
     * Builds the query string from the query parameters map.
     * Parameters are URL-encoded.
     * 
     * @return The encoded query string
     */
    private String buildQueryString() {
        List<String> params = new List<String>();
        
        for (String key : this.queryParams.keySet()) {
            String value = this.queryParams.get(key);
            String encodedKey = EncodingUtil.urlEncode(key, 'UTF-8');
            String encodedValue = EncodingUtil.urlEncode(value, 'UTF-8');
            params.add(encodedKey + '=' + encodedValue);
        }
        
        return String.join(params, '&');
    }
    
    // ─── Static Factory Methods ──────────────────────────────────────────
    
    /**
     * Creates a new CalloutManager instance for a GET request.
     * 
     * @param endpoint The endpoint URL
     * @return A new CalloutManager instance
     * @example
     * CalloutResult result = CalloutManager.get('https://api.example.com/users').execute();
     */
    public static CalloutManager get(String endpoint) {
        return new CalloutManager()
            .withEndpoint(endpoint)
            .withMethod('GET');
    }
    
    /**
     * Creates a new CalloutManager instance for a POST request.
     * 
     * @param endpoint The endpoint URL
     * @return A new CalloutManager instance
     * @example
     * CalloutResult result = CalloutManager.post('https://api.example.com/users')
     *     .withBody('{"name": "John"}')
     *     .execute();
     */
    public static CalloutManager post(String endpoint) {
        return new CalloutManager()
            .withEndpoint(endpoint)
            .withMethod('POST');
    }
    
    /**
     * Creates a new CalloutManager instance for a PUT request.
     * 
     * @param endpoint The endpoint URL
     * @return A new CalloutManager instance
     */
    public static CalloutManager put(String endpoint) {
        return new CalloutManager()
            .withEndpoint(endpoint)
            .withMethod('PUT');
    }
    
    /**
     * Creates a new CalloutManager instance for a PATCH request.
     * 
     * @param endpoint The endpoint URL
     * @return A new CalloutManager instance
     */
    public static CalloutManager patch(String endpoint) {
        return new CalloutManager()
            .withEndpoint(endpoint)
            .withMethod('PATCH');
    }
    
    /**
     * Creates a new CalloutManager instance for a DELETE request.
     * 
     * @param endpoint The endpoint URL
     * @return A new CalloutManager instance
     */
    public static CalloutManager del(String endpoint) {
        return new CalloutManager()
            .withEndpoint(endpoint)
            .withMethod('DELETE');
    }
    
    /**
     * Creates a new CalloutManager instance with a Named Credential.
     * 
     * @param credentialName The Named Credential developer name
     * @param path The endpoint path
     * @return A new CalloutManager instance
     * @example
     * CalloutResult result = CalloutManager.withCredential('MyAPI', '/users/123').execute();
     */
    public static CalloutManager withCredential(String credentialName, String path) {
        return new CalloutManager()
            .withNamedCredential(credentialName)
            .withEndpoint(path);
    }
    
    /**
     * Creates a new CalloutManager instance from a Custom Metadata configuration.
     * 
     * @param configName The Callout_Configuration__mdt developer name
     * @return A new CalloutManager instance
     * @example
     * CalloutResult result = CalloutManager.fromConfig('UserAPI_GetUser')
     *     .withQueryParam('id', '123')
     *     .execute();
     */
    public static CalloutManager fromConfig(String configName) {
        return new CalloutManager().withConfiguration(configName);
    }
}