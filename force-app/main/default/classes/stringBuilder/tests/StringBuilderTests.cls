/**
 * Test suite for the StringBuilder class.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
@IsTest
private class StringBuilderTests {
    /**
     * Private inner test class to validate
     * the toString() override
     */
    private class TestStringOverload { 
        public override String toString() { 
            return 'Test toString()'; 
        }
    }

    @IsTest
    private static void testDefaultsAndBuildEmpty() {
        StringBuilder sb = new StringBuilder();
        Assert.areEqual(0, sb.size, 'Default size should be 0');
        Assert.areEqual(true, sb.isEmpty, 'Default isEmpty should be true');
        Assert.areEqual('', sb.build(), 'Joining empty parts should yield empty string');
    }

    @IsTest
    private static void testWithFluentSetters() {
        StringBuilder sb = new StringBuilder()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_BLANK)
            .withTrimValue(true)
            .withSkipBlanks(true)
            .withDeduplicate(true)
            .withMaxLength(100)
            .withActionOnMaxLengthExceeded(StringBuilder.MaxLengthAction.TRUNCATE)
            .withDelimiter(',');

        // Exercise add and size/isEmpty updates
        sb.add(' a ').add('b').add('b').add(null).add('   ');
        // trimValue true -> ' a ' becomes 'a'
        // skipBlanks true -> '   ' skipped (handled in add based on processed)
        // deduplicate true -> duplicate 'b' ignored
        // actionOnNullValue -> blank string for null gets added, but later skipped by skipBlanks at add()
        Assert.areEqual(2, sb.size, 'Should only contain a and b');
        Assert.areEqual(false, sb.isEmpty, 'Should not be empty after adds');

        String result = sb.build();
        Assert.areEqual('a,b', result, 'Delimiter should be applied between unique, trimmed, non-blank values');
    }

    @IsTest
    private static void testAddObjectWithOverloadedToString() {
        StringBuilder sb = new StringBuilder().withTrimValue(true).withDelimiter('|');

        // Use TestStringOverload which overrides toString() to validate object handling
        TestStringOverload overload = new TestStringOverload();
        sb.add(overload).add(5).add(true);
        Assert.areEqual(3, sb.size, 'All object values should be added');
        Assert.areEqual(false, sb.isEmpty, 'Not empty after adds');
        Assert.areEqual('Test toString()|5|true', sb.build(), 'Should use overridden toString for object value');
    }

    @IsTest
    private static void testAddMixedObjectTypes() {
        StringBuilder sb = new StringBuilder().withTrimValue(true).withDelimiter('-');
        sb.addAll(new List<String>{' x ', 'y'});
        sb.addAll(new List<Object>{5.5, true, ' z ', 10});
        Assert.areEqual(6, sb.size, 'All items added across both overloads');
        Assert.areEqual('x-y-5.5-true-z-10', sb.build(), 'All items trimmed and joined with delimiter');
    }

    @IsTest
    private static void testNullHandlingSwitchCases() {
        // CONVERT_TO_BLANK
        StringBuilder sbBlank = new StringBuilder()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_BLANK)
            .withSkipBlanks(false);
        sbBlank.add(null);
        Assert.areEqual(1, sbBlank.size, 'Blank should be added when not skipping blanks');
        Assert.areEqual('', sbBlank.build(), 'Blank value contributes empty string');

        // CONVERT_TO_SINGLE_SPACE
        StringBuilder sbSpace = new StringBuilder()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_SINGLE_SPACE)
            .withDelimiter('.')
            .withSkipBlanks(false);
        sbSpace.add(null).add('a');
        Assert.areEqual(2, sbSpace.size, 'Single space should be added');

        // CONVERT_TO_LITERAL
        StringBuilder sbLiteral = new StringBuilder()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_LITERAL);
        sbLiteral.add(null);
        Assert.areEqual('null', sbLiteral.build(), 'Literal null should be added');
    }

    @IsTest
    private static void testTrimAndSkipBlanksInteraction() {
        StringBuilder sb = new StringBuilder()
            .withTrimValue(true)
            .withSkipBlanks(true)
            .withDelimiter(',');
        sb.add('  '); // becomes '' then skipped
        sb.add('  a  '); // becomes 'a'
        sb.add(''); // stays '' and skipped
        Assert.areEqual(1, sb.size, 'Only non-blank values after trimming should remain');
        Assert.areEqual('a', sb.build(), 'Only "a" should be included');
    }

    @IsTest
    private static void testDeduplication() {
        StringBuilder sb = new StringBuilder()
            .withDeduplicate(true)
            .withDelimiter(',');
        sb.add('x').add('x').add('y');
        Assert.areEqual(2, sb.size, 'Duplicate x should be ignored');
        Assert.areEqual('x,y', sb.build(), 'Should contain unique values only');
    }

    @IsTest
    private static void testMaxLengthThrowAndTruncate() {
        StringBuilder sbThrow = new StringBuilder()
            .withMaxLength(3)
            .withActionOnMaxLengthExceeded(StringBuilder.MaxLengthAction.THROW_EXCEPTION);
        sbThrow.add('abcd');
        Boolean exceptionThrown = false;
        try {
            sbThrow.build();
        } catch (IllegalStateException e) {
            exceptionThrown = true;
        }
        Assert.areEqual(true, exceptionThrown, 'Should throw exception when exceeding max length with THROW_EXCEPTION');

        // Truncate
        StringBuilder sbTrunc = new StringBuilder()
            .withMaxLength(3)
            .withActionOnMaxLengthExceeded(StringBuilder.MaxLengthAction.TRUNCATE);
        sbTrunc.add('abcd');
        Assert.areEqual('abc', sbTrunc.build(), 'Should truncate to max length');
    }

    @IsTest
    private static void testClear() {
        StringBuilder sb = new StringBuilder();
        sb.add('a').add('b');
        Assert.areEqual(2, sb.size, 'Precondition: two items before clear');
        sb.clear();
        Assert.areEqual(0, sb.size, 'Size should be zero after clear');
        Assert.areEqual(true, sb.isEmpty, 'Should report empty after clear');
    }
}
