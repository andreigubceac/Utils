#import "UITableViewCell+Additions.h"

@implementation UITableViewCell (Additions)
+ (NSString*)identifier
{
    static NSString *identifier;
    identifier = NSStringFromClass([self class]);
    return identifier;
}

+ (CGFloat)cellHeight
{
    return 44.;
}
@end
