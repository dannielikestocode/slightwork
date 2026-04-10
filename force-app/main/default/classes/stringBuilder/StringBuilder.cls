/**
 * Provides functionality to efficiently generate instances of 
 * String objects.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 */
public without sharing class StringBuilder {
    // String Parts
    private final List<String> stringParts {get;set;}
    private final Set<String> existingValues {get;set;} // For deduplication

    // Options
    private final NullValueAction actionOnNullValue {get;set;}
    private final Boolean trimValue {get;set;}
    private final Boolean skipBlanks {get;set;}
    private final Boolean deduplicate {get;set;}
    private final Integer maxLength {get;set;}
    private final MaxLengthAction actionOnMaxLengthExceeded {get;set;}
    private final String delimiter {get;set;}

    // Derived Properties
    public Integer size {
        get {
            return this.stringParts.size();
        }
    }
    
    public Boolean isEmpty {
        get {
            return this.stringParts.isEmpty();
        }
    }

    // Action-based Enums
    public enum NullValueAction {
        CONVERT_TO_BLANK,
        CONVERT_TO_SINGLE_SPACE,
        CONVERT_TO_LITERAL
    }

    public enum MaxLengthAction {
        THROW_EXCEPTION,
        TRUNCATE
    }

    /**
     * Encapsulates configurable options for the StringBuilder.
     * Provide an instance to the overloaded constructor to 
     * customize behavior.
     */
    public class BuilderOptions {
        private NullValueAction actionOnNullValue {get;set;}
        private Boolean trimValue {get;set;}
        private Boolean skipBlanks {get;set;}
        private Boolean deduplicate {get;set;}
        private Integer maxLength {get;set;}
        private MaxLengthAction actionOnMaxLengthExceeded {get;set;}
        private String delimiter {get;set;}

        public BuilderOptions() {
            this.actionOnNullValue = NullValueAction.CONVERT_TO_BLANK;
            this.trimValue = false;
            this.skipBlanks = false;
            this.deduplicate = false;
            this.maxLength = null;
            this.actionOnMaxLengthExceeded = MaxLengthAction.THROW_EXCEPTION;
            this.delimiter = '';
        }

        public BuilderOptions withActionOnNullValue(NullValueAction value) { this.actionOnNullValue = value; return this; }
        public BuilderOptions withTrimValue(Boolean value) { this.trimValue = value; return this; }
        public BuilderOptions withSkipBlanks(Boolean value) { this.skipBlanks = value; return this; }
        public BuilderOptions withDeduplicate(Boolean value) { this.deduplicate = value; return this; }
        public BuilderOptions withMaxLength(Integer value) { this.maxLength = value; return this; }
        public BuilderOptions withActionOnMaxLengthExceeded(MaxLengthAction value) { this.actionOnMaxLengthExceeded = value; return this; }
        public BuilderOptions withDelimiter(String value) { this.delimiter = value; return this; }
    }

    /**
     * No-arg, default constructor
     */
    public StringBuilder() {
        // String Parts
        this.stringParts = new List<String>();
        this.existingValues = new Set<String>();

        // Options
        this.actionOnNullValue = NullValueAction.CONVERT_TO_BLANK;
        this.trimValue = false;
        this.skipBlanks = false;
        this.deduplicate = false;
        this.maxLength = null;
        this.actionOnMaxLengthExceeded = MaxLengthAction.THROW_EXCEPTION;
        this.delimiter = '';

        this.validate();
    }
    
    /**
     * Overloaded constructor with BuilderOptions argument
     * for setting properties
     */
    public StringBuilder(BuilderOptions options) {
        if (options == null) {
            throw new IllegalArgumentException('StringBuilder options cannot be null for constructor');
        }

        // String Parts
        this.stringParts = new List<String>();
        this.existingValues = new Set<String>();

        // Options from provided BuilderOptions (allowing null for optional ones)
        this.actionOnNullValue = options.actionOnNullValue;
        this.trimValue = options.trimValue;
        this.skipBlanks = options.skipBlanks;
        this.deduplicate = options.deduplicate;
        this.maxLength = options.maxLength;
        this.actionOnMaxLengthExceeded = options.actionOnMaxLengthExceeded;
        this.delimiter = options.delimiter;

        this.validate();
    }

    public void validate() {
        if (this.actionOnNullValue == null) {
            throw new IllegalStateException('Null Value Action cannot be null');
        }

        if (this.trimValue == null) {
            throw new IllegalStateException('Trim Value cannot be null');
        }

        if (this.skipBlanks == null) {
            throw new IllegalStateException('Skip Blanks cannot be null');
        }

        if (this.deduplicate == null) {
            throw new IllegalStateException('Deduplicate cannot be null');
        }

        if (this.maxLength != null && this.maxLength < 0) {
            throw new IllegalStateException('Max Length must be a value of zero or greater');
        }

        if (this.actionOnMaxLengthExceeded == null) {
            throw new IllegalStateException('Action On Max Length Exceeded cannot be null');
        }

        if (this.delimiter == null) {
            throw new IllegalStateException('Delimiter cannot be null');
        }
    }

    public StringBuilder append(Object value) {
        // If an object of a class overrides the "toString()" method, String.valueOf()
        // will call the overriden toString() method. Otherwise, a log-friendly, 
        // string representation of the object will be provided
        // by the system
        String processed = processValue(value == null ? null : String.valueOf(value));
        if (this.skipBlanks == true && String.isBlank(processed)) {
            return this;
        }
        
        if (this.deduplicate == true) {
            if (this.existingValues.contains(processed)) {
                return this;
            }
            this.existingValues.add(processed);
        }
        this.stringParts.add(processed);
        return this;
    }

    public StringBuilder appendAll(List<Object> values) {
        if (values == null || values.isEmpty()) {
            return this;
        }

        for (Object val : values) {
            this.append(val);
        }
        return this;
    }

    public StringBuilder appendWhitespace(Whitespace wsType) {
        if (wsType == null) {
            throw new IllegalStateException('Whitespace argument cannot be null');
        }

        String token;
        switch on wsType {
            when SINGLE_SPACE { 
                token = ' '; 
            }
            when NEWLINE { 
                token = '\n'; 
            }
            when TAB { 
                token = '\t'; 
            }
        }

        // The appendWhitespace method bypasses the processing
        // logic performed by append(Object)
        this.stringParts.add(token);
        return this;
    }

    public String build() {
        String result = String.join(this.stringParts, this.delimiter);
        if (this.maxLength != null && result.length() > this.maxLength) {
            if (this.actionOnMaxLengthExceeded == MaxLengthAction.THROW_EXCEPTION) {
                throw new IllegalStateException(String.format(
                    'Defined max length ({0}) for string exceeded: {1}',
                    new List<Object>{this.maxLength, result}
                ));
            }
            else if (this.actionOnMaxLengthExceeded == MaxLengthAction.TRUNCATE) {
                result = result.substring(0, this.maxLength);
            }
        }
        return result;
    }

    public void clear() {
        this.stringParts.clear();
        this.existingValues.clear();
    }

    private String processValue(String value) {
        // A value of the type null (unless it's the string literal)
        // should never be returned after processing
        if (value == null) {
            switch on this.actionOnNullValue {
                when CONVERT_TO_BLANK {
                    value = '';
                }
                when CONVERT_TO_SINGLE_SPACE {
                    value = ' ';
                }
                when CONVERT_TO_LITERAL {
                    value = 'null';
                }
            }
        }
        else if (this.trimValue == true) {
            value = value.trim();
        }
        return value;
    }
}