//
//  KYMediaTools.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/6.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYMediaTools : NSObject

/**
 获取媒体时间长度（秒）
 @param mediaPath       媒体文件路径
 */
+ (NSInteger)getMediaTimeLength:(NSString *)mediaPath;
/**
 获取媒体大小（）
 @param mediaPath       媒体文件路径
 */
+ (NSInteger)getMediaSize:(NSString *)mediaPath;

/**
 是否为本地文件
 @param url
 */
//+ (BOOL)isLocalFileWithURL:(NSURL *)url;

/**
 获取格式化后的时间字符串
 @param timeLength       时间长度（秒）
 */
+ (NSString *)getFormatTimeString:(NSInteger)timeLength;

/** 获取当前控制器 */
+ (UIViewController *)getCurrentViewController;

/** 获取顶层控制器 */
+ (UIViewController *)getRootViewController;

/**
 获取视图所在导航控制器
 @param view       导航控制器内的某个视图
 */
+ (UINavigationController *)getNavigationControllerFromView:(UIView *)view;

/**
 获取视图所在控制器
 @param view       控制器内的某个视图
 */
+ (UIViewController *)getViewControllerFromView:(UIView *)view;

/// 获取底部安全区域高度
+ (CGFloat)getSafeArea;

/// 获取 Bundle 中的图片
+ (UIImage *)getBundleImage:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
