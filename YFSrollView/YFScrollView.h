//
//  YFScrollView.h
//  YDDemo
//
//  Created by enmonster on 2018/6/8.
//  Copyright © 2018年 enmonster. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1]


@class YFScrollView;
@protocol YFScrollViewDelegate<NSObject>

@required
- (UIScrollView *)yf_scrollView:(YFScrollView *)yfScrollView viewForItemAtIndex:(NSInteger)index;
- (NSInteger)numberOfItemsInYFScrollView;

/**
 横向滑动停止滚动

 @param startIndex 开始的Index
 @param endIndex 停止得到Index
 */
- (void)yf_scrollViewDidEndScroll:(NSInteger)startIndex EndIndex:(NSInteger)endIndex;

@end

@interface YFHeaderView : UIView

@property (nonatomic,assign) BOOL hang;

@end

@interface YFScrollView : UIView

@property (nonatomic,strong) NSArray<YFHeaderView *> *headerViewsList;
@property (nonatomic,weak) id<YFScrollViewDelegate> delegate;

- (void)scrollToIndex:(NSInteger)index;

@end
