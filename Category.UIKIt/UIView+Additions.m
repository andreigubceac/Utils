#import "UIView+Additions.h"

@implementation UIView (Additions)

- (CGSize)contentSize
{
    if ([self respondsToSelector:@selector(setText:)])
    {
        return [[(UILabel*)self text] boundingRectWithSize:CGSizeMake(self.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [(UILabel*)self font]} context:NULL].size;
    }
    return self.size;
}

- (void)adjustContentSizeHeightKeepingTopOffest:(BOOL)offset
{
    if ([self respondsToSelector:@selector(setText:)])
    {
        CGSize s = [self contentSize];
        self.height = s.height;
        return;
    }
    UIView *_v = [self.subviews firstObject];
    if (offset == NO)
        _v.top = 0;
    CGFloat _h = _v.hidden?0:_v.height;
    for (unsigned i = 1; i < [self.subviews count]; i++) {
        _v      = [self.subviews objectAtIndex:i];
        _v.top  = _h;
        _h      = _v.hidden?_h:_v.bottom;
    }
    self.height = _h;
    if ([self respondsToSelector:@selector(setContentSize:)])
    {
        _v = [self.subviews lastObject];
        [(UIScrollView*)self setContentSize:(CGSize){self.width, _v.bottom}];
    }
}

- (void)adjustContentSizeHeight
{
    [self adjustContentSizeHeightKeepingTopOffest:NO];
}

- (void)makeHorizontalCarousel
{
    CGRect _frame = self.frame;
    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.frame = _frame;
}
@end

@implementation UIView (Geometry)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


@end