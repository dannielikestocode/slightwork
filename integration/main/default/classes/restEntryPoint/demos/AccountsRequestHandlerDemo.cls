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
    private final static String DEFAULT_CONTENT_TYPE = 'application/json';
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
        response.responseBody = Blob.valueOf(String.valueOf(this.accountsService.createAccount(newAccount.accountName)));
        response.statusCode = 201;
        response.addHeader('Content-Type', DEFAULT_CONTENT_TYPE);
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
        String accountId = request.params.get('accountId');
        response.responseBody = Blob.valueOf(JSON.serialize(this.accountsService.getAccountById(Integer.valueOf(accountId))));
        response.statusCode = 200;
        response.addHeader('Content-Type', DEFAULT_CONTENT_TYPE);
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
        String accountId = pathVariables.get('id');
        AccountsServiceDemo.AccountDTO accountToUpdate = (AccountsServiceDemo.AccountDTO)JSON.deserialize(request.requestBody.toString(), AccountsServiceDemo.AccountDTO.class);
        this.accountsService.updateAccountById(Integer.valueOf(accountId), accountToUpdate.accountName);
        response.statusCode = 204;
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
        String accountId = pathVariables.get('id');
        AccountsServiceDemo.AccountDTO accountToUpdate = (AccountsServiceDemo.AccountDTO)JSON.deserialize(request.requestBody.toString(), AccountsServiceDemo.AccountDTO.class);
        this.accountsService.updateAccountById(Integer.valueOf(accountId), accountToUpdate.accountName);
        response.statusCode = 204;
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
        String accountId = request.params.get('accountId');
        this.accountsService.deleteAccountById(Integer.valueOf(accountId));
        response.statusCode = 204;
    }
}