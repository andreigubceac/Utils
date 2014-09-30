//
//  AGViewController.h
//
//  Created by Andrei Gubceac on 1/16/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *_tableView;
}
@property (nonatomic, readonly) UITableView *tableView;
- (void)loadWithTableViewStyle:(UITableViewStyle)style;//to switch in tableViewcontroller mode
- (void)updateUI;
- (void)dismissModalViewController;//[super dismissViewControllerAnimated:YES completion:nil]; usefull for inline buttons / bar item
@end
