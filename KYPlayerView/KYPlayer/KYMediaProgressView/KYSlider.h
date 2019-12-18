//
//  KYSlider.h
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/5.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KYSlider : UISlider

/** 是否允许拖动（滑动） */
@property (nonatomic, assign, getter=isEnableSlip)BOOL enableSlip;

@end

NS_ASSUME_NONNULL_END
