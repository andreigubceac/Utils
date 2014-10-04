//
//  AGViewController.m
//
//  Created by Andrei Gubceac on 1/16/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "AGViewController.h"

@interface AGViewController ()

@end

@implementation AGViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    return [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - public

- (void)loadWithTableViewStyle:(UITableViewStyle)style
{
    _tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:style];
    [_tableView setBackgroundView:nil];
    self.view = _tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)updateUI
{
    
}

- (void)dismissModalViewController
{
    [super dismissViewControllerAnimated:YES completion:nil];
}
#pragma uitableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}
@end
