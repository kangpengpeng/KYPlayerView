//
//  KYControlView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/4.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    KYMediaGestureScreenHorizontal,      // 全屏横向滑动手势
    KYMediaGestureLeftVertical,          // 左侧纵向手势
    KYMediaGestureRightVertical,         // 右侧纵向手势
    KYMediaGestureUnknown,
} KYMediaGestureLocation;

/** 手势状态 */
typedef enum : NSUInteger {
    KYMediaGestureStateBegan,      // 手势开始
    KYMediaGestureStateChange,     // 手势正在滑动
    KYMediaGestureStateEnd         // 手势结束
} KYMediaGestureState;

@class KYMediaControlView;
@protocol KYMediaControlViewProtocol <NSObject>

/** 播放、暂停 */
- (void)mediaControl:(KYMediaControlView *)mediaControl isSetPlay:(BOOL)isPlay;

@optional
/** 全屏、退出全屏 */
- (void)mediaControl:(KYMediaControlView *)mediaControl isSetFullScreen:(BOOL)isFullScreen;
/** 正在滑动进度条 */
- (void)mediaControl:(KYMediaControlView *)mediaControl isSlidingProgress:(float)progress;
/** 进度条滑动结束 */
- (void)mediaControl:(KYMediaControlView *)mediaControl endSlidProgress:(float)progress;

/** 手势正在滑动 */
- (void)mediaControl:(KYMediaControlView *)mediaControl gestureLocation:(KYMediaGestureLocation)location gestureStatus:(KYMediaGestureState)gestureState slidDistance:(float)distance;


@end

NS_ASSUME_NONNULL_BEGIN

@interface KYMediaControlView : UIView

@property (nonatomic, weak)id<KYMediaControlViewProtocol> contorlDelegate;

/** 设置视频时长 */
- (void)setTotalTime:(NSString *)timeText;
/** 设置已播放视频时长 */
- (void)setPlayTime:(NSString *)timeText;
/** 设置视频时长和已播放视频时长 */
- (void)setTotalTime:(NSString *)totalTimeLength playTime:(NSString *)playTimeLength;

/** 设置播放进度 取值范围 0-1 */
- (void)setPlayProgress:(CGFloat)progress;
/** 设置缓存进度 取值范围 0-1 */
- (void)setCacheProgress:(CGFloat)progress;

/** 是否允许进度条滑动（默认可滑动） */
- (void)setEnableSlipSlider:(BOOL)isEnable;
/** 是否显示顶部控制视图（默认可显示） */
- (void)setEnableShowTopView:(BOOL)isEnable;

/** 设置开始播放UI */
- (void)setPlayResumeUI;
/** 设置播放暂停UI */
- (void)setPlayPauseUI;
/** 设置播放结束UI */
- (void)setPlayEndUI;


@end

NS_ASSUME_NONNULL_END
