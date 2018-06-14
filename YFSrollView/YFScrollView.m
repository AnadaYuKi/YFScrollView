//
//  YFScrollView.m
//  YDDemo
//
//  Created by enmonster on 2018/6/8.
//  Copyright © 2018年 enmonster. All rights reserved.
//

#import "YFScrollView.h"
#pragma mark DataShow View

static NSString * const YFScrollViewCellIdfy = @"YFScrollViewCellIdfy";

@interface YFScrollViewCell : UITableViewCell <UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic,copy)   void (^endScrollHandler)(NSInteger startIndex,NSInteger endIndex);

@property (nonatomic,strong) UIScrollView *visibleScrollView;

@property (nonatomic,assign) NSInteger numberOfItems;

@property (nonatomic,assign) NSInteger currentPageIndex;

@property (nonatomic,strong) NSArray *visibleViews;

@end

@implementation YFScrollViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self commonUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
    self.flowLayout.itemSize = self.bounds.size;
}

- (void)commonUI{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.itemSize = self.bounds.size;
    self.flowLayout = layout;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.bounces = NO;
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:YFScrollViewCellIdfy];
    [self.contentView addSubview:self.collectionView];
}

- (void)setVisibleViews:(NSArray *)visibleViews{
    _visibleViews = visibleViews;
    self.visibleScrollView = visibleViews.firstObject;
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YFScrollViewCellIdfy forIndexPath:indexPath];
    UIScrollView *scrollView = [cell viewWithTag:112233];
    if (scrollView) {
        [scrollView removeFromSuperview];
    }
    scrollView = self.visibleViews[indexPath.row];
    scrollView.tag = 112233;
    [cell addSubview:scrollView];
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView == self.collectionView) {
        NSInteger page = scrollView.contentOffset.x/scrollView.frame.size.width;
        NSInteger lastPage = _currentPageIndex;
        if (page != lastPage) {
            _currentPageIndex = page;
            self.visibleScrollView = self.visibleViews[page];
            if (self.endScrollHandler) {
                self.endScrollHandler(lastPage, page);
            }
        }
    }
}

@end


#pragma mark Header
@interface YFHeaderView ()
/**
 悬浮Y坐标
 */
@property (nonatomic,assign) CGFloat hangOriginY;
@property (nonatomic,assign) CGFloat originalY;
@property (nonatomic,assign) BOOL    hadHang;

@property (nonatomic,strong) UILabel *textLabel;

@end

@implementation YFHeaderView

- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 15)];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.textColor = [UIColor blackColor];
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

- (void)setHang:(BOOL)hang{
    _hang = hang;
    self.textLabel.text = hang?@"卡":@"不卡";
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.center = CGPointMake(30, self.frame.size.height/2);
}

@end

#pragma mark MainScrill View
@interface YFScrollView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableDictionary *offsetYDecimalDict;

@property (nonatomic,assign) CGFloat listCellHeight;

@property (nonatomic,assign) CGFloat maxOffsetY;

@end

@implementation YFScrollView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)setHeaderViewsList:(NSArray<YFHeaderView *> *)headerViewsList{
    _headerViewsList = headerViewsList;
    [self updateTableViewHeaderView];
}


- (void)updateTableViewHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    CGFloat top = 0;
    CGFloat dataCellHeight = 0;
    CGFloat hangY = 0;
    self.maxOffsetY = 0;
    [self.offsetYDecimalDict removeAllObjects];
    for (NSInteger i = 0; i < _headerViewsList.count; i++) {
        YFHeaderView *view = _headerViewsList[i];
        CGRect frame = view.frame;
        frame.origin.y = top;
        view.frame = frame;
        view.originalY = top;
        [headerView addSubview:view];
        top += frame.size.height;
        if (view.hang) {
            CGPoint point = CGPointMake(frame.origin.y - hangY, frame.origin.y - hangY + frame.size.height); //self.tableView的Y偏移量 落在这个区间
            NSValue *value = [NSValue valueWithCGPoint:point];
            [self.offsetYDecimalDict setObject:view forKey:value];

            view.hangOriginY = hangY;
            hangY += frame.size.height;
            
            dataCellHeight += frame.size.height; //下面的数据高度
        }else{
            self.maxOffsetY += frame.size.height;
        }
    }
    headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, top);
    self.tableView.tableHeaderView = headerView;
    self.listCellHeight = self.frame.size.height - dataCellHeight;
    [self.tableView reloadData];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.listCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *dataListIdentifier = @"YFScrollViewCellID";
    YFScrollViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dataListIdentifier];
    if (!cell) {
        cell = [[YFScrollViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dataListIdentifier];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfItemsInYFScrollView)]) {
        cell.numberOfItems = [_delegate numberOfItemsInYFScrollView];
    }else{
        cell.numberOfItems = 1;
    }

    UIScrollView *scrollView = nil;
    NSMutableArray *views = [NSMutableArray array];
    if (_delegate && [_delegate respondsToSelector:@selector(yf_scrollView:viewForItemAtIndex:)]) {
        for (NSInteger i = 0; i < cell.numberOfItems; i++) {
            scrollView = [_delegate yf_scrollView:self viewForItemAtIndex:i];
            if (scrollView.superview) {
                [scrollView removeFromSuperview];
            }
            [views addObject:scrollView];
        }
    }else{
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, self.listCellHeight)];
        [views addObject:scrollView];
    }
    
    for (UIScrollView *scrView in views) {
        scrView.scrollsToTop = NO;
        scrollView.bounces = NO;
        scrView.showsVerticalScrollIndicator = NO;
        scrView.showsHorizontalScrollIndicator = NO;
        scrView.scrollEnabled = NO;
        scrView.frame = CGRectMake(0, 0, tableView.frame.size.width, self.listCellHeight);
    }
    
    __weak typeof(self) bself = self;
    __weak typeof(cell) bcell = cell;
    cell.endScrollHandler = ^(NSInteger startIndex, NSInteger endIndex) {
        bcell.visibleScrollView.scrollEnabled = !bself.tableView.scrollEnabled;
        if (bcell.visibleScrollView.scrollEnabled) {
            [bcell.visibleScrollView addObserver:bself forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        }
        
        if (bself.delegate && [bself.delegate respondsToSelector:@selector(yf_scrollViewDidEndScroll:EndIndex:)]) {
            [bself.delegate yf_scrollViewDidEndScroll:startIndex EndIndex:endIndex];
        }
    };
    
    
    
    cell.visibleViews = views;
    return cell;
}

#pragma mark Method

- (void)scrollToIndex:(NSInteger)index{
    YFScrollViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.headerViewsList.count]];
    [cell.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark UIScrollViewDelegate

CGFloat lastTableViewOffsetY = 0;
BOOL    scrollDirectionUp = NO;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.tableView) {
        CGFloat offsetY = scrollView.contentOffset.y;
        YFScrollViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (offsetY >= self.maxOffsetY) {
            lastTableViewOffsetY = self.maxOffsetY;
            self.tableView.scrollEnabled = NO;
            self.tableView.contentOffset = CGPointMake(0, self.maxOffsetY);
            cell.visibleScrollView.scrollEnabled = YES;
            [cell.visibleScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self hangHeaderViewToCorrect:YES];
        }else{
            //卡住代码 要做到极端滑动卡住
            scrollDirectionUp = (offsetY - lastTableViewOffsetY >= 0);
            lastTableViewOffsetY = offsetY;
            [self hangHeaderViewToCorrect:NO];
        }
    }
}

/**
 处理卡住的view

 @param isCorrent 矫正
 */
- (void)hangHeaderViewToCorrect:(BOOL)isCorrent{
    NSArray *keys = self.offsetYDecimalDict.allKeys;
    for (NSValue *value in keys) {
        CGPoint point = value.CGPointValue;
        YFHeaderView *view = self.offsetYDecimalDict[value];
        if (isCorrent) {
            if (!view.hadHang) {
                view.frame = CGRectMake(0, view.hangOriginY, view.frame.size.width, view.frame.size.height);
                [self addSubview:view];
                view.hadHang = YES;
            }
        }else{
            if (scrollDirectionUp) {
                if (point.x <= lastTableViewOffsetY && !view.hadHang) {
                    view.frame = CGRectMake(0, view.hangOriginY, view.frame.size.width, view.frame.size.height);
                    [self addSubview:view];
                    view.hadHang = YES;
                }
            }else{
                if (point.x >= lastTableViewOffsetY && view.hadHang) {
                    view.frame = CGRectMake(0, view.originalY, view.frame.size.width, view.frame.size.height);
                    [self.tableView.tableHeaderView addSubview:view];
                    view.hadHang = NO;
                }
            }
        }
    }
}

#pragma mark --Hang--

- (void)handlerHeaderViewHang:(BOOL)forceReset{
    NSArray *keys = self.offsetYDecimalDict.allKeys;
    CGFloat offsetY = self.tableView.contentOffset.y;
    scrollDirectionUp = (offsetY - lastTableViewOffsetY >= 0);
    lastTableViewOffsetY = offsetY;
    for (NSValue *value in keys) {
        CGPoint point = value.CGPointValue;
        YFHeaderView *view = self.offsetYDecimalDict[value];
        if (forceReset) {
            view.frame = CGRectMake(0, view.originalY, view.frame.size.width, view.frame.size.height);
            [self.tableView.tableHeaderView addSubview:view];
        }else{
            if (view.hang) {
                if (offsetY > point.x && offsetY < point.y) {
                    if (scrollDirectionUp) {
                        view.frame = CGRectMake(0, view.hangOriginY, view.frame.size.width, view.frame.size.height);
                        [self addSubview:view];
                    }else{
                        view.frame = CGRectMake(0, view.originalY, view.frame.size.width, view.frame.size.height);
                        [self.tableView.tableHeaderView addSubview:view];
                    }
                    break;
                }
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    YFScrollViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (object == cell.visibleScrollView) {
        CGPoint point = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (point.y <= 0) {
            cell.visibleScrollView.bounces = NO;
            [cell.visibleScrollView removeObserver:self forKeyPath:@"contentOffset"];
            self.tableView.scrollEnabled = YES;
            cell.visibleScrollView.scrollEnabled = NO;
            cell.visibleScrollView.contentOffset = CGPointZero;
        }else{
            cell.visibleScrollView.bounces = YES;
        }
    }
}

#pragma mark --getter--

- (NSMutableDictionary *)offsetYDecimalDict{
    if (!_offsetYDecimalDict) {
        _offsetYDecimalDict = [[NSMutableDictionary alloc] init];
    }
    return _offsetYDecimalDict;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = self.backgroundColor;
    }
    return _tableView;
}

@end
