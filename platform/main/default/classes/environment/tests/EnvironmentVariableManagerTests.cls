/**
 * Test class for EnvironmentVariableManager.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see EnvironmentVariableManager.cls
 */
@IsTest
private without sharing class EnvironmentVariableManagerTests {
    /**
     * Test setup method to create test data
     */
    @TestSetup
    private static void setupTestData() {
        // Create test environment variables in custom settings
        List<Environment_Variable__c> testVars = new List<Environment_Variable__c>();
        
        testVars.add(new Environment_Variable__c(
            Name = 'TEST_API_KEY',
            Value__c = 'test-api-key-123'
        ));
        
        testVars.add(new Environment_Variable__c(
            Name = 'TEST_ENDPOINT',
            Value__c = 'https://test.example.com/api'
        ));
        
        testVars.add(new Environment_Variable__c(
            Name = 'TEST_TIMEOUT',
            Value__c = '30000'
        ));
        
        insert testVars;
    }
    
    /**
     * Test constructor with valid deployment target
     */
    @IsTest
    private static void testConstructorWithValidTarget() {
        Test.startTest();
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        Test.stopTest();
        
        Assert.isNotNull(manager, 'Manager should be instantiated');
    }
    
    /**
     * Test constructor with null deployment target
     */
    @IsTest
    private static void testConstructorWithNullTarget() {
        Exception caughtException;
        
        Test.startTest();
        try {
            EnvironmentVariableManager manager = new EnvironmentVariableManager(null);
            Assert.fail('Expected IllegalArgumentException to be thrown');
        } catch (IllegalArgumentException e) {
            caughtException = e;
        }
        Test.stopTest();
        
        Assert.isNotNull(caughtException, 'Exception should have been thrown');
        Assert.isTrue(
            caughtException.getMessage().contains('Deployment Target must be provided'),
            'Exception message should indicate null target'
        );
    }
    
    /**
     * Test get() method with existing environment variable
     */
    @IsTest
    private static void testGetExistingVariable() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        EnvironmentVariableManager.EnvironmentVariable result = manager.get('TEST_API_KEY');
        Test.stopTest();
        
        Assert.isNotNull(result, 'Should retrieve existing variable');
        Assert.areEqual('TEST_API_KEY', result.key, 'Key should match');
        Assert.areEqual('test-api-key-123', result.value, 'Value should match');
        Assert.areEqual(false, result.pendingDeployment, 'Should not be pending deployment');
    }
    
    /**
     * Test get() method with non-existent variable
     */
    @IsTest
    private static void testGetNonExistentVariable() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        EnvironmentVariableManager.EnvironmentVariable result = manager.get('NONEXISTENT_KEY');
        Test.stopTest();
        
        Assert.isNull(result, 'Should return null for non-existent variable');
    }
    
    /**
     * Test get() method with blank key
     */
    @IsTest
    private static void testGetWithBlankKey() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        EnvironmentVariableManager.EnvironmentVariable result1 = manager.get('');
        EnvironmentVariableManager.EnvironmentVariable result2 = manager.get(null);
        EnvironmentVariableManager.EnvironmentVariable result3 = manager.get('   ');
        Test.stopTest();
        
        Assert.isNull(result1, 'Should return null for empty string');
        Assert.isNull(result2, 'Should return null for null key');
        Assert.isNull(result3, 'Should return null for whitespace key');
    }
    
    /**
     * Test get() method with key that has leading/trailing whitespace
     */
    @IsTest
    private static void testGetWithWhitespaceInKey() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        EnvironmentVariableManager.EnvironmentVariable result = manager.get('  TEST_API_KEY  ');
        Test.stopTest();
        
        Assert.isNotNull(result, 'Should retrieve variable after trimming whitespace');
        Assert.areEqual('TEST_API_KEY', result.key, 'Key should be trimmed');
    }
    
    /**
     * Test put() method adds new variable to in-memory map
     */
    @IsTest
    private static void testPutNewVariable() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        manager.put('NEW_VARIABLE', 'new-value-123');
        EnvironmentVariableManager.EnvironmentVariable result = manager.get('NEW_VARIABLE');
        Test.stopTest();
        
        Assert.isNotNull(result, 'Should retrieve newly added variable');
        Assert.areEqual('NEW_VARIABLE', result.key, 'Key should match');
        Assert.areEqual('new-value-123', result.value, 'Value should match');
        Assert.areEqual(true, result.pendingDeployment, 'Should be pending deployment');
    }
    
    /**
     * Test put() method with different value types
     */
    @IsTest
    private static void testPutWithDifferentValueTypes() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        manager.put('STRING_VAR', 'string value');
        manager.put('INTEGER_VAR', 12345);
        manager.put('DECIMAL_VAR', 123.45);
        manager.put('BOOLEAN_VAR', true);
        Test.stopTest();
        
        Assert.areEqual('string value', manager.get('STRING_VAR').value, 'String value should be stored');
        Assert.areEqual('12345', manager.get('INTEGER_VAR').value, 'Integer should be converted to string');
        Assert.areEqual('123.45', manager.get('DECIMAL_VAR').value, 'Decimal should be converted to string');
        Assert.areEqual('true', manager.get('BOOLEAN_VAR').value, 'Boolean should be converted to string');
    }
    
    /**
     * Test put() method with blank key or null value
     */
    @IsTest
    private static void testPutWithInvalidInputs() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        manager.put('', 'value');
        manager.put(null, 'value');
        manager.put('KEY', null);
        manager.put('   ', 'value');
        Test.stopTest();
        
        // Should not throw exceptions, just ignore invalid inputs
        Assert.isNull(manager.get(''), 'Should not store variable with empty key');
        Assert.isNull(manager.get('KEY'), 'Should not store variable with null value');
    }
    
    /**
     * Test put() method trims whitespace from key
     */
    @IsTest
    private static void testPutTrimsWhitespace() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        manager.put('  TRIMMED_KEY  ', 'trimmed-value');
        EnvironmentVariableManager.EnvironmentVariable result = manager.get('TRIMMED_KEY');
        Test.stopTest();
        
        Assert.isNotNull(result, 'Should retrieve variable with trimmed key');
        Assert.areEqual('TRIMMED_KEY', result.key, 'Key should be trimmed');
    }
    
    /**
     * Test deploy() method persists pending variables
     */
    @IsTest
    private static void testDeployPendingVariables() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        manager.put('DEPLOY_TEST_1', 'value1');
        manager.put('DEPLOY_TEST_2', 'value2');
        
        Test.startTest();
        EnvironmentVariableManager.DeploymentResult result = manager.deploy();
        Test.stopTest();
        
        Assert.areEqual(2, result.deployedVariables.size(), 'Should deploy 2 variables');
        
        // Verify variables are persisted
        Environment_Variable__c persisted1 = Environment_Variable__c.getValues('DEPLOY_TEST_1');
        Environment_Variable__c persisted2 = Environment_Variable__c.getValues('DEPLOY_TEST_2');
        
        Assert.isNotNull(persisted1, 'Variable 1 should be persisted');
        Assert.areEqual('value1', persisted1.Value__c, 'Variable 1 value should match');
        Assert.isNotNull(persisted2, 'Variable 2 should be persisted');
        Assert.areEqual('value2', persisted2.Value__c, 'Variable 2 value should match');
        
        // Verify variables are no longer pending deployment
        Assert.areEqual(false, manager.get('DEPLOY_TEST_1').pendingDeployment, 'Should not be pending after deploy');
        Assert.areEqual(false, manager.get('DEPLOY_TEST_2').pendingDeployment, 'Should not be pending after deploy');
    }
    
    /**
     * Test deploy() method with no pending variables
     */
    @IsTest
    private static void testDeployWithNoPendingVariables() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        // Get existing variable (not pending)
        manager.get('TEST_API_KEY');
        
        Test.startTest();
        EnvironmentVariableManager.DeploymentResult result = manager.deploy();
        Test.stopTest();
        
        Assert.areEqual(0, result.deployedVariables.size(), 'Should deploy 0 variables');
    }
    
    /**
     * Test deploy() updates existing variables
     */
    @IsTest
    private static void testDeployUpdatesExistingVariables() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        // Update existing variable
        manager.put('TEST_API_KEY', 'updated-api-key-456');
        
        Test.startTest();
        EnvironmentVariableManager.DeploymentResult result = manager.deploy();
        Test.stopTest();
        
        Assert.areEqual(1, result.deployedVariables.size(), 'Should deploy 1 variable');
        
        // Verify variable is updated
        Environment_Variable__c persisted = Environment_Variable__c.getValues('TEST_API_KEY');
        Assert.areEqual('updated-api-key-456', persisted.Value__c, 'Variable should be updated');
    }
    
    /**
     * Test putAndDeploy() convenience method
     */
    @IsTest
    private static void testPutAndDeploy() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        EnvironmentVariableManager.DeploymentResult result = manager.putAndDeploy('IMMEDIATE_VAR', 'immediate-value');
        Test.stopTest();
        
        Assert.areEqual(1, result.deployedVariables.size(), 'Should deploy 1 variable');
        Assert.areEqual('IMMEDIATE_VAR', result.deployedVariables[0].key, 'Deployed variable key should match');
        
        // Verify variable is persisted
        Environment_Variable__c persisted = Environment_Variable__c.getValues('IMMEDIATE_VAR');
        Assert.isNotNull(persisted, 'Variable should be persisted');
        Assert.areEqual('immediate-value', persisted.Value__c, 'Variable value should match');
        
        // Verify not pending deployment
        Assert.areEqual(false, manager.get('IMMEDIATE_VAR').pendingDeployment, 'Should not be pending after deploy');
    }
    
    /**
     * Test DeploymentResult.addDeployedVariable() method
     */
    @IsTest
    private static void testDeploymentResultAddVariable() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        EnvironmentVariableManager.DeploymentResult result = new EnvironmentVariableManager.DeploymentResult();
        
        Environment_Variable__c record = new Environment_Variable__c(
            Name = 'TEST_VAR',
            Value__c = 'test-value'
        );
        EnvironmentVariableManager.EnvironmentVariable envVar = new EnvironmentVariableManager.EnvironmentVariable(record.Name, record.Value__c, false);
        
        Test.startTest();
        result.addDeployedVariable(envVar);
        Test.stopTest();
        
        Assert.areEqual(1, result.deployedVariables.size(), 'Should have 1 deployed variable');
        Assert.areEqual('TEST_VAR', result.deployedVariables[0].key, 'Variable key should match');
    }
    
    /**
     * Test DeploymentResult.addDeployedVariable() with null
     */
    @IsTest
    private static void testDeploymentResultAddNullVariable() {
        EnvironmentVariableManager.DeploymentResult result = new EnvironmentVariableManager.DeploymentResult();
        
        Test.startTest();
        result.addDeployedVariable(null);
        Test.stopTest();
        
        Assert.areEqual(0, result.deployedVariables.size(), 'Should not add null variable');
    }
    
    /**
     * Test EnvironmentVariable wrapper construction
     */
    @IsTest
    private static void testEnvironmentVariableWrapper() {
        Environment_Variable__c record = new Environment_Variable__c(
            Name = 'WRAPPER_TEST',
            Value__c = 'wrapper-value'
        );
        
        Test.startTest();
        EnvironmentVariableManager.EnvironmentVariable envVar1 = new EnvironmentVariableManager.EnvironmentVariable(record.Name, record.Value__c, true);
        EnvironmentVariableManager.EnvironmentVariable envVar2 = new EnvironmentVariableManager.EnvironmentVariable(record.Name, record.Value__c, false);
        Test.stopTest();
        
        Assert.areEqual('WRAPPER_TEST', envVar1.key, 'Key should match');
        Assert.areEqual('wrapper-value', envVar1.value, 'Value should match');
        Assert.areEqual(true, envVar1.pendingDeployment, 'Should be pending deployment');
        Assert.areEqual(false, envVar2.pendingDeployment, 'Should not be pending deployment');
    }
    
    /**
     * Test multiple operations in sequence
     */
    @IsTest
    private static void testMultipleOperationsSequence() {
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        
        Test.startTest();
        
        // Add multiple variables
        manager.put('SEQ_VAR_1', 'value1');
        manager.put('SEQ_VAR_2', 'value2');
        manager.put('SEQ_VAR_3', 'value3');
        
        // Retrieve before deploy
        Assert.isNotNull(manager.get('SEQ_VAR_1'), 'Should get variable before deploy');
        Assert.areEqual(true, manager.get('SEQ_VAR_1').pendingDeployment, 'Should be pending');
        
        // Deploy
        EnvironmentVariableManager.DeploymentResult result = manager.deploy();
        Assert.areEqual(3, result.deployedVariables.size(), 'Should deploy 3 variables');
        
        // Update one variable
        manager.put('SEQ_VAR_2', 'updated-value2');
        Assert.areEqual(true, manager.get('SEQ_VAR_2').pendingDeployment, 'Should be pending after update');
        
        // Deploy again
        result = manager.deploy();
        Assert.areEqual(1, result.deployedVariables.size(), 'Should deploy 1 updated variable');
        
        Test.stopTest();
        
        // Verify final state
        Assert.areEqual('value1', Environment_Variable__c.getValues('SEQ_VAR_1').Value__c);
        Assert.areEqual('updated-value2', Environment_Variable__c.getValues('SEQ_VAR_2').Value__c);
        Assert.areEqual('value3', Environment_Variable__c.getValues('SEQ_VAR_3').Value__c);
    }
    
    /**
     * Test that existing variables are loaded on initialization
     */
    @IsTest
    private static void testLoadExistingVariablesOnInit() {
        Test.startTest();
        EnvironmentVariableManager manager = new EnvironmentVariableManager(
            EnvironmentVariableManager.DeploymentTarget.CUSTOM_SETTINGS
        );
        Test.stopTest();
        
        // Should be able to retrieve test data created in @TestSetup
        EnvironmentVariableManager.EnvironmentVariable var1 = manager.get('TEST_API_KEY');
        EnvironmentVariableManager.EnvironmentVariable var2 = manager.get('TEST_ENDPOINT');
        EnvironmentVariableManager.EnvironmentVariable var3 = manager.get('TEST_TIMEOUT');
        
        Assert.isNotNull(var1, 'Should load existing variable 1');
        Assert.isNotNull(var2, 'Should load existing variable 2');
        Assert.isNotNull(var3, 'Should load existing variable 3');
        Assert.areEqual('test-api-key-123', var1.value, 'Value 1 should match');
        Assert.areEqual('https://test.example.com/api', var2.value, 'Value 2 should match');
        Assert.areEqual('30000', var3.value, 'Value 3 should match');
    }
}