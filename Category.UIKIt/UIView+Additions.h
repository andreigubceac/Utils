#import <UIKit/UIKit.h>

@interface UIView (Additions)
- (CGSize)contentSize;
- (void)adjustContentSizeHeight;
- (void)adjustContentSizeHeightKeepingTopOffest:(BOOL)offset;
- (void)makeHorizontalCarousel;
@end

@interface UIView (Geometry)
@property (nonatomic) CGFloat left, top, right, bottom;

@property (nonatomic) CGFloat width, height;

@property (nonatomic) CGFloat centerX,centerY;

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;

@end