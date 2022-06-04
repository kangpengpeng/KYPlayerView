//
//  KYVolumeView.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/28.
//  Copyright © 2019年 kangpp. All rights reserved.
// AVFoundation.AVFAudio.AVAudioSession

#import "KYVolumeView.h"
#import <MediaPlayer/MPVolumeView.h>
#import <AVFoundation/AVFAudio.h>
#import "KYMediaTools.h"

/** 音量视图默认隐藏延迟时间 */
#define k_HIDDEN_DELAY      2

@interface KYVolumeView()
/** icon图标 */
@property (nonatomic, strong)UIImageView *iconIV;
/** 声音调节视图 */
@property (nonatomic, strong)MPVolumeView *volumeView;
@property (nonatomic, strong)UISlider *volumeSlider;

/** 音量视图方向 */
@property (nonatomic, assign)KYVolumeViewType volumeViewType;
/** 当前音量 */
@property (nonatomic, assign)CGFloat currVolume;
/** 非静音时的图片 */
@property (nonatomic, strong)UIImage *volumeImage;
/** 静音时的图片 */
@property (nonatomic, strong)UIImage *muteVolumeImage;


/** 隐藏动画 block */
@property (nonatomic, copy)dispatch_block_t hideAnimationBlock;
/** 背景透明度 */
@property (nonatomic, assign)CGFloat backgroundAlpha;
///** 背景颜色 */
//@property (nonatomic, strong)UIColor *backgroundColor;
@end

@implementation KYVolumeView {
}

#pragma mark: - 外部暴露方法
// 设置音量增量
- (void)setIncreaseVolumeValue:(CGFloat)value {
    [self setVolumeValue:[self getVolumeValue] + value];
}
// 设置音量值
- (void)setVolumeValue:(CGFloat)value {
//    [self setHidden:NO];
//    [self setHidden:YES delay:k_HIDDEN_DELAY];
    CGFloat tmpValue = value;
    if (tmpValue > 1) tmpValue = 1;
    if (tmpValue < 0) tmpValue = 0;
    _currVolume = tmpValue;
    // 赋值系统音量slider后，会走到音量监听方法 volumeChanged:
    [self.volumeSlider setValue:tmpValue animated:NO];
    if (_currVolume != 0 && self.iconIV.image != self.volumeImage) self.iconIV.image = self.volumeImage;
    if (_currVolume ==0 && self.iconIV.image != self.muteVolumeImage) self.iconIV.image = self.muteVolumeImage;
    
}
// 获取音量值
- (CGFloat)getVolumeValue {
    return _currVolume;
    // return self.volumeSlider.value;
    // return [[AVAudioSession sharedInstance] outputVolume];
}
// 设置音量图标
- (void)setVolumeIcon:(UIImage *)image {
    _volumeImage = image;
}
// 设置静音时的音量图标
- (void)setMuteVolumeIcon:(UIImage *)muteVolumeImage {
    _muteVolumeImage = muteVolumeImage;
}
// 设置音量图标
- (void)setVolumeIcon:(UIImage *)image muteVolumeIcon:(UIImage *)muteVolumeImage {
    _volumeImage = image;
    _muteVolumeImage = muteVolumeImage;
}
// 设置视图类型（横向 or 纵向）
- (void)setVolumeViewType:(KYVolumeViewType)viewType {
    if (_volumeViewType == viewType) {
        return;
    }
    _volumeViewType = viewType;
    [self removeConstraints:self.constraints];
    [self setupSubviews];
}


- (void)setHidden:(BOOL)hidden delay:(CGFloat)delay {
    if (hidden == NO) {
        if (_hideAnimationBlock) dispatch_block_cancel(_hideAnimationBlock);
        [self setHidden:hidden];
        return;
    }
    if (_hideAnimationBlock) dispatch_block_cancel(_hideAnimationBlock);
    __weak typeof(self) weakSelf = self;
    _hideAnimationBlock = dispatch_block_create(0, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf setHidden:hidden];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay*NSEC_PER_SEC), dispatch_get_main_queue(), _hideAnimationBlock);
}

#pragma mark: - 重写父类方法
- (void)setHidden:(BOOL)hidden {
    if (_hideAnimationBlock) dispatch_block_cancel(_hideAnimationBlock);
    [super setHidden:hidden];
}

#pragma mark: 初始化
- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认位置
        //self.frame = CGRectMake(0, 0, 30, 150);
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        [self setupSubviews];
        [self addNotify];
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)initData {

    // 默认纵向
    self.volumeViewType = KYVolumeTypeVertical;
    // 默认背景颜色
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    // 获取系统音量，在没有赋值之前，不能使用 volumeSlider.value 获取该值，不准确
    self.currVolume = [[AVAudioSession sharedInstance] outputVolume];
    [self.volumeSlider setValue:self.currVolume];
    // NSLog(@"currVolume == %f", self.currVolume);
    if (self.currVolume > 0) {
        self.iconIV.image = self.volumeImage;
    } else {
        self.iconIV.image = self.muteVolumeImage;
    }
    
}

#pragma mark: - 通知
- (void)addNotify {
    // AVSystemController_SystemVolumeDidChangeNotification  AVSystemController_AudioVolumeNotificationParameter
    // 音量通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                               object:nil];
    // 音频输出设备变更
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(outputDeviceChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
}
// 音量改变通知响应方法
- (void)volumeChanged:(NSNotification *)notification {
    // 音量改变原因
    // RouteChange 前后台切换，以及初次点击播放时
    // ExplicitVolumeChange
    NSString *changeReason = [[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    // 铃声改变 Ringtone
    // 播放音视频时改变音量 Audio/Video
    NSString *type = [[notification userInfo] objectForKey:@"AVSystemController_AudioCategoryNotificationParameter"];
    if ([@"ExplicitVolumeChange" isEqualToString:changeReason] && [@"Audio/Video" isEqualToString:type]) {
        [self setHidden:NO];
        [self setHidden:YES delay:k_HIDDEN_DELAY];
        float volume = [[[notification userInfo] objectForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        self.currVolume = volume;
        [self setNeedsDisplay];
        if (volume != 0 && self.iconIV.image != self.volumeImage) self.iconIV.image = self.volumeImage;
        if (volume ==0 && self.iconIV.image != self.muteVolumeImage) self.iconIV.image = self.muteVolumeImage;
    }
}
// 音量输出设备改变响应方法（耳机插拔）
- (void)outputDeviceChanged:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    NSInteger routeChangeReason = [[dict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable: {
            NSLog(@"耳机插入");
            if (self.delegate && [self.delegate respondsToSelector:@selector(volumeView:didChangeOutputDevice:)]) {
                [self.delegate volumeView:self didChangeOutputDevice:KYVolumeOutputExternal];
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"耳机拔出");
            if (self.delegate && [self.delegate respondsToSelector:@selector(volumeView:didChangeOutputDevice:)]) {
                [self.delegate volumeView:self didChangeOutputDevice:KYVolumeOutputSystem];
            }
    }
}
- (void)removeNotify {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//获取到当前所在的视图
- (UIViewController *)presentingVC {
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIViewController *result = window.rootViewController;
    while (result.presentedViewController) {
        result = result.presentedViewController;
    }
    if ([result isKindOfClass:[UITabBarController class]]) {
        result = [(UITabBarController *)result selectedViewController];
    }
    if ([result isKindOfClass:[UINavigationController class]]) {
        result = [(UINavigationController *)result topViewController];
    }
    return result;
}
#pragma mark: - 约束子视图
- (void)setupSubviews {
    // 将系统音量视图添加到控制器，否则无法隐藏
    [[KYMediaTools getRootViewController].view addSubview:self.volumeView];
    [self addSubview:self.iconIV];
    self.iconIV.translatesAutoresizingMaskIntoConstraints = NO;
    switch (self.volumeViewType) {
        case KYVolumeTypeVertical:
            [self layout_Vertical];
            break;
        case KYVolumeTypeHorizontal:
            [self layout_Horizontal];
            break;
        default:
            
            break;
    }
}

/** 纵向时的约束 */
- (void)layout_Vertical {
    CGFloat imgW = 20;

    // centerX
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    // bottom
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1
                                                      constant:-10]];
    // width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:imgW]];
    // height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:imgW]];
}
/** 水平方向时的约束 */
- (void)layout_Horizontal {
    CGFloat imgW = 20;
    // centerY
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    // left
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeft
                                                    multiplier:1
                                                      constant:10]];
    // width
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:imgW]];
    // height
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconIV
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1
                                                      constant:imgW]];
}


- (void)drawRect:(CGRect)rect {
    
    CGFloat lineW = 4;
    if (self.volumeViewType == KYVolumeTypeVertical) {
        
         CGFloat x = rect.size.width / 2;
         CGFloat startY = rect.size.height-40;
         CGFloat endY = 10;
         // 距离底边距40，上边距10
         CGFloat lineLength = startY - endY;
         CGPoint startP = CGPointMake(x, startY);
         
         UIBezierPath *bgPath = [[UIBezierPath alloc] init];
         [bgPath moveToPoint:startP];
         [bgPath addLineToPoint:CGPointMake(x, endY)];
         bgPath.lineWidth = lineW;
         [[UIColor colorWithWhite:0.3 alpha:1] setStroke];
         [bgPath stroke];
         
         UIBezierPath *brightPath = [UIBezierPath bezierPath];
         [brightPath moveToPoint:startP];
         [brightPath addLineToPoint:CGPointMake(x, startY - lineLength*self.currVolume)];
         brightPath.lineWidth = lineW;
         //[[UIColor colorWithRed:237/255.0 green:105/255.0 blue:57/255.0 alpha:1] setStroke];
         [[UIColor whiteColor] setStroke];
         [brightPath stroke];
         
        /*
        CGFloat x = rect.size.width / 2;
        CGFloat bottomY = rect.size.height-40;
        CGFloat topY = 10;
        CGFloat lineLength = fabs(bottomY - topY);
        CGFloat midY = bottomY - lineLength * self.currVolume;

        UIBezierPath *brightPath = [UIBezierPath bezierPath];
        [brightPath moveToPoint:CGPointMake(x, bottomY)];
        [brightPath addLineToPoint:CGPointMake(x, midY)];
        brightPath.lineWidth = lineW;
        //[[UIColor colorWithRed:237/255.0 green:105/255.0 blue:57/255.0 alpha:1] setStroke];
        [[UIColor whiteColor] setStroke];
        [brightPath stroke];

        UIBezierPath *bgPath = [[UIBezierPath alloc] init];
        [bgPath moveToPoint:CGPointMake(x, midY)];
        [bgPath addLineToPoint:CGPointMake(x, topY)];
        bgPath.lineWidth = lineW;
        [[UIColor colorWithWhite:0.3 alpha:1] setStroke];
        [bgPath stroke];
         */
    }
    else {
        //            NSLog(@"KYVolumeTypeHorizontal");
        //            CGFloat y = rect.size.height / 2;
        //            CGFloat startX = 40;
        //            CGFloat endX = rect.size.width - 10;
        //            CGFloat lineLength = endX - startX;
        //            CGPoint startP = CGPointMake(startX, y);
        //            UIBezierPath *bgPath = [[UIBezierPath alloc] init];
        //            [bgPath moveToPoint:startP];
        //            [bgPath addLineToPoint:CGPointMake(endX, y)];
        //            bgPath.lineWidth = lineW;
        //            [[UIColor colorWithWhite:0.3 alpha:1] setStroke];
        //            [bgPath stroke];
        //
        //            UIBezierPath *brightPath = [UIBezierPath bezierPath];
        //            [brightPath moveToPoint:startP];
        //            [brightPath addLineToPoint:CGPointMake(startX + lineLength*self.currVolume, y)];
        //            brightPath.lineWidth = lineW;
        //            //[[UIColor colorWithRed:237/255.0 green:105/255.0 blue:57/255.0 alpha:1] setStroke];
        //            [[UIColor whiteColor] setStroke];
        //            [brightPath stroke];
                    
        CGFloat y = rect.size.height / 2;
        CGFloat leftX = 40;
        CGFloat rightX = rect.size.width - 10;
        CGFloat lineLength = fabs(rightX - leftX);
        CGFloat midX = leftX + lineLength * self.currVolume;

        UIBezierPath *brightPath = [UIBezierPath bezierPath];
        [brightPath moveToPoint:CGPointMake(leftX, y)];
        [brightPath addLineToPoint:CGPointMake(midX, y)];
        brightPath.lineWidth = lineW;
        //[[UIColor colorWithRed:237/255.0 green:105/255.0 blue:57/255.0 alpha:1] setStroke];
        [[UIColor whiteColor] setStroke];
        [brightPath stroke];

        UIBezierPath *bgPath = [[UIBezierPath alloc] init];
        [bgPath moveToPoint:CGPointMake(midX, y)];
        [bgPath addLineToPoint:CGPointMake(rightX, y)];
        bgPath.lineWidth = lineW;
        [[UIColor colorWithWhite:0.3 alpha:1] setStroke];
        [bgPath stroke];
    }
}


#pragma mark: - 属性
- (UIImage *)volumeImage {
    if (!_volumeImage) {
        _volumeImage = [KYMediaTools getBundleImage:@"volume@2x.png"];
    }
    return _volumeImage;
}
- (UIImage *)muteVolumeImage {
    if (!_muteVolumeImage) {
        _muteVolumeImage = [KYMediaTools getBundleImage:@"unvolume@2x.png"];
    }
    return _muteVolumeImage;
}

- (UIImageView *)iconIV {
    if (!_iconIV) {
        _iconIV = [[UIImageView alloc] init];
    }
    return _iconIV;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc]init];
        _volumeView.showsRouteButton = NO;
        //默认YES
        _volumeView.showsVolumeSlider = YES;
        [_volumeView sizeToFit];
        // CGRectMake(-10000, -10000, 0, 0)
        [_volumeView setFrame:CGRectMake(-10000, -10000, 0, 0)];
        // [self addSubview:_volumeView];
        [_volumeView userActivity];
        __weak typeof(self) weakSelf = self;
        [[_volumeView subviews] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UISlider class]]) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.volumeSlider = obj;
                *stop = YES;
            }
        }];
        CGFloat tmp = self.volumeSlider.value;
        [self.volumeSlider setValue:tmp animated:NO];
    }
    return _volumeView;
}


#pragma mark: - dealloc
- (void)dealloc {
    [self removeNotify];
    //NSLog(@"%s", __func__);
}

@end
