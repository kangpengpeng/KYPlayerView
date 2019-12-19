//
//  KYProgressView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/5.
//  Copyright © 2019年 kangpp. All rights reserved.
//  

#import <UIKit/UIKit.h>

typedef void(^SlideBlock)(float value);

NS_ASSUME_NONNULL_BEGIN

@interface KYMediaProgressView : UIView

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

@end

NS_ASSUME_NONNULL_END
