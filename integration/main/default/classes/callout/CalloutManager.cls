/**
 * Provides a fluent interface for managing the lifecycle of an HTTP callout,
 * including send operations.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/integration/callout-manager.html
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm For HttpRequest
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httpresponse.htm For HttpResponse
 */
public inherited sharing class CalloutManager {
    /**
     * Constants
     */
    public static final Integer MAX_TIMEOUT = 120000; // In millis
    public static final Integer MIN_TIMEOUT = 1; // In mills
    public static final Integer DEFAULT_TIMEOUT = 10000; // 10 seconds millis (The Salesforce default: https://help.salesforce.com/s/articleView?id=000387845&type=1)
    public static final Set<String> SUPPORTED_HTTP_METHODS = new Set<String>{'DELETE','GET','HEAD','PATCH','POST','PUT','TRACE'};
    public static final String ENCODE_UTF8 = 'UTF-8';
    public static final Integer MAX_BODY_FIELD_LENGTH = 131072; // Max length of a long-text field

    /**
     * Properties
     */
    private Boolean encodeQueryParams {get;set;}
    private String calloutName {get;set;}
    private final Map<String, String> headers {get;set;}
    private final Map<String, String> queryParams {get;set;}
    private String endpoint {get;set;}
    private String method {get;set;}
    private String body {get;set;}
    private Blob blobBody {get;set;}
    private Dom.Document documentBody {get;set;}
    private Integer timeout {get;set;}
    private Boolean compressed {get;set;}
    private String clientCertificateName {get;set;}
    private String namedCredential {get;set;}
  
    /**
     * Default, no-arg constructor
     */
    public CalloutManager() {
        this.encodeQueryParams = false;
        this.headers = new Map<String, String>();
        this.queryParams = new Map<String, String>();
        this.compressed = false;
    }

    /**
     * Constructor with config argument
     * 
     * @param config The Callout Configuration record
     * @throws IllegalArgumentException when Callout Configuration is not provided
     */
    public CalloutManager(Callout_Configuration__mdt config) {
        if (config == null) {
            throw new QueryException('Callout Configuration must be provided');
        }

        // Set properties
        this.encodeQueryParams = false;
        this.calloutName = config.DeveloperName;
        this.headers = new Map<String, String>();
        this.queryParams = new Map<String, String>();
        this.compressed = false;

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

        if (config.Compressed__c != null) {
            this.compressed = config.Compressed__c;
        }

        if (String.isNotBlank(config.Client_Certificate__c)) {
            this.clientCertificateName = config.Client_Certificate__c;
        }

        if (config.Encode_Query_Params__c != null) {
            this.encodeQueryParams = config.Encode_Query_Params__c;
        }
    }
    
    /**
     * Sets the name of the callout for logging purposes.
     * 
     * @param calloutName The name of the callout
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if callout name is blank
     */
    public CalloutManager withCalloutName(String calloutName) {
        if (String.isBlank(calloutName)) {
            throw new IllegalArgumentException('Callout Name cannot be blank');
        }
        this.calloutName = calloutName;
        return this;
    }
    
    /**
     * Sets the full endpoint URL for the callout.
     * 
     * @param endpoint The endpoint URL or path
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if endpoint is blank
     */
    public CalloutManager withFullEndpoint(String endpoint) {
        if (String.isBlank(endpoint)) {
            throw new IllegalArgumentException('Endpoint cannot be blank');
        }
        this.endpoint = endpoint;
        return this;
    }

    /**
     * Creates full endpoint from a combination of named credentials
     * and partial endpoint
     * 
     * @param credentialName The named credential for the callout
     * @param endpoint The endpoint URL or path
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if credential name or endpoint is blank
     */
    public CalloutManager withNamedEndpoint(String credentialName, String endpoint) {
        if (String.isBlank(credentialName)) {
            throw new IllegalArgumentException('Credential Name cannot be blank');            
        }

        if (String.isBlank(endpoint)) {
            throw new IllegalArgumentException('Endpoint cannot be blank');
        }
        this.namedCredential = credentialName;
        this.endpoint = endpoint;
        return this;
    }
    
    /**
     * Sets the HTTP method for the request.
     * 
     * @param method The HTTP method (GET, POST, PUT, PATCH, DELETE, etc.)
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if method is blank or provided method is not supported
     */
    public CalloutManager withHttpMethod(String method) {
        if (String.isBlank(method)) {
            throw new IllegalArgumentException('Method cannot be blank');
        }

        method = method.toUpperCase();
        if (!SUPPORTED_HTTP_METHODS.contains(method)) {
            throw new IllegalArgumentException('Method is not supported');
        }
        this.method = method;
        return this;
    }
    
    /**
     * Sets the request body from a String value
     * 
     * @param body The request body
     * @return This builder instance for method chaining
     * @throws IllegalArgumentmentException when body is blank
     */
    public CalloutManager withBody(String body) {
        if (String.isBlank(body)) {
            throw new IllegalArgumentException('Body cannot be blank');
        }
        this.body = body;
        return this;
    }

    /**
     * Sets the request body from a blob value
     * 
     * @param body The request body
     * @return This builder instance for method chaining
     * @throws IllegalArgumentmentException when body is null
     */
    public CalloutManager withBodyAsBlob(Blob body) {
        if (body == null) {
            throw new IllegalArgumentException('Blob body cannot be null');
        }
        this.blobBody = body;
        return this;
    }

    /**
     * Sets the request body from a Dom.Document value
     * 
     * @param body The request body
     * @return This builder instance for method chaining
     * @throws IllegalArgumentmentException when body is null
     */
    public CalloutManager withBodyAsDocument(Dom.Document body) {
        if (body == null) {
            throw new IllegalArgumentException('Document body cannot be null');
        }
        this.documentBody = body;
        return this;
    }
    
    /**
     * Sets the timeout in milliseconds.
     * 
     * @param timeout Timeout in milliseconds
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if timeout is invalid
     */
    public CalloutManager withTimeout(Integer timeout) {
        if (timeout == null || timeout < MIN_TIMEOUT || timeout > MAX_TIMEOUT) {
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
     * @throws IllegalArgumentException if compressed is null
     */
    public CalloutManager withCompression(Boolean compressed) {
        if (compressed == null) {
            throw new IllegalArgumentException('Compressed cannot be null');
        }
        this.compressed = compressed;
        return this;
    }
    
    /**
     * Sets the client certificate name for mutual SSL authentication.
     * 
     * @param certificateName The name of the certificate in Salesforce
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException when certificate name is blank
     * @see https://developer.salesforce.com/docs/atlas.en-us.262.0.apexcode.meta/apexcode/apex_callouts_client_certs_http.htm
     */
    public CalloutManager withClientCertificate(String certificateName) {
        if (String.isBlank(certificateName)) {
            throw new IllegalArgumentException('Certificate Name cannot be blank');
        }
        this.clientCertificateName = certificateName;
        return this;
    }

    /**
     * Adds a single HTTP header to the request.
     * 
     * @param key The header key
     * @param value The header value
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if header key is blank
     */
    public CalloutManager withHeader(String key, String value) {
        if (String.isBlank(key)) {
            throw new IllegalArgumentException('Header key cannot be blank');
        }
        this.headers.put(key, value);
        return this;
    }
    
    /**
     * Adds multiple HTTP headers to the request.
     * 
     * @param headers Map of header keys to values
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if headers is null or empty, or header key is blank
     */
    public CalloutManager withHeaders(Map<String, String> headers) {
        if (headers == null || headers.isEmpty()) {
            throw new IllegalArgumentException('At least 1 header must be provided');
        }

        for (String key: headers.keySet()) {
            this.withHeader(key, headers.get(key));
        }
        return this;
    }
    
    /**
     * Adds a single query parameter to the endpoint URL.
     * Parameters are automatically URL-encoded.
     * 
     * @param key The parameter key
     * @param value The parameter value
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if param key is blank
     */
    public CalloutManager withQueryParam(String key, String value) {
        if (String.isBlank(key)) {
            throw new IllegalArgumentException('Query parameter key cannot be blank');
        }

        // Some APIs may accept blank query param values
        if (value != null) {
            this.queryParams.put(key, value);
        }
        return this;
    }
    
    /**
     * Adds multiple query parameters to the endpoint URL.
     * Parameters are automatically URL-encoded.
     * 
     * @param queryParams Map of parameter keys to values
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if params is null or empty, or param key is blank
     */
    public CalloutManager withQueryParams(Map<String, String> queryParams) {
        if (queryParams == null || queryParams.isEmpty()) {
            throw new IllegalArgumentException('At least 1 query parameter must be provided');
        }

        for (String key: queryParams.keySet()) {
            this.withQueryParam(key, queryParams.get(key));
        }
        return this;
    }
    
    /**
     * Configures the callout to use a Named Credential.
     * The Named Credential handles authentication and base URL.
     * 
     * @param namedCredential The developer name of the Named Credential
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException if credentialName is blank
     */
    public CalloutManager withNamedCredential(String namedCredential) {
        if (String.isBlank(namedCredential)) {
            throw new IllegalArgumentException('Named Credential cannot be blank');
        }
        this.namedCredential = namedCredential;
        return this;
    }

    /**
     * Enables encoding of query params within the endpoint.
     * 
     * @param encodeQueryParams True to enable request capture
     * @return This builder instance for method chaining
     * @throws IllegalArgumentException when encode query params is null
     */
    public CalloutManager withEncodeQueryParams(Boolean encodeQueryParams) {
        if (encodeQueryParams = null) {
            throw new IllegalArgumentException('Encode Query Params must be provided');
        }
        this.encodeQueryParams = encodeQueryParams;
        return this;
    }
    
    /**
     * Builds and returns the configured HttpRequest instance.
     * Does not send the callout - use send() for that.
     * 
     * @return A configured HttpRequest instance
     * @throws IllegalStateException if required fields are missing
     */
    public HttpRequest buildRequest() {
        validateState();
        
        // Build the request from manager properties
        HttpRequest request = new HttpRequest();
        request.setEndpoint(buildFinalEndpoint());
        request.setMethod(this.method);
        request.setTimeout(this.timeout == null ? DEFAULT_TIMEOUT : this.timeout);

        // Set headers
        for (String key : this.headers.keySet()) {
            request.setHeader(key, this.headers.get(key));
        }
        
        // Set body based on type
        if (String.isNotBlank(this.body)) {
            request.setBody(this.body);
        }
        else if (this.blobBody != null) {
            request.setBodyAsBlob(this.blobBody);
        }
        else if (this.documentBody != null) {
            request.setBodyDocument(documentBody);
        }
        
        // Set compression
        request.setCompressed(this.compressed);
        
        // Set client certificate
        if (String.isNotBlank(this.clientCertificateName)) {
            request.setClientCertificateName(this.clientCertificateName);
        }
        return request;
    }
    
    /**
     * Builds and executes the HTTP callout, returning a CalloutResult.
     * The result includes response data and optionally request data if capture is enabled.
     * 
     * @return A CalloutResult containing the response and optional request data
     * @throws CalloutException if the HTTP callout fails
     */
    public CalloutResult send() {
        // Build and send the request, then returnt the result
        HttpRequest request = buildRequest();
        Http http = new Http();
        HttpResponse response;
        response = http.send(request);
        return new CalloutResult(this, request, response);
    }
  
    /**
     * Validates state of the request before it's sent.
     * 
     * @throws IllegalStateException if the state of the request is invalid
     */
    private void validateState() {
        if (
            (String.isNotBlank(this.body) && this.blobBody != null) ||
            (String.isNotBlank(this.body) && this.documentBody != null) ||
            (this.blobBody != null && this.documentBody != null)
        ) {
            throw new IllegalStateException('Only one of Body (String), BlobBody, or DocumentBody should be provided');
        }
    }
    
    /**
     * Builds the final endpoint URL.
     * 
     * @return The complete endpoint URL
     */
    private String buildFinalEndpoint() {
        List<String> endpointParts = new List<String>();

        // Add Named Credential argument, if provided
        if (String.isNotBlank(this.namedCredential)) {
            endpointParts.add(this.namedCredential);
        }

        // Add endpoint, which should always be provided
        endpointParts.add(this.endpoint);

        // Add query parameters, if any
        if (!this.queryParams.isEmpty()) {
            endpointParts.add('?');

            // Add any query params to list of endpoint parts
            Integer numberOfParams = this.queryParams.size();
            Integer paramCounter = 0;
            for (String key: this.queryParams.keySet()) {
                endpointParts.add(this.encodeQueryParams ? EncodingUtil.urlEncode(key, ENCODE_UTF8) : key);
                endpointParts.add('=');
                endpointParts.add(this.encodeQueryParams ? EncodingUtil.urlEncode(this.queryParams.get(key), ENCODE_UTF8) : this.queryParams.get(key) );

                // If there are multiple query params, don't include the
                // ampersand/concat operator after the final param
                //
                // E.g., https://endpoint?param1=value1&param2=value2
                paramCounter += 1;
                if (paramCounter < numberOfParams) {
                    endpointParts.add('&');
                }
            }
        }
        return String.join(endpointParts, '');
    }
    
    /**
     * Inner class used to model the details of a 
     * callout.
     */
    public class CalloutResult {
        /**
         * Properties
         */
        public final HttpRequest request {get; private set;}
        public final HttpResponse response {get; private set;}
        public final Request__c requestRecord {get; private set;}
        
        /**
         * Constructor with args
         */
        public CalloutResult(CalloutManager callout, HttpRequest request, HttpResponse response) {
            this.request = request;
            this.response = response;
            this.requestRecord = buildRequestRecord(callout, request, response);
        }

        private Request__c buildRequestRecord(CalloutManager callout, HttpRequest request, HttpResponse response) {
            Request__c requestRecord = new Request__c();

            // Set configuration details
            requestRecord.Callout_Name__c = callout.calloutName;
            requestRecord.Named_Credential__c = callout.namedCredential;
            requestRecord.Client_Certificate__c = callout.clientCertificateName;
            requestRecord.Timeout__c = callout.timeout;
            requestRecord.Compressed__c = callout.compressed;
            requestRecord.Encode_Query_Params__c = callout.encodeQueryParams;

            // Set request details
            requestRecord.Method__c = callout.method;
            requestRecord.Endpoint__c = request.getEndpoint();
            requestRecord.Query_Params__c = JSON.serialize(callout.queryParams);
            requestRecord.Request_Headers__c = JSON.serialize(callout.headers);
            requestRecord.Request_Body__c = this.getTruncatedBody(request.getBody());

            // Set response details
            requestRecord.Status_Code__c = response.getStatusCode();
            requestRecord.Status_Message__c = response.getStatus();

            Map<String, String> responseHeaders = new Map<String, String>();
            for (String responseHeaderKey: response.getHeaderKeys()) {
                responseHeaders.put(responseHeaderKey, response.getHeader(responseHeaderKey));
            }

            requestRecord.Response_Headers__c = JSON.serialize(responseHeaders);
            requestRecord.Response_Body__c = this.getTruncatedBody(response.getBody());
            return requestRecord;
        }

        private String getTruncatedBody(String requestOrResponseBody) {
            if (String.isBlank(requestOrResponseBody)) {
                return '';
            }

            if (requestOrResponseBody.length() > MAX_BODY_FIELD_LENGTH) {
                return requestOrResponseBody.substring(0, MAX_BODY_FIELD_LENGTH - 1);
            }
            return requestOrResponseBody;
        }
    }
}