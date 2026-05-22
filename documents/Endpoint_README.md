# REST Endpoint Framework

A flexible, metadata-driven REST API framework for Salesforce that enables dynamic routing, path parameters, and declarative endpoint configuration.

## Architecture Overview

The framework consists of four main components:

1. **RestEntryPoint** - The main REST resource that receives all API requests
2. **EndpointDefinitionMatcher** - Handles dynamic routing and pattern matching
3. **Requestable Interface** - Contract that all request handlers must implement
4. **RequestContext** - Contains all request information (headers, params, body, RestContext)
5. **Endpoint_Definition__mdt** - Custom metadata type for declarative configuration

## Features

- ✅ Dynamic routing with path parameters (e.g., `/api/users/{id}`)
- ✅ Metadata-driven endpoint configuration
- ✅ Automatic query parameter parsing
- ✅ Header extraction and mapping
- ✅ Support for all HTTP methods (GET, POST, PUT, PATCH, DELETE)
- ✅ Configurable HTTP response codes
- ✅ Priority-based endpoint matching
- ✅ Method-level routing control

## Quick Start

### 1. Create a Request Handler

Implement the `Requestable` interface:

```apex
public class UserRequestHandler implements Requestable {
    
    public void handleGet(RequestContext context) {
        String userId = context.getPathParam('id');
        String filter = context.getQueryParam('filter');
        
        // Your logic here
        RestResponse res = context.getRestContext().response;
        res.responseBody = Blob.valueOf(JSON.serialize(result));
    }
    
    public void handlePost(RequestContext context) {
        String body = context.getRequestBody();
        // Handle POST logic
    }
    
    public void handlePut(RequestContext context) {
        // Handle PUT logic
    }
    
    public void handlePatch(RequestContext context) {
        // Handle PATCH logic
    }
    
    public void handleDelete(RequestContext context) {
        // Handle DELETE logic
    }
}
```

### 2. Configure Endpoint Definition

Create an `Endpoint_Definition__mdt` record:

| Field | Value | Description |
|-------|-------|-------------|
| **Label** | Get User By ID | Friendly name |
| **Developer Name** | Get_User_By_ID | API name |
| **Endpoint Pattern** | `/api/users/{id}` | URL pattern with path params |
| **Handler Class** | `UserRequestHandler` | Fully qualified class name |
| **Allowed Methods** | `GET,POST,PUT,DELETE` | Comma-separated HTTP methods |
| **Success Response Code** | `200` | HTTP status code for success |
| **Priority** | `100` | Lower numbers matched first |
| **Is Active** | `☑` | Enable/disable endpoint |
| **Requires Authentication** | `☑` | Future use |

### 3. Make API Calls

The RestEntryPoint is exposed at `/services/apexrest/api/*`:

```bash
# GET with path parameter
GET /services/apexrest/api/users/001xx000003DGb2AAG

# GET with query parameters
GET /services/apexrest/api/users/001xx000003DGb2AAG?includeDetails=true&format=json

# POST with body
POST /services/apexrest/api/users
Content-Type: application/json

{
  "firstName": "John",
  "lastName": "Doe"
}

# PUT to update
PUT /services/apexrest/api/users/001xx000003DGb2AAG
Content-Type: application/json

{
  "firstName": "Jane"
}

# DELETE
DELETE /services/apexrest/api/users/001xx000003DGb2AAG
```

## RequestContext API

The `RequestContext` object provides access to all request information:

### Path Parameters

```apex
String id = context.getPathParam('id');
Map<String, String> allPathParams = context.getPathParams();
```

### Query Parameters

```apex
String filter = context.getQueryParam('filter');
String page = context.getQueryParam('page');
Map<String, String> allQueryParams = context.getQueryParams();
```

### Headers

```apex
String contentType = context.getHeader('content-type');
String authorization = context.getHeader('authorization');
Map<String, String> allHeaders = context.getHeaders();
```

### Request Body

```apex
String body = context.getRequestBody();
Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(body);
```

### RestContext

```apex
RestContext ctx = context.getRestContext();
RestRequest req = ctx.request;
RestResponse res = ctx.response;

// Set response
res.statusCode = 201;
res.addHeader('Location', '/api/users/newId');
res.responseBody = Blob.valueOf(JSON.serialize(result));
```

## Dynamic Routing

The framework supports flexible URL patterns:

### Static Routes
```
/api/users              → Matches exactly /api/users
/api/products/featured  → Matches exactly /api/products/featured
```

### Dynamic Routes with Path Parameters
```
/api/users/{id}                        → /api/users/123
/api/users/{userId}/orders/{orderId}   → /api/users/123/orders/456
/api/{resource}/{id}                   → /api/accounts/001xxx
```

### Priority Matching

When multiple patterns could match a request, the `Priority__c` field determines the order:

```
Priority 10:  /api/users/special       (checked first)
Priority 50:  /api/users/{id}          (checked second)
Priority 100: /api/{resource}/{id}     (checked last)
```

## Method-Level Control

Control which HTTP methods are allowed per endpoint:

```apex
// Allow only GET and POST
Allowed_Methods__c = 'GET,POST'

// Allow all methods (leave blank)
Allowed_Methods__c = null

// Single method only
Allowed_Methods__c = 'GET'
```

## Error Handling

The framework automatically handles errors:

```json
{
  "error": true,
  "message": "Endpoint not found",
  "statusCode": 404,
  "timestamp": "2026-05-22T12:00:00Z"
}
```

Custom error handling in handlers:

```apex
public void handlePost(RequestContext context) {
    try {
        // Your logic
    } catch (Exception e) {
        RestResponse res = context.getRestContext().response;
        res.statusCode = 400;
        res.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object>{
            'error' => true,
            'message' => e.getMessage()
        }));
    }
}
```

## Best Practices

### 1. Handler Organization
```
- UserRequestHandler     (handles /api/users/*)
- OrderRequestHandler    (handles /api/orders/*)
- ProductRequestHandler  (handles /api/products/*)
```

### 2. Response Codes
Use appropriate HTTP status codes:
- `200 OK` - Successful GET, PUT, PATCH
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE
- `400 Bad Request` - Invalid input
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

### 3. Input Validation
```apex
public void handlePost(RequestContext context) {
    String body = context.getRequestBody();
    
    if (String.isBlank(body)) {
        sendError(context.getRestContext().response, 400, 'Request body is required');
        return;
    }
    
    // Continue processing
}
```

### 4. Bulk Operations
For bulk operations, consider pagination:
```apex
public void handleGet(RequestContext context) {
    String pageSize = context.getQueryParam('pageSize');
    String offset = context.getQueryParam('offset');
    
    Integer size = String.isNotBlank(pageSize) ? Integer.valueOf(pageSize) : 50;
    Integer off = String.isNotBlank(offset) ? Integer.valueOf(offset) : 0;
    
    // Query with LIMIT and OFFSET
}
```

## Testing

Create test methods for your handlers:

```apex
@isTest
private class UserRequestHandlerTest {
    
    @isTest
    static void testHandleGet() {
        // Setup
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/api/users/001xx000003DGb2AAG';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        // Create context
        Map<String, String> pathParams = new Map<String, String>{'id' => '001xx000003DGb2AAG'};
        RequestContext ctx = new RequestContext(
            new Map<String, String>(),
            new Map<String, String>(),
            null,
            RestContext.request.getRestContext()
        );
        ctx.setPathParams(pathParams);
        
        // Test
        Test.startTest();
        UserRequestHandler handler = new UserRequestHandler();
        handler.handleGet(ctx);
        Test.stopTest();
        
        // Assert
        System.assertEquals(200, RestContext.response.statusCode);
    }
}
```

## Security Considerations

1. **Authentication**: Implement authentication checks in your handlers
2. **Authorization**: Validate user permissions before processing
3. **Input Validation**: Always validate and sanitize input
4. **Rate Limiting**: Consider implementing rate limiting for public APIs
5. **Sharing Rules**: Use appropriate sharing settings (`with sharing`, `without sharing`)

## Examples

See `SampleRequestHandler.cls` for a complete working example demonstrating all HTTP methods.

## Troubleshooting

### Endpoint Not Found (404)
- Verify the Endpoint_Definition__mdt record is active
- Check the endpoint pattern matches your request URI
- Ensure the HTTP method is in the Allowed_Methods__c field

### Handler Not Found (500)
- Verify the Handler_Class__c value is correct
- Ensure the handler class exists and is accessible
- Confirm the handler implements the Requestable interface

### Pattern Not Matching
- Check for leading/trailing slashes in pattern
- Verify dynamic segments use `{paramName}` syntax
- Consider the Priority__c field for overlapping patterns

## Future Enhancements

- Authentication/authorization middleware
- Request/response interceptors
- Rate limiting
- API versioning support
- Caching layer
- OpenAPI/Swagger documentation generation