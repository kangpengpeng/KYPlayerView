//
//  KYSlider.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/5.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYSlider.h"

#define SLIDER_X_BOUND 30
#define SLIDER_Y_BOUND 40

@implementation KYSlider {
    float _trackHeight;
    CGRect _lastBounds;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _trackHeight = 4;
        _enableSlip = YES;
    }
    return self;
}


// 改变滑条的宽度
- (CGRect)trackRectForBounds:(CGRect)bounds {
    float width = bounds.size.width;
    float height = _trackHeight;
    float x = 0;
    float y = (bounds.size.height-height)/2;
    return CGRectMake(x, y, width, height);
}


- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect result = [super thumbRectForBounds:bounds trackRect:rect value:value];
    //记录下最终的frame
    _lastBounds = result;
    return result;
}

//检查点击事件点击范围是否能够交给self处理
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (_enableSlip == NO) return nil;
    //调用父类方法,找到能够处理event的view
    UIView* result = [super hitTest:point withEvent:event];
    if (result != self) {
        /*如果这个view不是self,我们给slider扩充一下响应范围,
         这里的扩充范围数据就可以自己设置了
         */
        if ((point.y >= -15) &&
            (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND)) &&
            (point.x >= 0 && point.x < CGRectGetWidth(self.bounds))) {
            //如果在扩充的范围类,就将event的处理权交给self
            result = self;
        }
    }
    //否则,返回能够处理的view
    return result;
}
//检查是点击事件的点是否在slider范围内
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (_enableSlip == NO) return NO;
    //调用父类判断
    BOOL result = [super pointInside:point withEvent:event];
    
    if (!result) {
        //同理,如果不在slider范围类,扩充响应范围
        if ((point.x >= (_lastBounds.origin.x - SLIDER_X_BOUND)) && (point.x <= (_lastBounds.origin.x + _lastBounds.size.width + SLIDER_X_BOUND))
            && (point.y >= -SLIDER_Y_BOUND) && (point.y < (_lastBounds.size.height + SLIDER_Y_BOUND))) {
            //在扩充范围内,返回yes
            result = YES;
        }
    }
    
    //NSLog(@"UISlider(%d).pointInside: (%f, %f) result=%d", self, point.x, point.y, result);
    //否则返回父类的结果
    return result;
}


//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __func__);
//    for (id obj in self.allTargets) {
//        if ([@"KYMediaProgressView" isEqual:[obj class]]) {
//            NSLog(@"相等的");
//        }
//    }
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"%s", __func__);
//}

@end
