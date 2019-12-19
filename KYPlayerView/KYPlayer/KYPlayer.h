//
//  KYPlayer.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/20.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
//AVPlayerStatusUnknown,
//AVPlayerStatusReadyToPlay,
//AVPlayerStatusFailed
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


@class KYPlayer;
@protocol KYPlayerDelegate <NSObject>

@optional
/** 播放器状态 */
- (void)ky_player:(KYPlayer *)player updateStatus:(KYPlayerStatus)status;

/** 播放时间 */
- (void)ky_player:(KYPlayer *)player currentPlayingTime:(CGFloat)playTime totalTime:(CGFloat)totalTime;

/** 播放结束 */
- (void)ky_player:(KYPlayer *)player didPlayEnd:(BOOL)isEnd;

/** 缓冲进度 */
- (void)ky_player:(KYPlayer *)player didCacheProgress:(CGFloat)progress;

/** */
//- (void)ky_player:(KYPlayer *)player ;

@end



@interface KYPlayer : NSObject

@property (nonatomic, weak)id<KYPlayerDelegate> delegate;

/** 视频播放单例 */
+ (instancetype)sharedInstance;

/** 获取播放器显示层 */
- (AVPlayerLayer *)ky_playerLayerWithURL:(NSURL *)url;
/** 快进到指定播放时间 */
- (void)ky_playerSeek2Time:(CGFloat)time;
/** 快进到指定播放进度 */
- (void)ky_playerSeek2Progress:(CGFloat)progress;
/** 快进到指定播放时间 */
- (void)ky_playerSeek2Time:(CGFloat)time completionHandler:(void (^)(BOOL finished))completionHandler;
/** 快进到指定播放进度 */
- (void)ky_playerSeek2Progress:(CGFloat)progress completionHandler:(void (^)(BOOL finished))completionHandler;

/** 播放 */
- (void)ky_play;
/** 暂停 */
- (void)ky_pause;
/** 停止播放 */
- (void)ky_stop;

/** 获取播放器状态 */
- (KYPlayerStatus)ky_getPlayerStatus;

@end

NS_ASSUME_NONNULL_END
