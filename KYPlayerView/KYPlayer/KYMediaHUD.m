//
//  KYMediaHUD.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/12/16.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYMediaHUD.h"

static KYMediaHUD *_sharedMediaHUD = nil;

@interface KYMediaHUD()
@property (nonatomic, strong)UIActivityIndicatorView *indicatorView;
@end

@implementation KYMediaHUD



#pragma mark -: KYPlayerManager 单例
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMediaHUD =[[self alloc] init];
        [_sharedMediaHUD setupSubviews];
    });
    return _sharedMediaHUD;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMediaHUD = [super allocWithZone:zone];
    });
    return _sharedMediaHUD;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedMediaHUD;
}

- (void)setupSubviews {
    self.indicatorView.frame = CGRectMake(0, 0, 50, 50);
    self.indicatorView.center = self.center;
    [self addSubview:self.indicatorView];
}

/** 正在加载 */
- (void)showLoading:(NSString *)message inView:(UIView *)view {
    
}
/** 隐藏加载提示 */
- (void)hideLoading {
    
}

//- (void)showLoading {
//    [self setHidden:NO];
//    [self.indicatorView startAnimating];
//}
//- (void)hideLoading {
//    [self setHidden:YES];
//    [self.indicatorView stopAnimating];
//}

#pragma mark: - 属性
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        //设置小菊花颜色
        _indicatorView.color = [UIColor whiteColor];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _indicatorView.backgroundColor = [UIColor blackColor];
    }
    return _indicatorView;
}
//    UIActivityIndicatorView *activiy = [[UIActivityIndicatorView alloc] init];
//    activiy.frame = CGRectMake(100, 100, 100, 100);
//    activiy.center = self.view.center;
//    activiy.backgroundColor = [UIColor blackColor];
//    //设置小菊花颜色
//    activiy.color = [UIColor whiteColor];
//    activiy.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//
//    [activiy startAnimating];
//    [self.view addSubview:activiy];
//    self.activiy = activiy;








/** 正在加载 */
- (void)setLoading:(NSString *)loadingMessage {
    
}
/** 加载失败 */
- (void)setLoadFailed:(NSString *)failMessage {
    
}
/** 加载错误提示 */
- (void)setLoadError:(NSString *)errorMessage {
    
}
/** 加载成功 */
- (void)setLoadSuccess:(NSString *)succMessage {
    
}
/** 暂停提示 */
- (void)setPauseUI:(NSString *)pauseMessage {
    
}

/** 隐藏 */
- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
}

@end
