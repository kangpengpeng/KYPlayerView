//
//  KYPlayerView.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/10/23.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYPlayerView.h"
#import "KYMediaControlView.h"
#import "KYMediaTools.h"
#import "KYFastView.h"
#import "KYBrightnessView.h"
#import "KYVolumeView.h"
#import "KYPlayer.h"

/** hidden 延迟时间 */
#define k_HIDDEN_DELAY       2

@interface KYPlayerView() <KYPlayerDelegate, KYMediaControlViewProtocol, KYVolumeViewDelegate>
/** 播放地址 */
@property (nonatomic, strong)NSURL *videoURL;

/** 显示视频的播放层 （AVPlayer本身并不显示视频）*/
@property (nonatomic, strong)AVPlayerLayer  *playerLayer;

/** 播放控制视图 */
@property (nonatomic, strong)KYMediaControlView *contolView;

/** 自定义player */
@property (nonatomic, strong)KYPlayer *myPlayer;

/** 快进显示视图 */
@property (nonatomic, strong)KYFastView *fastView;
/** 亮度调节视图 */
@property (nonatomic, strong)KYBrightnessView *brightSliderView;
/** 自定义显示音量视图 */
@property (nonatomic, strong)KYVolumeView *volumeSliderView;
/** 加载提示的小菊花 */
@property (nonatomic, strong)UIActivityIndicatorView *indicatorView;
@end

@implementation KYPlayerView {
    CGRect _orgFrame;
    CGFloat _totalTime;
    CGFloat _currentTime;
    BOOL _isEnableControlVolume;
    BOOL _isEnableControlBrightness;
    BOOL _isEnableControlFast;
    AVLayerVideoGravity _videoGravity;
    /// 记录系统导航栏初始状态，待全屏切回非全屏状态时恢复
    BOOL _naviBarState; // 记录系统导航栏是否隐藏
    BOOL _isShowGoback; // 记录是否显示返回按钮
    BOOL _isFullScreen; // 记录是否为全屏显示
}

#pragma mark: - 外部调用方法
/** 设置播放URL */
- (void)setURL:(NSURL *)url {
    [self setPlayerWithURL:url];
}

- (void)setURLWithString:(NSString *)urlString {
    if (urlString.length == 0) {
        NSLog(@"URLString为空");
        if (self.delegate && [self.delegate respondsToSelector:@selector(ky_playerView:updateStatus:)]) {
            [self.delegate ky_playerView:self updateStatus:KYPlayerStatusFailed];
        }
        return;
    }
    NSURL *url;
    // 判断是本地视频还是网络视频
    if ([urlString hasPrefix:@"http"]) {
        url = [NSURL URLWithString:urlString];
    } else {
        url = [NSURL fileURLWithPath:urlString];
    }
    [self setPlayerWithURL:url];
}

- (void)setPlayerWithURL:(NSURL *)url {
    [self showLoading];
    _videoURL = url;
    self.playerLayer = [self.myPlayer ky_playerLayerWithURL:url];
    self.myPlayer.delegate = self;
    self.playerLayer.frame = self.bounds;
    self.playerLayer.videoGravity = _videoGravity;
    [self.layer addSublayer:self.playerLayer];
    // 将播放按钮前置
    [self bringSubviewToFront:self.contolView];
}
- (void)setMediaTitle:(NSString *)text {
    [self.contolView setTitle:text];
}

/** 设置视频填充方式 */
- (void)setVideoGravity:(AVLayerVideoGravity)videoGravity {
    /*
     AVLayerVideoGravityResizeAspect        // 默认值，原始画面全显示
     AVLayerVideoGravityResizeAspectFill    // 等比拉伸填满
     AVLayerVideoGravityResize              // 拉伸填满，会变形
     */
    _videoGravity = videoGravity;
    if (_playerLayer) {
        _playerLayer.videoGravity = videoGravity;
    }
}
/** 是否显示中间大的播放/暂停按钮（默认不显示） */
- (void)setEnableShowCenterPlayButton:(BOOL)isEnable {
    [self.contolView setEnableShowCenterPlayButton:isEnable];
}
/** 是否开启亮度调节 */
- (void)setEnableControlBrightness:(BOOL)isEnable {
    _isEnableControlBrightness = isEnable;
}
/** 是否开启音量调节 */
- (void)setEnableControlVolume:(BOOL)isEnable {
    _isEnableControlVolume = isEnable;
}
/** 是否允许快进 */
- (void)setEnableControlFast:(BOOL)isEnable {
    _isEnableControlFast = isEnable;
    [self.contolView setEnableSlipSlider:isEnable];
}
/** 是否允许显示顶部视图 */
- (void)setEnableShowTopView:(BOOL)isEnable {
    [self.contolView setEnableShowTopView:isEnable];
}
/** 是否显示返回按钮，默认显示 */
- (void)setGobackShow:(BOOL)isShow {
    _isShowGoback = isShow;
    [self.contolView setGobackHidden:!isShow];
}

/** 播放 */
- (void)play {
    [self.contolView setPlayResumeUI];
    [self.myPlayer ky_play];
}
/** 暂停 */
- (void)pause {
    [self.contolView setPlayPauseUI];
    [self.myPlayer ky_pause];
}
/** 停止播放 */
- (void)stop {
    [self.contolView setPlayEndUI];
    [self.myPlayer ky_stop];
}

/** 获取播放的URL */
- (NSString *)getURLString {
    return self.videoURL.absoluteString;
}


#pragma mark -: HUD 提示
- (void)showLoading {
    [self.indicatorView setHidden:NO];
    [self.indicatorView startAnimating];
}
- (void)hideLoading {
    [self.indicatorView setHidden:YES];
    [self.indicatorView stopAnimating];
}

#pragma mark -: 初始化数据
- (instancetype)init {
    self = [super init];
    if (self) {
        NSAssert(NO, @"请使用 initWithFrame: 初始化播放器");
    }
    return self;
}
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        [self addObservers];
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        _orgFrame = frame;
        [self setupSubviews];
    }
    return self;
}
- (void)initData {
    _totalTime = 0;
    _currentTime = 0;
    _isEnableControlFast = YES;
    _isEnableControlVolume = YES;
    _isEnableControlBrightness = YES;
    _isShowGoback = YES;
    _isFullScreen = NO;
    _videoGravity = AVLayerVideoGravityResizeAspect;
    _naviBarState = [KYMediaTools getNavigationControllerFromView:self].navigationBar.isHidden;
}
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft || deviceOrientation == UIDeviceOrientationLandscapeRight) {
        //NSLog(@"监听到横屏");
        [self setScreenFull];
    }
    else if (deviceOrientation == UIDeviceOrientationPortrait) {
        //NSLog(@"监听到竖屏 1");
        [self setUnScreenFull];
    }
    else {
        // 其它屏幕状态不予处理
    }
}
- (void)setupSubviews {
    // 设置控制播放视图
    self.contolView.frame = self.bounds;
    [self addSubview:self.contolView];
    // 快进视图
    [self.contolView addSubview:self.fastView];
    // 亮度视图
    [self.contolView addSubview:self.brightSliderView];
    // 音量调节视图，应该在视频准备就绪，播放的时候添加
    [self.volumeSliderView setHidden:YES];
    //self.volumeSliderView.backgroundColor = [UIColor redColor];
    [self.contolView addSubview:self.volumeSliderView];
    
    // 加载提示小菊花
    self.indicatorView.frame = CGRectMake(50, 50, 50, 50);
    self.indicatorView.center = self.contolView.center;
    [self.contolView addSubview:_indicatorView];
    
}
#pragma mark: - KYPlayerDelegate
- (void)ky_player:(KYPlayer *)player updateStatus:(KYPlayerStatus)status {
    switch (status) {
        case KYPlayerStatusUnknown:
            //NSLog(@"*** KYPlayerStatusUnknown");
            [self hideLoading];
            break;
            
        case KYPlayerStatusReadyToPlay:
            //NSLog(@"*** KYPlayerStatusReadyToPlay");
            [self hideLoading];
            break;
            
        case KYPlayerStatusFailed:
            //NSLog(@"*** KYPlayerStatusFailed");
            [self hideLoading];
            break;
        case KYPlayerStatusPlaying:
            //NSLog(@"*** KYPlayerStatusPlaying");
            [self hideLoading];
            break;
            
        case KYPlayerStatusBufferEmpty:
            //NSLog(@"*** KYPlayerStatusBufferEmpty");
            [self showLoading];
            break;
            
        case KYPlayerStatusKeepUp:
            //NSLog(@"*** KYPlayerStatusKeepUp");
            [self hideLoading];
            break;
            
        case KYPlayerStatusPause:
            //NSLog(@"*** KYPlayerStatusPause");
            break;
            
        case KYPlayerStatusStop:
            //NSLog(@"*** KYPlayerStatusStop");
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_playerView:updateStatus:)]) {
        [self.delegate ky_playerView:self updateStatus:status];
    }
}

- (void)ky_player:(KYPlayer *)player currentPlayingTime:(CGFloat)playTime totalTime:(CGFloat)totalTime {
    _totalTime = totalTime < 0 ? 0 : totalTime;
    _currentTime = playTime < 0 ? 0 : playTime;
    CGFloat progress = _totalTime == 0 ? 0 : _currentTime/_totalTime;
    [self.contolView setTotalTime:[KYMediaTools getFormatTimeString:_totalTime]];
    [self.contolView setPlayTime:[KYMediaTools getFormatTimeString:_currentTime]];
    [self.contolView setPlayProgress:progress];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_playerView:currentPlayingTime:totalTime:)]) {
        [self.delegate ky_playerView:self currentPlayingTime:_currentTime totalTime:_totalTime];
    }
}

- (void)ky_player:(KYPlayer *)player didCacheProgress:(CGFloat)progress {
    [self.contolView setCacheProgress:progress];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_playerView:didCacheProgress:)]) {
        [self.delegate ky_playerView:self didCacheProgress:progress];
    }
}

- (void)ky_player:(KYPlayer *)player didPlayEnd:(BOOL)isEnd {
    if (isEnd) {
        //NSLog(@"didPlayEnd");
        [self.contolView setPlayEndUI];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_playerView:didPlayEnd:)]) {
        [self.delegate ky_playerView:self didPlayEnd:isEnd];
    }
}

#pragma mark: - KYVolumeViewDelegate
- (void)volumeView:(KYVolumeView *)volumeView didChangeOutputDevice:(KYVolumeOutputWay)volumeOutputWay {
    switch (volumeOutputWay) {
        // 耳机插入暂停
        case KYVolumeOutputExternal:
            // 插入不做暂停处理
            break;
        // 二级拔出
        case KYVolumeOutputSystem:
            [self pause];
            break;
        // 其它情况暂不做处理...
        case KYVolumeOutputUnknown:
            break;
        default:
            break;
    }
}

#pragma mark: - KYMediaContorlViewDelegate
- (void)mediaControl:(KYMediaControlView *)mediaControl isSetPlay:(BOOL)isPlay {
    if (isPlay) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)mediaControl:(KYMediaControlView *)mediaControl isSetFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        //NSLog(@"全屏");
        [KYPlayerView switchNewOrientation:UIInterfaceOrientationLandscapeRight];
        [self setScreenFull];
    } else {
        //NSLog(@"非全屏");
        [KYPlayerView switchNewOrientation:UIInterfaceOrientationPortrait];
        [self setUnScreenFull];
    }
}

- (void)mediaControl:(KYMediaControlView *)mediaControl isSlidingProgress:(float)progress {
    // 待添加业务方法
}
- (void)mediaControl:(KYMediaControlView *)mediaControl endSlidProgress:(float)progress {
    [self.myPlayer ky_playerSeek2Time:_totalTime * progress];
    [self.contolView setPlayTime:[KYMediaTools getFormatTimeString:_totalTime*progress]];
}

- (void)mediaControl:(KYMediaControlView *)mediaControl gestureLocation:(KYMediaGestureLocation)location gestureStatus:(KYMediaGestureState)gestureState slidDistance:(float)distance {
    switch (location) {
        // 快进手势
        case KYMediaGestureScreenHorizontal: {
            if (_isEnableControlFast == NO) return;
            static CGFloat tmpCurrent = 0;
            static CGFloat fastTime = 0;
            if (gestureState == KYMediaGestureStateBegan) {
                tmpCurrent = _currentTime;
                [self.fastView setHidden:NO];
                // 隐藏其它指示视图（亮度、声音）
                [self.volumeSliderView setHidden:YES];
                [self.brightSliderView setHidden:YES];
            } else if (gestureState == KYMediaGestureStateChange) {
                // 设置阀值，视频长度大于 500 时，以 500 为快进阀值（最多一次快进500s），否则以视频长度为阀值
                float flag = _totalTime < 500 ? _totalTime : 500;
                fastTime = distance/self.frame.size.width*flag;
                NSString *symbol = @"+";
                // 判断快进 or 快退
                if (fastTime<0) {
                    symbol = @"-";
                }
                // 快退 or 快进 超出视频长度播放范围，不更新视图return
                CGFloat targetCurrTime = _currentTime + fastTime;
                if (targetCurrTime < 0) {
                    // 回退到起点位置
                    fastTime = -_currentTime;
                    targetCurrTime = 0;
                }
                if (targetCurrTime > _totalTime) {
                    // 快进至视频结尾
                    fastTime = _totalTime - _currentTime;
                    targetCurrTime = _totalTime;
                }
                // 快进增加的 text
                NSString *fastText = [NSString stringWithFormat:@"%@ %@",  symbol, [KYMediaTools getFormatTimeString:fabs(fastTime)]];
                // 快进到指定进度的值 0~1
                CGFloat progress = targetCurrTime/_totalTime;
                // 快进至的播放位置
                NSString *targetFastText = [KYMediaTools getFormatTimeString:targetCurrTime];
                
                [self.fastView setFastTime:fastText];
                [self.fastView setFastProgress:progress];
                [self.fastView setFastTime:targetFastText totalTime:[KYMediaTools getFormatTimeString:_totalTime]];
            } else if (gestureState == KYMediaGestureStateEnd) {
                CGFloat fast2Time = fastTime + tmpCurrent;
                [self.myPlayer ky_playerSeek2Time:fast2Time];
                [self.fastView setHidden:YES];
                [self.contolView setPlayProgress:fast2Time/_totalTime];
            }
            
            break;
        }
        // 亮度调节手势
        case KYMediaGestureLeftVertical: {
            if (_isEnableControlBrightness == NO) return;
            static CGFloat brightness = 0;
            if (gestureState == KYMediaGestureStateBegan) {
                brightness = [UIScreen mainScreen].brightness;
                [self.brightSliderView setHidden:NO];
                // 隐藏其它指示视图（快进、声音）
                [self.volumeSliderView setHidden:YES];
                [self.fastView setHidden:YES];
            } else if (gestureState == KYMediaGestureStateChange) {
                float changeValue = - distance / (self.frame.size.height/3);
                float targetBrightness = brightness + changeValue;
                if (targetBrightness < 0) targetBrightness = 0;
                if (targetBrightness > 1) targetBrightness = 1;
                [self.brightSliderView setSliderValue:targetBrightness];
                [[UIScreen mainScreen] setBrightness:targetBrightness];
            } else if (gestureState == KYMediaGestureStateEnd) {
                [self.brightSliderView setHidden:YES delay:k_HIDDEN_DELAY];
            }
            break;
        }
        // 音量调节手势
        case KYMediaGestureRightVertical:{
            if (_isEnableControlVolume == NO) return;
            static CGFloat startVolume = 0;
            if (gestureState == KYMediaGestureStateBegan) {
                startVolume = [self.volumeSliderView getVolumeValue];
                // 记录起始音量
                [self.volumeSliderView setHidden:NO];
                // 隐藏其它视图（快进、亮度）
                [self.fastView setHidden:YES];
                [self.brightSliderView setHidden:YES];
            } else if (gestureState == KYMediaGestureStateChange) {
                // 计算音量的增量
                float changeValue = - distance / (self.frame.size.height/2);
                [self.volumeSliderView setVolumeValue:startVolume + changeValue];
            } else if (gestureState == KYMediaGestureStateEnd) {
                [self.volumeSliderView setHidden:YES delay:k_HIDDEN_DELAY];
            }
            break;
        }
        default:
            break;
    }
}
- (void)mediaControl:(KYMediaControlView *)mediaControl gobackAction:(UIButton *)gobackButton {
    // 全屏显示，则
    if (_isFullScreen) {
        [KYPlayerView switchNewOrientation:UIInterfaceOrientationPortrait];
        [self setUnScreenFull];
        return;
    }
    UIViewController *currController = [KYMediaTools getCurrentViewController];
    if (currController.presentingViewController) {
        [currController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [currController.navigationController popViewControllerAnimated:YES];
}





#pragma mark: - 横竖屏切换
/** 设置屏幕旋转方向 */
+ (void)switchNewOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    //    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:(int)interfaceOrientation];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
}
- (void)setScreenFull {
    UINavigationController *nvc = [KYMediaTools getNavigationControllerFromView:self];
    [nvc.navigationBar setHidden:YES];
    CGRect fullScreenFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.contolView setGobackHidden:NO];
    self.frame = fullScreenFrame;
    self.contolView.frame = fullScreenFrame;
    self.contolView.screenFullLayout = YES;
    self.playerLayer.frame = self.bounds;
    self.fastView.center = self.contolView.center;
    self.brightSliderView.frame = [self getBrightSliderViewFrame];
    self.volumeSliderView.frame = [self getVolumeSliderViewFrame];
    [self.volumeSliderView setHidden:YES delay:0];
    [self.contolView setNeedsLayout];
    [self.contolView layoutIfNeeded];
}

- (void)setUnScreenFull {
    UINavigationController *nvc = [KYMediaTools getNavigationControllerFromView:self];
    [nvc.navigationBar setHidden:_naviBarState];
    self.frame = _orgFrame;
    [self.contolView setGobackHidden:!_isShowGoback];
    // 坐标如果不更新，子视图会有问题
    self.contolView.frame = self.bounds;
    self.contolView.screenFullLayout = NO;
    self.playerLayer.frame = self.bounds;
    self.fastView.center = self.contolView.center;
    self.brightSliderView.frame = [self getBrightSliderViewFrame];
    self.volumeSliderView.frame = [self getVolumeSliderViewFrame];
    [self.volumeSliderView setHidden:YES delay:0];
    [self.contolView setNeedsLayout];
}

#pragma mark: - 私有方法
/** 获取亮度调节视图坐标 */
- (CGRect)getBrightSliderViewFrame {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    BOOL isScreenFull = screenSize.width > screenSize.height;
    CGFloat bvW = 40;
    // TODO: 高度应该根据手机旋转进行调整
    //CGFloat bvH = self.frame.size.height / 2;
    CGFloat bvH = _orgFrame.size.height / 2;
    CGFloat bvX = isScreenFull ? 80 : 30;
    CGFloat bvY = (self.frame.size.height-bvH)/2;
    return CGRectMake(bvX, bvY, bvW, bvH);
}
- (CGRect)getVolumeSliderViewFrame {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    BOOL isScreenFull = screenSize.width > screenSize.height;
    CGFloat bvW = 40;
    // TODO: 高度应该根据手机旋转进行调整，但是声音这块有bug，暂行用固定值
#warning 高度应该根据手机旋转进行调整，但是声音这块调整高度后，draw 绘制有问题，
    //CGFloat bvH = self.frame.size.height / 2;
    CGFloat bvH = _orgFrame.size.height / 2;
    CGFloat bvX = self.frame.size.width - bvW - (isScreenFull ? 80 : 30);
    CGFloat bvY = (self.frame.size.height-bvH)/2;
    return CGRectMake(bvX, bvY, bvW, bvH);
}

#pragma mark: - 懒加载属性
- (KYMediaControlView *)contolView {
    if (!_contolView) {
        _contolView = [[KYMediaControlView alloc] init];
        _contolView.contorlDelegate = self;
    }
    return _contolView;
}

- (KYPlayer *)myPlayer {
    if (!_myPlayer) {
        _myPlayer = [KYPlayer sharedInstance];
    }
    return _myPlayer;
}

- (KYFastView *)fastView {
    if (!_fastView) {
        _fastView = [[KYFastView alloc] initWithFrame:CGRectMake(0, 0, 150, 80)];
        _fastView.center = self.contolView.center;
        [_fastView setFastTime:@"+00:00:00"];
        [_fastView setFastTime:@"00:00:00" totalTime:@"00:00:00"];
        [_fastView setHidden:YES];
    }
    return _fastView;
}

- (KYBrightnessView *)brightSliderView {
    if (!_brightSliderView) {
        _brightSliderView = [[KYBrightnessView alloc] initWithFrame:[self getBrightSliderViewFrame]];
        [_brightSliderView setIconImage:[KYMediaTools getBundleImage:@"liangdu@2x.png"]];
        [_brightSliderView setHidden:YES];
    }
    return _brightSliderView;
}

- (KYVolumeView *)volumeSliderView {
    if (!_volumeSliderView) {
        _volumeSliderView = [[KYVolumeView alloc] initWithFrame:[self getVolumeSliderViewFrame]];
        [_volumeSliderView setHidden:YES];
        _volumeSliderView.delegate = self;
    }
    return _volumeSliderView;
}
- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.layer.cornerRadius = 6;
        _indicatorView.clipsToBounds = YES;
        _indicatorView.backgroundColor = [UIColor blackColor];
        //设置小菊花颜色
        _indicatorView.color = [UIColor whiteColor];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return _indicatorView;
}

#pragma mark: - delloc
- (void)dealloc {
    //NSLog(@"%s", __func__);
    [self removeObservers];
}

@end
