//
//  KYBrightnessView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/26.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYBrightnessView : UIView

/** 设置滑块值 */
- (void)setSliderValue:(CGFloat)value;
/** 获取滑块值 */
- (CGFloat)getSliderValue;

/** 设置图标 */
- (void)setIconImage:(UIImage *)image;

/** 延迟隐藏 */
- (void)setHidden:(BOOL)hidden delay:(CGFloat)delay;


@end

NS_ASSUME_NONNULL_END
