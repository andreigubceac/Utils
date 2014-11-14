#import "NSString+Additions.h"

@implementation NSString (URLEncoding)
- (NSString *)URLEncodedString {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[self UTF8String];
    size_t sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || 
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end


@implementation NSString (Regex)

- (BOOL)isEmailFormatValid
{    
    NSString *emailRegEx = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    return [regExPredicate evaluateWithObject:self];
}

- (BOOL) isPhoneNumberFormatValid
{
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]>0;//todo
    //need a regex for all countries
    NSString *phoneRegEx = @"[235689][0-9]{6}([0-9]{3})?";
    
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegEx];
    return [regExPredicate evaluateWithObject:self];
}

//http://www.regular-expressions.info/floatingpoint.html
- (BOOL) isDecimalFormat
{
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[-+]?[0-9]*\\.?[0-9]*"] evaluateWithObject:self];
}

- (BOOL) isDecimalPositiveFormat
{
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[+]?[0-9]*\\.?[0-9]*"] evaluateWithObject:self];
}

- (BOOL) isZIPFormatValid
{
    NSString *zipRegEx = @"^(\\d{5}(-\\d{4})?|[a-z]\\d[a-z][- ]*\\d[a-z]\\d)$";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", zipRegEx];
    return [regExPredicate evaluateWithObject:self];
}
@end

@implementation NSString (NilCheck)

+ (NSString*)emptyString:(NSString*)s
{
    return s?([s isEqual:[NSNull null]]?@"":s):@"";
}

- (NSString*)emptyString
{
    return [NSString emptyString:self];
}

@end

@implementation NSString (UUID)

+ (NSString*)getUUID
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef str = CFUUIDCreateString(NULL, uuid);
    NSString* mediaId = [NSString stringWithString:(__bridge NSString*)str];
    CFRelease(str);
    CFRelease(uuid);
    
    return mediaId;
}

@end

@implementation NSString (URL)

- (NSMutableDictionary*)queryParams
{
    NSMutableDictionary *_qParams = [NSMutableDictionary dictionary];
    [[self componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *_keyValue = [obj componentsSeparatedByString:@"="];
        if (_keyValue.count==2)
            [_qParams setValue:_keyValue.lastObject forKey:_keyValue.firstObject];
    }];
    return _qParams;
}

@end

@implementation NSString (unicodeUTF16)

- (NSString*)unicodeUTF16Translation
{
    NSString *_decode = [self stringByReplacingOccurrencesOfString:@"Äƒ" withString:@"ă"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"Ã¢" withString:@"â"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"Ã®" withString:@"î"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"È™" withString:@"ș"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"È›" withString:@"ț"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"â€“" withString:@"-"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"È˜" withString:@"Ș"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"ÃŽ" withString:@"Î"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"Ã‰" withString:@"É"];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"â€œ" withString:@"\""];
    _decode = [_decode stringByReplacingOccurrencesOfString:@"â€" withString:@"\""];
    return _decode;
}

@end