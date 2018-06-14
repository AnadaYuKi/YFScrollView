//
//  ViewController.m
//  YFSrollView
//
//  Created by enmonster on 2018/6/14.
//  Copyright © 2018年 enmonster. All rights reserved.
//

#import "ViewController.h"
#import "YFScrollView.h"
#import "ListViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Title";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    YFScrollView *scrollView = [[YFScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    scrollView.delegate = self;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        YFHeaderView *view = [[YFHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        view.backgroundColor = UIRandomColor;
        view.hang = (i%3 == 0);
        [arr addObject:view];
    }
    scrollView.headerViewsList = arr;
    
    [self.view addSubview:scrollView];
}

- (UIScrollView *)yf_scrollView:(YFScrollView *)yfScrollView viewForItemAtIndex:(NSInteger)index{
    ListViewController *listVC = [[ListViewController alloc] init];
    [self addChildViewController:listVC];
    [self.view addSubview:listVC.view];
    listVC.view.bounds = self.view.bounds;
    listVC.view.backgroundColor = [UIColor clearColor];
    [self.view sendSubviewToBack:listVC.view];
    return listVC.tableView;
}

- (NSInteger)numberOfItemsInYFScrollView{
    return 4;
}

- (void)yf_scrollViewDidEndScroll:(NSInteger)startIndex EndIndex:(NSInteger)endIndex{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
