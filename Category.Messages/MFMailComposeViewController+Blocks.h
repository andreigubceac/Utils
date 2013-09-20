//
//  MFMailComposeViewController+Blocks.h
//
//  Created by Andrei Gubceac on 4/2/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface MFMailComposeViewController (BlocksAdditions)
+ (MFMailComposeViewController*)mailComposerWithParams:(NSDictionary*)d//subject,messasge, image
                                     withCompleteBlock:(void(^)(MFMailComposeViewController *, MFMailComposeResult))cblock;
+ (NSString*)userFriendlyResult:(MFMailComposeResult)result;
@end
