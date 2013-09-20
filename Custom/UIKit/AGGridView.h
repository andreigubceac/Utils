//
//  AGGridView.h
//
//  Created by Andrei Gubceac on 3/3/13.
//  Copyright (c) 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGGridView : UITableView<UITableViewDataSource>
//mandatory
@property (nonatomic, copy) NSUInteger (^numberOfColumnsBlock)();
@property (nonatomic, copy) NSUInteger (^totalNumberOfRowsBlock)();
//optional
@property (nonatomic, copy) UIView* (^viewForRecordAtIndexBlock)(UIView *view, NSUInteger index);//If view == nil then it's a new view;
@property (nonatomic, copy) void(^didTapOnRecordAtIndexBlock)(UIView*view, NSUInteger index);
@end
