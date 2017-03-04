//
//  ViewController.m
//  ZWRefreshDemo
//
//  Created by 郑亚伟 on 2017/3/2.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ViewController.h"
//#import "ZWPullDownToRefreshView.h"
//#import "ZWPullUpToLoadView.h"

#import "UIScrollView+Refresh.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataSource;
@end
static NSString *cellId = @"cellId";
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"自定义刷新控件";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    //设置原始数据
    [self loadData];
    [self.view addSubview:self.tableView];
    
    
     __weak typeof(self) weakSelf = self;
    //==================下拉刷新===================
    self.tableView.refreshHeaderView.refreshingBlock = ^(){
        NSLog(@"这里调用下拉刷新的方法");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (int i = 0; i < 5; i++) {
                 [weakSelf.dataSource insertObject:@"刷新增加的数据" atIndex:0];
            }
            [weakSelf.tableView reloadData];
            //结束刷新
            [weakSelf.tableView.refreshHeaderView endRefreshing];
        });
    };
    //初次加载控制器，直接刷新
    [self.tableView.refreshHeaderView startRefreshing];
    
    //================上拉加载===================
    self.tableView.refreshFooterView.refreshingBlock = ^(){
        NSLog(@"这里调用上拉加载的方法");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (int i = 0; i < 5; i++) {
                [weakSelf.dataSource addObject:@"上拉加载更多数据"];
            }
            [weakSelf.tableView reloadData];
            //结束刷新
            [weakSelf.tableView.refreshFooterView endRefreshing];
        });
    };
}


#pragma mark -private
//加载数据
- (void)loadData{
    for (NSInteger i = 0; i < 25; i++) {
        [self.dataSource addObject:[NSString stringWithFormat:@"原始数据%ld",i]];
    }
}

#pragma mark - tableView代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataSource[indexPath.row]];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //注意这里面的设置
        _tableView.contentInset = UIEdgeInsetsMake(ZWRefreshViewHeight, 0, 0, 0);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(ZWRefreshViewHeight, 0, 0, 0);
    }
    return _tableView;
}

- (NSMutableArray *)dataSource{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return  _dataSource;
}

@end
