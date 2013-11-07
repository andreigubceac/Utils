//
//  UIImagePickerController+Blocks.h
//
//  Created by Andrei Gubceac on 12/4/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImagePickerControllerWithBlocks : UIImagePickerController
@property (nonatomic, copy) void (^didFinishPickingMediaWithInfoBlock)(UIImagePickerControllerWithBlocks*v,NSDictionary*d);
@property (nonatomic, copy) void (^didCancelBlock)(UIImagePickerControllerWithBlocks*v);
+ (UIImage*)imageFromInfo:(NSDictionary*)info;
@end
