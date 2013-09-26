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
- (unsigned char*)colorOfPointInImage:(CGPoint)point;
@end