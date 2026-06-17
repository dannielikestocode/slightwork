/**
 * Test suite for the HttpContext class.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see HttpContext.cls
 */
@IsTest
private without sharing class HttpContextTests {
    @IsTest
    private static void testHttpMethodConstants() {
        Assert.areEqual('POST', HttpContext.POST_METHOD, 'POST_METHOD should be POST');
        Assert.areEqual('GET', HttpContext.GET_METHOD, 'GET_METHOD should be GET');
        Assert.areEqual('PUT', HttpContext.PUT_METHOD, 'PUT_METHOD should be PUT');
        Assert.areEqual('PATCH', HttpContext.PATCH_METHOD, 'PATCH_METHOD should be PATCH');
        Assert.areEqual('DELETE', HttpContext.DELETE_METHOD, 'DELETE_METHOD should be DELETE');
    }

    @IsTest
    private static void testStatusCodeMappings() {
        Map<HttpContext.StatusCode, Integer> expectedMappings = new Map<HttpContext.StatusCode, Integer>{
            HttpContext.StatusCode.HTTP_OK => 200,
            HttpContext.StatusCode.HTTP_CREATED => 201,
            HttpContext.StatusCode.HTTP_ACCEPTED => 202,
            HttpContext.StatusCode.HTTP_NO_CONTENT => 204,
            HttpContext.StatusCode.HTTP_PARTIAL_CONTENT => 206,

            HttpContext.StatusCode.HTTP_MULTIPLE_CHOICES => 300,
            HttpContext.StatusCode.HTTP_MOVED_PERMANENTLY => 301,
            HttpContext.StatusCode.HTTP_FOUND => 302,
            HttpContext.StatusCode.HTTP_NOT_MODIFIED => 304,

            HttpContext.StatusCode.HTTP_BAD_REQUEST => 400,
            HttpContext.StatusCode.HTTP_UNAUTHORIZED => 401,
            HttpContext.StatusCode.HTTP_FORBIDDEN => 403,
            HttpContext.StatusCode.HTTP_NOT_FOUND => 404,
            HttpContext.StatusCode.HTTP_METHOD_NOT_ALLOWED => 405,
            HttpContext.StatusCode.HTTP_NOT_ACCEPTABLE => 406,
            HttpContext.StatusCode.HTTP_CONFLICT => 409,
            HttpContext.StatusCode.HTTP_GONE => 410,
            HttpContext.StatusCode.HTTP_PRECONDITION_FAILED => 412,
            HttpContext.StatusCode.HTTP_REQUEST_ENTITY_TOO_LARGE => 413,
            HttpContext.StatusCode.HTTP_REQUEST_URI_TOO_LARGE => 414,
            HttpContext.StatusCode.HTTP_UNSUPPORTED_MEDIA_TYPE => 415,
            HttpContext.StatusCode.HTTP_EXPECTATION_FAILED => 417,

            HttpContext.StatusCode.HTTP_INTERNAL_SERVER_ERROR => 500,
            HttpContext.StatusCode.HTTP_SERVER_UNAVAILABLE => 503
        };

        for (HttpContext.StatusCode expectedStatusCode : expectedMappings.keySet()) {
            Integer actualStatusCode = HttpContext.statusCodeToInteger(expectedStatusCode);
            Assert.areEqual(expectedMappings.get(expectedStatusCode), actualStatusCode, 'Unexpected mapping for status code: ' + String.valueOf(expectedStatusCode));
        }
    }

    @IsTest
    private static void testStatusCodeEnumCount() {
        List<HttpContext.StatusCode> values = HttpContext.StatusCode.values();
        Assert.areEqual(24, values.size(), 'StatusCode enum count has changed. Update tests accordingly.');
    }
}