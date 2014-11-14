#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)
- (NSString *)URLEncodedString;
@end
@interface NSString (Regex)
- (BOOL) isEmailFormatValid;
- (BOOL) isPhoneNumberFormatValid;
- (BOOL) isDecimalFormat;
- (BOOL) isDecimalPositiveFormat;
- (BOOL) isZIPFormatValid;
@end
@interface NSString (NilCheck)
+ (NSString*)emptyString:(NSString*)s;
- (NSString*)emptyString;
@end

@interface NSString (UUID)
+ (NSString*)getUUID;
@end

@interface NSString (URL)
- (NSMutableDictionary*)queryParams;
@end

@interface NSString (unicodeUTF16)
- (NSString*)unicodeUTF16Translation;
@end
