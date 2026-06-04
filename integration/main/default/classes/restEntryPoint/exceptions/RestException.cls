/**
 * The RestException is used to throw exceptions pertaining
 * to processing errors of Apex REST requests.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
public without sharing class RestException extends Exception {
    /**
     * Properies
     */
    @AuraEnabled public final Integer statusCode {get; private set;}

    /**
     * Constructor with args
     * 
     * @param message The exception message
     * @param statusCode The status code enum
     */
    public RestException(String message, HttpStatusCode statusCode) {
        this(message);
        this.statusCode = this.mapStatusCodeToInteger(statusCode);
    }

    /**
     * Maps the status code enum to the respective code number
     * 
     * @param statusCode The Status Code enum
     * @return The mapped status code number
     */
    private Integer mapStatusCodeToInteger(HttpStatusCode statusCode) {
        Integer mappedStatusCode;
        switch on statusCode {
            when HTTP_OK {
                mappedStatusCode = 200;
            }
            when HTTP_CREATED {
                mappedStatusCode = 201;
            }
            when HTTP_ACCEPTED {
                mappedStatusCode = 202;
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
            when HTTP_INTERNAL_SERVER_ERROR {
                mappedStatusCode = 500;
            }
            when HTTP_SERVICE_UNAVAILABLE {
                mappedStatusCode = 503;
            }
        }
        return mappedStatusCode;
    }
}   
