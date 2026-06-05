/**
 * Sample implementation of the Requestable interface demonstrating
 * how to handle REST requests through the RestEntryPoint framework.
 * 
 * This handler can be configured in Endpoint_Definition__mdt with patterns like:
 * - /api/sample
 * - /api/sample/{id}
 * - /api/sample/{id}/details
 */
public without sharing class RequestHandlerDemo implements Requestable {
    
    /**
     * Handle GET requests
     * Example: GET /api/sample?name=test&limit=10
     * Example: GET /api/sample/{id}
     */
    public ResponseContext handleGet(RequestContext context) {
        RestResponse res = RestContext.response;
        
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
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;

        return null;
    }
    
    /**
     * Handle POST requests
     * Example: POST /api/sample with JSON body
     */
    public ResponseContext handlePost(RequestContext context) {
        RestResponse res = RestContext.response;
        
        // Parse request body
        String requestBody = context.getRequestBody();
        Map<String, Object> requestData = null;
        
        if (String.isNotBlank(requestBody)) {
            try {
                requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            } catch (Exception e) {
                sendError(res, 400, 'Invalid JSON in request body: ' + e.getMessage());
                return null;
            }
        }
        
        // Build response
        Map<String, Object> response = new Map<String, Object>{
            'method' => 'POST',
            'message' => 'Sample POST handler executed successfully',
            'receivedData' => requestData,
            'timestamp' => DateTime.now().format()
        };
        
        // Set response
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 201; // Created

        return null;
    }
    
    /**
     * Handle PUT requests
     * Example: PUT /api/sample/{id} with JSON body
     */
    public ResponseContext handlePut(RequestContext context) {
        RestResponse res = RestContext.response;
        
        String id = context.getPathParam('id');
        String requestBody = context.getRequestBody();
        
        if (String.isBlank(id)) {
            sendError(res, 400, 'ID is required for PUT requests');
            return null;
        }
        
        // Parse request body
        Map<String, Object> requestData = null;
        if (String.isNotBlank(requestBody)) {
            try {
                requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            } catch (Exception e) {
                sendError(res, 400, 'Invalid JSON in request body: ' + e.getMessage());
                return null;
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
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;

        return null;
    }
    
    /**
     * Handle PATCH requests
     * Example: PATCH /api/sample/{id} with partial JSON body
     */
    public ResponseContext handlePatch(RequestContext context) {
        RestResponse res = RestContext.response;
        
        String id = context.getPathParam('id');
        String requestBody = context.getRequestBody();
        
        if (String.isBlank(id)) {
            sendError(res, 400, 'ID is required for PATCH requests');
            return null;
        }
        
        // Parse request body
        Map<String, Object> requestData = null;
        if (String.isNotBlank(requestBody)) {
            try {
                requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            } catch (Exception e) {
                sendError(res, 400, 'Invalid JSON in request body: ' + e.getMessage());
                return null;
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
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;

        return null;
    }
    
    /**
     * Handle DELETE requests
     * Example: DELETE /api/sample/{id}
     */
    public ResponseContext handleDelete(RequestContext context) {
        RestResponse res = RestContext.response;
        
        String id = context.getPathParam('id');
        
        if (String.isBlank(id)) {
            sendError(res, 400, 'ID is required for DELETE requests');
            return null;
        }
        
        // Build response
        Map<String, Object> response = new Map<String, Object>{
            'method' => 'DELETE',
            'message' => 'Sample DELETE handler executed successfully',
            'id' => id,
            'deleted' => true,
            'timestamp' => DateTime.now().format()
        };
        
        // Set response
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(response));
        res.statusCode = 200;

        return null;
    }
    
    /**
     * Helper method to send error responses
     */
    private void sendError(RestResponse res, Integer statusCode, String message) {
        Map<String, Object> errorResponse = new Map<String, Object>{
            'error' => true,
            'message' => message,
            'statusCode' => statusCode,
            'timestamp' => DateTime.now().format()
        };
        
        res.statusCode = statusCode;
        res.addHeader('Content-Type', 'application/json');
        res.responseBody = Blob.valueOf(JSON.serialize(errorResponse));
    }
}