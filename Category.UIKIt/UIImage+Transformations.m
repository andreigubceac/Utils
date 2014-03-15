#import "UIImage+Transformations.h"

@implementation UIImage (Transformations)

- (id)copyWithZone:(NSZone*)zone
{
    return [[UIImage allocWithZone: zone] initWithCGImage:self.CGImage];
}

- (UIImage*)flippedImage
{
    UIImageOrientation o = UIImageOrientationUp;
    switch (self.imageOrientation)
    {
        case UIImageOrientationUp: o = UIImageOrientationUpMirrored;break;
        case UIImageOrientationDown: o = UIImageOrientationDownMirrored;break;
        case UIImageOrientationLeft: o = UIImageOrientationRightMirrored;break;
        case UIImageOrientationRight: o = UIImageOrientationLeftMirrored;break;
        default:break;
    }

    UIImage* image = [UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:o];
    return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:image.size interpolationQuality:kCGInterpolationDefault];
}

- (UIImage*)uprightImage
{
    if (self.imageOrientation == UIImageOrientationUp)
        return self;

    UIImage* image = [UIImage imageWithCGImage:self.CGImage scale:1.0 orientation:self.imageOrientation];
    return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:image.size interpolationQuality:kCGInterpolationDefault];
}

- (UIImage *)croppedImage:(CGRect)bounds
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality
{
    BOOL drawTransposed;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality
{
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio;
    
    switch (contentMode) {
        case UIViewContentModeScaleAspectFill:
            ratio = MAX(horizontalRatio, verticalRatio);
            break;
            
        case UIViewContentModeScaleAspectFit:
            ratio = MIN(horizontalRatio, verticalRatio);
            break;
            
        default:
            [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %ld", contentMode];
    }
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    return [self resizedImage:newSize interpolationQuality:quality];
}

#pragma mark -
#pragma mark Private helper methods

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    //    size_t bytesPerRow = (CGImageGetBytesPerRow(imageRef) / self.size.width)  * newRect.size.width;
    //
    //    CGContextRef bitmap = CGBitmapContextCreate(NULL,
    //                                                newRect.size.width,
    //                                                newRect.size.height,
    //                                                CGImageGetBitsPerComponent(imageRef),
    //                                                bytesPerRow,
    //                                                CGImageGetColorSpace(imageRef),
    //                                                kCGImageAlphaPremultipliedFirst);
    //    
    //    CGContextConcatCTM(bitmap, transform);
    //    CGContextSetInterpolationQuality(bitmap, quality);
    //    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    //    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    //    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    //    CGContextRelease(bitmap);
    //    CGImageRelease(newImageRef);
    UIGraphicsBeginImageContext(newRect.size);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(bitmap, 1, -1);
    CGContextTranslateCTM(bitmap, 0, -newRect.size.height);
    CGContextConcatCTM(bitmap, transform);
    CGContextSetInterpolationQuality(bitmap, quality);
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (CGAffineTransform)transformForOrientation:(CGSize)newSize
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:break;
    }
    
    return transform;
}

- (UIImage*)rotatedImage:(CGFloat)r fillColor:(UIColor*)fillColor
{
    CGSize size = CGRectApplyAffineTransform(CGRectMake(0,0,self.size.width,self.size.height),CGAffineTransformMakeRotation(r)).size;

    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if (fillColor != NULL)
    {
        CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
        CGContextFillRect(ctx, CGRectMake(0.0, 0.0, size.width, size.height));
    }

    CGContextTranslateCTM(ctx, size.width/2, size.height/2);
    CGContextRotateCTM(ctx, r);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    CGContextDrawImage(ctx, CGRectMake(-self.size.width/2, -self.size.height/2, self.size.width, self.size.height), self.CGImage);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return img;
}

@end
