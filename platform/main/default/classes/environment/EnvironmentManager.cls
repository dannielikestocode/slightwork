/**
 * Handles managing the lifecycle of SlightWork's implementation of Environment Variables.
 * List Custom Settings needs to be enabled within an org.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/platform/environment-manager.html
 * @see https://help.salesforce.com/s/articleView?id=000383145&type=1 (For enablement of List Custom settings)
 */ 
public inherited sharing class EnvironmentManager {
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

    public enum DeploymentTarget {
        CUSTOM_SETTINGS
    }

    /**
     * Constructor
     */
    public EnvironmentManager(DeploymentTarget target) {
        if (target == null) {
            throw new IllegalArgumentException('Deployment Target cannot be null');
        }
        this.target = target;
    }

    private Map<String, EnvironmentVariable> loadEnvironmentVariables() {
        Map<String, EnvironmentVariable> envVars = new Map<String, EnvironmentVariable>();
        if (this.target == DeploymentTarget.CUSTOM_SETTINGS) {
            for (Environment_Variable__c record: Environment_Variable__c.getAll().values()) {
                envVars.put(record.Name, new EnvironmentVariable(record, false));
            }
        }
        return envVars;
    }

    /*
     * Retrieves an environment variable value by key.
     */
    public EnvironmentVariable get(String key) {
        if (String.isBlank(key)) {
            return null;
        }
        key = key.trim();

        // First, attempt to fetch environment variable
        // from in-memory map
        EnvironmentVariable envVar = this.envVars.get(key);
        if (envVar != null) {
            return envVar;
        }

        // If no match is found in-memory, attempt to
        // perform a match on any persisted Environment_Variable__c records
        Environment_Variable__c record = Environment_Variable__c.getValues(key);
        if (record != null) {
           envVar = new EnvironmentVariable(record, false);
           this.envVars.put(envVar.key, envVar);
           return envVar;
        }
        return null;
    }

    /*
     * Adds environment variable to in-memory map.
     */
    public void put(String key, Object value) {
        if (String.isBlank(key) || value == null) {
            return;
        }
        key = key.trim();
        this.envVars.put(key, buildNewEnvironmentVariable(key, value));
    }

    /*
     * Adds/updates and deploys immediately.
     */
    public DeploymentResult putAndDeploy(String key, Object value) {
        put(key, value);
        return deploy();
    }

    /*
     * Persists all in-memory environment variables.
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
            upsert recordsToDeploy Name;
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

    /*
     * Creates an EnvironmentVariable wrapper from a typed value.
     */
    private EnvironmentVariable buildNewEnvironmentVariable(String key, Object value) {
        EnvironmentVariable envVar = envVars.get(key);
        if (envVar == null) {
            Environment_Variable__c record = new Environment_Variable__c();
            record.Name = key;
            record.Value__c = String.valueOf(value);
            envVar = new EnvironmentVariable(record, true);
        }
        return envVar;
    }

    /*
     * Wrapper class for Environment_Variable__c custom setting.
     */
    public class EnvironmentVariable {
        public String key {get; private set;}
        public String value {get; private set;}
        public Boolean pendingDeployment {get; private set;}
        
        public EnvironmentVariable(Environment_Variable__c record, Boolean pendingDeployment) {
            this.key = record.Name;
            this.value = record.Value__c;
            this.pendingDeployment = pendingDeployment;
        }
    }

    /*
     * Result object returned by deploy methods.
     */
    public class DeploymentResult {
        public List<EnvironmentVariable> deployedVars {get; private set;}

        public DeploymentResult() {
            deployedVars = new List<EnvironmentVariable>();
        }

        public void addDeployedVariable(EnvironmentVariable deployedVar) {
            if (deployedVar == null) {
                return;
            }
            this.deployedVars.add(deployedVar);
        }
    }
}
