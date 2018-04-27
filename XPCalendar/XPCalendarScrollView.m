//
//  GFCalendarScrollView.m
//
//  Created by Mercy on 2016/11/9.
//  Copyright © 2016年 Mercy. All rights reserved.
//

#import "XPCalendarScrollView.h"
#import "XPCalendarCell.h"
#import "XPCalendarMonth.h"
#import "NSDate+XPCalendar.h"

@interface XPCalendarScrollView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionViewL;
@property (nonatomic, strong) UICollectionView *collectionViewM;
@property (nonatomic, strong) UICollectionView *collectionViewR;



@property (nonatomic, strong) NSMutableArray *monthArray;
@property (nonatomic, assign) BOOL isChangeCalendarMain;
@end

@implementation XPCalendarScrollView
#define titleColor [UIColor colorWithRed:121.0 / 255.0 green:121.0 / 255.0 blue:121.0 / 255.0 alpha:1.0]
//#define selectBkgCircleColor [UIColor colorWithRed:82.0 / 255.0 green:210.0 / 255.0 blue:87.0 / 255.0 alpha:1.0]
#define kCalendarBasicColor [UIColor colorWithRed:231.0 / 255.0 green:85.0 / 255.0 blue:85.0 / 255.0 alpha:1.0]
//#define kCalendarBasicColor [UIColor colorWithRed:252.0 / 255.0 green:60.0 / 255.0 blue:60.0 / 255.0 alpha:1.0]

static NSString *const kCellIdentifier = @"cell";


#pragma mark - Initialiaztion

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectBkgCircleColor = [UIColor colorWithRed:82.0 / 255.0 green:210.0 / 255.0 blue:87.0 / 255.0 alpha:1.0];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.bounces = NO;
        self.delegate = self;
        
        self.contentSize = CGSizeMake(3 * self.bounds.size.width, self.bounds.size.height);
        [self setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO];
        
        _currentMonthDate = [NSDate date];
        [self setupCollectionViews];
        
    }
    
    return self;
    
}

- (NSMutableArray *)monthArray {
    
    if (_monthArray == nil) {
        
        _monthArray = [NSMutableArray arrayWithCapacity:4];
        
        NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
        
        NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
        
        [_monthArray addObject:[[XPCalendarMonth alloc] initWithDate:previousMonthDate]];
        [_monthArray addObject:[[XPCalendarMonth alloc] initWithDate:_currentMonthDate]];
        [_monthArray addObject:[[XPCalendarMonth alloc] initWithDate:nextMonthDate]];
        [_monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]]; // 存储左边的月份的前一个月份的天数，用来填充左边月份的首部
        
        // 发通知，更改当前月份标题
        [self notifyToChangeCalendarHeader];
    }
    
    return _monthArray;
}

- (NSNumber *)previousMonthDaysForPreviousDate:(NSDate *)date {
    return [[NSNumber alloc] initWithInteger:[[date previousMonthDate] totalDaysInMonth]];
}


- (void)setupCollectionViews {
        
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width / 7.0, self.bounds.size.width / 7.0 * 0.7);
    flowLayout.minimumLineSpacing = 0.0;
    flowLayout.minimumInteritemSpacing = 0.0;
    
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    
    _collectionViewL = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewL.dataSource = self;
    _collectionViewL.delegate = self;
    _collectionViewL.backgroundColor = [UIColor clearColor];
    [_collectionViewL registerClass:[XPCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewL];
    
    _collectionViewM = [[UICollectionView alloc] initWithFrame:CGRectMake(selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewM.dataSource = self;
    _collectionViewM.delegate = self;
    _collectionViewM.backgroundColor = [UIColor clearColor];
    [_collectionViewM registerClass:[XPCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewM];
    
    _collectionViewR = [[UICollectionView alloc] initWithFrame:CGRectMake(2 * selfWidth, 0.0, selfWidth, selfHeight) collectionViewLayout:flowLayout];
    _collectionViewR.dataSource = self;
    _collectionViewR.delegate = self;
    _collectionViewR.backgroundColor = [UIColor clearColor];
    [_collectionViewR registerClass:[XPCalendarCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [self addSubview:_collectionViewR];

}


#pragma mark -

- (void)notifyToChangeCalendarHeader {
    
    XPCalendarMonth *currentMonthInfo = self.monthArray[1];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.year] forKey:@"year"];
    [userInfo setObject:[[NSNumber alloc] initWithInteger:currentMonthInfo.month] forKey:@"month"];
   [userInfo setObject:[[NSNumber alloc] initWithBool:_isChangeCalendarMain] forKey:@"isChangeCalendarMain"];
    NSNotification *notify = [[NSNotification alloc] initWithName:@"ChangeCalendarHeaderNotification" object:nil userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notify];
}

- (void)refreshToCurrentMonth {
    
    // 如果现在就在当前月份，则不执行操作
    XPCalendarMonth *currentMonthInfo = self.monthArray[1];
    if ((currentMonthInfo.month == [[NSDate date] dateMonth]) && (currentMonthInfo.year == [[NSDate date] dateYear])) {
        return;
    }
    
    _currentMonthDate = [NSDate date];
    
    NSDate *previousMonthDate = [_currentMonthDate previousMonthDate];
    NSDate *nextMonthDate = [_currentMonthDate nextMonthDate];
    
    [self.monthArray removeAllObjects];
    [self.monthArray addObject:[[XPCalendarMonth alloc] initWithDate:previousMonthDate]];
    [self.monthArray addObject:[[XPCalendarMonth alloc] initWithDate:_currentMonthDate]];
    [self.monthArray addObject:[[XPCalendarMonth alloc] initWithDate:nextMonthDate]];
    [self.monthArray addObject:[self previousMonthDaysForPreviousDate:previousMonthDate]];
    
    // 刷新数据
    [_collectionViewM reloadData];
    [_collectionViewL reloadData];
    [_collectionViewR reloadData];
    
}


#pragma mark - UICollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42; // 7 * 6
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    XPCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (collectionView == _collectionViewL) {
        
        XPCalendarMonth *monthInfo = self.monthArray[0];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = titleColor;
            
            // 标识今天
            if ((monthInfo.month == _selectMonth) && (monthInfo.year == _selectYear)) {
                if (indexPath.row ==_selectDay+ firstWeekday - 1) {
                    cell.todayCircle.backgroundColor = self.selectBkgCircleColor;
                    cell.todayLabel.textColor = [UIColor whiteColor];
                } else {
                    cell.todayCircle.backgroundColor = [UIColor clearColor];
                }
            } else {
                cell.todayCircle.backgroundColor = [UIColor clearColor];
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
//            int totalDaysOflastMonth = [self.monthArray[3] intValue];
//            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
//            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//            cell.todayCircle.backgroundColor = [UIColor clearColor];
            cell.todayLabel.text = @"";
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        } else if (indexPath.row >= firstWeekday + totalDays) {
//            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
//            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//            cell.todayCircle.backgroundColor = [UIColor clearColor];
            cell.todayLabel.text = @"";
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        }
        else if ( firstWeekday + totalDays >35)
        {
            
        }
       
        cell.userInteractionEnabled = NO;
        
    }
    else if (collectionView == _collectionViewM) {
        
        XPCalendarMonth *monthInfo = self.monthArray[1];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = titleColor;
            cell.userInteractionEnabled = YES;
            
            // 标识今天
            if ((monthInfo.month == _selectMonth) && (monthInfo.year == _selectYear)) {
                if (indexPath.row ==_selectDay+ firstWeekday - 1) {
                    cell.todayCircle.backgroundColor = self.selectBkgCircleColor;
                    cell.todayLabel.textColor = [UIColor whiteColor];
                } else {
                    cell.todayCircle.backgroundColor = [UIColor clearColor];
                }
            } else {
                cell.todayCircle.backgroundColor = [UIColor clearColor];
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
//            GFCalendarMonth *lastMonthInfo = self.monthArray[0];
//            NSInteger totalDaysOflastMonth = lastMonthInfo.totalDays;
//            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
//            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//            cell.todayCircle.backgroundColor = [UIColor clearColor];
            cell.todayLabel.text = @"";
            cell.todayCircle.backgroundColor = [UIColor clearColor];
            cell.userInteractionEnabled = NO;
        } else if (indexPath.row >= firstWeekday + totalDays) {
//            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
//            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//            cell.todayCircle.backgroundColor = [UIColor clearColor];
//            cell.userInteractionEnabled = NO;
            cell.todayLabel.text = @"";
            cell.todayCircle.backgroundColor = [UIColor clearColor];
            if( (firstWeekday + totalDays) > 35)
            {
                _isChangeCalendarMain = YES;
                [self notifyToChangeCalendarHeader];
                NSLog(@"firstWeekday + totalDays=%ld",(long)firstWeekday + totalDays);
            }
        }
       
      
        
    }
    else if (collectionView == _collectionViewR) {
        
        XPCalendarMonth *monthInfo = self.monthArray[2];
        NSInteger firstWeekday = monthInfo.firstWeekday;
        NSInteger totalDays = monthInfo.totalDays;
        
        // 当前月
        if (indexPath.row >= firstWeekday && indexPath.row < firstWeekday + totalDays) {
            
            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row - firstWeekday + 1];
            cell.todayLabel.textColor = titleColor;
            
           //  标识今天
            if ((monthInfo.month == _selectMonth) && (monthInfo.year == _selectYear)) {
                if (indexPath.row ==_selectDay+ firstWeekday - 1) {
                    cell.todayCircle.backgroundColor = self.selectBkgCircleColor;
                    cell.todayLabel.textColor = [UIColor whiteColor];
                } else {
                    cell.todayCircle.backgroundColor = [UIColor clearColor];
                }
            } else {
                cell.todayCircle.backgroundColor = [UIColor clearColor];
            }
            
        }
        // 补上前后月的日期，淡色显示
        else if (indexPath.row < firstWeekday) {
//            GFCalendarMonth *lastMonthInfo = self.monthArray[1];
//            NSInteger totalDaysOflastMonth = lastMonthInfo.totalDays;
//            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", totalDaysOflastMonth - (firstWeekday - indexPath.row) + 1];
//            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
            cell.todayLabel.text = @"";
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        } else if (indexPath.row >= firstWeekday + totalDays) {
//            cell.todayLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row - firstWeekday - totalDays + 1];
//            cell.todayLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
//            cell.todayCircle.backgroundColor = [UIColor clearColor];
            cell.todayLabel.text = @"";
            cell.todayCircle.backgroundColor = [UIColor clearColor];
        }
      
        cell.userInteractionEnabled = NO;
        
    }
    
    return cell;
    
}


#pragma mark - UICollectionViewDeleagate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.didSelectDayHandler != nil) {
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:_currentMonthDate];
        NSDate *currentDate = [calendar dateFromComponents:components];
        
        XPCalendarCell *cell = (XPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        _selectYear = [currentDate dateYear];
        _selectMonth = [currentDate dateMonth];
        _selectDay = [cell.todayLabel.text integerValue];
        cell.todayCircle.backgroundColor = self.selectBkgCircleColor;
        cell.todayLabel.textColor = [UIColor whiteColor];
        [_collectionViewM reloadData];
        [_collectionViewL reloadData];
        [_collectionViewR reloadData];
        self.didSelectDayHandler(_selectYear, _selectMonth, _selectDay); // 执行回调
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectDayHandler != nil) {
        
        
        XPCalendarCell *cell = (XPCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        cell.todayLabel.textColor = titleColor;
        cell.todayCircle.backgroundColor = [UIColor clearColor];
        //        self.didSelectDayHandler(year, month, day); // 执行回调
    }
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (scrollView != self) {
        return;
    }
    
    // 向右滑动
    if (scrollView.contentOffset.x < self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate previousMonthDate];
        NSDate *previousDate = [_currentMonthDate previousMonthDate];
        
        // 数组中最左边的月份现在作为中间的月份，中间的作为右边的月份，新的左边的需要重新获取
        XPCalendarMonth *currentMothInfo = self.monthArray[0];
        XPCalendarMonth *nextMonthInfo = self.monthArray[1];
        
        
        XPCalendarMonth *olderNextMonthInfo = self.monthArray[2];
        
        // 复用 GFCalendarMonth 对象
        olderNextMonthInfo.totalDays = [previousDate totalDaysInMonth];
        olderNextMonthInfo.firstWeekday = [previousDate firstWeekDayInMonth];
        olderNextMonthInfo.year = [previousDate dateYear];
        olderNextMonthInfo.month = [previousDate dateMonth];
        XPCalendarMonth *previousMonthInfo = olderNextMonthInfo;
        
        NSNumber *prePreviousMonthDays = [self previousMonthDaysForPreviousDate:[_currentMonthDate previousMonthDate]];
        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
        if ((currentMothInfo.totalDays +  currentMothInfo.firstWeekday) > 35) {
            _isChangeCalendarMain = YES;
           
        }
        else
        {
            _isChangeCalendarMain = NO;
        }
        
    }
    // 向左滑动
    else if (scrollView.contentOffset.x > self.bounds.size.width) {
        
        _currentMonthDate = [_currentMonthDate nextMonthDate];
        NSDate *nextDate = [_currentMonthDate nextMonthDate];
        
        // 数组中最右边的月份现在作为中间的月份，中间的作为左边的月份，新的右边的需要重新获取
        XPCalendarMonth *previousMonthInfo = self.monthArray[1];
        XPCalendarMonth *currentMothInfo = self.monthArray[2];
        
        
        XPCalendarMonth *olderPreviousMonthInfo = self.monthArray[0];
        
        NSNumber *prePreviousMonthDays = [[NSNumber alloc] initWithInteger:olderPreviousMonthInfo.totalDays]; // 先保存 olderPreviousMonthInfo 的月天数
        
        // 复用 GFCalendarMonth 对象
        olderPreviousMonthInfo.totalDays = [nextDate totalDaysInMonth];
        olderPreviousMonthInfo.firstWeekday = [nextDate firstWeekDayInMonth];
        olderPreviousMonthInfo.year = [nextDate dateYear];
        olderPreviousMonthInfo.month = [nextDate dateMonth];
        XPCalendarMonth *nextMonthInfo = olderPreviousMonthInfo;

        
        [self.monthArray removeAllObjects];
        [self.monthArray addObject:previousMonthInfo];
        [self.monthArray addObject:currentMothInfo];
        [self.monthArray addObject:nextMonthInfo];
        [self.monthArray addObject:prePreviousMonthDays];
       
        if ((currentMothInfo.totalDays +  currentMothInfo.firstWeekday) > 35) {
            _isChangeCalendarMain = YES;
        }
        else
        {
            _isChangeCalendarMain = NO;
        }
        
    }
    
    [_collectionViewM reloadData]; // 中间的 collectionView 先刷新数据
    [scrollView setContentOffset:CGPointMake(self.bounds.size.width, 0.0) animated:NO]; // 然后变换位置
    [_collectionViewL reloadData]; // 最后两边的 collectionView 也刷新数据
    [_collectionViewR reloadData];
    
    // 发通知，更改当前月份标题
    [self notifyToChangeCalendarHeader];
   
    
}

@end
