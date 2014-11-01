#import "NSDate+Additions.h"


@implementation NSDate (DateFormats)

- (NSString *) stringWithDateFormat:(NSString *) format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

- (NSInteger) daysToDate:(NSDate*) endDate
{
    NSDate *startDate = [[self stringWithDateFormat:@"yyyy-MM-dd"] dateWithDateFormat:@"yyyy-MM-dd"];
    endDate = [[endDate stringWithDateFormat:@"yyyy-MM-dd"] dateWithDateFormat:@"yyyy-MM-dd"];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    return [comps day];
}

NSMutableArray * NSStringFromComponent(NSString *name, NSUInteger val, NSMutableArray *acc)
{
    if (0 == val)
    {
        return acc;
    }
    NSMutableString *str = [NSMutableString stringWithFormat:@"%lu %@", (unsigned long)val, name];
    if (val > 1)
    {
        [str appendString:@"s"];
    }
    [acc addObject:str];
    return acc;
}

- (NSString *) humanizedTimeIntervalToDate:(NSDate *) endDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:NSCalendarUnitDay | NSCalendarUnitDay | NSCalendarUnitSecond fromDate:self toDate:endDate options:0];
    // TODO: use some pluralize library
    NSMutableArray *components = NSStringFromComponent(@"sec", [dateComponents second], NSStringFromComponent(@"min", [dateComponents minute], NSStringFromComponent(@"day", [dateComponents day], [NSMutableArray array])));
    return [components componentsJoinedByString:@" "];
}

- (NSString*)hhmm{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    return [df stringFromDate:self];
}

- (NSString*)eventFormat0{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEE, MMM d HH:mm a"];
    return [df stringFromDate:self];
}

+ (NSDate*)roundedUpToNextHourFromDate:(NSDate*)date
{
    NSUInteger hours = (([date timeIntervalSince1970]/3600)+1);
    return [NSDate dateWithTimeIntervalSince1970:hours*3600];
}

- (NSString*)datePrefix
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dc = [cal components:NSCalendarUnitDay fromDate:self];
    if ([dc day] >= 11 && [dc day] <= 13) {
        return @"th";
    }
    else
        switch ([dc day] % 10) {
            case 1:
                return @"st";
            case 2:
                return @"nd";
            case 3:
                return @"rd";
            default:
                return @"th";
        }
    return @"";
}

- (NSString*)descriptionFromDateFormat:(NSString*)dateFormat
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:dateFormat];
    NSString *string = [df stringFromDate:self];
    return [NSString stringWithFormat:string,[self datePrefix]];
}

- (NSString*)shortDescription
{
    return [self descriptionFromDateFormat:@"MMM d%@ YYYY"];
}

- (NSString*)longDescription
{
    return [self descriptionFromDateFormat:@"hh:mm a MMM d%@, YYYY"];
}

- (NSString*)userfriendlyFormat
{
    NSString *ufdate = nil;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval elapsed = now - [self timeIntervalSince1970];
    if(elapsed <= 0) ufdate = @"Now";
    else if(elapsed == 1) ufdate = @"1 second ago";
    else if(elapsed < 60) ufdate = [NSString stringWithFormat:@"%.0f seconds ago",elapsed];
    else if(elapsed < 3600) //One hour in seconds
    {
        int mins = floor(elapsed/60);
        int secs = (int)elapsed%60;
        int disp = MIN((secs <= 30 ? mins : mins + 1), 59);
        ufdate =  [NSString stringWithFormat:@"%.0d minute%@ ago",disp,(disp == 1 ? @"" : @"s")];
    }
    else if(elapsed < 86400) //One day in seconds
    {
        int hours = floor(elapsed/3600);
        int mins = floor(((int)elapsed%3600)/60);
        int disp = MIN((mins <= 30 ? hours : hours + 1), 23);
        ufdate = [NSString stringWithFormat:@"%d hour%@ ago",disp,(disp == 1 ? @"" : @"s")];
    }
    else if(elapsed < 604800) //One week in seconds
    {
        int days = floor(elapsed/86400);
        int hours = floor(((int)elapsed%86400)/3600);
        int disp = MIN((hours <= 12 ? days : days + 1), 6);
        ufdate = [NSString stringWithFormat:@"%d day%@ ago", disp,(disp == 1 ? @"" : @"s")];
    }
    else
        return [self shortDescription];
    return ufdate;
}

- (NSString*)stringWithFormat:(NSString*)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

- (NSString*)weekDayName
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE"];
    });
    return [formatter stringFromDate:self];
}
@end


@implementation NSString (DateFormats)

- (NSDate *) dateWithDateFormat:(NSString *) format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:self];
}

@end
