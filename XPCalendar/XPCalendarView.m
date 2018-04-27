//
//  GFCalendarView.m
//
//  Created by Mercy on 2016/11/9.
//  Copyright © 2016年 Mercy. All rights reserved.
//

#import "XPCalendarView.h"

#import "NSDate+XPCalendar.h"

@interface XPCalendarView()

@property (nonatomic, strong) UIButton *calendarHeaderButton;
@property (nonatomic, strong) UIView *weekHeaderView;


@end

#define headTitleColor [UIColor colorWithRed:121.0 / 255.0 green:121.0 / 255.0 blue:121.0 / 255.0 alpha:1.0]
#define kCalendarBasicColor [UIColor colorWithRed:231.0 / 255.0 green:85.0 / 255.0 blue:85.0 / 255.0 alpha:1.0]
//#define kCalendarBasicColor [UIColor colorWithRed:252.0 / 255.0 green:60.0 / 255.0 blue:60.0 / 255.0 alpha:1.0]

@implementation XPCalendarView


#pragma mark - Initialization

- (instancetype)initWithFrameOrigin:(CGPoint)origin width:(CGFloat)width {
    
    // 根据宽度计算 calender 主体部分的高度
    CGFloat weekLineHight = 0.63 * (width / 7.0);
    CGFloat monthHeight = 7 * weekLineHight;
    
    // 星期头部栏高度
    CGFloat weekHeaderHeight =0.8* weekLineHight;
    
    // calendar 头部栏高度
//    CGFloat calendarHeaderHeight = 0.8 * weekLineHight;
    
    // 最后得到整个 calender 控件的高度
    _calendarHeight = weekHeaderHeight + monthHeight;
    
    if (self = [super initWithFrame:CGRectMake(origin.x, origin.y, width, _calendarHeight)]) {
        
//        self.layer.masksToBounds = YES;
//        self.layer.borderColor = kCalendarBasicColor.CGColor;
//        self.layer.borderWidth = 2.0 / [UIScreen mainScreen].scale;
//        self.layer.cornerRadius = 8.0;
//
        _calendarHeaderButton = [self setupCalendarHeaderButtonWithFrame:CGRectMake(15, 0.0, 104, 40)];
        _weekHeaderView = [self setupWeekHeadViewWithFrame:CGRectMake(0.0, 40, width, weekHeaderHeight)];
        _calendarScrollView = [self setupCalendarScrollViewWithFrame:CGRectMake(0.0,  weekHeaderHeight+40, width, monthHeight)];
        _weekHeaderView.backgroundColor = [UIColor whiteColor];
        _calendarScrollView.backgroundColor = [UIColor whiteColor];
       
        
        
        [self addSubview:_calendarHeaderButton];
        [self addSubview:_weekHeaderView];
        [self addSubview:_calendarScrollView];
         [self addNotificationObserver];
        
        // 注册 Notification 监听
        
        
    }
    
    return self;
    
}

- (void)dealloc {
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark 通知修改视图界面
- (void)addNotificationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCalendarHeaderAction:) name:@"ChangeCalendarHeaderNotification" object:nil];
}

- (void)changeCalendarHeaderAction:(NSNotification *)sender {
    
    NSDictionary *dic = sender.userInfo;
    
    NSNumber *year = dic[@"year"];
    NSNumber *month = dic[@"month"];
    
    [_calendarHeaderButton setTitle: [NSString stringWithFormat:@"%@年%@月", year, month] forState:UIControlStateNormal];
    
}
- (UIButton *)setupCalendarHeaderButtonWithFrame:(CGRect)frame {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor:headTitleColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [button addTarget:self action:@selector(refreshToCurrentMonthAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)setupWeekHeadViewWithFrame:(CGRect)frame {
    
    CGFloat height = frame.size.height;
    CGFloat width = frame.size.width / 7.0;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    
    NSArray *weekArray = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
    for (int i = 0; i < 7; ++i) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i * width, 0.0, width, height)];
        label.backgroundColor = [UIColor clearColor];
        label.text = weekArray[i];
        label.textColor = headTitleColor;
        label.font = [UIFont systemFontOfSize:13.5];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
    }
    
    return view;
    
}

- (XPCalendarScrollView *)setupCalendarScrollViewWithFrame:(CGRect)frame {
    XPCalendarScrollView *scrollView = [[XPCalendarScrollView alloc] initWithFrame:frame];
    return scrollView;
}

- (void)setDidSelectDayHandler:(DidSelectDayHandler)didSelectDayHandler {
    _didSelectDayHandler = didSelectDayHandler;
    if (_calendarScrollView != nil) {
        _calendarScrollView.didSelectDayHandler = _didSelectDayHandler; // 传递 block
    }
}




#pragma mark - Actions

- (void)refreshToCurrentMonthAction:(UIButton *)sender {
    
    NSInteger year = [[NSDate date] dateYear];
    NSInteger month = [[NSDate date] dateMonth];
   
    NSString *title = [NSString stringWithFormat:@"%ld年%ld月", (long)year, (long)month];
    
    [_calendarHeaderButton setTitle:title forState:UIControlStateNormal];
    
    [_calendarScrollView refreshToCurrentMonth];
    
}



@end
