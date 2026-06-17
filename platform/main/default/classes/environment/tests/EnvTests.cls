/**
 * Test suite for the Env class.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see Env.cls
 */
@IsTest
private without sharing class EnvTests {
    /**
     * Constants
     */
    private static final String TEST_ENV_DEVELOPER_NAME = 'Test';

    @IsTest
    private static void testGetReturnsNullForNullKey() {
        Test.startTest();
        Env.EnvironmentVariable result = Env.get(null);
        Test.stopTest();

        // Assert
        Assert.areEqual(null, result, 'Null keys should return null');
    }

    @IsTest
    private static void testGetReturnsNullForBlankKey() {
        Test.startTest();
        Env.EnvironmentVariable result = Env.get('   ');
        Test.stopTest();

        // Assert
        Assert.areEqual(null, result, 'Blank keys should return null');
    }

    @IsTest
    private static void testGetReturnsExistingVariable() {
        Test.startTest();
        Env.EnvironmentVariable result = Env.get(TEST_ENV_DEVELOPER_NAME);
        Test.stopTest();

        // Assert
        Assert.areNotEqual(null, result, 'Expected environment variable to be returned');
        Assert.areEqual('Test', result.key);
        Assert.areEqual('Test', result.value);
    }

    @IsTest
    private static void testGetTrimsInputKey() {
        Test.startTest();
        Env.EnvironmentVariable result = Env.get('   ' + TEST_ENV_DEVELOPER_NAME + '   ');
        Test.stopTest();

        // Assert
        Assert.areNotEqual(null, result, 'Trimmed key should resolve successfully');
        Assert.areEqual('Test', result.value);
    }

    @IsTest
    private static void testGetReturnsNullForUnknownKey() {
        Test.startTest();
        Env.EnvironmentVariable result = Env.get('DOES_NOT_EXIST');
        Test.stopTest();

        // Assert
        Assert.areEqual(null, result, 'Unknown keys should return null');
    }

    @IsTest
    private static void testEnvironmentVariableConstructorSetsValues() {
        Test.startTest();
        Env.EnvironmentVariable envVar = new Env.EnvironmentVariable(
            'TEST_KEY',
            'TEST_VALUE'
        );
        Test.stopTest();

        // Assert
        Assert.areEqual('TEST_KEY', envVar.key);
        Assert.areEqual('TEST_VALUE', envVar.value);
    }

    @IsTest
    private static void testCacheReturnsSameVariable() {
        Test.startTest();
        Env.EnvironmentVariable first = Env.get(TEST_ENV_DEVELOPER_NAME);
        Env.EnvironmentVariable second = Env.get(TEST_ENV_DEVELOPER_NAME);
        Test.stopTest();

        // Assert
        Assert.areNotEqual(null, first);
        Assert.areNotEqual(null, second);
        Assert.areEqual(first.value, second.value, 'Cached value should be consistent');
    }
}