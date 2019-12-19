//
//  KYControlView.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/4.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYMediaControlView.h"
#import "KYMediaProgressView.h"
#import <AVFoundation/AVFoundation.h>
#import "KYMediaTools.h"


#define k_ANIMATION_DURATION         0.3

/** 隐藏底部视图的延迟时间 */
#define k_HIDDEN_DELAY     5

@interface KYMediaControlView()
/** 中间打的播放按钮 */
@property (nonatomic, strong)UIButton *largePlayBtn;
/** 播放、暂停按钮 */
@property (nonatomic, strong)UIButton *playBtn;
/** 全屏按钮 */
@property (nonatomic, strong)UIButton *fullBtn;
/** 总时长 Label */
@property (nonatomic, strong)UILabel *totalTimeLb;
/** 已播放时长 Label */
@property (nonatomic, strong)UILabel *playTimeLb;
/** 进度条 */
@property (nonatomic, strong)KYMediaProgressView *progressView;

/** 底部控制的容器视图 */
@property (nonatomic, strong)UIView *bottomContentView;
/** 头部控制的容器视图 */
@property (nonatomic, strong)UIView *topContentView;
@end

@implementation KYMediaControlView {
    /** 当前是否正在播放 */
    BOOL _isPlay;
    /** 当前是否显示控制视图 */
    BOOL _isShowControlView;
    /** 当前是否正在执行动画 */
    BOOL _isAnimating;
    
    /** 底部容器视图高度 */
    float _bottomContentHeight;
    /** 头部容器视图高度 */
    float _topContentHeight;
    /** 底部容器视图的底部约束 */
    NSLayoutConstraint *_bottomContentConstraintBottom;
    /** 头部容器视图的top约束 */
    NSLayoutConstraint *_topContentConstraintTop;
    
    /** 隐藏底部控制视图的动画block */
    dispatch_block_t _hideAnimationBlock;
}

#pragma mark: - 提供给外部的数据设置
/** 设置视频时长 */
- (void)setTotalTime:(NSString *)timeText {
    self.totalTimeLb.text = [NSString stringWithFormat:@"%@", timeText];
}
/** 设置已播放视频时长 */
- (void)setPlayTime:(NSString *)timeText {
    self.playTimeLb.text = timeText;
}
/** 设置视频时长和已播放视频时长 */
- (void)setTotalTime:(NSString *)totalTimeLength playTime:(NSString *)playTimeLength {
    [self setTotalTime:totalTimeLength];
    [self setPlayTime:playTimeLength];
}
/** 设置播放进度 取值范围 0-1 */
- (void)setPlayProgress:(CGFloat)progress {
    CGFloat tmpValue = (isnan(progress) || progress < 0) ? 0 : progress;
    [self.progressView setPlayValue:tmpValue];
}
/** 设置缓存进度 取值范围 0-1 */
- (void)setCacheProgress:(CGFloat)progress {
    CGFloat tmpValue = (isnan(progress) || progress < 0) ? 0 : progress;
    [self.progressView setCacheValue:tmpValue];
}


/** 是否允许进度条滑动（默认可滑动） */
- (void)setEnableSlipSlider:(BOOL)isEnable {
    [self.progressView setEnableSlip:isEnable];
}

/** 是否显示顶部控制视图（默认不显示） */
- (void)setEnableShowTopView:(BOOL)isEnable {
    [self.topContentView setHidden:!isEnable];
}

/** 设置开始播放UI */
- (void)setPlayResumeUI {
    [self.playBtn setSelected:YES];
    [self.largePlayBtn setSelected:YES];
    [self.largePlayBtn setHidden:YES];
    [self hideControlViewDelay:k_HIDDEN_DELAY];
    _isPlay = YES;
}
/** 设置播放暂停UI */
- (void)setPlayPauseUI {
    [self.playBtn setSelected:NO];
    [self.largePlayBtn setSelected:NO];
    [self.largePlayBtn setHidden:NO];
    _isPlay = NO;
}
/** 设置是否播放结束 */
- (void)setPlayEndUI {
    [self.playBtn setSelected:NO];
    [self.largePlayBtn setSelected:NO];
    [self.largePlayBtn setHidden:NO];
    _isPlay = NO;
}


#pragma mark: - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
        [self setInitData];
        [self addSubviews];
        [self setupSubviews];
        [self addGesture];
        __weak typeof(self) weakSelf = self;
        self.progressView.sliderWillChangeBlock = ^(float value) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf showControlView];
        };
        self.progressView.sliderDidChangeBlock = ^(float value) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.contorlDelegate && [strongSelf.contorlDelegate respondsToSelector:@selector(mediaControl:isSlidingProgress:)]) {
                [strongSelf.contorlDelegate mediaControl:strongSelf isSlidingProgress:value];
            }
        };
        self.progressView.sliderEndChangeBlock = ^(float value) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.contorlDelegate && [strongSelf.contorlDelegate respondsToSelector:@selector(mediaControl:endSlidProgress:)]) {
                [strongSelf.contorlDelegate mediaControl:strongSelf endSlidProgress:value];
            }
        };
    }
    return self;
}


#pragma mark: - 手势
/** 给视图添加手势 */
- (void)addGesture {
    // 单击手势
    UITapGestureRecognizer *singleTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction:)];
    singleTapGes.numberOfTapsRequired =1;
    singleTapGes.numberOfTouchesRequired  =1;
    [self addGestureRecognizer:singleTapGes];
    // 双击手势
    UITapGestureRecognizer *doubleTapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTapGes.numberOfTapsRequired =2;
    doubleTapGes.numberOfTouchesRequired =1;
    [self addGestureRecognizer:doubleTapGes];
    //只有当doubleTapGesture识别失败的时候(即识别出这不是双击操作)，singleTapGesture才能开始识别
    // 解决单击和双击的手势冲突
    [singleTapGes requireGestureRecognizerToFail:doubleTapGes];
    // 左右、上下滑动手势
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self addGestureRecognizer:panGes];
}

- (void)singleTapAction:(UITapGestureRecognizer *)ges {
    if (_isShowControlView) {
        [self hideControlViewDelay:0];
    } else {
        [self showControlView];
    }
}
- (void)doubleTapAction:(UITapGestureRecognizer *)ges {
    if (_isPlay) {
        [self setPlayPauseUI];
    } else {
        [self setPlayResumeUI];
    }
    if (self.contorlDelegate && [self.contorlDelegate respondsToSelector:@selector(mediaControl:isSetPlay:)]) {
        [self.contorlDelegate mediaControl:self isSetPlay:_isPlay];
    }
}
- (void)panGestureAction:(UIPanGestureRecognizer *)ges {
    CGPoint gPoint = [ges locationInView:self];
    
    static CGPoint _startPoint;
    static KYMediaGestureLocation _gestureType;
    static float _slidDiffValue = 0;
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        _startPoint = gPoint;
        _gestureType = KYMediaGestureUnknown;
        
    } else if (ges.state == UIGestureRecognizerStateChanged) {

        float diffX = [self slipDistanceXFromPoint:_startPoint endPoint:gPoint];
        float diffY = [self slipDistanceYFromPoint:_startPoint endPoint:gPoint];
        float absX = fabsf(diffX);
        float absY = fabsf(diffY);
        // 手势优化距离的阀值
        int flagValue = 3;
        
        switch (_gestureType) {
            case KYMediaGestureUnknown: {
                // 优化：延迟反应时间，更准确的确定手势类型（更准确的理解用户意图），同时需要结果减去延迟的距离  flagValue
                if (absX < flagValue && absY < flagValue) {
                    return;
                }
                // 判断手势类型
                if (absY < absX) {
                    // 横向滑动
                    _gestureType = KYMediaGestureScreenHorizontal;
                    _slidDiffValue = diffX;
                } else {
                    float centerX = self.frame.size.width/2;
                    if (_startPoint.x < centerX) {
                        _gestureType = KYMediaGestureLeftVertical;
                    } else {
                        _gestureType = KYMediaGestureRightVertical;
                    }
                    _slidDiffValue = diffY;
                }
                if (self.contorlDelegate && [self.contorlDelegate respondsToSelector:@selector(mediaControl:gestureLocation:gestureStatus:slidDistance:)]) {
                    [self.contorlDelegate mediaControl:self gestureLocation:_gestureType gestureStatus:KYMediaGestureStateBegan slidDistance:0];
                }
                return;
                break;
            }
            case KYMediaGestureScreenHorizontal: {
                _slidDiffValue = diffX;
                break;
            }
            case KYMediaGestureLeftVertical: {
                _slidDiffValue = diffY;
                break;
            }
            case KYMediaGestureRightVertical: {
                _slidDiffValue = diffY;
                break;
            }
            default:
                break;
        }
        // 修正优化后的滑动距离
        _slidDiffValue -= flagValue;
        
        if (self.contorlDelegate && [self.contorlDelegate respondsToSelector:@selector(mediaControl:gestureLocation:gestureStatus:slidDistance:)]) {
            [self.contorlDelegate mediaControl:self gestureLocation:_gestureType gestureStatus:KYMediaGestureStateChange slidDistance:_slidDiffValue];
        }
        
    } else if (ges.state == UIGestureRecognizerStateEnded) {
        if (self.contorlDelegate && [self.contorlDelegate respondsToSelector:@selector(mediaControl:gestureLocation:gestureStatus:slidDistance:)]) {
            [self.contorlDelegate mediaControl:self gestureLocation:_gestureType gestureStatus:KYMediaGestureStateEnd slidDistance:_slidDiffValue];
        }
    }
}

/** x轴滑动距离 */
- (CGFloat)slipDistanceXFromPoint:(CGPoint)fromPoint endPoint:(CGPoint)endPoint {
    CGFloat xMtp = endPoint.x - fromPoint.x;
    return xMtp;
}
/** y轴滑动距离 */
- (CGFloat)slipDistanceYFromPoint:(CGPoint)fromPoint endPoint:(CGPoint)endPoint {
    CGFloat yMtp = endPoint.y - fromPoint.y;
    return yMtp;
}

#pragma mark: - 按钮事件
- (void)fullScreen:(UIButton *)sender {
    if (self.contorlDelegate && [self.contorlDelegate respondsToSelector:@selector(mediaControl:isSetFullScreen:)]) {
        sender.selected = !sender.isSelected;
        [self.contorlDelegate mediaControl:self isSetFullScreen:sender.isSelected];
    }
}

//播放按钮事件
- (void)clickPlayBtn:(UIButton *)sender {
    if (self.contorlDelegate && [self.contorlDelegate respondsToSelector:@selector(mediaControl:isSetPlay:)]) {
        [sender setSelected:!sender.isSelected];
        if (sender.isSelected) {
            [self setPlayResumeUI];
        } else {
            [self setPlayPauseUI];
        }
        [self.contorlDelegate mediaControl:self isSetPlay:sender.isSelected];
    }
}


#pragma mark: - 视图控制
/** 显示控制视图 */
- (void)showControlView {
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    _bottomContentConstraintBottom.constant = 0;
    _topContentConstraintTop.constant = 0;
    [self.bottomContentView setNeedsUpdateConstraints];
    [self.topContentView setNeedsUpdateConstraints];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:k_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf->_isShowControlView = YES;
        strongSelf->_isAnimating = NO;
    }];
}
/** 隐藏控制视图 */
- (void)hideControlViewDelay:(NSTimeInterval)delay {
    if (_hideAnimationBlock) dispatch_block_cancel(_hideAnimationBlock);
    __weak typeof(self) weakSelf = self;
    _hideAnimationBlock = dispatch_block_create(0, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) return;
        if (strongSelf->_isAnimating) return;
        strongSelf->_isAnimating = YES;
        strongSelf->_bottomContentConstraintBottom.constant = strongSelf->_bottomContentHeight;
        strongSelf->_topContentConstraintTop.constant = -strongSelf->_topContentHeight;
        [strongSelf.bottomContentView setNeedsUpdateConstraints];
        [strongSelf.topContentView setNeedsUpdateConstraints];
        [UIView animateWithDuration:k_ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [strongSelf layoutIfNeeded];
        } completion:^(BOOL finished) {
            strongSelf->_isShowControlView = NO;
            strongSelf->_isAnimating = NO;
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC), dispatch_get_main_queue(), _hideAnimationBlock);
}

#pragma mark: - 初始化约束视图
- (void)addSubviews {
    [self addSubview:self.largePlayBtn];
    [self addSubview:self.bottomContentView];
    [self addSubview:self.topContentView];
    [self.bottomContentView addSubview:self.playBtn];
    [self.bottomContentView addSubview:self.fullBtn];
    [self.bottomContentView addSubview:self.totalTimeLb];
    [self.bottomContentView addSubview:self.playTimeLb];
    [self.bottomContentView addSubview:self.progressView];
}
- (void)setupSubviews {
    
    self.largePlayBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomContentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.playBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.fullBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.totalTimeLb.translatesAutoresizingMaskIntoConstraints = NO;
    self.playTimeLb.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.topContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    int largeBtnW = 60;
    int btnW = 25;
    int labelW = 65;
    
    // ********************************** self.bottomContentView **********************************
    // self.bottomContentView 左边距
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContentView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:0]];
    // self.bottomContentView 右边距
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContentView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:0]];
    // self.bottomContentView 下边距
    _bottomContentConstraintBottom = [NSLayoutConstraint constraintWithItem:self.bottomContentView
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:0];
    [self addConstraint:_bottomContentConstraintBottom];
    // self.bottomContentView 高
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomContentView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0
                                                      constant:_bottomContentHeight]];
    
    // ********************************** self.topContentView **********************************
    // self.topContentView 左边距
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topContentView
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:0]];
    // self.topContentView 右边距
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topContentView
                                                     attribute:NSLayoutAttributeRight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeRight
                                                    multiplier:1
                                                      constant:0]];
    // self.topContentView 上边距
    _topContentConstraintTop = [NSLayoutConstraint constraintWithItem:self.topContentView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1
                                                             constant:0];
    [self addConstraint:_topContentConstraintTop];
    // self.topContentView 高
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topContentView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0
                                                      constant:_topContentHeight]];
    
    // ********************************** self.largePlayBtn **********************************
    // self.largePlayBtn centerX
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.largePlayBtn
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    // self.largePlayBtn centerY
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.largePlayBtn
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    // self.largePlayBtn 宽
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.largePlayBtn
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0
                                                      constant:largeBtnW]];
    // self.largePlayBtn 高
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.largePlayBtn
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:0
                                                      constant:largeBtnW]];
    

    
    // ********************************** self.playBtn **********************************
    // self.playBtn 左边距
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playBtn
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:5]];
    // self.playBtn cneterY
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playBtn
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
    // self.playBtn 宽
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playBtn
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:btnW]];
    // self.playBtn 高
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playBtn
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:btnW]];
    
    // ********************************** self.playTimeLb **********************************
    // self.playTimeLb 左边距
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playTimeLb
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.playBtn
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:5]];
    // self.playTimeLb centerY
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playTimeLb
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
    // self.playTimeLb 宽
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playTimeLb
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:labelW]];
    // self.playTimeLb 高
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.playTimeLb
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1
                                                                        constant:0]];
    
    // ********************************** self.fullBtn **********************************
    // self.fullBtn 右边距
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullBtn
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:-10]];
    // self.fullBtn centerY
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullBtn
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
    // self.fullBtn 宽
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullBtn
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:btnW]];
    // self.fullBtn 高
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.fullBtn
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:btnW]];
    
    // ********************************** self.totalTimeLb **********************************
    // self.totalTimeLb 右边距
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.totalTimeLb
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.fullBtn
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:-5]];
    // self.totalTimeLb centerY
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.totalTimeLb
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
    // self.totalTimeLb 宽
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.totalTimeLb
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:labelW]];
    // self.totalTimeLb 高
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.totalTimeLb
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1
                                                                        constant:0]];
    

    
    // ********************************** self.progressView **********************************
    // self.progressView 左边距
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.playTimeLb
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1
                                                                        constant:10]];
    // self.progressView 右边距
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                       attribute:NSLayoutAttributeRight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.totalTimeLb
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1
                                                                        constant:-10]];
    // self.progressView centerY
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.bottomContentView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1
                                                                        constant:0]];
    // self.progressView 高
    [self.bottomContentView addConstraint:[NSLayoutConstraint constraintWithItem:self.progressView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:0
                                                                        constant:10]];
    
}

#pragma mark: - 初始化默认数据
- (void)setInitData {
    /** 底部容器视图高度 */
    _bottomContentHeight = 50;
    _topContentHeight = 50;
    _isPlay = NO;
    _isShowControlView = YES;
    _isAnimating = NO;
}


#pragma mark: - 懒加载属性
- (UIView *)bottomContentView {
    if (!_bottomContentView) {
        _bottomContentView = [[UIView alloc] init];
        _bottomContentView.backgroundColor = [UIColor clearColor];
    }
    return _bottomContentView;
}
- (UIView *)topContentView {
    if (!_topContentView) {
        _topContentView = [[UIView alloc] init];
        _topContentView.backgroundColor = [UIColor redColor];
    }
    return _topContentView;
}

- (UIButton *)largePlayBtn {
    if (!_largePlayBtn) {
        _largePlayBtn = [[UIButton alloc] init];
        [_largePlayBtn setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_largePlayBtn setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        [_largePlayBtn addTarget:self action:@selector(clickPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _largePlayBtn;
}



- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
//        _playBtn.backgroundColor = [UIColor redColor];
        // [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"play_2" ofType:@"png"]]
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"play_2"] forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"pause_2"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(clickPlayBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)fullBtn {
    if (!_fullBtn) {
        _fullBtn = [[UIButton alloc] init];
        [_fullBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"full" ofType:@"png"]] forState:UIControlStateNormal];
        [_fullBtn setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"unfull" ofType:@"png"]] forState:UIControlStateSelected];
        [_fullBtn addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullBtn;
}

- (UILabel *)totalTimeLb {
    if (!_totalTimeLb) {
        _totalTimeLb = [[UILabel alloc] init];
        _totalTimeLb.textColor = [UIColor whiteColor];
        _totalTimeLb.text = @"--:--:--";
        _totalTimeLb.textAlignment = NSTextAlignmentCenter;
        // _totalTimeLb.adjustsFontSizeToFitWidth = YES;
        _totalTimeLb.font = [UIFont systemFontOfSize:14];
    }
    return _totalTimeLb;
}

- (UILabel *)playTimeLb {
    if (!_playTimeLb) {
        _playTimeLb = [[UILabel alloc] init];
        _playTimeLb.textColor = [UIColor whiteColor];
        _playTimeLb.text = @"--:--:--";
        _playTimeLb.textAlignment = NSTextAlignmentCenter;
        // _playTimeLb.adjustsFontSizeToFitWidth = YES;
        _playTimeLb.font = [UIFont systemFontOfSize:14];
    }
    return _playTimeLb;
}

- (KYMediaProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[KYMediaProgressView alloc] init];
    }
    return _progressView;
}


#pragma mark: - delloc
- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
