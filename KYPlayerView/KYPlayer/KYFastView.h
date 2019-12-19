//
//  KYFastView.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/25.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYFastView : UIView

/** 设置显示的快进时间 */
- (void)setFastTime:(NSString *)fastTime;
/** 设置快进进度，取值 0~1 */
- (void)setFastProgress:(CGFloat)fastProgress;
/** 设置总时间和快进至的时间 */
- (void)setFastTime:(NSString *)fastTime totalTime:(NSString *)totalTime;

@end

NS_ASSUME_NONNULL_END
