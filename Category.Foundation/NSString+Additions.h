#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)
- (NSString *)URLEncodedString;
@end
@interface NSString (Regex)
- (BOOL)isEmailFormatValid;
- (BOOL) isPhoneNumberFormatValid;
- (BOOL) isDecimalFormat;
- (BOOL) isDecimalPositiveFormat;
@end
@interface NSString (NilCheck)
+ (NSString*)emptyString:(NSString*)s;
@end

@interface NSString (UUID)
+ (NSString*)getUUID;
@end
