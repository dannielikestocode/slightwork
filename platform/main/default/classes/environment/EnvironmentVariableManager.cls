/**
 * Handles managing the lifecycle of SlightWork's implementation of Environment Variables.
 * List Custom Settings needs to be enabled within an org.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/platform/environment-variable-manager.html
 * @see https://help.salesforce.com/s/articleView?id=000383145&type=1 (For enablement of List Custom settings)
 */ 
public inherited sharing class EnvironmentVariableManager {
    /**
     * Properties
     */
    private final DeploymentTarget target {get;set;}
    private Map<String, EnvironmentVariable> envVars {
        get {
            if (envVars == null) {
                envVars = loadEnvironmentVariables();
            }
            return envVars;
        }
        set;
    }

    /**
     * Enums
     */
    public enum DeploymentTarget {
        CUSTOM_SETTINGS
    }

    /**
     * Constructor
     */
    public EnvironmentVariableManager(DeploymentTarget target) {
        if (target == null) {
            throw new IllegalArgumentException('Deployment Target must be provided');
        }
        this.target = target;
    }

    /**
     * Retrieves an environment variable value by key.
     * First checks the in-memory map, then queries 
     * persisted records if not found.
     * 
     * @param key The key identifier for the environment variable
     * @return The EnvironmentVariable wrapper if found, null otherwise
     */
    public EnvironmentVariable get(String key) {
        if (String.isBlank(key)) {
            return null;
        }
        key = key.trim();

        // Attempt to fetch environment variable from in-memory map
        EnvironmentVariable envVar = this.envVars.get(key);
        if (envVar != null) {
            return envVar;
        }

        // If no match is found within the in-memory map, attempt to
        // perform a match on any persisted records
        Environment_Variable__c record = Environment_Variable__c.getValues(key);
        if (record != null) {
           envVar = new EnvironmentVariable(record.Name, record.Value__c, false);
           this.envVars.put(envVar.key, envVar);
           return envVar;
        }
        return null;
    }

    /**
     * Adds or updates an environment variable within the in-memory map.
     * The variable is pending deployment until deploy() is called.
     * 
     * @param key The key identifier for the environment variable
     * @param value The value to store (will be converted to String)
     */
    public void put(String key, Object value) {
        if (String.isBlank(key) || value == null) {
            return;
        }
        key = key.trim();
        this.envVars.put(key, buildNewEnvironmentVariable(key, value));
    }

    /**
     * Adds or updates an environment variable and immediately deploys it.
     * Convenience method that combines put() and deploy() operations.
     * 
     * @param key The key identifier for the environment variable
     * @param value The value to store (will be converted to String)
     * @return DeploymentResult containing the deployment status and deployed variables
     */
    public DeploymentResult putAndDeploy(String key, Object value) {
        put(key, value);
        return deploy();
    }

    /**
     * Persists all in-memory environment variables. Uses upsert operation 
     * to create or update Environment_Variable__c records.
     * 
     * @return DeploymentResult containing the deployment status and successfully deployed variables
     */
    public DeploymentResult deploy() {
        DeploymentResult result = new DeploymentResult();
        if (this.envVars.isEmpty()) {
            return result;
        }

        List<Environment_Variable__c> recordsToDeploy = new List<Environment_Variable__c>();
        for (EnvironmentVariable envVar : this.envVars.values()) {
            if (envVar.pendingDeployment) {
                Environment_Variable__c recordToDeploy = new Environment_Variable__c();
                recordToDeploy.Name = envVar.key;
                recordToDeploy.Value__c = envVar.value;
                recordsToDeploy.add(recordToDeploy);
            }
        }

        if (recordsToDeploy.isEmpty()) {
            return result;
        }

        try {
            Database.upsert(recordsToDeploy, Environment_Variable__c.Name, true, AccessLevel.USER_MODE);
            for (EnvironmentVariable envVar : envVars.values()) {
                if (envVar.pendingDeployment) {
                    envVar.pendingDeployment = false;
                    result.addDeployedVariable(envVar);
                }
            }
        }
        catch (Exception e) {
            System.debug('Failed to deploy pending environment variables: ' + e.getMessage());
        }
        return result;
    }

     /**
     * Loads all existing environment variables from the configured deployment target.
     * Currently supports Custom Settings as the deployment target.
     * 
     * @return Map of environment variable key to EnvironmentVariable wrapper
     */
    private Map<String, EnvironmentVariable> loadEnvironmentVariables() {
        Map<String, EnvironmentVariable> envVars = new Map<String, EnvironmentVariable>();
        if (this.target == DeploymentTarget.CUSTOM_SETTINGS) {
            for (Environment_Variable__c record: Environment_Variable__c.getAll().values()) {
                envVars.put(record.Name, new EnvironmentVariable(record.Name, record.Value__c, false));
            }
        }
        return envVars;
    }

    /**
     * Creates an EnvironmentVariable wrapper from a typed value. If the
     * variable already exists in memory, returns the existing instance.
     * Otherwise, creates a new instance marked for deployment.
     * 
     * @param key The key identifier for the environment variable
     * @param value The value to store (will be converted to String)
     * @return EnvironmentVariable wrapper instance
     */
    private EnvironmentVariable buildNewEnvironmentVariable(String key, Object value) {
        EnvironmentVariable envVar = envVars.get(key);
        if (envVar == null) {
            envVar = new EnvironmentVariable(key, String.valueOf(value), true);
        }
        else {
            envVar.value = String.valueOf(value);
            envVar.pendingDeployment = true; // Set to redeploy existing variable
        }
        return envVar;
    }

    /**
     * Domain class use to create instances of environment variables.
     * Encapsulates the key-value pair and deployment status.
     */
    public class EnvironmentVariable {
        /**
         * Properties
         */
        public String key {get; set;}
        public String value {get; set;}
        public Boolean pendingDeployment {get; set;}
        
        /**
         * Constructor with args
         * 
         * @param key The key to identify an environment variable
         * @param value The string value of an environment variable
         * @param pendingDeployment Indicates if an environment variable should be deployed
         */
        public EnvironmentVariable(String key, String value, Boolean pendingDeployment) {
            this.key = key;
            this.value = value;
            this.pendingDeployment = pendingDeployment;
        }
    }

    /**
     * Result object returned by deploy methods.
     * Contains a list of successfully deployed environment variables.
     */
    public class DeploymentResult {
        /**
         * Properties
         */
        public List<EnvironmentVariable> deployedVariables {get; private set;}

        /**
         * No-arg constructor
         */
        public DeploymentResult() {
            deployedVariables = new List<EnvironmentVariable>();
        }

        /**
         * Adds a successfully deployed environment variable to the result.
         * 
         * @param deployedVariable The environment variable that was successfully deployed
         */
        public void addDeployedVariable(EnvironmentVariable deployedVariable) {
            if (deployedVariable == null) {
                return;
            }
            this.deployedVariables.add(deployedVariable);
        }
    }
}
