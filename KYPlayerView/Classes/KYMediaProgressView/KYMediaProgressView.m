//
//  KYProgressView.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/5.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYMediaProgressView.h"
#import "KYSlider.h"
#import "KYMediaTools.h"

@interface KYMediaProgressView()
/** 进度条滑块 */
@property (nonatomic, strong)KYSlider *playSlider;
/** 进度条高度 */
@property (nonatomic, assign)CGFloat trackHeight;
@end

@implementation KYMediaProgressView {
    SlideBlock _slideBlock;
    BOOL _isSliding;
    BOOL _isEnableSlip;
}

#pragma mark: - 暴露的设置属性方法
- (void)setPlayValue:(CGFloat)playValue {
    _playValue = playValue;
    // 拖拽过程中，仅更新播放值，不更新滑块值
    if (_isSliding) {
        return;
    }
    [self.playSlider setValue:playValue];
    // 当使用贝塞尔曲线描绘已播放线段时，需要打开此方法
    // [self setNeedsDisplay];
}

- (void)setCacheValue:(CGFloat)cacheValue {
    _cacheValue = cacheValue;
    [self setNeedsDisplay];
}

/** 是否允许进度条滑动 */
- (void)setEnableSlip:(BOOL)isEnable {
    [self.playSlider setEnableSlip:isEnable];
}

//- (void)setTrackHeight:(CGFloat)trackHeight {
//    _trackHeight = trackHeight;
//    _playSlider.transform = CGAffineTransformMakeScale(1.0, 10);
//}
//- (void)setThumbTintColor:(UIColor *)color andImage:(UIImage *)image {
//    self.playColor = color;
//    self.playSlider.thumbTintColor = self.playColor;
//    self.
//}

#pragma mark: - 属性
- (KYSlider *)playSlider {
    if (!_playSlider) {
        _playSlider = [[KYSlider alloc] init];
        // 默认值为YES设置为YES只要滑轮滚动就会触发change方法设置为NO只有当滑轮停止移动时才会触发change方法
        _playSlider.continuous = YES;
        _playSlider.value = 0;
        [_playSlider addTarget:self action:@selector(playSliderStart:) forControlEvents:UIControlEventTouchDown];
        [_playSlider addTarget:self action:@selector(playSliderChange:) forControlEvents:UIControlEventValueChanged];
        [_playSlider addTarget:self action:@selector(playSliderEnd:) forControlEvents:UIControlEventTouchUpInside];
        [_playSlider addTarget:self action:@selector(playSliderEnd:) forControlEvents:UIControlEventTouchUpOutside];
        [_playSlider addTarget:self action:@selector(playSliderEnd:) forControlEvents:UIControlEventTouchCancel];

    }
    return _playSlider;
}

#pragma mark: - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        [self setInitData];
    }
    return self;
}

- (void)setInitData {
    self.backgroundColor = [UIColor clearColor];
    // 默认白色
    self.defaultColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    // 缓存颜色，默认灰色
    self.cacheColor = [UIColor colorWithWhite:1 alpha:0.3];
    // 播放后的颜色
    self.playColor = [UIColor colorWithRed:237/255.0 green:105/255.0 blue:57/255.0 alpha:1];
    _trackHeight = 4;
    _cacheValue = 0;
    _playValue = 0;
    _isSliding = NO;
    
    [_playSlider setValue:_playValue];
    _playSlider.maximumTrackTintColor = [UIColor clearColor];
    _playSlider.minimumTrackTintColor = self.playColor;
    _playSlider.thumbTintColor = self.playColor;
    [self.playSlider setThumbImage:[KYMediaTools getBundleImage:@"slider@2x.png"] forState:UIControlStateNormal];
    [self.playSlider setThumbImage:[KYMediaTools getBundleImage:@"slider_seleted@2x.png"] forState:UIControlStateHighlighted];
}

- (void)setupSubviews {
    [self addSubview:self.playSlider];
    self.playSlider.translatesAutoresizingMaskIntoConstraints = NO;
    // ********************************** self.playSlider **********************************
    // self.playSlider 左边距
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playSlider
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:0]];
    // self.playSlider 右边距
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playSlider
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:_trackHeight/2]];
    // self.playBtn centerY
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.playSlider
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
}






- (void)drawRect:(CGRect)rect {
    // 起点和终点如果不考虑线段圆角半径，终点就是平直四方效果
    CGFloat marginW = _trackHeight/2;
    CGFloat pY = (rect.size.height)/2 + 1;
    CGPoint startP = CGPointMake(marginW, pY);
    CGPoint endP = CGPointMake(rect.size.width-marginW, pY);
    CGPoint cacheEndP = CGPointMake(rect.size.width*_cacheValue-marginW, pY);
    CGPoint playEndP = CGPointMake(rect.size.width*_playValue-marginW, pY);
    if (cacheEndP.x<marginW) cacheEndP.x = marginW;
    if (playEndP.x<marginW) playEndP.x = marginW;
    
    // 背景线
    UIBezierPath *bgPath = [[UIBezierPath alloc] init];
    [bgPath moveToPoint:startP];
    [bgPath addLineToPoint:endP];
    [bgPath setLineWidth:_trackHeight];
    // 终点处理
    bgPath.lineCapStyle = kCGLineCapRound;
    [self.defaultColor setStroke];
    [bgPath stroke];
    
    // 缓存线
    UIBezierPath *cachePath = [[UIBezierPath alloc] init];
    [cachePath moveToPoint:startP];
    [cachePath addLineToPoint:cacheEndP];
    [cachePath setLineWidth:_trackHeight];
    cachePath.lineCapStyle = kCGLineCapRound;
    [_cacheColor setStroke];
    [cachePath stroke];
    
    /*
    // 已播放线
    UIBezierPath *playPath = [[UIBezierPath alloc] init];
    [playPath moveToPoint:startP];
    [playPath addLineToPoint:playEndP];
    [playPath setLineWidth:_trackHeight];
    playPath.lineCapStyle = kCGLineCapRound;
    [_playColor setStroke];
    [playPath stroke];
     */
}

/** slider 开始滑动 */
- (void)playSliderStart:(KYSlider *)sender {
    if (self.sliderWillChangeBlock) {
        self.sliderWillChangeBlock(sender.value);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaProgressView:sliderWillChange:)]) {
        [self.delegate mediaProgressView:self sliderWillChange:sender.value];
    }
}
/** slider 正在滑动 */
- (void)playSliderChange:(KYSlider *)sender {
    _isSliding = YES;
    _playValue = sender.value;
    if (self.sliderDidChangeBlock) {
        self.sliderDidChangeBlock(sender.value);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaProgressView:sliderDidChange:)]) {
        [self.delegate mediaProgressView:self sliderDidChange:sender.value];
    }
    // 当使用贝塞尔曲线描绘已播放线段时，需要打开此方法
    // [self setNeedsDisplay];
}

/** slider 结束滑动 */
- (void)playSliderEnd:(KYSlider *)sender {
    _playValue = sender.value;
    _isSliding = NO;
    if (self.sliderEndChangeBlock) {
        self.sliderEndChangeBlock(sender.value);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaProgressView:sliderEndChange:)]) {
        [self.delegate mediaProgressView:self sliderEndChange:sender.value];
    }
    // 当使用贝塞尔曲线描绘已播放线段时，需要打开此方法
    // [self setNeedsDisplay];
}






#pragma mark: - delloc
- (void)dealloc {
    //NSLog(@"%s", __func__);
}








@end
