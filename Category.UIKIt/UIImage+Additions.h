//
//  UIImage+Additions.h
//
//  Created by Andrei Gubceac on 12/5/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
- (UIImage *)scaleToSize:(CGSize)targetSize;
@end

@interface UIImage (quartz)
+ (UIImage*)pointImageWithColor:(UIColor*)c;
+ (UIImage *)captureView:(UIView *)view;
+ (UIImage*)imageWithSize:(CGSize)size backgroundColor:(UIColor*)bcolor foregroundImage:(UIImage*)fimage;

- (unsigned char*)colorOfPointInImage:(CGPoint)point;
- (UIImage*)imageWithMaskColorForPoint:(CGPoint)point;
- (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;
@end