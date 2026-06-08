/**
 * Test class for the RestEntryPoint logic.
 *
 * Uses AccountsRequestHandlerDemo and AccountsServiceDemo as the concrete
 * handler implementation under test, routed through the deployed
 * Endpoint_Definition__mdt custom metadata records.
 *
 * Confirmed custom metadata endpoint patterns:
 *   - GET    /accounts/{id}   → handler reads accountId from request.params
 *   - POST   /accounts        → handler deserializes AccountDTO from body
 *   - PUT    /accounts/{id}   → handler reads id from pathVariables
 *   - PATCH  /accounts/{id}   → handler reads id from pathVariables
 *   - DELETE /accounts/{id}   → handler reads accountId from request.params
 *
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see RestEntryPoint.cls
 * @see AccountsRequestHandlerDemo.cls
 * @see AccountsServiceDemo.cls
 */
@IsTest
private without sharing class RestEntryPointTests {
    /**
     * POST /accounts with a valid AccountDTO body should create a new
     * in-memory account and return HTTP 201 Created with the new account Id.
     */
    @IsTest
    private static void doPost_shouldReturn201_whenValidAccountDtoBodyIsProvided() {
        // Given
        String requestBody = JSON.serialize(new Map<String, Object>{
            'accountName' => 'Acme Corp'
        });
        setupRestContext('POST', '/accounts', requestBody, null);

        // When
        Test.startTest();
        RestEntryPoint.doPost();
        Test.stopTest();

        // Then
        RestResponse res = RestContext.response;
        Assert.areEqual(201, res.statusCode, 'Expected HTTP 201 Created');
        Assert.isNotNull(res.responseBody, 'Response body should contain the new account Id');

        Integer newAccountId = Integer.valueOf(res.responseBody.toString());
        Integer expectedId = AccountsRequestHandlerDemo.NUMBER_OF_ACCOUNTS_TO_CREATE + 1;
        Assert.areEqual(expectedId, newAccountId, 'New account Id should be NUMBER_OF_ACCOUNTS_TO_CREATE + 1');
    }

    /**
     * GET /accounts/{id} with an accountId query param pointing to an existing
     * account should return HTTP 200 OK with the serialized AccountDTO payload.
     *
     * Note: AccountsRequestHandlerDemo.handleGet reads accountId from
     * request.params (query parameter), not from the URI path variable.
     */
    @IsTest
    private static void doGet_shouldReturn200WithAccountDto_whenValidAccountIdParamIsProvided() {
        // Given — account at index 3 is present in the 10-account default set
        setupRestContext(
            'GET',
            '/accounts/3',
            null,
            new Map<String, String>{ 'accountId' => '3' }
        );

        // When
        Test.startTest();
        RestEntryPoint.doGet();
        Test.stopTest();

        // Then
        RestResponse res = RestContext.response;
        Assert.areEqual(200, res.statusCode, 'Expected HTTP 200 OK');
        Assert.isNotNull(res.responseBody, 'Response body should not be null');

        Map<String, Object> payload = responseBodyAsMap();
        Assert.areEqual(3L, (Long) payload.get('accountId'), 'accountId in payload should match the requested Id');
        Assert.areEqual('Account 3', (String) payload.get('accountName'), 'accountName should match the initialised value');
    }

    /**
     * PUT /accounts/{id} with a valid AccountDTO body should update the
     * in-memory account identified by the URI path variable and return 204.
     *
     * Note: AccountsRequestHandlerDemo.handlePut reads the account Id from
     * pathVariables ('id'), so the URI segment drives the lookup.
     */
    @IsTest
    private static void doPut_shouldReturn204_whenValidAccountIdAndBodyAreProvided() {
        // Given
        String requestBody = JSON.serialize(new Map<String, Object>{
            'accountName' => 'Updated Corp'
        });
        setupRestContext('PUT', '/accounts/2', requestBody, null);

        // When
        Test.startTest();
        RestEntryPoint.doPut();
        Test.stopTest();

        // Then
        Assert.areEqual(204, RestContext.response.statusCode, 'Expected HTTP 204 No Content');
        Assert.isNull(RestContext.response.responseBody, 'PUT 204 response should have no body');
    }

    /**
     * PATCH /accounts/{id} with a valid AccountDTO body should partially update
     * the in-memory account and return HTTP 204 No Content.
     *
     * Note: AccountsRequestHandlerDemo.handlePatch reads the account Id from
     * pathVariables ('id'), so the URI segment drives the lookup.
     */
    @IsTest
    private static void doPatch_shouldReturn204_whenValidAccountIdAndBodyAreProvided() {
        // Given
        String requestBody = JSON.serialize(new Map<String, Object>{
            'accountName' => 'Patched Corp'
        });
        setupRestContext('PATCH', '/accounts/5', requestBody, null);

        // When
        Test.startTest();
        RestEntryPoint.doPatch();
        Test.stopTest();

        // Then
        Assert.areEqual(204, RestContext.response.statusCode, 'Expected HTTP 204 No Content');
        Assert.isNull(RestContext.response.responseBody, 'PATCH 204 response should have no body');
    }

    /**
     * DELETE /accounts/{id} with an accountId query param pointing to an
     * existing in-memory account should return HTTP 204 No Content.
     *
     * Note: AccountsRequestHandlerDemo.handleDelete reads accountId from
     * request.params (query parameter), not from the URI path variable.
     */
    @IsTest
    private static void doDelete_shouldReturn204_whenValidAccountIdParamIsProvided() {
        // Given — account at index 7 is present in the 10-account default set
        setupRestContext(
            'DELETE',
            '/accounts/7',
            null,
            new Map<String, String>{ 'accountId' => '7' }
        );

        // When
        Test.startTest();
        RestEntryPoint.doDelete();
        Test.stopTest();

        // Then
        Assert.areEqual(204, RestContext.response.statusCode, 'Expected HTTP 204 No Content');
        Assert.isNull(RestContext.response.responseBody, 'DELETE 204 response should have no body');
    }

    /**
     * A GET request to a URI with no matching Endpoint_Definition__mdt record
     * should yield HTTP 404 with a JSON error body.
     * Exercises the RestException (HTTP_NOT_FOUND) catch branch.
     */
    @IsTest
    private static void doGet_shouldReturn404WithErrorBody_whenUriMatchesNoEndpointDefinition() {
        // Given — no endpoint pattern has three segments
        setupRestContext('GET', '/totally/nonexistent/route', null, null);

        // When
        Test.startTest();
        RestEntryPoint.doGet();
        Test.stopTest();

        // Then
        RestResponse res = RestContext.response;
        Assert.areEqual(404, res.statusCode, 'Expected HTTP 404 Not Found');
        Assert.isNotNull(res.responseBody, 'Error response body should be present');

        Map<String, Object> errorPayload = responseBodyAsMap();
        Assert.isTrue(
            errorPayload.containsKey('error'),
            'Error response body should contain an error key'
        );
        Assert.areEqual(
            'Endpoint not found or is invalid',
            (String) errorPayload.get('error'),
            'Error message should describe the not-found condition'
        );
    }

    /**
     * A GET request to /accounts matches the POST /accounts endpoint pattern
     * but not the GET method, so processRequest should return HTTP 405.
     * Exercises the RestException (HTTP_METHOD_NOT_ALLOWED) catch branch.
     */
    @IsTest
    private static void doGet_shouldReturn405WithErrorBody_whenMethodIsNotAllowedForMatchedPattern() {
        // Given — only POST is registered for the single-segment /accounts pattern
        setupRestContext('GET', '/accounts', null, null);

        // When
        Test.startTest();
        RestEntryPoint.doGet();
        Test.stopTest();

        // Then
        RestResponse res = RestContext.response;
        Assert.areEqual(405, res.statusCode, 'Expected HTTP 405 Method Not Allowed');
        Assert.isNotNull(res.responseBody, 'Error response body should be present');

        Map<String, Object> errorPayload = responseBodyAsMap();
        Assert.isTrue(
            errorPayload.containsKey('error'),
            'Error response body should contain an error key'
        );
        Assert.areEqual(
            'Method not allowed for endpoint',
            (String) errorPayload.get('error'),
            'Error message should describe the method-not-allowed condition'
        );
    }

    /**
     * A POST request with a malformed JSON body should cause JSON.deserialize
     * inside the handler to throw a JSONException, which processRequest catches
     * and maps to HTTP 400 Bad Request.
     */
    @IsTest
    private static void doPost_shouldReturn400WithErrorBody_whenRequestBodyContainsInvalidJson() {
        // Given — {invalid} is not legal JSON (unquoted key)
        setupRestContext('POST', '/accounts', '{invalid}', null);

        // When
        Test.startTest();
        RestEntryPoint.doPost();
        Test.stopTest();

        // Then
        RestResponse res = RestContext.response;
        Assert.areEqual(400, res.statusCode, 'Expected HTTP 400 Bad Request');
        Assert.isNotNull(res.responseBody, 'Error response body should be present');

        Map<String, Object> errorPayload = responseBodyAsMap();
        Assert.isTrue(
            errorPayload.containsKey('error'),
            'Error response body should contain an error key'
        );
    }

    /**
     * A GET request for an account Id that does not exist in AccountsServiceDemo
     * causes the service to throw a QueryException, which falls into the general
     * Exception catch block and maps to HTTP 500 Internal Server Error.
     */
    @IsTest
    private static void doGet_shouldReturn500WithErrorBody_whenHandlerThrowsUnhandledException() {
        // Given — accountId 999 is outside the 0–9 range initialised by AccountsServiceDemo
        setupRestContext(
            'GET',
            '/accounts/999',
            null,
            new Map<String, String>{ 'accountId' => '999' }
        );

        // When
        Test.startTest();
        RestEntryPoint.doGet();
        Test.stopTest();

        // Then
        RestResponse res = RestContext.response;
        Assert.areEqual(500, res.statusCode, 'Expected HTTP 500 Internal Server Error');
        Assert.isNotNull(res.responseBody, 'Error response body should be present');

        Map<String, Object> errorPayload = responseBodyAsMap();
        Assert.isTrue(
            errorPayload.containsKey('error'),
            'Error response body should contain an error key'
        );
        Assert.areEqual(
            'Internal Server Error',
            (String) errorPayload.get('error'),
            'Generic error message should be returned to the caller'
        );
    }

    /**
     * Matching /accounts/42 against the deployed GET pattern /accounts/{id}
     * should succeed, resolve to the GET method, and extract id=42 as a
     * path variable.
     */
    @IsTest
    private static void endpointDefinitionMatcher_shouldMatchDynamicSegmentAndExtractPathVariable_whenUriMatchesGetPattern() {
        // Given
        RestEntryPoint.EndpointDefinitionMatcher matcher = new RestEntryPoint.EndpointDefinitionMatcher();

        // When
        Test.startTest();
        RestEntryPoint.EndpointMatchResult result = matcher.match('/accounts/42', 'GET');
        Test.stopTest();

        // Then
        Assert.isNotNull(result, 'Matcher should return a non-null result for a matching URI');
        Assert.isNotNull(result.definition, 'Match result should carry the endpoint definition');
        Assert.areEqual(
            'AccountsRequestHandlerDemo',
            result.definition.Handler_Class__c,
            'Handler class should be AccountsRequestHandlerDemo'
        );
        Assert.isNotNull(result.pathVariables, 'Path variables map should not be null');
        Assert.areEqual(
            '42',
            result.pathVariables.get('id'),
            'Dynamic segment {id} should be extracted with value 42'
        );
    }

    /**
     * Matching /accounts/5 against the deployed POST pattern /accounts
     * succeeds for pattern matching but fails method resolution, so the matcher
     * should throw a RestException with statusCode 405.
     */
    @IsTest
    private static void endpointDefinitionMatcher_shouldThrow405RestException_whenMethodIsNotAllowedForPattern() {
        // Given
        RestEntryPoint.EndpointDefinitionMatcher matcher = new RestEntryPoint.EndpointDefinitionMatcher();

        // When / Then
        Test.startTest();
        try {
            matcher.match('/accounts', 'DELETE');
            Assert.fail('Expected a RestException to be thrown for method not allowed');
        } catch (RestException e) {
            Assert.areEqual(405, e.statusCode, 'RestException statusCode should be 405 Method Not Allowed');
            Assert.isTrue(
                e.getMessage().contains('Method not allowed'),
                'Exception message should describe the method-not-allowed condition'
            );
        }
        Test.stopTest();
    }

    /**
     * Matching a URI that has no corresponding Endpoint_Definition__mdt record
     * should throw a RestException with statusCode 404.
     */
    @IsTest
    private static void endpointDefinitionMatcher_shouldThrow404RestException_whenNoEndpointDefinitionMatchesUri() {
        // Given
        RestEntryPoint.EndpointDefinitionMatcher matcher = new RestEntryPoint.EndpointDefinitionMatcher();

        // When / Then
        Test.startTest();
        try {
            matcher.match('/no/such/endpoint/exists', 'GET');
            Assert.fail('Expected a RestException to be thrown for endpoint not found');
        } catch (RestException e) {
            Assert.areEqual(404, e.statusCode, 'RestException statusCode should be 404 Not Found');
            Assert.isTrue(
                e.getMessage().contains('Endpoint not found'),
                'Exception message should describe the not-found condition'
            );
        }
        Test.stopTest();
    }

    /**
     * URI normalisation inside the matcher should strip leading and trailing
     * slashes and query strings before segment comparison, so /accounts/5/
     * and /accounts/5?foo=bar should both resolve to the same GET endpoint.
     */
    @IsTest
    private static void endpointDefinitionMatcher_shouldNormalizeTrailingSlashAndQueryString_whenMatchingUri() {
        // Given
        RestEntryPoint.EndpointDefinitionMatcher matcher = new RestEntryPoint.EndpointDefinitionMatcher();

        // When — trailing slash variant
        Test.startTest();
        RestEntryPoint.EndpointMatchResult trailingSlashResult = matcher.match('/accounts/5/', 'GET');

        // And — query string variant
        RestEntryPoint.EndpointMatchResult queryStringResult = matcher.match('/accounts/5?foo=bar', 'GET');
        Test.stopTest();

        // Then
        Assert.isNotNull(trailingSlashResult, 'Trailing slash URI should still match the GET pattern');
        Assert.areEqual('5', trailingSlashResult.pathVariables.get('id'), 'Path variable id should be 5 for trailing-slash URI');

        Assert.isNotNull(queryStringResult, 'URI with query string should still match the GET pattern');
        Assert.areEqual('5', queryStringResult.pathVariables.get('id'), 'Path variable id should be 5 for query-string URI');
    }

    /**
     * EndpointMatchResult should store the endpoint definition and path
     * variable map passed to its constructor and expose them via its
     * public properties.
     */
    @IsTest
    private static void endpointMatchResult_shouldStoreDefinitionAndPathVariables_viaConstructor() {
        // Given
        Endpoint_Definition__mdt def = new Endpoint_Definition__mdt(
            Label = 'Test Definition',
            DeveloperName = 'Test_Definition',
            Endpoint_Pattern__c = '/accounts/{id}',
            Handler_Class__c = 'AccountsRequestHandlerDemo',
            Http_Method__c = 'GET',
            Is_Active__c = true
        );
        Map<String, String> pathVars = new Map<String, String>{ 'id' => '99' };

        // When
        Test.startTest();
        RestEntryPoint.EndpointMatchResult result = new RestEntryPoint.EndpointMatchResult(def, pathVars);
        Test.stopTest();

        // Then
        Assert.isNotNull(result, 'EndpointMatchResult should be instantiated');
        Assert.areEqual(def, result.definition, 'definition property should equal the value passed to the constructor');
        Assert.areEqual(pathVars, result.pathVariables, 'pathVariables property should equal the map passed to the constructor');
        Assert.areEqual('99', result.pathVariables.get('id'), 'id path variable should be accessible by key');
        Assert.areEqual('AccountsRequestHandlerDemo', result.definition.Handler_Class__c, 'Handler class should be readable from the stored definition');
    }

    /**
     * Configures RestContext with a new request and response so that the
     * @HttpXxx entry-point methods have a context to read from and write to.
     *
     * @param method  HTTP verb (GET, POST, PUT, PATCH, DELETE)
     * @param uri     Request URI matched against endpoint patterns (e.g. /accounts/3)
     * @param body    Optional JSON request body
     * @param params  Optional query parameters to pre-populate on the request
     */
    private static void setupRestContext(
        String method,
        String uri,
        String body,
        Map<String, String> params
    ) {
        RestRequest req = new RestRequest();
        req.httpMethod = method;
        req.requestURI = uri;

        if (String.isNotBlank(body)) {
            req.requestBody = Blob.valueOf(body);
        }
        if (params != null) {
            req.params.putAll(params);
        }

        RestContext.request = req;
        RestContext.response = new RestResponse();
    }

    /**
     * Returns the current response body as a deserialized map for field-level
     * assertions. Returns an empty map when no body has been set.
     */
    private static Map<String, Object> responseBodyAsMap() {
        Blob body = RestContext.response.responseBody;
        if (body == null) {
            return new Map<String, Object>();
        }
        return (Map<String, Object>) JSON.deserializeUntyped(body.toString());
    }
}