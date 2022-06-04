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

/// 播放状态
typedef enum : NSUInteger {
    KYPlayerStatusUnknown,        // 未知状态
    KYPlayerStatusReadyToPlay,    // 准备播放状态
    KYPlayerStatusFailed,         // 播放准备失败
    KYPlayerStatusBufferEmpty,    // 正在缓冲视频
    KYPlayerStatusKeepUp,         // 缓冲进度可播放
    KYPlayerStatusPlaying,        // 正在播放视频
    KYPlayerStatusPause,          // 暂停状态
    KYPlayerStatusStop,           // 停止状态，不可恢复
} KYPlayerStatus;

@class KYPlayerView;
@protocol KYPlayerViewDelegate <NSObject>
@optional
/// 播放器状态更新
/// @param playerView 播放视图
/// @param state 变更后的状态
- (void)ky_playerView:(KYPlayerView *)playerView updateStatus:(KYPlayerStatus)state;
/// 播放进度更新
/// @param playerView 播放视图
/// @param playTime 当前播放时长
/// @param totalTime 总时长
- (void)ky_playerView:(KYPlayerView *)playerView currentPlayingTime:(CGFloat)playTime totalTime:(CGFloat)totalTime;
/// 播放结束
/// @param playerView 播放视图
/// @param isEnd 是否结束
- (void)ky_playerView:(KYPlayerView *)playerView didPlayEnd:(BOOL)isEnd;
/// 缓冲进度
/// @param playerView 播放视图
/// @param progress 缓冲进度
- (void)ky_playerView:(KYPlayerView *)playerView didCacheProgress:(CGFloat)progress;
@end

@interface KYPlayerView : UIView

@property (nonatomic, weak)id<KYPlayerViewDelegate>delegate;

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
/** 是否显示返回按钮，默认显示 */
- (void)setGobackShow:(BOOL)isShow;

/** 播放 */
- (void)play;
/** 暂停 */
- (void)pause;
/** 停止播放 */
- (void)stop;

/** 获取播放的URL */
- (NSString *)getURLString;

@end

NS_ASSUME_NONNULL_END
