public without sharing class ENV {

    private static Map<String, Environment_Variable__c> pending =
        new Map<String, Environment_Variable__c>();

    /*
     * Retrieves an environment variable value by key.
     */
    public static Object get(String key) {

        Environment_Variable__c record =
            Environment_Variable__c.getValues(key);

        if (record == null) {
            return null;
        }

        if (record.String_Value__c != null) {
            return record.String_Value__c;
        }

        if (record.Integer_Value__c != null) {
            return Integer.valueOf(record.Integer_Value__c);
        }

        if (record.Decimal_Value__c != null) {
            return record.Decimal_Value__c;
        }

        if (record.Boolean_Value__c != null) {
            return record.Boolean_Value__c;
        }

        if (record.Date_Value__c != null) {
            return record.Date_Value__c;
        }

        if (record.Datetime_Value__c != null) {
            return record.Datetime_Value__c;
        }

        return null;
    }

    /*
     * Adds/updates a pending environment variable.
     */
    public static void put(String key, Object value) {

        Environment_Variable__c record =
            createRecord(key, value);

        pending.put(key, record);
    }

    /*
     * Adds/updates and deploys immediately.
     */
    public static DeploymentResult putAndDeploy(
        String key,
        Object value
    ) {

        put(key, value);

        return deploy();
    }

    /*
     * Deploys all pending environment variables.
     */
    public static DeploymentResult deploy() {

        DeploymentResult result = new DeploymentResult();

        if (pending.isEmpty()) {
            return result;
        }

        List<Environment_Variable__c> records =
            pending.values();

        upsert records Key__c;

        result.records.addAll(records);

        pending.clear();

        return result;
    }

    /*
     * Creates a custom setting record from a typed value.
     */
    private static Environment_Variable__c createRecord(
        String key,
        Object value
    ) {

        Environment_Variable__c record =
            new Environment_Variable__c();

        record.Key__c = key;
        record.Name = key;

        if (value == null) {
            return record;
        }

        if (value instanceof String) {

            record.String_Value__c =
                (String)value;

        } else if (value instanceof Integer) {

            record.Integer_Value__c =
                (Integer)value;

        } else if (value instanceof Long) {

            record.Integer_Value__c =
                Decimal.valueOf(String.valueOf(value));

        } else if (value instanceof Decimal) {

            record.Decimal_Value__c =
                (Decimal)value;

        } else if (value instanceof Double) {

            record.Decimal_Value__c =
                Decimal.valueOf(String.valueOf(value));

        } else if (value instanceof Boolean) {

            record.Boolean_Value__c =
                (Boolean)value;

        } else if (value instanceof Date) {

            record.Date_Value__c =
                (Date)value;

        } else if (value instanceof Datetime) {

            record.Datetime_Value__c =
                (Datetime)value;

        } else {

            record.String_Value__c =
                JSON.serialize(value);
        }

        return record;
    }

    /*
     * Result object returned by deploy methods.
     */
    public class DeploymentResult {

        public List<Environment_Variable__c> records {
            get;
            private set;
        }

        public DeploymentResult() {
            records = new List<Environment_Variable__c>();
        }
    }
}