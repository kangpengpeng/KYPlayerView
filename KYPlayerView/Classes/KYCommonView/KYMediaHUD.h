//
//  KYMediaHUD.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/12/16.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYMediaHUD : UIView
/** 初始化单例 */
+ (instancetype)shared;

/** 正在加载 */
- (void)showLoading:(NSString *)message inView:(UIView *)view;
/** 隐藏加载提示 */
- (void)hideLoading;

///** 正在加载 */
//- (void)setLoading:(NSString *)loadingMessage;
///** 加载失败 */
//- (void)setLoadFailed:(NSString *)failMessage;
///** 加载错误提示 */
//- (void)setLoadError:(NSString *)errorMessage;
///** 加载成功 */
//- (void)setLoadSuccess:(NSString *)succMessage;
///** 暂停提示 */
//- (void)setPauseUI:(NSString *)pauseMessage;
///** 播放结束 */
//- (void)setEndUI:(NSString *)endMessage;

/** 隐藏 */
- (void)setHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
