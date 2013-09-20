//
//
//  Created by Andrei Gubceac on 2/20/13.
//

#import "AGDatePickerViewController.h"

@interface AGDatePickerViewController ()
{
    IBOutlet UIDatePicker *_datePicker;
    NSDate *_date;
}
@end

@implementation AGDatePickerViewController

- (id)initWithDate:(NSDate*)date
{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        _date = date?date:[NSDate date];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _datePicker.date = _date;
    self.contentSizeForViewInPopover = self.view.bounds.size;
}

- (IBAction)cancelAction:(id)sender
{
    if (self.cancelBlock)
        self.cancelBlock(self);
}

- (IBAction)doneAction:(id)sender
{
    if (self.doneBlock)
        self.doneBlock(self,_datePicker.date);
}

#pragma mark - public

- (void)setDatePickerMode:(UIDatePickerMode)datePickerMode_
{
    _datePicker.datePickerMode = datePickerMode_;
}

- (void)setMinDate:(NSDate *)minDate_
{
    _datePicker.minimumDate = minDate_;
}

- (void)setMaxDate:(NSDate *)maxDate_
{
    _datePicker.maximumDate = maxDate_;
}

@end
