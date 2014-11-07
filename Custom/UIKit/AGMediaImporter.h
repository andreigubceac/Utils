//
//  AGMediaImporter.h
//
//  Created by Andrei Gubceac on 8/3/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "UIImagePickerController+Blocks.h"
#import <AVFoundation/AVFoundation.h>

@interface AGMediaImporterSheet : UIActionSheet
+ (void)showMediaImporterMenuWithSuccesBlock:(void(^)(UIImagePickerControllerWithBlocks* picker, id info))successBock
                             withCancelBlock:(void(^)(void))cancelBlock
                          fromViewController:(UIViewController*)viewc
                   canRemoveTheExistingPhoto:(BOOL)remove
                                  allowEding:(BOOL)edit;
@end
