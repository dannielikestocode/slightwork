public without sharing class ENV {

    private static Map<String, EnvironmentVariable> envVars {
        get {
            if (envVars == null) {
                envVars = new Map<String,EnvironmentVariable>();
                for (Environment_Variable__c record: Environment_Variable__c.getAll().values()) {
                    envVars.put(record.Name, new EnvironmentVariable(record));
                }
            }
            return envVars;
        }
        set;
    }

    /*
     * Wrapper class for Environment_Variable__c custom setting.
     */
    public class EnvironmentVariable {

        public Environment_Variable__c record {get; private set;}
        private String key {get; set;}
        private String value {get; set;}
        private DataType currentDataType {get; set;}
        
        public EnvironmentVariable(Environment_Variable__c record) {
            this.key = record.Name;
            this.value = record.Value__c;
            this.currentDataType = record.Data_Type__c;
        }

        /*
         * Sets the value and clears other fields if data type changes.
         */
        public void setValue(Object value) {
            if (value == null) {
                return;
            }

            // Determine the new data type of the incoming value
            // and clear the data for all existing fields if the
            // data type isn't the same
            DataType newDataType = getDataType(value);
            if (currentDataType != null && currentDataType != newDataType) {
                clearAllFields();
            }

            if (value instanceof String) {
                record.String_Value__c = String.valueOf(value);
                currentDataType = DataType.STRING;
            } 
            else if (value instanceof Integer) {
                record.Integer_Value__c = (Integer)value;
                currentDataType = DataType.INTEGER;
            } 
            else if (value instanceof Long) {
                record.Integer_Value__c = Decimal.valueOf(String.valueOf(value));
                currentDataType = DataType.INTEGER;
            } else if (value instanceof Decimal) {

                record.Decimal_Value__c = (Decimal)value;
                currentDataType = DataType.DOUBLE;

            } else if (value instanceof Double) {

                record.Decimal_Value__c =
                    Decimal.valueOf(String.valueOf(value));
                currentDataType = DataType.DOUBLE;

            } else if (value instanceof Boolean) {

                record.Boolean_Value__c = (Boolean)value;
                currentDataType = DataType.BOOLEAN;

            } else if (value instanceof Date) {

                record.Date_Value__c = (Date)value;
                currentDataType = DataType.DATE;

            } else if (value instanceof Datetime) {

                record.Datetime_Value__c = (Datetime)value;
                currentDataType = DataType.DATETIME;

            } else {

                record.String_Value__c = JSON.serialize(value);
                currentDataType = DataType.STRING;
            }
        }

        /*
         * Gets the data type name for a given value.
         */
        public DataType getDataType(Object value) {
            if (value instanceof String) {
                return DataType.STRING;
            }
            else if (value instanceof Integer || value instanceof Long) {
                return DataType.INTEGER;
            }
            else if (value instanceof Decimal || value instanceof Double) {
                return DataType.DOUBLE;
            }
            else if (value instanceof Boolean) {
                return DataType.BOOLEAN;
            }
            else if (value instanceof Date) {
                return DataType.DATE;
            }
            else if (value instanceof Datetime) {
                return DataType.DATETIME;
            }
            return DataType.STRING;
        }
    }

    /*
     * Result object returned by deploy methods.
     */
    public class DeploymentResult {

        public List<EnvironmentVariable> records {get; private set;}

        public DeploymentResult() {
            records = new List<EnvironmentVariable>();
        }
    }

    /*
     * Retrieves an environment variable value by key.
     */
    public static EnvironmentVariable get(String key) {
        if (String.isBlank(key)) {
            return null;
        }
        key = key.trim();

        // First, attempt to fetch environment variable
        // from in-memory map
        EnvironmentVariable envVar = envVars.get(key);
        if (envVar != null) {
            return envVar;
        }

        // If no match founds within in-memory, attempt to
        // perform a match on any persisted Environment_Variable__c records
        Environment_Variable__c envVarRecord = Environment_Variable__c.getValues(key);
        if (envVarRecord != null) {
           envVar = new EnvironmentVariable(envVarRecord);
           envVars.put(envVar.Name, envVar);
           return envVar;
        }
        return null;
    }

    /*
     * Adds environment variable to in-memory map.
     */
    public static void put(String key, Object value) {
        if (String.isBlank(key) || value == null) {
            return null;
        }
        key = key.trim();
        EnvironmentVariable envVar = buildEnvironmentVariable(key, value);
    }

    /*
     * Adds/updates and deploys immediately.
     */
    public static DeploymentResult putAndDeploy(String key, Object value) {
        put(key, value);
        return deploy();
    }

    /*
     * Persists all in-memory environment variables.
     */
    public static DeploymentResult deploy() {
        DeploymentResult result = new DeploymentResult();
        if (envVars.isEmpty()) {
            return result;
        }

        List<Environment_Variable__c> records = new List<Environment_Variable__c>();
        for (EnvironmentVariable envVar : envVars.values()) {
            records.add(envVar.record);
        }
        upsert records Name;

        result.records.addAll(records);

        envVars.clear();

        return result;
    }

    /*
     * Creates an EnvironmentVariable wrapper from a typed value.
     */
    private static EnvironmentVariable buildEnvironmentVariable(String key, Object value) {
        EnvironmentVariable envVar = envVars.get(key);

        if (envVar == null) {
            Environment_Variable__c record = new Environment_Variable__c();
            record.Name = key;
            record.Value__c = String.valueOf(value);
            record.Data_Type__c = getDataType(value);
            envVar = new EnvironmentVariable(record);
        }
        envVar.setValue(value);
        
        envVars.put(key, envVar);

        return envVar;
    }
}
