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
    private static void testAddObjectWithOverloadedToString() {
        StringBuilder.BuilderOptions options = new StringBuilder.BuilderOptions()
            .withTrimValue(true).
            withDelimiter('|');
        StringBuilder sb = new StringBuilder(options);

        // Use TestStringOverload which overrides toString() to validate object handling
        TestStringOverload overload = new TestStringOverload();
        sb.append(overload).append(5).append(true);
        Assert.areEqual(3, sb.size, 'All object values should be added');
        Assert.areEqual(false, sb.isEmpty, 'Not empty after adds');
        Assert.areEqual('Test toString()|5|true', sb.build(), 'Should use overridden toString for object value');
    }

    @IsTest
    private static void testAddMixedObjectTypes() {
        StringBuilder.BuilderOptions options = new StringBuilder.BuilderOptions()
            .withTrimValue(true)
            .withDelimiter('-');
        StringBuilder sb = new StringBuilder(options);
        sb.appendAll(new List<String>{' x ', 'y'});
        sb.appendAll(new List<Object>{5.5, true, ' z ', 10});
        Assert.areEqual(6, sb.size, 'All items added across both overloads');
        Assert.areEqual('x-y-5.5-true-z-10', sb.build(), 'All items trimmed and joined with delimiter');
    }

    @IsTest
    private static void testNullHandlingSwitchCases() {
        // CONVERT_TO_BLANK
         StringBuilder.BuilderOptions options = new StringBuilder.BuilderOptions()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_BLANK)
            .withSkipBlanks(false);
        StringBuilder sbBlank = new StringBuilder(options);
        sbBlank.append(null);
        Assert.areEqual(1, sbBlank.size, 'Blank should be added when not skipping blanks');
        Assert.areEqual('', sbBlank.build(), 'Blank value contributes empty string');

        // CONVERT_TO_SINGLE_SPACE
        options = new StringBuilder.BuilderOptions()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_SINGLE_SPACE)
            .withDelimiter('.')
            .withSkipBlanks(false);
        StringBuilder sbSpace = new StringBuilder(options);
        sbSpace.append(null).append('a');
        Assert.areEqual(2, sbSpace.size, 'Single space should be added');

        // CONVERT_TO_LITERAL
        options = new StringBuilder.BuilderOptions()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_LITERAL);
        StringBuilder sbLiteral = new StringBuilder(options);
        sbLiteral.append(null);
        Assert.areEqual('null', sbLiteral.build(), 'Literal null should be added');
    }

    @IsTest
    private static void testTrimAndSkipBlanksInteraction() {
        StringBuilder.BuilderOptions options = new StringBuilder.BuilderOptions()
            .withTrimValue(true)
            .withSkipBlanks(true)
            .withDelimiter(',');
        StringBuilder sb = new StringBuilder(options);

        sb.append('  '); // becomes '' then skipped
        sb.append('  a  '); // becomes 'a'
        sb.append(''); // stays '' and skipped
        Assert.areEqual(1, sb.size, 'Only non-blank values after trimming should remain');
        Assert.areEqual('a', sb.build(), 'Only "a" should be included');
    }

    @IsTest
    private static void testDeduplication() {
        StringBuilder.BuilderOptions options = new StringBuilder.BuilderOptions()
            .withDeduplicate(true)
            .withDelimiter(',');
        StringBuilder sb = new StringBuilder(options);
        sb.append('x').append('x').append('y');
        Assert.areEqual(2, sb.size, 'Duplicate x should be ignored');
        Assert.areEqual('x,y', sb.build(), 'Should contain unique values only');
    }

    @IsTest
    private static void testMaxLengthThrowAndTruncate() {
        // Throw Exception
        StringBuilder.BuilderOptions options = new StringBuilder.BuilderOptions()
            .withMaxLength(3)
            .withActionOnMaxLengthExceeded(StringBuilder.MaxLengthAction.THROW_EXCEPTION);
        StringBuilder sbThrow = new StringBuilder(options);
        sbThrow.append('a').append('b').append('c').append('d');

        try {
            sbThrow.build();
            Assert.fail('sbThrow should throw an exception for max length exceeded');
        }
        catch(IllegalStateException e) {
            Assert.areEqual(sbThrow.size, 4, 'Length of sbThrow should be 4 (abcd)');
        }

        // Truncate
        options = new StringBuilder.BuilderOptions()
            .withMaxLength(3)
            .withActionOnMaxLengthExceeded(StringBuilder.MaxLengthAction.TRUNCATE);
        StringBuilder sbTrunc = new StringBuilder(options);
        sbTrunc.append('abcd');
        Assert.areEqual('abc', sbTrunc.build(), 'Should truncate to max length');
    }

    @IsTest
    private static void testClear() {
        StringBuilder sb = new StringBuilder();
        sb.append('a').append('b');
        Assert.areEqual(2, sb.size, 'Precondition: two items before clear');
        sb.clear();
        Assert.areEqual(0, sb.size, 'Size should be zero after clear');
        Assert.areEqual(true, sb.isEmpty, 'Should report empty after clear');
    }

    @IsTest
    private static void testAppendWhitespace() {
        StringBuilder sb = new StringBuilder();
        sb.append('a')
          .appendWhitespace(Whitespace.SINGLE_SPACE)
          .append('b')
          .appendWhitespace(Whitespace.TAB)
          .append('c')
          .appendWhitespace(Whitespace.NEWLINE)
          .append('d');

        Assert.areEqual('a b\tc\nd', sb.build(), 'appendWhitespace should insert correct whitespace tokens');
    }

    @IsTest
    private static void testConstructorWithBuilderOptions_AllOptions() {
        StringBuilder.BuilderOptions options = new StringBuilder.BuilderOptions()
            .withActionOnNullValue(StringBuilder.NullValueAction.CONVERT_TO_SINGLE_SPACE)
            .withTrimValue(true)
            .withSkipBlanks(true)
            .withDeduplicate(true)
            .withMaxLength(5)
            .withActionOnMaxLengthExceeded(StringBuilder.MaxLengthAction.TRUNCATE)
            .withDelimiter('-');

        StringBuilder sb = new StringBuilder(options);
        sb.append('  a  ').append('a').append(null).append('     ').append('bcdef');

        // After trim/skip/dedupe: values => 'a' (second 'a' removed), null => ' ' then skipped due to skipBlanks, blanks skipped
        // build => 'a-bcdef' then truncated to 5 => 'a-bcd'
        Assert.areEqual('a-bcd', sb.build(), 'Options passed via BuilderOptions should be honored');
    }

    @IsTest
    private static void testConstructorWithBuilderOptions_DefaultsMatchNoArg() {
        StringBuilder sbDefaultsViaOpts = new StringBuilder(new StringBuilder.BuilderOptions());
        Assert.areEqual(0, sbDefaultsViaOpts.size, 'Defaults size should be zero');
        Assert.isTrue(sbDefaultsViaOpts.isEmpty, 'Defaults should be empty');
        Assert.areEqual('', sbDefaultsViaOpts.build(), 'Defaults join should be empty string');
    }
}
