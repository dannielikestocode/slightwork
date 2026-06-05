/**
 * Contains context information and operations pertaining to Http.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
public with sharing class HttpContext {
    /**
     * Defines Status codes for Http Responses.
     * 
     * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status For full status code reference
     * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_restresponse.htm#apex_System_RestRequest_responseBody For legal response codes
     */
    public enum StatusCode {
        /**
         * Success Codes
         */
        HTTP_OK, // 200
        HTTP_CREATED, // 201
        HTTP_ACCEPTED, // 202
        HTTP_NO_CONTENT, // 204
        HTTP_PARTIAL_CONTENT, // 206

        /**
         * Redirection Codes
         */
        HTTP_MULTIPLE_CHOICES, // 300
        HTTP_MOVED_PERMANENTLY, // 301
        HTTP_FOUND, // 302
        HTTP_NOT_MODIFIED, // 304
        
        /**
         * Client Error Codes
         */
        HTTP_BAD_REQUEST, // 400
        HTTP_UNAUTHORIZED, // 401
        HTTP_FORBIDDEN, // 403
        HTTP_NOT_FOUND, // 404
        HTTP_METHOD_NOT_ALLOWED, // 405
        HTTP_NOT_ACCEPTABLE, // 406
        HTTP_CONFLICT, // 409
        HTTP_GONE, // 410
        HTTP_PRECONDITION_FAILED, // 412
        HTTP_REQUEST_ENTITY_TOO_LARGE, // 413
        HTTP_REQUEST_URI_TOO_LARGE, // 414
        HTTP_UNSUPPORTED_MEDIA_TYPE, // 415
        HTTP_EXPECTATION_FAILED, // 417

        /**
         * Server Error Codes
         */
        HTTP_INTERNAL_SERVER_ERROR, // 500
        HTTP_SERVER_UNAVAILABLE // 503
    }

    /**
     * Maps the status code enum to the respective code number
     * 
     * @param statusCodeEnum The Status Code enum
     * @return The mapped status code number integer
     */
    public static Integer statusCodeToInteger(StatusCode statusCodeEnum) {
        Integer mappedStatusCode;
        switch on statusCodeEnum {
            when HTTP_OK {
                mappedStatusCode = 200;
            }
            when HTTP_CREATED {
                mappedStatusCode = 201;
            }
            when HTTP_ACCEPTED {
                mappedStatusCode = 202;
            }
            when HTTP_NO_CONTENT {
                mappedStatusCode = 204;
            }
            when HTTP_PARTIAL_CONTENT {
                mappedStatusCode = 206;
            }
            when HTTP_MULTIPLE_CHOICES {
                mappedStatusCode = 300;
            }
            when HTTP_MOVED_PERMANENTLY {
                mappedStatusCode = 301;
            }
            when HTTP_FOUND {
                mappedStatusCode = 302;
            }
            when HTTP_NOT_MODIFIED {
                mappedStatusCode = 304;
            }
            when HTTP_BAD_REQUEST {
                mappedStatusCode = 400;
            }
            when HTTP_UNAUTHORIZED {
                mappedStatusCode = 401;
            }
            when HTTP_FORBIDDEN {
                mappedStatusCode = 403;
            }
            when HTTP_NOT_FOUND {
                mappedStatusCode = 404;
            }
            when HTTP_METHOD_NOT_ALLOWED {
                mappedStatusCode = 405;
            }
            when HTTP_NOT_ACCEPTABLE {
                mappedStatusCode = 406;
            }
            when HTTP_CONFLICT {
                mappedStatusCode = 409;
            }
            when HTTP_GONE {
                mappedStatusCode = 410;
            }
            when HTTP_PRECONDITION_FAILED {
                mappedStatusCode = 412;
            }
            when HTTP_REQUEST_ENTITY_TOO_LARGE {
                mappedStatusCode = 413;
            }
            when HTTP_REQUEST_URI_TOO_LARGE {
                mappedStatusCode = 414;
            }
            when HTTP_UNSUPPORTED_MEDIA_TYPE {
                mappedStatusCode = 415;
            }
            when HTTP_EXPECTATION_FAILED {
                mappedStatusCode = 417;
            }
            when HTTP_INTERNAL_SERVER_ERROR {
                mappedStatusCode = 500;
            }
            when HTTP_SERVER_UNAVAILABLE {
                mappedStatusCode = 503;
            }
            when else {
                mappedStatusCode = 500;
            }
        }
        return mappedStatusCode;
    }
}