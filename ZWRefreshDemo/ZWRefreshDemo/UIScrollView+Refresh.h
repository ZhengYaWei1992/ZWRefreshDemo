//
//  UIScrollView+Refresh.h
//  ZWRefreshDemo
//
//  Created by 郑亚伟 on 2017/3/2.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWPullUpToLoadView.h"
#import "ZWPullDownToRefreshView.h"

@interface UIScrollView (Refresh)

//上拉加载控件  底部
@property(nonatomic,strong)ZWPullUpToLoadView *refreshFooterView;
//下拉刷新控件  头部
@property(nonatomic,strong)ZWPullDownToRefreshView *refreshHeaderView;

@end
