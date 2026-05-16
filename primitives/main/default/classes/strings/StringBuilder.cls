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
    private final Set<String> existingValues {get;set;}

    // Options
    private NullValueAction actionOnNullValue {get;set;}
    private Boolean trimValue {get;set;}
    private Boolean skipBlanks {get;set;}
    private Boolean deduplicate {get;set;}
    private Integer maxLength {get;set;}
    private MaxLengthAction actionOnMaxLengthExceeded {get;set;}
    private String separator {get;set;}

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
        this.separator = '';
    }

    public StringBuilder withActionOnNullValue(NullValueAction value) {
        if (value == null) {
            throw new IllegalStateException('Null Value Action cannot be null');
        }
        this.actionOnNullValue = value;
        return this;
    }

    public StringBuilder withTrimValue(Boolean value) {
        if (value == null) {
            throw new IllegalStateException('Trim Value cannot be null');
        }
        this.trimValue = value;
        return this;
    }

    public StringBuilder withSkipBlanks(Boolean value) {
        if (value == null) {
            throw new IllegalStateException('Skip Blanks cannot be null');
        }
        this.skipBlanks = value;
        return this;
    }

    public StringBuilder withDeduplicate(Boolean value) {
        if (value == null) {
            throw new IllegalStateException('Deduplicate cannot be null');
        }
        this.deduplicate = value;
        return this;
    }

    public StringBuilder withMaxLength(Integer value) {
        if (value == null || value < 0) {
            throw new IllegalStateException('Max Length must be a value of zero or greater');
        }
        this.maxLength = value;
        return this;
    }

    public StringBuilder withActionOnMaxLengthExceeded(MaxLengthAction value) {
        if (value == null) {
            throw new IllegalArgumentException('Action On Max Length Exceeded cannot be null');
        }
        this.actionOnMaxLengthExceeded = value;
        return this;
    }

    public StringBuilder withSeparator(String value) {
        if (value == null) {
            throw new IllegalArgumentException('Separator cannot be null');
        }
        this.separator = value;
        return this;
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
        String result = String.join(this.stringParts, this.separator);
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