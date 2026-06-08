/**
 * Sample implementation of the Requestable interface demonstrating
 * how to handle REST requests through the RestEntryPoint framework.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
public inherited sharing class AccountsRequestHandlerDemo implements Requestable {
    /**
     * Properties
     */
    public final static Integer NUMBER_OF_ACCOUNTS_TO_CREATE = 10;
    private final AccountsServiceDemo accountsService {get; set;}
    
    /**
     * No-arg constructor
     */
    public AccountsRequestHandlerDemo() {
        this.accountsService = new AccountsServiceDemo(NUMBER_OF_ACCOUNTS_TO_CREATE);
    }

    /**
     * Handle HTTP POST requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param endpointDefinition The endpoint definition
     * @param pathVariables The path variables extracted from the endpoint path
     */
    public void handlePost(RestRequest request, RestResponse response,  Endpoint_Definition__mdt endpointDefinition, Map<String, String> pathVariables) {
        AccountsServiceDemo.AccountDTO newAccount = (AccountsServiceDemo.AccountDTO)JSON.deserialize(request.requestBody.toString(), AccountsServiceDemo.AccountDTO.class);
        this.accountsService.createAccount(newAccount.accountName);
    }
    
    /**
     * Handle HTTP GET requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param endpointDefinition The endpoint definition
     * @param pathVariables The path variables extracted from the endpoint path
     */
    public void handleGet(RestRequest request, RestResponse response,  Endpoint_Definition__mdt endpointDefinition, Map<String, String> pathVariables) {
        
        /*
        // Access path parameters
        String id = context.getPathParam('id');
        
        // Access query parameters
        String name = context.getQueryParam('name');
        String limitValue = context.getQueryParam('limit');
        
        // Access headers
        String contentType = context.getHeader('content-type');
        String authorization = context.getHeader('authorization');
        
        // Build response
        Map<String, Object> response = new Map<String, Object>{
            'method' => 'GET',
            'message' => 'Sample GET handler executed successfully',
            'pathParams' => context.getPathParams(),
            'queryParams' => context.getQueryParams(),
            'headers' => new Map<String, String>{
                'content-type' => contentType,
                'authorization' => authorization != null ? '***' : null
            },
            'timestamp' => DateTime.now().format()
        };
        
        // Set response
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(response));
        response.statusCode = 200;     */   
    }
    
    /**
     * Handle HTTP PUT requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param endpointDefinition The endpoint definition
     * @param pathVariables The path variables extracted from the endpoint path
     */
    public void handlePut(RestRequest request, RestResponse response,  Endpoint_Definition__mdt endpointDefinition, Map<String, String> pathVariables) {
        /*
        
        String id = context.getPathParam('id');
        String requestBody = context.getRequestBody();
        
        if (String.isBlank(id)) {
            sendError(response, 400, 'ID is required for PUT requests');
            return;
        }
        
        // Parse request body
        Map<String, Object> requestData = null;
        if (String.isNotBlank(requestBody)) {
            try {
                requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            } catch (Exception e) {
                sendError(response, 400, 'Invalid JSON in request body: ' + e.getMessage());
                return;
            }
        }
        
        // Build response
        Map<String, Object> response = new Map<String, Object>{
            'method' => 'PUT',
            'message' => 'Sample PUT handler executed successfully',
            'id' => id,
            'updatedData' => requestData,
            'timestamp' => DateTime.now().format()
        };
        
        // Set response
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(response));
        response.statusCode = 200;
*/
        
    }
    
    /**
     * Handle HTTP PATCH requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param endpointDefinition The endpoint definition
     * @param pathVariables The path variables extracted from the endpoint path
     */
    public void handlePatch(RestRequest request, RestResponse response,  Endpoint_Definition__mdt endpointDefinition, Map<String, String> pathVariables) {
        /*
        
        String id = context.getPathParam('id');
        String requestBody = context.getRequestBody();
        
        if (String.isBlank(id)) {
            sendError(response, 400, 'ID is required for PATCH requests');
            return;
        }
        
        // Parse request body
        Map<String, Object> requestData = null;
        if (String.isNotBlank(requestBody)) {
            try {
                requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            } catch (Exception e) {
                sendError(response, 400, 'Invalid JSON in request body: ' + e.getMessage());
                return;
            }
        }
        
        // Build response
        Map<String, Object> response = new Map<String, Object>{
            'method' => 'PATCH',
            'message' => 'Sample PATCH handler executed successfully',
            'id' => id,
            'patchedData' => requestData,
            'timestamp' => DateTime.now().format()
        };
        
        // Set response
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(response));
        response.statusCode = 200;
*/
        
    }
    
    /**
     * Handle HTTP DELETE requests
     * 
     * @param request The REST request context
     * @param response The REST response context
     * @param endpointDefinition The endpoint definition
     * @param pathVariables The path variables extracted from the endpoint path
     */
    public void handleDelete(RestRequest request, RestResponse response,  Endpoint_Definition__mdt endpointDefinition, Map<String, String> pathVariables) {
        
    }
}