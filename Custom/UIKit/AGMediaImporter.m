//
//  AGMediaImporter.m
//
//  Created by Andrei Gubceac on 8/3/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AGMediaImporter.h"

@interface AGMediaImporter ()<UIActionSheetDelegate>
@property (nonatomic,copy) void (^successBock)(UIImagePickerControllerWithBlocks*,id);
@property (nonatomic,copy) void (^cancelBlock)();
@property (nonatomic,strong) UIViewController *viewController;
@end

static AGMediaImporter *delegate;

@implementation AGMediaImporter
@synthesize successBock, cancelBlock;
@synthesize viewController;

+ (void)showMediaImporterMenuWithSuccesBlock:(void(^)(UIImagePickerControllerWithBlocks* picker, id info))successBock
                             withCancelBlock:(void(^)(void))cancelBlock
                          fromViewController:(UIViewController*)viewc
                   canRemoveTheExistingPhoto:(BOOL)remove
{
    delegate = [[AGMediaImporter alloc] init];
    delegate.viewController = viewc;
    delegate.successBock = successBock;
    delegate.cancelBlock = cancelBlock;
    if (viewc.tabBarController)
    {
        [[[UIActionSheet alloc] initWithTitle:nil delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:(remove?@"Delete":nil)
                            otherButtonTitles:@"From Library",([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]?@"Take Photo":nil), nil] showFromTabBar:viewc.tabBarController.tabBar];
    }
    else
        [[[UIActionSheet alloc] initWithTitle:nil delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:(remove?@"Delete":nil)
                            otherButtonTitles:@"From Library",([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]?@"Take Photo":nil), nil] showInView:viewc.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        if (self.successBock)
            self.successBock(nil, nil);
    }
    else if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (actionSheet.destructiveButtonIndex != -1)
            buttonIndex--;
        UIImagePickerControllerWithBlocks *picker = [[UIImagePickerControllerWithBlocks alloc] init];
        picker.allowsEditing = YES;
        picker.sourceType = (buttonIndex==0?UIImagePickerControllerSourceTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera);
        [self.viewController presentModalViewController:picker animated:YES];
        picker.didCancelBlock = ^(UIImagePickerControllerWithBlocks *picker_)
        {
            [self.viewController dismissViewControllerAnimated:YES completion:^{
                if (self.cancelBlock)
                    self.cancelBlock();
            }];
        };
        picker.didFinishPickingMediaWithInfoBlock = ^(UIImagePickerControllerWithBlocks *picker_, NSDictionary *info)
        {
            [self.viewController dismissViewControllerAnimated:YES completion:^{
                if (self.successBock)
                    self.successBock(picker_, info);
            }];
        };
    }
    delegate = nil;
}

@end
