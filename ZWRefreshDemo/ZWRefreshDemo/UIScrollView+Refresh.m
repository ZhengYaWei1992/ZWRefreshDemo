//
//  UIScrollView+Refresh.m
//  ZWRefreshDemo
//
//  Created by 郑亚伟 on 2017/3/2.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <objc/runtime.h>

static const char *refreshFooterKey = "refreshFooterKey";
static const char *refreshHeaderKey = "refreshHeaderKey";

@interface UIScrollView (){
    //分类中不能有成员变量
}

@end

@implementation UIScrollView (Refresh)
#pragma mark - 头部刷新控件关联对象
-(void)setRefreshHeaderView:(ZWPullDownToRefreshView *)refreshHeaderView{
    objc_setAssociatedObject(self, refreshHeaderKey, refreshHeaderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ZWPullDownToRefreshView *)refreshHeaderView{
    ZWPullDownToRefreshView *refreshHeaderView = objc_getAssociatedObject(self, refreshHeaderKey);
    if (refreshHeaderView == nil) {
        refreshHeaderView = [[ZWPullDownToRefreshView alloc]initWithFrame:CGRectMake(0, -ZWRefreshViewHeight, [UIScreen mainScreen].bounds.size.width, ZWRefreshViewHeight)];
         //保存对象
         self.refreshHeaderView = refreshHeaderView;
         [self addSubview:refreshHeaderView];
    }
    return refreshHeaderView;
}



#pragma mark - 底部加载更多控件关联对象
- (ZWPullUpToLoadView *)refreshFooterView{
    ZWPullUpToLoadView *refreshFooterView = objc_getAssociatedObject(self, refreshFooterKey);
    if (refreshFooterView == nil) {
        refreshFooterView = [[ZWPullUpToLoadView alloc]init];
        [self addSubview:refreshFooterView];
        //保存对象
        self.refreshFooterView = refreshFooterView;
    }
    return refreshFooterView;
}

- (void)setRefreshFooterView:(ZWPullUpToLoadView *)refreshFooterView{
    objc_setAssociatedObject(self, refreshFooterKey, refreshFooterView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
