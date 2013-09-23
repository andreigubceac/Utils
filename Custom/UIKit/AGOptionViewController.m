//
//  AGOptionViewController.m
//
//  Created by Andrei Gubceac on 3/12/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGOptionViewController.h"

NSString *kOptionSectionHeaderText = @"kOptionSectionHeaderText", *kOptionSectionRowsArray = @"kOptionSectionRowsArray", *kOptionSectionFooterText = @"kOptionSectionFooterText", *kOptionSectionRowBlock = @"kOptionSectionRowBlock";

@interface AGOptionViewController ()

@end

@implementation AGOptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setBackgroundView:nil];
}

- (void)configureCell:(UITableViewCell*)cell withDictionary:(id)dict atIndexPath:(NSIndexPath*)indexPath
{
}

- (void)reloadData:(NSArray*)optionArray
{
    if ([_optionsArray isEqualToArray:optionArray])
        return;
    _optionsArray = optionArray;
    [self.tableView reloadData];
}
@end

@implementation AGOptionViewController (UITableView)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_optionsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_optionsArray objectAtIndex:section][kOptionSectionRowsArray] count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_optionsArray objectAtIndex:section][kOptionSectionHeaderText];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [_optionsArray objectAtIndex:section][kOptionSectionFooterText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    id obj = [[_optionsArray objectAtIndex:indexPath.section][kOptionSectionRowsArray] objectAtIndex:indexPath.row];
    // Configure the cell...
    [self configureCell:cell withDictionary:obj atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id obj = [[_optionsArray objectAtIndex:indexPath.section][kOptionSectionRowsArray] objectAtIndex:indexPath.row];
    void (^block)() = obj[kOptionSectionRowBlock];
    if (block)
        block();
}


@end