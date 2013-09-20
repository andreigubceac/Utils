//
//  ModalAlert.m
//
//  Created by Gubceac Andrei on 5/30/11.
//

#import "ModalAlert.h"


@interface ModalAlertDelegate : NSObject <UIAlertViewDelegate>
{
	CFRunLoopRef currentLoop;
	NSUInteger index;
}
@property (readonly) NSUInteger index;
@end

@implementation ModalAlertDelegate
@synthesize index;

-(id) initWithRunLoop: (CFRunLoopRef)runLoop 
{
    self = [super init];
	if (self)
        currentLoop = runLoop;
	return self;
}

-(void) alertView: (UIAlertView*)aView clickedButtonAtIndex: (NSInteger)anIndex 
{
	index = anIndex;
	CFRunLoopStop(currentLoop);
}
@end

@implementation ModalAlert
+(NSUInteger) queryWith: (NSString *)question button1: (NSString *)button1 button2: (NSString *)button2
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
    
	ModalAlertDelegate *madelegate = [[ModalAlertDelegate alloc] initWithRunLoop:currentLoop];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:question message:nil delegate:madelegate cancelButtonTitle:button1 otherButtonTitles:button2, nil];
	[alertView show];
	CFRunLoopRun();
    
	NSUInteger answer = madelegate.index;
	return answer;
}

+ (BOOL) ask: (NSString *) question
{
	return	([ModalAlert queryWith:question 
                          button1:NSLocalizedString(@"Yes",@"Yes")
                          button2:NSLocalizedString(@"No",@"No")] == 0);
}

+ (BOOL) confirm: (NSString *) statement
{
	return	[ModalAlert queryWith:statement
                         button1:NSLocalizedString(@"Cancel",@"Cancel")
                         button2:NSLocalizedString(@"Ok",@"Ok")];
}
@end



