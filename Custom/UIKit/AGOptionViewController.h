//
//  AGOptionViewController.h
//
//  Created by Andrei Gubceac on 3/12/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGOptionViewController : UITableViewController
{
    NSArray *_optionsArray;
}
- (void)configureCell:(UITableViewCell*)cell withDictionary:(id)dict atIndexPath:(NSIndexPath*)indexPath;
@end
