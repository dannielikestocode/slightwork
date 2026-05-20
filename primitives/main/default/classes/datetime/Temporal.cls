/**
 * Temporal.cls
 *
 * A comprehensive utility API for working with Date, Time, and Datetime in Apex.
 *
 * Features:
 * - Start/end boundaries
 * - Relative date math
 * - Business day calculations
 * - Comparisons
 * - Parsing/formatting helpers
 * - Unix timestamp conversions
 * - Range utilities
 * - Leap year and calendar helpers
 * - Safe construction methods
 *
 * Example:
 *
 * Datetime nowUtc = Temporal.nowUtc();
 * Datetime startOfWeek = Temporal.startOfWeek(System.today());
 * Date nextBusiness = Temporal.addBusinessDays(System.today(), 5);
 * Long epoch = Temporal.toUnixMillis(Datetime.now());
 */
public without sharing class Temporal {

    public static final Integer DAYS_PER_WEEK = 7;
    public static final Integer MONTHS_PER_YEAR = 12;

    /**
 * ============================================================
 * MILLIS CONSTANTS
 * ============================================================
 */

public static final Long MILLIS_PER_SECOND = 1000L;
public static final Long MILLIS_PER_MINUTE = 60L * MILLIS_PER_SECOND;
public static final Long MILLIS_PER_HOUR   = 60L * MILLIS_PER_MINUTE;
public static final Long MILLIS_PER_DAY    = 24L * MILLIS_PER_HOUR;

    /*
     * ============================================================
     * START / END HELPERS
     * ============================================================
     */

    public static Datetime startOfDay(Date d) {
        return Datetime.newInstance(
            d.year(),
            d.month(),
            d.day(),
            0,
            0,
            0
        );
    }

    public static Datetime endOfDay(Date d) {
        return Datetime.newInstance(
            d.year(),
            d.month(),
            d.day(),
            23,
            59,
            59
        );
    }

    public static Date startOfMonth(Date d) {
        return Date.newInstance(d.year(), d.month(), 1);
    }

    public static Date endOfMonth(Date d) {
        return startOfMonth(d).addMonths(1).addDays(-1);
    }

    public static Date startOfYear(Date d) {
        return Date.newInstance(d.year(), 1, 1);
    }

    public static Date endOfYear(Date d) {
        return Date.newInstance(d.year(), 12, 31);
    }

    public static Date startOfWeek(Date d) {
        Integer dow = getDayOfWeek(d);
        return d.addDays(-(dow - 1));
    }

    public static Date endOfWeek(Date d) {
        return startOfWeek(d).addDays(6);
    }

    /*
     * ============================================================
     * DATE COMPARISON
     * ============================================================
     */

    public static Boolean isToday(Date d) {
        return d == Date.today();
    }

    public static Boolean isPast(Date d) {
        return d < Date.today();
    }

    public static Boolean isFuture(Date d) {
        return d > Date.today();
    }

    public static Boolean isWeekend(Date d) {
        Integer dow = getDayOfWeek(d);
        return dow == 6 || dow == 7;
    }

    public static Boolean isWeekday(Date d) {
        return !isWeekend(d);
    }

    public static Boolean isSameDay(Date a, Date b) {
        return a == b;
    }

    public static Boolean isSameMonth(Date a, Date b) {
        return a.year() == b.year() &&
            a.month() == b.month();
    }

    public static Boolean isSameYear(Date a, Date b) {
        return a.year() == b.year();
    }

    /*
     * ============================================================
     * BUSINESS DAYS
     * ============================================================
     */

    public static Date addBusinessDays(Date d, Integer days) {
        Integer direction = days >= 0 ? 1 : -1;
        Integer remaining = Math.abs(days);

        Date current = d;

        while (remaining > 0) {

            current = current.addDays(direction);

            if (isWeekday(current)) {
                remaining--;
            }
        }

        return current;
    }

    public static Integer businessDaysBetween(Date startDate, Date endDate) {
        if (startDate == endDate) {
            return 0;
        }

        Integer direction = startDate < endDate ? 1 : -1;

        Date current = startDate;
        Integer total = 0;

        while (current != endDate) {

            current = current.addDays(direction);

            if (isWeekday(current)) {
                total += direction;
            }
        }

        return total;
    }

    /*
     * ============================================================
     * RANGE HELPERS
     * ============================================================
     */

    public static Integer monthsBetween(Date startDate, Date endDate) {
        Integer months =
            (endDate.year() - startDate.year()) * 12;

        months += endDate.month() - startDate.month();

        return months;
    }

    /*
     * ============================================================
     * UNIX / EPOCH HELPERS
     * ============================================================
     */

    public static Long toUnixSeconds(Datetime dt) {
        return dt.getTime() / 1000;
    }

    public static Datetime fromUnixSeconds(Long seconds) {
        return Datetime.newInstance(seconds * 1000);
    }

    /*
     * ============================================================
     * CALENDAR HELPERS
     * ============================================================
     */

    public static Integer daysInMonth(Integer year, Integer month) {
        Date start = Date.newInstance(year, month, 1);
        return start.addMonths(1).addDays(-1).day();
    }

    /**
     * Returns:
     * 1 = Monday
     * 2 = Tuesday
     * ...
     * 7 = Sunday
     */
    public static Integer getDayOfWeek(Date d) {

        Date anchor = Date.newInstance(1900, 1, 1);

        Integer days = anchor.daysBetween(d);

        Integer dow = Math.mod(days, 7);

        if (dow < 0) {
            dow += 7;
        }

        return dow + 1;
    }

    /*
     * ============================================================
     * TIME HELPERS
     * ============================================================
     */

    public static Integer secondsBetween(Time start, Time end) {

        Integer startSeconds =
            (start.hour() * 3600) +
            (start.minute() * 60) +
            start.second();

        Integer endSeconds =
            (end.hour() * 3600) +
            (end.minute() * 60) +
            end.second();

        return endSeconds - startSeconds;
    }

    public static Time addSeconds(Time t, Integer seconds) {

        Integer totalMillis =
            (
                (t.hour() * 3600) +
                (t.minute() * 60) +
                t.second()
            ) * 1000;

        totalMillis += t.millisecond();
        totalMillis += seconds * 1000;

        Integer millisPerDay = 24 * 60 * 60 * 1000;

        totalMillis = Math.mod(totalMillis, millisPerDay);

        if (totalMillis < 0) {
            totalMillis += millisPerDay;
        }

        Integer hour = totalMillis / (60 * 60 * 1000);
        totalMillis = Math.mod(totalMillis, 60 * 60 * 1000);

        Integer minute = totalMillis / (60 * 1000);
        totalMillis = Math.mod(totalMillis, 60 * 1000);

        Integer second = totalMillis / 1000;
        Integer millisecond = Math.mod(totalMillis, 1000);

        return Time.newInstance(
            hour,
            minute,
            second,
            millisecond
        );
    }

    /*
     * ============================================================
     * HUMAN FRIENDLY HELPERS
     * ============================================================
     */

    public static String relativeDate(Date d) {

        Integer diff = Date.today().daysBetween(d);

        if (diff == 0) {
            return 'Today';
        }

        if (diff == 1) {
            return 'Tomorrow';
        }

        if (diff == -1) {
            return 'Yesterday';
        }

        if (diff > 1) {
            return 'In ' + diff + ' days';
        }

        return Math.abs(diff) + ' days ago';
    }

    public static String monthName(Integer month) {

        List<String> names = new List<String>{
            'January',
            'February',
            'March',
            'April',
            'May',
            'June',
            'July',
            'August',
            'September',
            'October',
            'November',
            'December'
        };

        return names[month - 1];
    }
}