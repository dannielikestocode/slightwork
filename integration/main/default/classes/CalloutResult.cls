/**
 * Result object for HTTP callouts that encapsulates request and response data.
 * Provides convenient methods to access response data in various formats.
 * Optionally captures request details for debugging and logging.
 * 
 * @author Agentforce
 * @since v66.0
 * @see CalloutManager
 * @see HttpRequest
 * @see HttpResponse
 */
public class CalloutResult {
    
    // ─── Response Properties ─────────────────────────────────────────────
    
    private HttpResponse response;
    private Integer statusCode;
    private String status;
    private String responseBody;
    private Map<String, String> responseHeaders;
    
    // ─── Request Properties (Optional Capture) ───────────────────────────
    
    private Boolean requestCaptured;
    private String requestMethod;
    private String requestEndpoint;
    private String requestBody;
    private Map<String, String> requestHeaders;
    
    // ─── Constructor ─────────────────────────────────────────────────────
    
    /**
     * Creates a new CalloutResult from an HttpRequest and HttpResponse.
     * 
     * @param request The HttpRequest that was sent
     * @param response The HttpResponse that was received
     * @param captureRequest Whether to capture request details
     */
    public CalloutResult(HttpRequest request, HttpResponse response, Boolean captureRequest) {
        this.response = response;
        this.requestCaptured = captureRequest != null ? captureRequest : false;
        
        // Capture response data
        captureResponseData(response);
        
        // Optionally capture request data
        if (this.requestCaptured) {
            captureRequestData(request);
        }
    }
    
    // ─── Response Data Methods ───────────────────────────────────────────
    
    /**
     * Gets the HTTP status code of the response.
     * 
     * @return The status code (e.g., 200, 404, 500)
     * @example
     * Integer code = result.getStatusCode(); // 200
     */
    public Integer getStatusCode() {
        return this.statusCode;
    }
    
    /**
     * Gets the HTTP status text of the response.
     * 
     * @return The status text (e.g., 'OK', 'Not Found', 'Internal Server Error')
     * @example
     * String status = result.getStatus(); // 'OK'
     */
    public String getStatus() {
        return this.status;
    }
    
    /**
     * Gets the response body as a string.
     * 
     * @return The response body
     * @example
     * String body = result.getBody();
     */
    public String getBody() {
        return this.responseBody;
    }
    
    /**
     * Gets the original HttpResponse object.
     * Use this to access additional response methods not exposed by CalloutResult.
     * 
     * @return The HttpResponse object
     * @example
     * HttpResponse response = result.getResponse();
     */
    public HttpResponse getResponse() {
        return this.response;
    }
    
    /**
     * Gets all response headers as a map.
     * 
     * @return Map of header names to values
     * @example
     * Map<String, String> headers = result.getResponseHeaders();
     */
    public Map<String, String> getResponseHeaders() {
        return this.responseHeaders;
    }
    
    /**
     * Gets a specific response header value.
     * 
     * @param headerName The name of the header
     * @return The header value, or null if not found
     * @example
     * String contentType = result.getResponseHeader('Content-Type');
     */
    public String getResponseHeader(String headerName) {
        return this.responseHeaders.get(headerName);
    }
    
    // ─── Success/Error Checking Methods ──────────────────────────────────
    
    /**
     * Checks if the response indicates success (status code 2xx).
     * 
     * @return True if status code is between 200-299
     * @example
     * if (result.isSuccess()) {
     *     // Process successful response
     * }
     */
    public Boolean isSuccess() {
        return this.statusCode >= 200 && this.statusCode < 300;
    }
    
    /**
     * Checks if the response indicates a client error (status code 4xx).
     * 
     * @return True if status code is between 400-499
     * @example
     * if (result.isClientError()) {
     *     // Handle client error
     * }
     */
    public Boolean isClientError() {
        return this.statusCode >= 400 && this.statusCode < 500;
    }
    
    /**
     * Checks if the response indicates a server error (status code 5xx).
     * 
     * @return True if status code is between 500-599
     * @example
     * if (result.isServerError()) {
     *     // Handle server error
     * }
     */
    public Boolean isServerError() {
        return this.statusCode >= 500 && this.statusCode < 600;
    }
    
    /**
     * Checks if the response indicates any error (status code >= 400).
     * 
     * @return True if status code is 400 or greater
     * @example
     * if (result.isError()) {
     *     System.debug('Error: ' + result.getStatus());
     * }
     */
    public Boolean isError() {
        return this.statusCode >= 400;
    }
    
    // ─── Body Parsing Methods ────────────────────────────────────────────
    
    /**
     * Parses the response body as JSON and returns a map.
     * 
     * @return Map representing the JSON object
     * @throws JSONException if the body is not valid JSON
     * @example
     * Map<String, Object> data = result.getBodyAsMap();
     * String name = (String) data.get('name');
     */
    public Map<String, Object> getBodyAsMap() {
        if (String.isBlank(this.responseBody)) {
            return new Map<String, Object>();
        }
        return (Map<String, Object>) JSON.deserializeUntyped(this.responseBody);
    }
    
    /**
     * Parses the response body as JSON and returns a list.
     * 
     * @return List representing the JSON array
     * @throws JSONException if the body is not valid JSON
     * @example
     * List<Object> items = result.getBodyAsList();
     */
    public List<Object> getBodyAsList() {
        if (String.isBlank(this.responseBody)) {
            return new List<Object>();
        }
        return (List<Object>) JSON.deserializeUntyped(this.responseBody);
    }
    
    /**
     * Parses the response body as JSON and deserializes to a specific type.
     * 
     * @param type The Apex class type to deserialize to
     * @return The deserialized object
     * @throws JSONException if the body is not valid JSON or doesn't match the type
     * @example
     * User user = (User) result.getBodyAs(User.class);
     */
    public Object getBodyAs(Type apexType) {
        if (String.isBlank(this.responseBody)) {
            return null;
        }
        return JSON.deserialize(this.responseBody, apexType);
    }
    
    // ─── Request Data Methods (Optional) ─────────────────────────────────
    
    /**
     * Checks if request data was captured.
     * 
     * @return True if request details were captured
     * @example
     * if (result.isRequestCaptured()) {
     *     System.debug('Request endpoint: ' + result.getRequestEndpoint());
     * }
     */
    public Boolean isRequestCaptured() {
        return this.requestCaptured;
    }
    
    /**
     * Gets the HTTP method of the request.
     * Only available if request capture was enabled.
     * 
     * @return The HTTP method (e.g., 'GET', 'POST')
     * @example
     * String method = result.getRequestMethod();
     */
    public String getRequestMethod() {
        return this.requestMethod;
    }
    
    /**
     * Gets the endpoint URL of the request.
     * Only available if request capture was enabled.
     * 
     * @return The endpoint URL
     * @example
     * String endpoint = result.getRequestEndpoint();
     */
    public String getRequestEndpoint() {
        return this.requestEndpoint;
    }
    
    /**
     * Gets the request body.
     * Only available if request capture was enabled.
     * 
     * @return The request body
     * @example
     * String body = result.getRequestBody();
     */
    public String getRequestBody() {
        return this.requestBody;
    }
    
    /**
     * Gets the request headers.
     * Only available if request capture was enabled.
     * 
     * @return Map of header names to values
     * @example
     * Map<String, String> headers = result.getRequestHeaders();
     */
    public Map<String, String> getRequestHeaders() {
        return this.requestHeaders;
    }
    
    // ─── Utility Methods ─────────────────────────────────────────────────
    
    /**
     * Returns a string representation of the result for debugging.
     * 
     * @return A formatted string with response details
     * @example
     * System.debug(result.toString());
     */
    public override String toString() {
        String str = 'CalloutResult[' +
            'statusCode=' + this.statusCode + ', ' +
            'status=' + this.status + ', ' +
            'bodyLength=' + (this.responseBody != null ? this.responseBody.length() : 0);
        
        if (this.requestCaptured) {
            str += ', requestMethod=' + this.requestMethod +
                   ', requestEndpoint=' + this.requestEndpoint;
        }
        
        str += ']';
        return str;
    }
    
    /**
     * Returns a detailed string representation including headers and body.
     * Useful for logging and debugging.
     * 
     * @return A detailed string with all captured data
     * @example
     * System.debug(result.toDetailedString());
     */
    public String toDetailedString() {
        StringBuilder sb = new StringBuilder();
        
        sb.append('═══ CALLOUT RESULT ═══\n');
        
        // Request details (if captured)
        if (this.requestCaptured) {
            sb.append('\n─── REQUEST ───\n');
            sb.append('Method: ').append(this.requestMethod).append('\n');
            sb.append('Endpoint: ').append(this.requestEndpoint).append('\n');
            
            if (this.requestHeaders != null && !this.requestHeaders.isEmpty()) {
                sb.append('Headers:\n');
                for (String key : this.requestHeaders.keySet()) {
                    sb.append('  ').append(key).append(': ').append(this.requestHeaders.get(key)).append('\n');
                }
            }
            
            if (String.isNotBlank(this.requestBody)) {
                sb.append('Body: ').append(this.requestBody).append('\n');
            }
        }
        
        // Response details
        sb.append('\n─── RESPONSE ───\n');
        sb.append('Status: ').append(this.statusCode).append(' ').append(this.status).append('\n');
        
        if (this.responseHeaders != null && !this.responseHeaders.isEmpty()) {
            sb.append('Headers:\n');
            for (String key : this.responseHeaders.keySet()) {
                sb.append('  ').append(key).append(': ').append(this.responseHeaders.get(key)).append('\n');
            }
        }
        
        if (String.isNotBlank(this.responseBody)) {
            sb.append('Body: ').append(this.responseBody).append('\n');
        }
        
        sb.append('\n═══════════════════════\n');
        
        return sb.toString();
    }
    
    // ─── Private Helper Methods ──────────────────────────────────────────
    
    /**
     * Captures response data from the HttpResponse object.
     * 
     * @param response The HttpResponse to capture data from
     */
    private void captureResponseData(HttpResponse response) {
        this.statusCode = response.getStatusCode();
        this.status = response.getStatus();
        this.responseBody = response.getBody();
        
        // Capture response headers
        this.responseHeaders = new Map<String, String>();
        List<String> headerKeys = response.getHeaderKeys();
        if (headerKeys != null) {
            for (String key : headerKeys) {
                this.responseHeaders.put(key, response.getHeader(key));
            }
        }
    }
    
    /**
     * Captures request data from the HttpRequest object.
     * 
     * @param request The HttpRequest to capture data from
     */
    private void captureRequestData(HttpRequest request) {
        this.requestMethod = request.getMethod();
        this.requestEndpoint = request.getEndpoint();
        this.requestBody = request.getBody();
        
        // Capture request headers (HttpRequest doesn't provide a direct way to get all headers,
        // so this will be empty unless we track them in CalloutManager)
        this.requestHeaders = new Map<String, String>();
    }
}