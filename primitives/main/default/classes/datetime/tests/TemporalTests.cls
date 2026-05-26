/**
 * Contains units for validating functionality for the Temporal class.
 * 
 * @author Dannie @ Wynforce
 * @since v66.0
 * @see Temporal.cls
 */
@IsTest
private without sharing class TemporalTests {
    @IsTest
    private static void testLocalStartOfDay() {
        Date testDate = Date.newInstance(2024, 6, 15);
        Datetime result = Temporal.localStartOfDay(testDate);
        
        Assert.areEqual(2024, result.year(), 'Year should match');
        Assert.areEqual(6, result.month(), 'Month should match');
        Assert.areEqual(15, result.day(), 'Day should match');
        Assert.areEqual(0, result.hour(), 'Hour should be 0');
        Assert.areEqual(0, result.minute(), 'Minute should be 0');
        Assert.areEqual(0, result.second(), 'Second should be 0');
    }
    
    @IsTest
    private static void testLocalEndOfDay() {
        Date testDate = Date.newInstance(2024, 6, 15);
        Datetime result = Temporal.localEndOfDay(testDate);
        
        Assert.areEqual(2024, result.year(), 'Year should match');
        Assert.areEqual(6, result.month(), 'Month should match');
        Assert.areEqual(15, result.day(), 'Day should match');
        Assert.areEqual(23, result.hour(), 'Hour should be 23');
        Assert.areEqual(59, result.minute(), 'Minute should be 59');
        Assert.areEqual(59, result.second(), 'Second should be 59');
    }
    
    @IsTest
    private static void testStartOfMonth() {
        Date testDate = Date.newInstance(2024, 6, 15);
        Date result = Temporal.startOfMonth(testDate);
        
        Assert.areEqual(Date.newInstance(2024, 6, 1), result, 'Should return first day of month');
    }
   
    @IsTest
    private static void testEndOfMonth() {
        Date testDate = Date.newInstance(2024, 6, 15);
        Date result = Temporal.endOfMonth(testDate);
        
        Assert.areEqual(Date.newInstance(2024, 6, 30), result, 'June should have 30 days');
        
        // Test February in leap year
        Date febLeapYear = Date.newInstance(2024, 2, 15);
        Date febResult = Temporal.endOfMonth(febLeapYear);
        Assert.areEqual(Date.newInstance(2024, 2, 29), febResult, 'Feb 2024 should have 29 days');
        
        // Test February in non-leap year
        Date febNonLeapYear = Date.newInstance(2023, 2, 15);
        Date febNonLeapResult = Temporal.endOfMonth(febNonLeapYear);
        Assert.areEqual(Date.newInstance(2023, 2, 28), febNonLeapResult, 'Feb 2023 should have 28 days');
    }
    
    @IsTest
    private static void testStartOfYear() {
        Date testDate = Date.newInstance(2024, 6, 15);
        Date result = Temporal.startOfYear(testDate);
        
        Assert.areEqual(Date.newInstance(2024, 1, 1), result, 'Should return January 1st');
    }
    
    @IsTest
    private static void testEndOfYear() {
        Date testDate = Date.newInstance(2024, 6, 15);
        Date result = Temporal.endOfYear(testDate);
        
        Assert.areEqual(Date.newInstance(2024, 12, 31), result, 'Should return December 31st');
    }
    
    @IsTest
    private static void testStartOfWeek() {
        // June 15, 2024 is a Saturday
        Date testDate = Date.newInstance(2024, 6, 15);
        Date result = Temporal.startOfWeek(testDate);
        
        // Should return Sunday of that week (June 9, 2024)
        Assert.areEqual(Date.newInstance(2024, 6, 9), result, 'Should return Sunday of the week');
    }
    
    @IsTest
    private static void testEndOfWeek() {
        // June 10, 2024 is a Monday
        Date testDate = Date.newInstance(2024, 6, 10);
        Date result = Temporal.endOfWeek(testDate);
        
        // Should return Saturday of that week (June 15, 2024)
        Assert.areEqual(Date.newInstance(2024, 6, 15), result, 'Should return Saturday of the week');
    }
    
    @IsTest
    private static void testIsToday() {
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date tomorrow = today.addDays(1);
        
        Assert.isTrue(Temporal.isToday(today), 'Today should return true');
        Assert.isFalse(Temporal.isToday(yesterday), 'Yesterday should return false');
        Assert.isFalse(Temporal.isToday(tomorrow), 'Tomorrow should return false');
    }
    
    @IsTest
    private static void testIsPast() {
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date tomorrow = today.addDays(1);
        
        Assert.isTrue(Temporal.isPast(yesterday), 'Yesterday should be in the past');
        Assert.isFalse(Temporal.isPast(today), 'Today should not be in the past');
        Assert.isFalse(Temporal.isPast(tomorrow), 'Tomorrow should not be in the past');
    }
    
    @IsTest
    private static void testIsFuture() {
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date tomorrow = today.addDays(1);
        
        Assert.isTrue(Temporal.isFuture(tomorrow), 'Tomorrow should be in the future');
        Assert.isFalse(Temporal.isFuture(today), 'Today should not be in the future');
        Assert.isFalse(Temporal.isFuture(yesterday), 'Yesterday should not be in the future');
    }
    
    @IsTest
    private static void testIsWeekend() {
        // June 15, 2024 is a Saturday
        Date saturday = Date.newInstance(2024, 6, 15);
        // June 16, 2024 is a Sunday
        Date sunday = Date.newInstance(2024, 6, 16);
        // June 17, 2024 is a Monday
        Date monday = Date.newInstance(2024, 6, 17);
        
        Assert.isTrue(Temporal.isWeekend(saturday), 'Saturday should be a weekend');
        Assert.isTrue(Temporal.isWeekend(sunday), 'Sunday should be a weekend');
        Assert.isFalse(Temporal.isWeekend(monday), 'Monday should not be a weekend');
    }
    
    @IsTest
    private static void testIsWeekday() {
        // June 15, 2024 is a Saturday
        Date saturday = Date.newInstance(2024, 6, 15);
        // June 17, 2024 is a Monday
        Date monday = Date.newInstance(2024, 6, 17);
        
        Assert.isFalse(Temporal.isWeekday(saturday), 'Saturday should not be a weekday');
        Assert.isTrue(Temporal.isWeekday(monday), 'Monday should be a weekday');
    }
    
    @IsTest
    private static void testIsSameDay() {
        Date date1 = Date.newInstance(2024, 6, 15);
        Date date2 = Date.newInstance(2024, 6, 15);
        Date date3 = Date.newInstance(2024, 6, 16);
        
        Assert.isTrue(Temporal.isSameDay(date1, date2), 'Same dates should return true');
        Assert.isFalse(Temporal.isSameDay(date1, date3), 'Different dates should return false');
    }
    
    @IsTest
    private static void testIsSameMonth() {
        Date date1 = Date.newInstance(2024, 6, 15);
        Date date2 = Date.newInstance(2024, 6, 20);
        Date date3 = Date.newInstance(2024, 7, 15);
        Date date4 = Date.newInstance(2023, 6, 15);
        
        Assert.isTrue(Temporal.isSameMonth(date1, date2), 'Same month and year should return true');
        Assert.isFalse(Temporal.isSameMonth(date1, date3), 'Different months should return false');
        Assert.isFalse(Temporal.isSameMonth(date1, date4), 'Same month different year should return false');
    }
    
    @IsTest
    private static void testIsSameYear() {
        Date date1 = Date.newInstance(2024, 6, 15);
        Date date2 = Date.newInstance(2024, 12, 31);
        Date date3 = Date.newInstance(2023, 6, 15);
        
        Assert.isTrue(Temporal.isSameYear(date1, date2), 'Same year should return true');
        Assert.isFalse(Temporal.isSameYear(date1, date3), 'Different years should return false');
    }
    
    @IsTest
    private static void testAddBusinessDaysPositive() {
        // June 13, 2024 is a Thursday
        Date thursday = Date.newInstance(2024, 6, 13);
        
        // Add 1 business day (should be Friday)
        Date result1 = Temporal.addBusinessDays(thursday, 1);
        Assert.areEqual(Date.newInstance(2024, 6, 14), result1, 'Should be Friday');
        
        // Add 3 business days (should skip weekend and be Tuesday)
        Date result2 = Temporal.addBusinessDays(thursday, 3);
        Assert.areEqual(Date.newInstance(2024, 6, 18), result2, 'Should be Tuesday (skipping weekend)');
        
        // Add 5 business days (should be Thursday next week)
        Date result3 = Temporal.addBusinessDays(thursday, 5);
        Assert.areEqual(Date.newInstance(2024, 6, 20), result3, 'Should be Thursday next week');
    }
    
    @IsTest
    private static void testAddBusinessDaysNegative() {
        // June 18, 2024 is a Tuesday
        Date tuesday = Date.newInstance(2024, 6, 18);
        
        // Subtract 1 business day (should be Monday)
        Date result1 = Temporal.addBusinessDays(tuesday, -1);
        Assert.areEqual(Date.newInstance(2024, 6, 17), result1, 'Should be Monday');
        
        // Subtract 3 business days (should skip weekend and be Thursday)
        Date result2 = Temporal.addBusinessDays(tuesday, -3);
        Assert.areEqual(Date.newInstance(2024, 6, 13), result2, 'Should be Thursday (skipping weekend)');
    }
    
    @IsTest
    private static void testBusinessDaysBetween() {
        // June 13, 2024 is a Thursday
        Date thursday = Date.newInstance(2024, 6, 13);
        // June 18, 2024 is a Tuesday
        Date tuesday = Date.newInstance(2024, 6, 18);
        
        // Same date should return 0
        Integer result0 = Temporal.businessDaysBetween(thursday, thursday);
        Assert.areEqual(0, result0, 'Same date should return 0');
        
        // Thursday to Tuesday (skipping weekend) = 3 business days
        Integer result1 = Temporal.businessDaysBetween(thursday, tuesday);
        Assert.areEqual(3, result1, 'Should be 3 business days');
        
        // Reverse direction should be negative
        Integer result2 = Temporal.businessDaysBetween(tuesday, thursday);
        Assert.areEqual(-3, result2, 'Should be -3 business days');
    }
    
    @IsTest
    private static void testGetIsoDayOfWeek() {
        // June 10, 2024 is a Monday (ISO day 1)
        Date monday = Date.newInstance(2024, 6, 10);
        Assert.areEqual(1, Temporal.getIsoDayOfWeek(monday), 'Monday should be 1');
        
        // June 15, 2024 is a Saturday (ISO day 6)
        Date saturday = Date.newInstance(2024, 6, 15);
        Assert.areEqual(6, Temporal.getIsoDayOfWeek(saturday), 'Saturday should be 6');
        
        // June 16, 2024 is a Sunday (ISO day 7)
        Date sunday = Date.newInstance(2024, 6, 16);
        Assert.areEqual(7, Temporal.getIsoDayOfWeek(sunday), 'Sunday should be 7');
        
        // Test null input
        Integer nullResult = Temporal.getIsoDayOfWeek(null);
        Assert.isNull(nullResult, 'Null input should return null');
    }
    
    @IsTest
    private static void testRelativeDate() {
        Date today = Date.today();
        Date yesterday = today.addDays(-1);
        Date tomorrow = today.addDays(1);
        Date future = today.addDays(5);
        Date past = today.addDays(-5);
        
        Assert.areEqual('Today', Temporal.relativeDate(today), 'Today should return "Today"');
        Assert.areEqual('Yesterday', Temporal.relativeDate(yesterday), 'Yesterday should return "Yesterday"');
        Assert.areEqual('Tomorrow', Temporal.relativeDate(tomorrow), 'Tomorrow should return "Tomorrow"');
        Assert.areEqual('In 5 days', Temporal.relativeDate(future), 'Future should return "In 5 days"');
        Assert.areEqual('5 days ago', Temporal.relativeDate(past), 'Past should return "5 days ago"');
    }
}