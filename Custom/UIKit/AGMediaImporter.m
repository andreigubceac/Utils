//
//  AGMediaImporter.m
//
//  Created by Andrei Gubceac on 8/3/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "AGMediaImporter.h"

@interface AGMediaImporterSheet ()<UIActionSheetDelegate>
@property (nonatomic,copy) void (^successBock)(UIImagePickerControllerWithBlocks*,id);
@property (nonatomic,copy) void (^cancelBlock)();
@property (nonatomic,strong) UIViewController *viewController;
@end


@implementation AGMediaImporterSheet
@synthesize successBock, cancelBlock;
@synthesize viewController;

+ (void)showMediaImporterMenuWithSuccesBlock:(void(^)(UIImagePickerControllerWithBlocks* picker, id info))successBock
                             withCancelBlock:(void(^)(void))cancelBlock
                          fromViewController:(UIViewController*)viewc
                   canRemoveTheExistingPhoto:(BOOL)remove
{
    AGMediaImporterSheet *delegate = [AGMediaImporterSheet alloc];
    delegate.viewController = viewc;
    delegate.successBock = successBock;
    delegate.cancelBlock = cancelBlock;
    if (viewc.tabBarController)
    {
        [[delegate initWithTitle:nil delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:(remove?@"Delete":nil)
               otherButtonTitles:@"From Library",([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]?@"Take Photo":nil), nil] showFromTabBar:viewc.tabBarController.tabBar];
    }
    else
        [[delegate initWithTitle:nil delegate:delegate cancelButtonTitle:@"Cancel" destructiveButtonTitle:(remove?@"Delete":nil)
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
        picker.allowsEditing = NO;
        picker.sourceType = (buttonIndex==0?UIImagePickerControllerSourceTypePhotoLibrary:UIImagePickerControllerSourceTypeCamera);
        [self.viewController presentViewController:picker animated:YES completion:nil];
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
    else if (self.cancelBlock)
        self.cancelBlock();
}

@end
