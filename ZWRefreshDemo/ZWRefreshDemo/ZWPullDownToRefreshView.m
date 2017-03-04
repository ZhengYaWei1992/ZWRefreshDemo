//
//  ZWPullDownToRefreshView.m
//  ZWRefreshDemo
//
//  Created by 郑亚伟 on 2017/3/2.
//  Copyright © 2017年 zhengyawei. All rights reserved.
//

#import "ZWPullDownToRefreshView.h"
#import "UIView+SDAutoLayout.h"


typedef enum : NSUInteger {
    ZWPullDownToRefreshViewStatusNormal,//正常
    ZWPullDownToRefreshViewStatusPulling,//释放刷新
    ZWPullDownToRefreshViewStatusRefreshing,//正在刷新
} ZWPullDownToRefreshViewStatus;

@interface ZWPullDownToRefreshView ()

//自定义控件显示内容
//图片
@property(nonatomic,strong)UIImageView *imageView;
//文字
@property(nonatomic,strong)UILabel *label;



//当前状态
@property(nonatomic,assign)ZWPullDownToRefreshViewStatus currentStatus;
//父控件(可以滚动的)
@property(nonatomic,strong)UIScrollView *superScrollView;
//动画图片数组
@property(nonatomic,strong)NSArray *refreshingImages;

@end

@implementation ZWPullDownToRefreshView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.label];
        
        self.imageView.sd_layout.rightSpaceToView(self,self.frame.size.width/2+ 10).centerYEqualToView(self).widthIs(40).heightIs(40);
        self.label.sd_layout.leftSpaceToView(self,self.frame.size.width/2).centerYEqualToView(self).heightIs(40);
        [self.label setSingleLineAutoResizeWithMaxWidth:150];
    }
    return self;
}
-(void)dealloc{
    [self.superScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

//在控制器中调用[self.tableView addSubview:refreshView];会调用这个方法
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    //这里可以获取到父控件 tableView、scrollView、collection,在本类中监听父控件的滚动
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.superScrollView = (UIScrollView *)newSuperview;
        //监听父控件elf.superScrollView的滚动  即contentOffset属性
        //最好通过KVO监听；如果通过代理监听，外部再次设置代理会使这里面的监听滚动会失效
        //本类self监听self.superScrollView的contentOffset属性
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
}
#pragma mark - public
//结束刷新
- (void)endRefreshing{
    //refreshing  -> normal
    if (self.currentStatus == ZWPullDownToRefreshViewStatusRefreshing) {
        self.currentStatus = ZWPullDownToRefreshViewStatusNormal;
        //tableView回去
        [UIView animateWithDuration:0.25 animations:^{
            //self.superScrollView往下走
            self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top - ZWRefreshViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
        }];
    }
}
//开始刷新
- (void)startRefreshing{
    self.currentStatus = ZWPullDownToRefreshViewStatusRefreshing;
}


#pragma mark - KVC监听事件
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        //NSLog(@"%f",self.superScrollView.contentOffset.y);
        //拖动中：normal -> pulling   pulling ->normal
        if (self.superScrollView.isDragging) {//手在拖动
            //在控制器中self.superScrollView中初始contentOffset.y为-64
            CGFloat normalPullingOffset = - 2 * ZWRefreshViewHeight;
            if (self.superScrollView.contentOffset.y > normalPullingOffset && self.currentStatus == ZWPullDownToRefreshViewStatusPulling){
                //NSLog(@"从pulling切换到normal状态");
                self.currentStatus = ZWPullDownToRefreshViewStatusNormal;
            }else if(self.superScrollView.contentOffset.y <= normalPullingOffset && self.currentStatus == ZWPullDownToRefreshViewStatusNormal){
                //NSLog(@"从normal切换到pulling状态");
                self.currentStatus = ZWPullDownToRefreshViewStatusPulling;
            }
        }else{//松开：pulling -> refreshing
            if (self.currentStatus == ZWPullDownToRefreshViewStatusPulling) {
                //NSLog(@"从pulling切换到Refreshing状态");
                self.currentStatus = ZWPullDownToRefreshViewStatusRefreshing;
            }
        }
    }
}

#pragma mark - setter方法
- (void)setCurrentStatus:(ZWPullDownToRefreshViewStatus)currentStatus{
    _currentStatus = currentStatus;
    //设置内容
    switch (_currentStatus) {
        case ZWPullDownToRefreshViewStatusNormal:
            //结束动画
            [self.imageView stopAnimating];
            self.label.text = @"下拉刷新";
            self.imageView.image = [UIImage imageNamed:@"normal"];
            
            break;
        case ZWPullDownToRefreshViewStatusPulling:
            self.label.text = @"释放刷新";
            self.imageView.image = [UIImage imageNamed:@"pulling"];
            break;
        case ZWPullDownToRefreshViewStatusRefreshing:
            self.label.text = @"正在刷新";
            
            self.imageView.animationImages = self.refreshingImages;
            self.imageView.animationDuration = 0.1 * self.refreshingImages.count;
            [self.imageView startAnimating];
            
            //说明：系统很多动画时间都是0.25s
            [UIView animateWithDuration:0.25 animations:^{
                //self.superScrollView往下走
                self.superScrollView.contentInset = UIEdgeInsetsMake(self.superScrollView.contentInset.top + ZWRefreshViewHeight, self.superScrollView.contentInset.left, self.superScrollView.contentInset.bottom, self.superScrollView.contentInset.right);
            }];
            //让控制器做事情
            if (self.refreshingBlock) {
                self.refreshingBlock();
            }
            break;
    }
}



#pragma mark-懒加载
- (UILabel *)label{
    if (_label == nil) {
        _label = [[UILabel alloc]init];
        _label.textColor = [UIColor darkGrayColor];
        _label.font = [UIFont systemFontOfSize:16];
        _label.text = @"下拉刷新";
    }
    return _label;
}
- (UIImageView *)imageView{
    if (_imageView == nil) {
        UIImage *normalImage = [UIImage imageNamed:@"normal"];
        _imageView = [[UIImageView alloc]initWithImage:normalImage];
    }
    return _imageView;
}
- (NSArray *)refreshingImages{
    if (_refreshingImages == nil) {
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSInteger i = 1; i < 4; i++) {
            NSString *imageName = [NSString stringWithFormat:@"refreshing_0%ld",i];
            UIImage *image = [UIImage imageNamed:imageName];
            [arrayM addObject:image];
        }
        _refreshingImages = arrayM;
    }
    return _refreshingImages;
}

@end
