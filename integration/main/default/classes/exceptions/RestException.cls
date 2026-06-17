/**
 * Custom exception class used to throw REST exceptions from Apex
 * REST logic.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_exception_methods.htm
 */
public without sharing class RestException extends Exception {
    /**
     * Properties
     */
    @AuraEnabled public final Integer statusCode {get; private set;}

    /**
     * Constructor with args
     * 
     * @param message The exception message
     * @param statusCode The Http Status Code enum
     */
    public RestException(String message, HttpContext.StatusCode statusCode) {
        this(message);
        this.statusCode = HttpContext.statusCodeToInteger(statusCode);
    }
}
