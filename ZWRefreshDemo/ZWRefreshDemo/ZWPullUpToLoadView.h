//
//  ZWPuuUpToLoadView.h
//  ZWRefreshDemo
//
//  Created by 郑亚伟 on 2017/3/2.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//上拉加载更多控件

#import <UIKit/UIKit.h>
#define ZWLoadViewHeight 64

@interface ZWPullUpToLoadView : UIView

@property(nonatomic,copy)void(^refreshingBlock)();

//结束刷新
- (void)endRefreshing;

@end
