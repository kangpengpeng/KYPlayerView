//
//  KYPlayerView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/10/23.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYPlayerView : UIView

//+ (instancetype)sharedInstance;

/** 设置播放 URL */
- (void)setURL:(NSURL *)url;
/** 设置播放 URLString */
- (void)setURLWithString:(NSString *)urlString;

/** 设置媒体标题文字 */
- (void)setMediaTitle:(NSString *)text;

/** 设置视频填充方式 */
- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity;

/** 是否显示中间大的播放/暂停按钮（默认显示） */
- (void)setEnableShowCenterPlayButton:(BOOL)isEnable;
/** 是否开启亮度调节 */
- (void)setEnableControlBrightness:(BOOL)isEnable;
/** 是否开启音量调节 */
- (void)setEnableControlVolume:(BOOL)isEnable;
/** 是否允许快进 */
- (void)setEnableControlFast:(BOOL)isEnable;
/** 是否允许显示顶部视图 */
- (void)setEnableShowTopView:(BOOL)isEnable;

/** 播放 */
- (void)play;
/** 暂停 */
- (void)pause;
/** 停止播放 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
