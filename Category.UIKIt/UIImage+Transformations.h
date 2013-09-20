#import <UIKit/UIKit.h>

@interface UIImage (Transformations)

- (id)copyWithZone:(NSZone*)zone;
- (UIImage*)flippedImage;
- (UIImage*)uprightImage;
- (UIImage*)croppedImage:(CGRect)bounds;
- (UIImage*)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage*)rotatedImage:(CGFloat)radians fillColor:(UIColor*)fillColor;

@end
