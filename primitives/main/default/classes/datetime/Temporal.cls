/**
 * A comprehensive utility API for working with Date, Time, and Datetime
 * within Apex.
 *
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see https://slightwork.dev/modules/primitives/temporal.html
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_datetime.htm
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_date.htm
 * @see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_time.htm
 * @see https://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
 */
public inherited sharing class Temporal {
    /**
     * Significant Values
     */
    private static final Integer ZERO_LITERAL = 0;
    private static final Integer ONE_LITERAL = 1;
    
    /**
     * Calendar Constants
     */
    public static final Integer FIRST_MONTH_OF_YEAR = 1;
    public static final Integer LAST_MONTH_OF_YEAR = 12;
    public static final Integer FIRST_DAY_OF_MONTH = 1;
    public static final Integer DAYS_PER_WEEK = 7;
    public static final Integer MAX_DAYS_PER_MONTH = 31;

    /**
     * Time Constants
     */
    public static final Integer MILLIS_PER_SECOND = 1000;
    public static final Integer MILLIS_PER_MINUTE = 60 * MILLIS_PER_SECOND;
    public static final Integer MILLIS_PER_HOUR = 60 * MILLIS_PER_MINUTE;
    public static final Integer MILLIS_PER_DAY = 24 * MILLIS_PER_HOUR;
    public static final Integer FIRST_HOUR_OF_DAY = 0;
    public static final Integer FIRST_MINUTE_OF_HOUR = 0;
    public static final Integer FIRST_SECOND_OF_MINUTE = 0;
    public static final Integer LAST_HOUR_OF_DAY = 23;
    public static final Integer LAST_MINUTE_OF_HOUR = 59;
    public static final Integer LAST_SECOND_OF_MINUTE = 59;

    /**
     * Constructs a Datetime instance in the user's local time zone
     * on the start time (12AM) of the given date.
     * 
     * @param Date d The given date
     * @return Datetime instance at 12:00:00 AM on the given date
     */
    public static Datetime localStartOfDay(Date d) {
        return Datetime.newInstance(
            d.year(),
            d.month(),
            d.day(),
            FIRST_HOUR_OF_DAY,
            FIRST_MINUTE_OF_HOUR,
            FIRST_SECOND_OF_MINUTE
        );
    }

    /**
     * Constructs a Datetime instance in the user's local time zone
     * on the end time (11:59:59 PM) of the given date.
     * 
     * @param d The given date
     * @return Datetime instance at 11:59:59 PM on the given date
     */
    public static Datetime localEndOfDay(Date d) {
        return Datetime.newInstance(
            d.year(),
            d.month(),
            d.day(),
            LAST_HOUR_OF_DAY,
            LAST_MINUTE_OF_HOUR,
            LAST_SECOND_OF_MINUTE
        );
    }

    /**
     * Returns the first day of the month for the given date.
     * 
     * @param d The given date
     * @return The first day of the month
     */
    public static Date startOfMonth(Date d) {
        return d.toStartOfMonth();
    }

    /**
     * Returns the last day of the month for the given date.
     * 
     * @param d The given date
     * @return The last day of the month
     */
    public static Date endOfMonth(Date d) {
        return d.addMonths(ONE_LITERAL).toStartOfMonth().addDays(-ONE_LITERAL);
    }

    /**
     * Returns the first day of the year (January 1st) for the given date.
     * 
     * @param d The given date
     * @return January 1st of the year
     */
    public static Date startOfYear(Date d) {
        return Date.newInstance(d.year(), FIRST_MONTH_OF_YEAR, FIRST_DAY_OF_MONTH);
    }

    /**
     * Returns the last day of the year (December 31st) for the given date.
     * 
     * @param d The given date
     * @return December 31st of the year
     */
    public static Date endOfYear(Date d) {
        return Date.newInstance(d.year(), LAST_MONTH_OF_YEAR, MAX_DAYS_PER_MONTH);
    }

    /**
     * Returns the first day of the week (Sunday) for the given date.
     * 
     * @param d The given date
     * @return The Sunday of the week
     */
    public static Date startOfWeek(Date d) {
        return d.toStartOfWeek();
    }

    /**
     * Returns the last day of the week (Saturday) for the given date.
     * 
     * @param d The given date
     * @return The Saturday of the week
     */
    public static Date endOfWeek(Date d) {
        return startOfWeek(d).addDays(DAYS_PER_WEEK - ONE_LITERAL);
    }

    /**
     * Checks if the given date is today.
     * 
     * @param d The date to check
     * @return True if the date is today, false otherwise
     */
    public static Boolean isToday(Date d) {
        return d == Date.today();
    }

    /**
     * Checks if the given date is in the past.
     * 
     * @param d The date to check
     * @return True if the date is before today, false otherwise
     */
    public static Boolean isPast(Date d) {
        return d < Date.today();
    }

    /**
     * Checks if the given date is in the future.
     * 
     * @param d The date to check
     * @return True if the date is after today, false otherwise
     */
    public static Boolean isFuture(Date d) {
        return d > Date.today();
    }

    /**
     * Checks if the given date falls on a weekend (Saturday or Sunday).
     * 
     * @param d The date to check
     * @return True if the date is Saturday or Sunday, false otherwise
     */
    public static Boolean isWeekend(Date d) {
        Integer dayOfWeek = getIsoDayOfWeek(d);
        return dayOfWeek == 6 || dayOfWeek == 7;
    }

    /**
     * Checks if the given date falls on a weekday (Monday through Friday).
     * 
     * @param d The date to check
     * @return True if the date is a weekday, false otherwise
     */
    public static Boolean isWeekday(Date d) {
        return !isWeekend(d);
    }

    /**
     * Checks if two dates are the same day.
     * 
     * @param firstDate The first date to compare
     * @param secondDate The second date to compare
     * @return True if both dates are the same, false otherwise
     */
    public static Boolean isSameDay(Date firstDate, Date secondDate) {
        return firstDate == secondDate;
    }

    /**
     * Checks if two dates fall in the same month and year.
     * 
     * @param firstDate The first date to compare
     * @param secondDate The second date to compare
     * @return True if both dates are in the same month and year, false otherwise
     */
    public static Boolean isSameMonth(Date firstDate, Date secondDate) {
        return firstDate.year() == secondDate.year() && firstDate.month() == secondDate.month();
    }

    /**
     * Checks if two dates fall in the same year.
     * 
     * @param firstDate The first date to compare
     * @param secondDate The second date to compare
     * @return True if both dates are in the same year, false otherwise
     */
    public static Boolean isSameYear(Date firstDate, Date secondDate) {
        return firstDate.year() == secondDate.year();
    }

    /**
     * Adds business days (weekdays only) to a date, skipping weekends.
     * 
     * @param currentDate The starting date
     * @param daysToAdd The number of business days to add (can be negative to subtract)
     * @return The resulting date after adding business days
     */
    public static Date addBusinessDays(Date inputDate, Integer daysToAdd) {
        Integer direction = daysToAdd >= ZERO_LITERAL ? ONE_LITERAL : -ONE_LITERAL;
        Integer remaining = Math.abs(daysToAdd);
        Date currentDate = inputDate;
        while (remaining > 0) {
            currentDate = currentDate.addDays(direction);
            if (isWeekday(currentDate)) {
                remaining--;
            }
        }
        return currentDate;
    }

    /**
     * Calculates the number of business days (weekdays only) between two dates.
     * 
     * @param startDate The starting date
     * @param endDate The ending date
     * @return The number of business days between the dates
     */
    public static Integer businessDaysBetween(Date startDate, Date endDate) {
        if (startDate == endDate) {
            return ZERO_LITERAL;
        }

        Integer direction = startDate < endDate ? ONE_LITERAL : -ONE_LITERAL;
        Date current = startDate;
        Integer total = ZERO_LITERAL;
        while (current != endDate) {
            current = current.addDays(direction);
            if (isWeekday(current)) {
                total += direction;
            }
        }
        return total;
    }

    /**
     * Returns the day of the week according to the ISO standard    
     * (Monday = 1, Sunday = 7).
     * 
     * @param inputDate The provided date to review
     * @return Integer ISO day of week (Monday=1, ..., Sunday=7)
     * @see https://en.wikipedia.org/wiki/ISO_week_date
     */
    public static Integer getIsoDayOfWeek(Date inputDate) {
        if (inputDate == null) {
            return null;
        }

        Datetime dt = Datetime.newInstance(
            inputDate.year(),
            inputDate.month(),
            inputDate.day()
        );
        return Integer.valueOf(dt.format('u'));
    }

    /**
     * Returns a human-readable relative date string (e.g., "Today", "Yesterday", "In 5 days").
     * 
     * @param d The date to describe relative to today
     * @return A relative date description
     */
    public static String relativeDate(Date d) {
        Integer diff = Date.today().daysBetween(d);
        if (diff == ZERO_LITERAL) {
            return 'Today';
        }

        if (diff == ONE_LITERAL) {
            return 'Tomorrow';
        }

        if (diff == -ONE_LITERAL) {
            return 'Yesterday';
        }

        if (diff > ONE_LITERAL) {
            return 'In ' + diff + ' days';
        }
        return Math.abs(diff) + ' days ago';
    }
}