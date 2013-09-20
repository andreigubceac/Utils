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
