#import "UICollectionViewCell+Additions.h"

@implementation UICollectionViewCell (Additions)
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
