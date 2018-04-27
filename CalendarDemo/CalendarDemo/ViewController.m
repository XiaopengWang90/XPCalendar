//
//  ViewController.m
//  CalendarDemo
//
//  Created by apple on 2018/4/27.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"
#import "XPCalendar.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat width = self.view.bounds.size.width ;
    CGPoint origin = CGPointMake(0, 40);
    XPCalendarView *calendar = [[XPCalendarView alloc] initWithFrameOrigin:origin width:width];
    calendar.didSelectDayHandler= ^(NSInteger year, NSInteger month, NSInteger day) {
        
    };
    calendar.calendarScrollView.selectYear = 2018;
    calendar.calendarScrollView.selectMonth = 04;
    calendar.calendarScrollView.selectDay = 8;
//    calendar.calendarScrollView.selectBkgCircleColor = [UIColor colorWithRed:182.0 / 255.0 green:210.0 / 255.0 blue:87.0 / 255.0 alpha:1.0];;
    [self.view addSubview:calendar];
    
   
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
