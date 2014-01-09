#import <Foundation/Foundation.h>


@interface NSDate (Additions)

- (NSString *) stringWithDateFormat:(NSString *) format;

- (NSInteger) daysToDate:(NSDate*) anEndDate;

- (NSString *) humanizedTimeIntervalToDate:(NSDate *) refDate;

- (NSString*)hhmm;
- (NSString*)eventFormat0;

+ (NSDate*)roundedUpToNextHourFromDate:(NSDate*)date;
- (NSString*)datePrefix;
- (NSString*)longDescription;
- (NSString*)shortDescription;
- (NSString*)userfriendlyFormat;
- (NSString*)weekDayName;

- (NSString*)stringWithFormat:(NSString*)format;
@end



@interface NSString (DateFormats)

- (NSDate *) dateWithDateFormat:(NSString *) format;

@end