//
//  ModalAlert.h
//
//  Created by Gubceac Andrei on 5/30/11.
//

#import <UIKit/UIKit.h>

@interface ModalAlert : NSObject
+ (BOOL) ask: (NSString *) question;
+ (BOOL) confirm:(NSString *) statement;
@end