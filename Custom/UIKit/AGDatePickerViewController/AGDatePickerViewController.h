//
//  Created by Andrei Gubceac on 2/20/13.
//  Copyright (c) 2013. All rights reserved.
//


@interface AGDatePickerViewController : UIViewController
@property (nonatomic, copy) void (^cancelBlock)(AGDatePickerViewController*);
@property (nonatomic, copy) void (^doneBlock)(AGDatePickerViewController*, NSDate*);
@property (nonatomic,assign) NSDate *minDate, *maxDate;
@property (nonatomic,readwrite) UIDatePickerMode datePickerMode;
- (id)initWithDate:(NSDate*)date;
- (void)showViewFromViewController:(UIViewController*)viewController animated:(BOOL)animated;
- (void)hideViewAnimated:(BOOL)animated;
@end
