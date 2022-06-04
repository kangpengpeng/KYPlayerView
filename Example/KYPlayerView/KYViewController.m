//
//  KYViewController.m
//  KYPlayerView
//
//  Created by 搁浅de烟花 on 06/03/2022.
//  Copyright (c) 2022 搁浅de烟花. All rights reserved.
//

#import "KYViewController.h"
#import <KYPlayerView.h>

@interface KYViewController () <KYPlayerViewDelegate>
@property (nonatomic, strong)KYPlayerView *playerView;
@end

@implementation KYViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_playerView pause];
    [_playerView stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
}


- (void)setupSubviews {
    
    _playerView = [[KYPlayerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    _playerView.delegate = self;
    [self.view addSubview:_playerView];
    
    // 远程URL 使用如下代码
    NSString *path = @"https://vd2.bdstatic.com/mda-mkfg1m4wa2uei4w2/hd/cae_h264/1637064533574521063/mda-mkfg1m4wa2uei4w2.mp4?v_from_s=hkapp-haokan-hbe&auth_key=1654320323-0-0-9e159a86e5ede52b512a594c2f968399&bcevod_channel=searchbox_feed&pd=1&cd=0&pt=3&logid=3323378644&vid=17363961917071734229&abtest=101830_2-102599_1-17451_2-3000231_2-3000232_1&klogid=3323378644";
    // 本地URL
    //NSString *path = [[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
    //NSURL *videoUrl = [NSURL fileURLWithPath:path];
    [_playerView setURLWithString:path];
    //[_playerView setURL:videoUrl];
    [_playerView setMediaTitle:@"望庐山普利 -- 飞流直下三千尺，疑似银河落九天！"];
    [_playerView setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_playerView setEnableShowCenterPlayButton:NO];
    [_playerView setGobackShow:NO];
    // 如果需要自动播放，请手动调用 play 方法
    //[_playerView play];
}

#pragma mark: - KYPlayerViewDelegate
/// 播放器状态更新
/// @param playerView 播放视图
/// @param state 变更后的状态
- (void)ky_playerView:(KYPlayerView *)playerView updateStatus:(KYPlayerStatus)state {
    if (state == KYPlayerStatusFailed) {
        NSLog(@"监听到播放错误 %@", [playerView getURLString]);
    }
}
/// 播放进度更新
/// @param playerView 播放视图
/// @param playTime 当前播放时长
/// @param totalTime 总时长
- (void)ky_playerView:(KYPlayerView *)playerView currentPlayingTime:(CGFloat)playTime totalTime:(CGFloat)totalTime {
    
}
/// 播放结束
/// @param playerView 播放视图
/// @param isEnd 是否结束
- (void)ky_playerView:(KYPlayerView *)playerView didPlayEnd:(BOOL)isEnd {
    
}
/// 缓冲进度
/// @param playerView 播放视图
/// @param progress 缓冲进度
- (void)ky_playerView:(KYPlayerView *)playerView didCacheProgress:(CGFloat)progress {
    
}

@end
