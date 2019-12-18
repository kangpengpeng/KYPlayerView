//
//  KYPlayerView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/10/23.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYPlayerView : UIView

//+ (instancetype)sharedInstance;

/** 设置播放 URL */
- (void)setURL:(NSURL *)url;
/** 设置播放 URLString */
- (void)setURLWithString:(NSString *)urlString;

/** 是否开启亮度调节 */
- (void)setEnableControlBrightness:(BOOL)isEnable;
/** 是否开启音量调节 */
- (void)setEnableControlVolume:(BOOL)isEnable;
/** 是否允许快进 */
- (void)setEnableControlFast:(BOOL)isEnable;

/** 播放 */
- (void)play;
/** 暂停 */
- (void)pause;
/** 停止播放 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
