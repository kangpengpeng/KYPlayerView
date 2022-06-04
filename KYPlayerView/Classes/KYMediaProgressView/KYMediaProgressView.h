//
//  KYProgressView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/5.
//  Copyright © 2019年 kangpp. All rights reserved.
//  

#import <UIKit/UIKit.h>

@class KYMediaProgressView;
@protocol KYMediaProgressViewDelegate <NSObject>

@optional
/** 将要拖拽滑动 */
- (void)mediaProgressView:(KYMediaProgressView *)progressView sliderWillChange:(CGFloat)value;
/** 正在拖拽滑动 */
- (void)mediaProgressView:(KYMediaProgressView *)progressView sliderDidChange:(CGFloat)value;
/** 完成拖拽滑动 */
- (void)mediaProgressView:(KYMediaProgressView *)progressView sliderEndChange:(CGFloat)value;
@end

typedef void(^SlideBlock)(CGFloat value);

NS_ASSUME_NONNULL_BEGIN

@interface KYMediaProgressView : UIView

@property (nonatomic, weak)id<KYMediaProgressViewDelegate> delegate;

/** 缓存进度 */
@property (nonatomic, assign)CGFloat cacheValue;
/** 播放进度 */
@property (nonatomic, assign)CGFloat playValue;


/** 进度条默认颜色 */
@property (nonatomic, strong)UIColor *defaultColor;
/** 进度条缓存颜色 */
@property (nonatomic, strong)UIColor *cacheColor;
/** 进度条播放颜色 */
@property (nonatomic, strong)UIColor *playColor;

/** slider 将要滑动 */
@property (nonatomic, copy)SlideBlock sliderWillChangeBlock;
/** slider 正在滑动 */
@property (nonatomic, copy)SlideBlock sliderDidChangeBlock;
/** slider 结束滑动 */
@property (nonatomic, copy)SlideBlock sliderEndChangeBlock;

/** 是否允许进度条滑动 */
- (void)setEnableSlip:(BOOL)isEnable;

/**
 设置滑块颜色和图片
 @param  color              滑动条左侧颜色
 @param  normalImage        滑块 UIControlStateNormal 状态图片
 @param  highlightedImage   滑块 UIControlStateHighlighted 状态图片
 */
- (void)setThumbTintColor:(UIColor *)color normalImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage;

@end

NS_ASSUME_NONNULL_END
