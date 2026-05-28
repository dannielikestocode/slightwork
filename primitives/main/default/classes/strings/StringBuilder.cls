/**
 * Provides functionality to efficiently generate instances of 
 * String objects.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/primitives/string-builder.html
 */
public inherited sharing class StringBuilder {
    /**
     * String Builder Parts
     */
    private final List<String> stringParts {get;set;}
    private final Set<String> existingValues {get;set;}

    /**
     * Builder Options
     */
    private NullValueAction actionOnNullValue {get;set;}
    private Boolean trimValue {get;set;}
    private Boolean skipBlanks {get;set;}
    private Boolean deduplicate {get;set;}
    private Integer maxLength {get;set;}
    private MaxLengthAction actionOnMaxLengthExceeded {get;set;}
    private String separator {get;set;}

    /**
     * Derived Properties
     */
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

    /**
     *  Action-based Enums
     */
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

    /**
     * Sets the action to perform when a null value is appended
     * 
     * @param value The null value action strategy
     * @return This instance for method chaining
     */
    public StringBuilder withActionOnNullValue(NullValueAction value) {
        if (value == null) {
            throw new IllegalStateException('Null Value Action cannot be null');
        }
        this.actionOnNullValue = value;
        return this;
    }

    /**
     * Sets whether to trim whitespace from appended values
     * 
     * @param value True to trim values, false otherwise
     * @return This instance for method chaining
     */
    public StringBuilder withTrimValue(Boolean value) {
        if (value == null) {
            throw new IllegalStateException('Trim Value cannot be null');
        }
        this.trimValue = value;
        return this;
    }

    /**
     * Sets whether to skip blank/empty values when appending
     * 
     * @param value True to skip blanks, false otherwise
     * @return This instance for method chaining
     */
    public StringBuilder withSkipBlanks(Boolean value) {
        if (value == null) {
            throw new IllegalStateException('Skip Blanks cannot be null');
        }
        this.skipBlanks = value;
        return this;
    }

    /**
     * Sets whether to deduplicate values (skip duplicate entries)
     * 
     * @param value True to deduplicate, false otherwise
     * @return This instance for method chaining
     */
    public StringBuilder withDeduplicate(Boolean value) {
        if (value == null) {
            throw new IllegalStateException('Deduplicate cannot be null');
        }
        this.deduplicate = value;
        return this;
    }

    /**
     * Sets the maximum length for the final built string
     * 
     * @param value The maximum length (must be 0 or greater)
     * @return This instance for method chaining
     */
    public StringBuilder withMaxLength(Integer value) {
        if (value == null || value < 0) {
            throw new IllegalStateException('Max Length must be a value of zero or greater');
        }
        this.maxLength = value;
        return this;
    }

    /**
     * Sets the action to perform when max length is exceeded
     * 
     * @param value The max length action strategy
     * @return This instance for method chaining
     */
    public StringBuilder withActionOnMaxLengthExceeded(MaxLengthAction value) {
        if (value == null) {
            throw new IllegalArgumentException('Action On Max Length Exceeded cannot be null');
        }
        this.actionOnMaxLengthExceeded = value;
        return this;
    }

    /**
     * Sets the separator to use when joining string parts
     * 
     * @param value The separator string
     * @return This instance for method chaining
     */
    public StringBuilder withSeparator(String value) {
        if (value == null) {
            throw new IllegalArgumentException('Separator cannot be null');
        }
        this.separator = value;
        return this;
    }

    /**
     * Appends an object's string representation to the builder
     * 
     * @param value The object to append
     * @return This instance for method chaining
     */
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

    /**
     * Appends all objects from a list to the builder
     * 
     * @param values The list of objects to append
     * @return This instance for method chaining
     */
    public StringBuilder appendAll(List<Object> values) {
        if (values == null || values.isEmpty()) {
            return this;
        }

        for (Object val : values) {
            this.append(val);
        }
        return this;
    }

    /**
     * Appends a specific type of whitespace to the builder
     * 
     * @param wsType The type of whitespace
     * @return This instance for method chaining
     */
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

    /**
     * Builds and returns the final concatenated string
     * 
     * @return The joined string with configured separator, respecting max length settings
     */
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

    /**
     * Clears all appended string parts and resets the builder
     */
    public void clear() {
        this.stringParts.clear();
        this.existingValues.clear();
    }

    /**
     * Processes a value according to configured options (null handling, trimming, etc.)
     * 
     * @param value The string value to process
     * @return The processed string value
     */
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