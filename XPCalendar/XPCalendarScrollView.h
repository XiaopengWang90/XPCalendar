//
//  GFCalendarScrollView.h
//
//  Created by Mercy on 2016/11/9.
//  Copyright © 2016年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidSelectDayHandler)(NSInteger, NSInteger, NSInteger);

@interface XPCalendarScrollView : UIScrollView


@property (nonatomic, strong) DidSelectDayHandler didSelectDayHandler; // 日期点击回调
@property (nonatomic, assign) NSInteger selectYear;  //选中的年份
@property (nonatomic, assign) NSInteger selectMonth;  //选中的月份
@property (nonatomic, assign) NSInteger selectDay;  //选中的日期
@property (nonatomic, strong) NSDate *currentMonthDate;
@property (nonatomic, strong) UIColor *selectBkgCircleColor;

- (void)refreshToCurrentMonth; // 刷新 calendar 回到当前日期月份


@end
