/**
 * Handles managing interactions with SlightWork's concept of
 * Environment Variables within an org.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/platform/env.html
 */ 
public inherited sharing class Env {
    /**
     * Derived Properties
     */
    private static Map<String, EnvironmentVariable> variables {
        get {
            if (variables == null) {
                variables = loadEnvironmentVariables();
            }
            return variables;
        }
        set;
    }

    /**
     * Retrieves an environment variable value by key.
     * First checks the in-memory map, then queries 
     * persisted records if not found.
     * 
     * @param key The key identifier for the environment variable
     * @return The EnvironmentVariable wrapper if found, null otherwise
     */
    public static EnvironmentVariable get(String developerName) {
        if (String.isBlank(developerName)) {
            return null;
        }
        developerName = developerName.trim();

        // Attempt to fetch environment variable from in-memory map
        EnvironmentVariable envVar = variables.get(developerName);
        if (envVar != null) {
            return envVar;
        }
        return null;
    }

     /**
     * Loads all existing environment variables from the configured deployment target.
     * Currently supports Custom Settings as the deployment target.
     * 
     * @return Map of environment variable key to EnvironmentVariable wrapper
     */
    private static Map<String, EnvironmentVariable> loadEnvironmentVariables() {
        Map<String, EnvironmentVariable> variables = new Map<String, EnvironmentVariable>();
        for (Environment_Variable__mdt record: Environment_Variable__mdt.getAll().values()) {
            variables.put(record.DeveloperName, new EnvironmentVariable(record.DeveloperName, record.Value__c));
        }
        return variables;
    }

    /**
     * Domain class use to create instances of environment variables.
     * Encapsulates the key-value pair and deployment status.
     */
    public class EnvironmentVariable {
        /**
         * Properties
         */
        public final String key {get; private set;}
        public final String value {get; private set;}
        
        /**
         * Constructor with args
         * 
         * @param key The key to identify an environment variable
         * @param value The string value of an environment variable
         */
        public EnvironmentVariable(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }
}
