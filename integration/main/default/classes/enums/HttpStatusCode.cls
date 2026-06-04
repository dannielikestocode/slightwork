/**
 * Defines Status codes for Http Responses.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_restresponse.htm#apex_System_RestRequest_responseBody For legal response codes
 */
public enum HttpStatusCode {
    /**
     * Success Codes
     */
    HTTP_OK, // 200
    HTTP_CREATED, // 201
    HTTP_ACCEPTED, // 202

    /**
     * Client Error Codes
     */
    HTTP_BAD_REQUEST, // 400
    HTTP_UNAUTHORIZED, // 401
    HTTP_FORBIDDEN, // 403
    HTTP_NOT_FOUND, // 404
    HTTP_METHOD_NOT_ALLOWED, // 405

    /**
     * Server Error Codes
     */
    HTTP_INTERNAL_SERVER_ERROR, // 500
    HTTP_SERVICE_UNAVAILABLE // 503
}