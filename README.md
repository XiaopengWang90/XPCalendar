# XPCalendar

#效果图展示


![image](https://github.com/XiaopengWang90/XPCalendar/blob/master/Calendar.gif)

#使用cocoapod 导入XPCalendar

platform :ios, '8.0'
#use_frameworks!个别需要用到它，比如reactiveCocoa

target 'CalendarDemo' do
    pod 'XPCalendar'
end


#调用XPCalendar

导入头文件 #import "XPCalendar.h"


    CGFloat width = self.view.bounds.size.width ;
    CGPoint origin = CGPointMake(0, 40);
    XPCalendarView *calendar = [[XPCalendarView alloc] initWithFrameOrigin:origin width:width];
    calendar.didSelectDayHandler= ^(NSInteger year, NSInteger month, NSInteger day) {
        
    };
    calendar.calendarScrollView.selectYear = 2018;   //设置初始的年份
    calendar.calendarScrollView.selectMonth = 04;    //设置初始的月份
    calendar.calendarScrollView.selectDay = 8;       //设置初始的日期
    calendar.calendarScrollView.selectBkgCircleColor = [UIColor colorWithRed:182.0 / 255.0 green:210.0 / 255.0 blue:87.0 /         255.0 alpha:1.0];;     //设置选中的颜色
    [self.view addSubview:calendar];
