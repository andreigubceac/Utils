//
//  UIImage+Additions.m
//
//  Created by Andrei Gubceac on 12/5/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

- (UIImage *)scaleToSize:(CGSize)targetSize {
    CGFloat xscale = targetSize.width / self.size.width;
    CGFloat yscale = targetSize.height / self.size.height;
    
    CGFloat scaleFactor = fminf(fminf(xscale, yscale), 1.0f);
    
    UIGraphicsBeginImageContext(CGSizeMake(self.size.width*scaleFactor, self.size.height*scaleFactor));
    
    //Creating the rect where the scaled image is drawn in
    // CGRect rect = CGRectMake((targetSize.width - self.size.width * scaleFactor) / 2,
    //                          (targetSize.height -  self.size.height * scaleFactor) / 2,
    //                          self.size.width * scaleFactor, self.size.height * scaleFactor);
    
    CGRect rect = CGRectMake(0, 0, self.size.width*scaleFactor, self.size.height*scaleFactor);
    
    //Draw the image into the rect
    [self drawInRect:rect];
    
    //Saving the image, ending image context
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
        
    return scaledImage;
}


@end

@implementation UIImage (quartz)

+ (UIImage*)pointImageWithColor:(UIColor*)c
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), c.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 1, 1));
    UIImage *_img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return _img;
}

+ (UIImage *)captureView:(UIView *)view
{
    UIGraphicsBeginImageContext([view bounds].size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, [view bounds]);
    [view.layer renderInContext:ctx];
    UIImage *_img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    ctx = nil;
    return _img;
}

- (unsigned char*)colorOfPointInImage:(CGPoint)pt
{
    unsigned char *pixel = malloc(sizeof(unsigned char)*4);
    
    CGDataProviderRef provider = CGImageGetDataProvider(self.CGImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(pixelData);
    int pixelInfo = ((CGImageGetWidth(self.CGImage) * pt.y) + pt.x) * 4; // The image is png
    pixel[0] = data[pixelInfo];
    pixel[1] = data[pixelInfo + 1];
    pixel[2] = data[pixelInfo + 2];
    pixel[3] = data[pixelInfo + 3];
    CFRelease(pixelData);
    return pixel;
}

- (UIImage*)imageWithMaskColorForPoint:(CGPoint)point
{
    unsigned char *selectedColor = [self colorOfPointInImage:point];
    CGFloat components[6] =  {selectedColor[1]-5,selectedColor[1]+5, selectedColor[2]-5, selectedColor[2]+5,selectedColor[3]-5, selectedColor[3]+5};
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                CGImageGetWidth(self.CGImage),
                                                CGImageGetHeight(self.CGImage),
                                                CGImageGetBitsPerComponent(self.CGImage),
                                                CGImageGetBytesPerRow(self.CGImage),
                                                CGImageGetColorSpace(self.CGImage),
                                                kCGBitmapAlphaInfoMask);
    CGContextDrawImage(bitmap, CGRectMake(0, 0, CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage)), self.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    CGImageRef img = CGImageCreateWithMaskingColors(newImageRef, components);
    CGImageRelease(newImageRef);
    CGContextRelease(bitmap);
    UIImage *_img = [UIImage imageWithCGImage:img];
    CGImageRelease(img);
    return _img;
}

- (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{
    CGImageRef srcImg  = image.CGImage;
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask(srcImg, mask);
    UIImage *result = [UIImage imageWithCGImage:masked];
    
    CGImageRelease(masked);
    CGImageRelease(mask);
    
	return result;
}

+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor*)bcolor foregroundImage:(UIImage*)fimage
{
    if (CGSizeEqualToSize(size, CGSizeZero))
        return nil;
    size.width *= [UIScreen mainScreen].scale;
    size.height*= [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContext(size);
    CGContextRef _ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(_ctx, bcolor.CGColor);
    CGContextFillRect(_ctx, CGRectMake(0, 0, size.width, size.height));
    [fimage drawInRect:(CGRect){CGPointMake((size.width-fimage.size.width)/2,(size.height-fimage.size.height)/2),fimage.size}];
    UIImage *_img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return _img;
}
@end

