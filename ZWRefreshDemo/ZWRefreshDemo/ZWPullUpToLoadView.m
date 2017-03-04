//
//  ZWPuuUpToLoadView.m
//  ZWRefreshDemo
//
//  Created by 郑亚伟 on 2017/3/2.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWPullUpToLoadView.h"
#import "UIView+SDAutoLayout.h"



typedef enum {
    ZWPullUpToLoadViewStatusNormal, // 正常状态
    ZWPullUpToLoadViewtatusPulling, // 释放刷新状态
    ZWPullUpToLoadViewStatusRefreshing // 正在刷新
} ZWPullUpToLoadViewStatus;

@interface ZWPullUpToLoadView ()

//具体可以自定义
//图像
@property(nonatomic,strong)UIImageView *imageView;
//文字
@property(nonatomic,strong)UILabel *label;
//动画图片数组
@property (nonatomic, strong) NSArray *refreshImages;


//父控件
@property(nonatomic,strong)UIScrollView *superScrollView;
//当前状态
@property(nonatomic,assign)ZWPullUpToLoadViewStatus currentStatus;

@end

@implementation ZWPullUpToLoadView

- (instancetype)initWithFrame:(CGRect)frame
{
    CGRect newFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ZWLoadViewHeight);
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = newFrame;
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        self.imageView.sd_layout.rightSpaceToView(self,self.frame.size.width/2+ 10).centerYEqualToView(self).widthIs(40).heightIs(40);
        self.label.sd_layout.leftSpaceToView(self,self.frame.size.width/2).centerYEqualToView(self).heightIs(40);
        [self.label setSingleLineAutoResizeWithMaxWidth:150];
        
    }
    return self;
}

//该类被添加到父控件的时候会调用该方法
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
         [self.superScrollView addObserver:self forKeyPath:@"contentSize" options:0 context:nil];
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
}
- (void)dealloc{
    [self.superScrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.superScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark- 结束刷新
//结束刷新
- (void)endRefreshing{
    if (self.currentStatus == ZWPullUpToLoadViewStatusRefreshing) {
        //回到normal状态
        //NSLog(@"停止刷新");
        self.currentStatus = ZWPullUpToLoadViewStatusNormal;
        //说明：系统很多动画时间都是0.25s
        [UIView animateWithDuration:0.25 animations:^{
            //self.superScrollView的内容底部往下走
            self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top , self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom - ZWLoadViewHeight, self.superScrollView.contentInset.right);
        }];
    }
}


#pragma mark - 监听contentSize事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentSize"]) {
        //NSLog(@"contentSize.height = %f",self.superScrollView.contentSize.height);
        //可能会有数据量比较少,页面中留有空白的情况
//        NSLog(@"%f",self.superScrollView.contentSize.height);
//        NSLog(@"%f",self.superScrollView.frame.size.height);
//        if (self.superScrollView.contentSize.height  + self.superScrollView.contentInset.top < self.superScrollView.frame.size.height) {
//            
//            CGRect frame = self.frame;
//            frame.origin.y = self.superScrollView.frame.size.height - self.superScrollView.contentInset.top * 2;
//            self.frame = frame;
//
//        }else{
//            CGRect frame = self.frame;
//            frame.origin.y = self.superScrollView.contentSize.height;
//            self.frame = frame;
//        }
        CGRect frame = self.frame;
        frame.origin.y = self.superScrollView.contentSize.height;
        self.frame = frame;
        
        
    }else if ([keyPath isEqualToString:@"contentOffset"]){
        //NSLog(@"contentOffset.y = %f",self.superScrollView.contentOffset.y);
        //切换状态
        //拖动：normal -> pulling   pulling -> normal
        if (self.superScrollView.isDragging) {
            if (self.superScrollView.contentOffset.y + self.superScrollView.frame.size.height < self.superScrollView.contentSize.height + ZWLoadViewHeight && self.currentStatus == ZWPullUpToLoadViewtatusPulling) {
                //NSLog(@"从pulling切换到normal状态");
                self.currentStatus = ZWPullUpToLoadViewStatusNormal;
                
            }else if (self.superScrollView.contentOffset.y + self.superScrollView.frame.size.height >= self.superScrollView.contentSize.height + ZWLoadViewHeight && self.currentStatus == ZWPullUpToLoadViewStatusNormal){
                //NSLog(@"从normal切换到pulling状态");
                self.currentStatus = ZWPullUpToLoadViewtatusPulling;
            }
        }else{//松开：pulling ->refreshing
            if (self.currentStatus == ZWPullUpToLoadViewtatusPulling) {
                self.currentStatus = ZWPullUpToLoadViewStatusRefreshing;
            }
        }
    }
}


#pragma mark - setter
- (void)setCurrentStatus:(ZWPullUpToLoadViewStatus)currentStatus{
    _currentStatus = currentStatus;
    //设置内容
    switch (_currentStatus) {
        case ZWPullUpToLoadViewStatusNormal:
            //结束动画
            [self.imageView stopAnimating];
            self.label.text = @"上拉加载数据";
            self.imageView.image = [UIImage imageNamed:@"normal"];
            
            break;
        case ZWPullUpToLoadViewtatusPulling:
            self.label.text = @"释放刷新数据";
            self.imageView.image = [UIImage imageNamed:@"pulling"];
            break;
        case ZWPullUpToLoadViewStatusRefreshing:
            self.label.text = @"正在刷新数据...";
            
            self.imageView.animationImages = self.refreshImages;
            self.imageView.animationDuration = 0.1 * self.refreshImages.count;
            [self.imageView startAnimating];
            
            //说明：系统很多动画时间都是0.25s
            [UIView animateWithDuration:0.25 animations:^{
                //self.superScrollView的内容底部往上走
                self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top , self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom + ZWLoadViewHeight, self.superScrollView.contentInset.right);
            }];
            //让控制器做事情
            if (self.refreshingBlock) {
                self.refreshingBlock();
            }
            break;
    }

}

#pragma mark -懒加载
- (UIImageView *)imageView{
    if (_imageView == nil) {
        UIImage *image = [UIImage imageNamed:@"normal"];
        _imageView = [[UIImageView alloc]initWithImage:image];
    }
    return _imageView;
}
- (UILabel *)label{
    if (_label == nil) {
        _label = [[UILabel alloc]init];
        _label.textColor = [UIColor darkGrayColor];
        _label.font = [UIFont systemFontOfSize:16];
        _label.text = @"上拉加载更多数据";
    }
    return _label;
}
- (NSArray *)refreshImages {
    if (_refreshImages == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        
        for (int i = 1; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"refreshing_0%d", i];
            UIImage *image = [UIImage imageNamed:imageName];
            
            [arrayM addObject:image];
        }
        
        _refreshImages = [arrayM copy];
    }
    return _refreshImages;
}


@end
