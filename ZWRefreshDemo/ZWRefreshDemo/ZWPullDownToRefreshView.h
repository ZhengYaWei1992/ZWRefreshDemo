//
//  ZWPullDownToRefreshView.h
//  ZWRefreshDemo
//
//  Created by 郑亚伟 on 2017/3/2.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//自定义下拉刷新控件

#import <UIKit/UIKit.h>
#define ZWRefreshViewHeight 64


@interface ZWPullDownToRefreshView : UIView

@property(nonatomic,copy)void(^refreshingBlock)();

//结束刷新
- (void)endRefreshing;

//开始刷新
- (void)startRefreshing;

@end
