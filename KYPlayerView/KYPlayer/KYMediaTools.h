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
@end

NS_ASSUME_NONNULL_END
