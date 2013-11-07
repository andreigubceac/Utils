//
//  UIImagePickerController+Blocks.m
//
//  Created by Andrei Gubceac on 12/4/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "UIImagePickerController+Blocks.h"

@interface UIImagePickerControllerWithBlocks ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation UIImagePickerControllerWithBlocks

- (id)init
{
    self = [super init];
    if (self)
    {
        self.delegate = self;
        self.allowsEditing = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.didCancelBlock)
        self.didCancelBlock(self);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.didFinishPickingMediaWithInfoBlock)
        self.didFinishPickingMediaWithInfoBlock(self,info);
}

+ (UIImage*)imageFromInfo:(NSDictionary*)info
{
    if ([info valueForKey:UIImagePickerControllerEditedImage])
        return [info valueForKey:UIImagePickerControllerEditedImage];
    return [info valueForKey:UIImagePickerControllerOriginalImage];
}

@end
