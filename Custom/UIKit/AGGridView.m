//
//  AGGridView.m
//
//  Created by Andrei Gubceac on 3/3/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "AGGridView.h"

@interface AGGridView ()
{
    NSUInteger _numberOfColumns, _totalNumberOfRows;
}
@end

@implementation AGGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib
{
    self.dataSource = self;
    _numberOfColumns = 1;
    [self setNumberOfColumnsBlock:^NSUInteger{
        return 1;
    }];
    [self setTotalNumberOfRowsBlock:^NSUInteger{
        return 0;
    }];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
}

- (void)setNumberOfColumns:(NSUInteger)numberOfColumns_
{
    _numberOfColumns = MAX(1, numberOfColumns_);
}

- (void)tapAction:(UITapGestureRecognizer*)g
{
    if (UIGestureRecognizerStateEnded == g.state)
    {
        if (self.didTapOnRecordAtIndexBlock)
        {
            CGPoint _pt = [g locationInView:g.view];
            NSIndexPath *_ip = [self indexPathForRowAtPoint:_pt];
            UITableViewCell *_cell = [self cellForRowAtIndexPath:_ip];
            int i = _pt.x/(CGRectGetWidth(g.view.bounds)/(float)_numberOfColumns);
            UIView *_v = (i<[_cell.contentView.subviews count]?[_cell.contentView.subviews objectAtIndex:i]:nil);
            if (_v)
                self.didTapOnRecordAtIndexBlock(_v,(_ip.row*_numberOfColumns+i));
        }
    }
}

- (void)reloadData
{
    _numberOfColumns = self.numberOfColumnsBlock();
    _totalNumberOfRows = self.totalNumberOfRowsBlock();
    [super reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ceilf((_totalNumberOfRows+1)/(float)_numberOfColumns);
}

- (UITableViewCell*)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"AGGridCell";
    static NSUInteger space = 11;
    UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:identifier];
    if (nil==cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    for (NSInteger i=0; i<_numberOfColumns; i++)
    {
        UIView *_v = (i < [cell.contentView.subviews count]?[cell.contentView.subviews objectAtIndex:i]:nil);
        NSInteger index = (indexPath.row*_numberOfColumns+i);
        if (self.viewForRecordAtIndexBlock)
        {
            if (index < _totalNumberOfRows)
            {
                _v = self.viewForRecordAtIndexBlock(_v, index);
                _v.hidden = NO;
            }
            else
            {
                _v.hidden = YES;
            }
        }
        if (_v == nil)
        {
            NSLog(@"No view at index : %d",indexPath.row * _numberOfColumns + i);
        }
        if (_v.superview == nil && _v)
        {
            CGRect frame = _v.frame;
            frame.origin.x = (space*(i+1) + i % _numberOfColumns * frame.size.width);
            _v.frame = frame;
            [cell.contentView addSubview:_v];
        }
    }

    return cell;
}
@end

