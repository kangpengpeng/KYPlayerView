//
//  KYVolumeView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/28.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 视图方向 */
typedef enum : NSUInteger {
    KYVolumeTypeVertical,      // 纵向
    KYVolumeTypeHorizontal,    // 水平
} KYVolumeViewType;

/** 音频输出方式 */
typedef enum : NSUInteger {
    KYVolumeOutputSystem,       // 系统扬声器播放
    KYVolumeOutputExternal,     // 外部设备播放（耳机）
    KYVolumeOutputUnknown,      // 未知播放途径
} KYVolumeOutputWay;

NS_ASSUME_NONNULL_BEGIN

@class KYVolumeView;
@protocol KYVolumeViewDelegate <NSObject>

@optional
@optional
/** 音频输出设备改变的通知 */
- (void)volumeView:(KYVolumeView *)volumeView didChangeOutputDevice:(KYVolumeOutputWay)volumeOutputWay;
/** 音量改变通知 */
- (void)volumeView:(KYVolumeView *)volumeView didChangeToValue:(CGFloat)value;
@end

@interface KYVolumeView : UIView

@property (nonatomic, weak)id<KYVolumeViewDelegate> delegate;

/** 设置音量增量 */
- (void)setIncreaseVolumeValue:(CGFloat)value;
/** 设置音量值（0~1）*/
- (void)setVolumeValue:(CGFloat)value;
/** 获取音量值 */
- (CGFloat)getVolumeValue;

/** 设置视图类型枚举值 */
- (void)setVolumeViewType:(KYVolumeViewType)viewType;

/** 设置非静音 音量图标 */
- (void)setVolumeIcon:(UIImage *)image;
/** 设置静音图标 */
- (void)setMuteVolumeIcon:(UIImage *)muteImage;
/** 设置音量图标 */
- (void)setVolumeIcon:(UIImage *)image muteVolumeIcon:(UIImage *)muteImage;

/** 延迟隐藏 */
- (void)setHidden:(BOOL)hidden delay:(CGFloat)delay;

@end

NS_ASSUME_NONNULL_END
