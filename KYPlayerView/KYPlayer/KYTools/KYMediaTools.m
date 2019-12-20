//
//  KYMediaTools.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/6.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYMediaTools.h"
#import <AVFoundation/AVFoundation.h>

@implementation KYMediaTools

/** 获取媒体时间长度（秒）*/
+ (NSInteger)getMediaTimeLength:(NSString *)mediaPath {
    AVURLAsset * asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:mediaPath]];
    CMTime time = [asset duration];
    int seconds = ceil(time.value/time.timescale);
    return seconds;
}

/** 获取媒体大小（）*/
+ (NSInteger)getMediaSize:(NSString *)mediaPath {
     NSInteger fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:mediaPath error:nil].fileSize;
    return fileSize;
}

//传入秒  得到 xx:xx:xx
+ (NSString *)getFormatTimeString:(NSInteger)timeLength {
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",timeLength/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(timeLength%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",timeLength%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}


/** 获取当前控制器 */
+ (UIViewController *)getCurrentViewController {
    UIViewController *controller = [[[UIApplication sharedApplication] delegate].window rootViewController];
    if ([controller isKindOfClass:[UITabBarController class]]) {
        controller = [(UITabBarController *)controller selectedViewController];
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = [(UINavigationController *)controller visibleViewController];
    }
    return controller;
}


/** 获取顶层控制器 */
+ (UIViewController *)getRootViewController {
    UIViewController *RootVC = [[UIApplication sharedApplication] delegate].window.rootViewController;
    UIViewController *topVC = RootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

/** 获取视图所在导航控制器 */
+ (UINavigationController *)getNavigationControllerFromView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)nextResponder;
        }
    }
    return nil;
}

/** 获取视图所在控制器 */
+ (UIViewController *)getViewControllerFromView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

@end
