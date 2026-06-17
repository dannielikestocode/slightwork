/**
 * Test suite for the CalloutManager class.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see CalloutManager.cls
 */
@IsTest
private without sharing class CalloutManagerTests {
    /**
     * Test Constants
     */
    private static final String DEFAULT_TEST_CONFIG_NAME = 'Random_Joke_Demo';

    @IsTest
    private static void testConstructor_acceptsCalloutConfigurationRecord() {
        // This test attempts to instantiate CalloutManager with a Callout_Configuration__mdt record
        Callout_Configuration__mdt config = Callout_Configuration__mdt.getInstance(DEFAULT_TEST_CONFIG_NAME);
        CalloutManager callout = new CalloutManager(config);

        // Assertions
        Assert.areEqual(config.Endpoint__c, callout.endpoint, 'Endpoint should come from config');
        Assert.areEqual(config.Method__c.toUpperCase(), callout.method, 'Method should come from config');
        Assert.areEqual(Integer.valueOf(config.Timeout__c), callout.timeout, 'Timeout should come from config');
    }

    @IsTest
    private static void testBuildRequest_ValidState() {
        CalloutManager callout = new CalloutManager();
        callout.withCalloutName('MyCallout');
        callout.withFullEndpoint('https://example.com/api');
        callout.withHttpMethod('POST');
        callout.withTimeout(5000);
        callout.withCompression(false);
        callout.withHeader('X-Test','value');
        callout.withUrlParam('q','1');
        callout.withBody('{"data":"x"}');

        Test.startTest();
        HttpRequest req = callout.buildRequest();
        Test.stopTest();

        // Assert request properties
        Assert.isNotNull(req, 'HttpRequest should be built');
        Assert.areEqual('POST', req.getMethod(), 'Method should be POST');
        Assert.areEqual('https://example.com/api?q=1', req.getEndpoint(), 'Endpoint should include query param');
        Assert.areEqual('{"data":"x"}', req.getBody(), 'Body should match');
        Assert.areEqual('value', req.getHeader('X-Test'), 'Header should be present');
    }

    @IsTest
    private static void testBuildRequest_invalidStates_and_inputs() {
        // withCalloutName blank
        CalloutManager callout = new CalloutManager();
        try {
            callout.withCalloutName('');
            Assert.fail('Expected IllegalArgumentException for blank callout name');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank callout name should throw');
        }

        // withFullEndpoint blank
        try {
            callout.withFullEndpoint('');
            Assert.fail('Expected IllegalArgumentException for blank endpoint');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank endpoint should throw');
        }

        // withHttpMethod blank / unsupported
        try {
            callout.withHttpMethod('');
            Assert.fail('Expected IllegalArgumentException for blank method');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank method should throw');
        }
        try {
            callout.withHttpMethod('UNKNOWN');
            Assert.fail('Expected IllegalArgumentException for unsupported method');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Unsupported method should throw');
        }

        // withBody blank
        try {
            callout.withBody('');
            Assert.fail('Expected IllegalArgumentException for blank body');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank body should throw');
        }

        // withBodyAsBlob null
        try {
            callout.withBodyAsBlob(null);
            Assert.fail('Expected IllegalArgumentException for null blob');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Null blob should throw');
        }

        // withBodyAsDocument null
        try {
            callout.withBodyAsDocument(null);
            Assert.fail('Expected IllegalArgumentException for null document');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Null document should throw');
        }

        // withTimeout invalid
        try {
            callout.withTimeout(0);
            Assert.fail('Expected IllegalArgumentException for timeout < MIN');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Invalid timeout should throw');
        }
        try {
            callout.withTimeout(CalloutManager.MAX_TIMEOUT + 1);
            Assert.fail('Expected IllegalArgumentException for timeout > MAX');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Invalid timeout should throw');
        }

        // withCompression null
        try {
            callout.withCompression(null);
            Assert.fail('Expected IllegalArgumentException for null compressed');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Null compression should throw');
        }

        // withClientCertificate blank
        try {
            callout.withClientCertificate('');
            Assert.fail('Expected IllegalArgumentException for blank certificate name');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank certificate should throw');
        }

        // withHeader blank key
        try {
            callout.withHeader('', 'v');
            Assert.fail('Expected IllegalArgumentException for blank header key');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank header key should throw');
        }

        // withHeaders null/empty
        try {
            callout.withHeaders(null);
            Assert.fail('Expected IllegalArgumentException for null headers');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Null headers should throw');
        }
        try {
            callout.withHeaders(new Map<String,String>());
            Assert.fail('Expected IllegalArgumentException for empty headers');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Empty headers should throw');
        }

        // withUrlParam blank key
        try {
            callout.withUrlParam('', 'v');
            Assert.fail('Expected IllegalArgumentException for blank query key');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank query key should throw');
        }

        // withUrlParams null/empty
        try {
            callout.withUrlParams(null);
            Assert.fail('Expected IllegalArgumentException for null query params');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Null query params should throw');
        }
        try {
            callout.withUrlParams(new Map<String,String>());
            Assert.fail('Expected IllegalArgumentException for empty query params');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Empty query params should throw');
        }

        // withNamedCredential blank
        try {
            callout.withNamedCredential('');
            Assert.fail('Expected IllegalArgumentException for blank named credential');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Blank named credential should throw');
        }

        // withEncodeUrlParams with null value
        try {
            callout.withEncodeUrlParams(null);
            // no exception expected for valid boolean
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalArgumentException.class, 'Null query params should throw');
        }
    }

    @IsTest
    private static void testSend_withMockResponse_and_CalloutResult() {
        // Register mock
        Test.setMock(HttpCalloutMock.class, new SimpleMock());

        CalloutManager callout = new CalloutManager();
        callout.withFullEndpoint('https://api.example.com/resource')
          .withHttpMethod('GET')
          .withCalloutName('TestSend')
          .withHeader('Accept','application/json');

        Test.startTest();
        CalloutManager.CalloutResult result = callout.send();
        Test.stopTest();

        // Validate CalloutResult and inner Request__c mapping
        Assert.isNotNull(result, 'CalloutResult should not be null');
        Assert.areEqual(200, result.statusCode, 'Status code should be 200');
        Assert.areEqual('OK', result.status, 'Status text should be OK');
        Assert.isNotNull(result.responseBody, 'Response body should be present');
        // Request record should be built
        Assert.isNotNull(result.requestRecord, 'Request__c record should be constructed in memory');
        Assert.areEqual('GET', result.requestRecord.Method__c, 'Request record method should be GET');
        Assert.isNotNull(result.requestRecord.Endpoint__c, 'Request record should have endpoint');
        Assert.isNotNull(result.requestRecord.Response_Body__c, 'Response body should be recorded');
    }

    @IsTest
    private static void testValidateState_conflicting_bodies_throws() {
        CalloutManager callout = new CalloutManager();
        callout.withFullEndpoint('https://example.com')
          .withHttpMethod('POST')
          .withBody('string body');

        // set blobBody via reflection-like approach by using withBodyAsBlob to provoke error
        try {
            callout.withBodyAsBlob(Blob.valueOf('xyz'));
            // After setting both, buildRequest should throw IllegalStateException when validateState runs
            callout.buildRequest();
            Assert.fail('Expected IllegalStateException when multiple body types are provided');
        } catch (Exception ex) {
            Assert.isInstanceOfType(ex, IllegalStateException.class, 'Conflicting body types should throw IllegalStateException');
        }
    }

    // Simple HttpCalloutMock to return a predictable response
    private class SimpleMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"success":true,"message":"ok"}');
            res.setHeader('Content-Type','application/json');
            return res;
        }
    }
}