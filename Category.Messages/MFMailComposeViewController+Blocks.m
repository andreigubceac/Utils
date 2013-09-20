//
//  MFMailComposeViewController+Blocks.m
//
//  Created by Andrei Gubceac on 4/2/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "MFMailComposeViewController+Blocks.h"

@interface MFMailComposeViewControllerWithBlocks : MFMailComposeViewController <MFMailComposeViewControllerDelegate>
@property (nonatomic, copy) void (^completeBlock)(MFMailComposeViewController*, MFMailComposeResult);
@end
@implementation MFMailComposeViewControllerWithBlocks

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (self.completeBlock)
        self.completeBlock(self, result);
}
@end

@implementation MFMailComposeViewController (BlocksAdditions)
+ (MFMailComposeViewController*)mailComposerWithParams:(NSDictionary *)d withCompleteBlock:(void (^)(MFMailComposeViewController*, MFMailComposeResult))cblock
{
	if (![MFMailComposeViewController canSendMail]){
		NSURL *emailUrl = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@",[d valueForKey:@"to"]]];
		if ([[UIApplication sharedApplication] canOpenURL:emailUrl])
			[[UIApplication sharedApplication] openURL:emailUrl];
		else {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Can't send email"
                                       delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
		}
		return nil;
	}
	MFMailComposeViewControllerWithBlocks *picker = [[MFMailComposeViewControllerWithBlocks alloc] init];
    picker.completeBlock = cblock;
    [picker setToRecipients:d[@"to"]];
    [picker setSubject:[d valueForKey:@"subject"]];
    [picker setMessageBody:[d valueForKey:@"message"] isHTML:YES];
	picker.mailComposeDelegate = picker;
	if ([d objectForKey:@"image"])
    {
        if ([[d objectForKey:@"image"] isKindOfClass:[NSData class]])
            [picker addAttachmentData:[d objectForKey:@"image"] mimeType:@"image/png" fileName:@"image"];
        else if ([[d objectForKey:@"image"] isKindOfClass:[UIImage class]])
            [picker addAttachmentData:UIImagePNGRepresentation([d objectForKey:@"image"]) mimeType:@"image/png" fileName:@"image"];
    }
    else if ([d objectForKey:@"file"])
        [picker addAttachmentData:d[@"file"][@"content"] mimeType:d[@"file"][@"fileType"] fileName:d[@"file"][@"fileName"]];
    return picker;
}

#pragma mark MessageComposeResult
+ (NSString*)userFriendlyResult:(MFMailComposeResult)result
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			return @"Result: canceled";
		case MFMailComposeResultSaved:
			return @"Result: saved";
		case MFMailComposeResultSent:
			return @"Result: sent";
		case MFMailComposeResultFailed:
			return @"Result: failed";
		default:
			return @"Result: not sent";
	}
}

@end
