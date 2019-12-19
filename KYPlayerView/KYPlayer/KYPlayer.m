//
//  KYPlayer.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/20.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYPlayer.h"


static KYPlayer *_sharedPlayer = nil;

@interface KYPlayer()
/** 媒体播放控制 */
@property (nonatomic, strong)AVPlayer *player;
/** 媒体播放显示层 */
@property (nonatomic, strong)AVPlayerLayer *playerLayer;
/** 媒体信息 */
@property (nonatomic, strong)AVPlayerItem *playerItem;

/** 视频播放时的观察 */
@property (nonatomic,strong) id timeObserverToken;

/** 是否正在播放 */
@property (nonatomic, assign)BOOL isPlaying;
/** 播放器当前状态（默认 KYPlayerStatusUnknown）*/
@property (nonatomic, assign)KYPlayerStatus playerStatus;
/** 视频总长度 */
@property (nonatomic, assign)CGFloat totalTime;
/** 当前播放时间 */
@property (nonatomic, assign)CGFloat currentTime;

/** 标记正在跳转（解决外部滑块调用快进时，进度条跳闪问题）*/
@property (nonatomic, assign)BOOL isSeeking;

@end

@implementation KYPlayer

#pragma mark -: KYPlayerManager 单例
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer =[[self alloc] init];
    });
    return _sharedPlayer;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer = [super allocWithZone:zone];
    });
    return _sharedPlayer;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedPlayer;
}

/** 是否播放资源 */
- (void)releasePlayer {
    self.totalTime = 0;
    self.currentTime = 0;
    [self removeNotifyAndKVO];
    self.timeObserverToken = nil;
    self.playerItem = nil;
    self.player = nil;
    self.isPlaying = NO;
    self.playerStatus = KYPlayerStatusUnknown;
}

- (void)dealloc {
    [self releasePlayer];
    NSLog(@"%s", __func__);
}


#pragma mark -: 获取播放层 playerLayer
/** 播放前准备 */
- (void)prepareBeforePlay {
    self.totalTime = 0;
    self.currentTime = 0;
    [self ky_pause];
    [self releasePlayer];
}
- (AVPlayerLayer *)ky_playerLayerWithURL:(NSURL *)url {
    // 初始化时设置状态
    [self setPlayerStatus:KYPlayerStatusUnknown];
    [self prepareBeforePlay];
    

    // 请求代理
//    self.resourceLoader = [[KYMediaURLSession alloc] init];
//    NSURL *playURL = [self.resourceLoader getSchemeVideoURL:url];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
//    [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];

    //判断
    if(!self.playerItem){
         NSAssert(NO, @"AVPlayerplayerItem (_playerItem) 创建失败");
        [self setPlayerStatus:KYPlayerStatusFailed];
        return nil;
    }
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    } else {
        self.player = [[AVPlayer alloc] initWithPlayerItem:_playerItem];
    }
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    // AVLayerVideoGravityResizeAspectFill AVLayerVideoGravityResizeAspect
//     _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:nil];
    [self addNotifyAndKVO];
    return self.playerLayer;
}


/** 播放 */
- (void)ky_play {
    if (self.playerItem == nil) return;
    [self.player play];
    self.isPlaying = YES;
    self.playerStatus = KYPlayerStatusPlaying;
}
/** 暂停 */
- (void)ky_pause {
    if (self.playerItem == nil) return;
    [self.player pause];
    self.isPlaying = NO;
    self.playerStatus = KYPlayerStatusPause;
}
/** 停止播放 */
- (void)ky_stop {
    [self ky_pause];
    [self releasePlayer];
    self.isPlaying = NO;
    self.playerStatus = KYPlayerStatusStop;
}
/** 跳转到指定播放位置（无需回调）*/
- (void)ky_playerSeek2Time:(CGFloat)time {
    [self ky_playerSeek2Time:time completionHandler:^(BOOL finished) {}];
}
/** 跳转到指定播放位置（需要回调）*/
- (void)ky_playerSeek2Time:(CGFloat)time completionHandler:(void (^)(BOOL))completionHandler {
    _isSeeking = YES;
    CGFloat seekTime = time;
    if (seekTime >= self.totalTime) {
        seekTime -= 3;
    }
    __weak typeof(self) weakSelf = self;
    [_player seekToTime:CMTimeMakeWithSeconds(seekTime, NSEC_PER_SEC) toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
#warning 此处 finished 待确定
        strongSelf.isSeeking = NO;
        [strongSelf updateCurrentPlayTime:seekTime totalTime:strongSelf.totalTime];
        completionHandler(finished);
    }];
}
/** 快进到指定播放进度（无需回调） */
- (void)ky_playerSeek2Progress:(CGFloat)progress {
    [self ky_playerSeek2Progress:progress completionHandler:^(BOOL finished) {}];
}
/** 快进到指定播放进度 （需要回调）*/
- (void)ky_playerSeek2Progress:(CGFloat)progress completionHandler:(void (^)(BOOL))completionHandler {
    if (self.totalTime == 0 || progress > 1.0) return;
    CGFloat seekTime = progress * self.totalTime;
    if (seekTime>=self.totalTime) {
        seekTime -= 3;
    }
    [self ky_playerSeek2Time:seekTime completionHandler:completionHandler];
}

- (KYPlayerStatus)ky_getPlayerStatus {
    return _playerStatus;
}


#pragma mark: - 通知和监听
- (void)removeNotifyAndKVO {
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 移除KVO
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferFull"];
    // 移除播放监听
    if (_timeObserverToken) {
        [_player pause];
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }

}

- (void)addNotifyAndKVO {
    // 监听应用从后台、前台的相互切换
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterPlayGround)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    // 监听视频播放完毕
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaDidPlayEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    // 注册观察者，监测播放器属性
    // 观察Status属性，可以在加载成功之后得到视频的长度
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 观察loadedTimeRanges，可以获取缓存进度，实现缓冲进度条
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
}


/** 进入后台 */
- (void)appDidEnterBackground{
    if (self.isPlaying == NO) return;
}
/** 从后台返回前台 */
- (void)appDidEnterPlayGround{
    if (self.isPlaying == NO) return;
    [self ky_play];
}
/** 视频播放结束通知方法 */
- (void)mediaDidPlayEnd:(NSNotification *)notify {
//    NSLog(@"播放结束");
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_player:didPlayEnd:)]) {
        [self.delegate ky_player:self didPlayEnd:YES];
    }
}
// 添加属性观察
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        //获取playerItem的status属性最新的状态
        AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
        switch (status) {
            case AVPlayerStatusReadyToPlay:{
                //获取视频长度
                CMTime duration = playerItem.duration;
                self.totalTime = CMTimeGetSeconds(duration);
                // 添加播放时间监听
                [self addPeriodicTimeObserver];
                // 更新播放器状态
                [self setPlayerStatus:KYPlayerStatusReadyToPlay];
                // 更新播放进度
                [self updateCurrentPlayTime:self.currentTime totalTime:self.totalTime];
                
                //开启滑块的滑动功能
                
                //关闭加载Loading提示
                
                //开始播放视频
                
                break;
            }
            case AVPlayerStatusFailed:{//视频加载失败，点击重新加载
                // 更新播放器状态
                [self setPlayerStatus:KYPlayerStatusFailed];
                break;
            }
            case AVPlayerStatusUnknown:{
                // 更新播放器状态
                [self setPlayerStatus:KYPlayerStatusUnknown];
                break;
            }
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        CGFloat cacheProgress = [self getCacheProgressWithPlayerItem:playerItem];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ky_player:didCacheProgress:)]) {
            [self.delegate ky_player:self didCacheProgress:cacheProgress];
        }
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        /* indicates that playback has consumed all buffered media and that playback will stall or end
         * 指示播放已消耗所有缓冲媒体，且播放将停止或结束
         */
        // 更新播放器状态
//        [self setPlayerStatus:KYPlayerStatusBufferEmpty];
        if (playerItem.isPlaybackBufferEmpty) {
            [self setPlayerStatus:KYPlayerStatusBufferEmpty];
        }
    }
    else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        /// seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
        // 更新播放器状态
//        [self setPlayerStatus:KYPlayerStatusKeepUp];
        if (playerItem.isPlaybackLikelyToKeepUp) {
            [self setPlayerStatus:KYPlayerStatusKeepUp];
        }
    } else if ([keyPath isEqualToString:@"playbackBufferFull"]) {
        if (playerItem.isPlaybackBufferFull) {
            
        }
    }
}
// 添加播放监听
- (void)addPeriodicTimeObserver {
    if (_timeObserverToken) {
        return;
    }
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Add time observer
    __weak typeof(self) weakSelf = self;
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:interval queue:mainQueue usingBlock:^(CMTime time) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf.isSeeking == YES) return;
        float totalTimeLength = CMTimeGetSeconds(strongSelf.player.currentItem.duration);
        float playTimeLength = CMTimeGetSeconds(strongSelf.player.currentItem.currentTime);
        [strongSelf updateCurrentPlayTime:playTimeLength totalTime:totalTimeLength];
    }];
}



/** 获取缓存进度 */
- (CGFloat)getCacheProgressWithPlayerItem:(AVPlayerItem *)playerItem {
    // 缓冲区域
    CMTimeRange ranges = [[playerItem loadedTimeRanges].firstObject CMTimeRangeValue];
    // 缓冲起始时间
    CGFloat start = CMTimeGetSeconds(ranges.start);
    // 缓冲长度
    CGFloat duration = CMTimeGetSeconds(ranges.duration);
    // 缓冲截止时间
    NSTimeInterval timeInterval = start + duration;
    // 视频时长
    CMTime durationTime   = playerItem.duration;
    CGFloat totalDuration = CMTimeGetSeconds(durationTime);
    // 缓冲进度比例
    CGFloat cacheProgress = timeInterval / totalDuration;
    return cacheProgress;
}

/** 重写记录播放器状态的 setter 方法*/
- (void)setPlayerStatus:(KYPlayerStatus)playerStatus {
    _playerStatus = playerStatus;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_player:updateStatus:)]) {
        [self.delegate ky_player:self updateStatus:playerStatus];
    }
}

/** 更新播放时间 */
- (void)updateCurrentPlayTime:(CGFloat)playTime totalTime:(CGFloat)totalTime {
    self.currentTime = playTime;
    self.totalTime = totalTime;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ky_player:currentPlayingTime:totalTime:)]) {
        [self.delegate ky_player:self currentPlayingTime:playTime totalTime:totalTime];
    }
}



@end
