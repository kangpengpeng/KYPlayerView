//
//  KYVideoViewController.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/12/19.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYVideoViewController.h"
#import "KYPlayer/KYPlayerView.h"

@interface KYVideoViewController ()
@property (nonatomic, strong)KYPlayerView *playerView;
@end

@implementation KYVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubviews];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_playerView pause];
    [_playerView stop];
    NSLog(@"%s", __func__);
}

- (void)setupSubviews {
    
    _playerView = [[KYPlayerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    [self.view addSubview:_playerView];
    NSString *path = @"https://media.w3.org/2010/05/sintel/trailer.mp4";
    [_playerView setURLWithString:path];
    [_playerView setMediaTitle:@"望庐山普利 -- 飞流直下三千尺，疑似银河落九天！"];
    [_playerView setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_playerView setEnableShowCenterPlayButton:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%s", __func__);
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
//    NSURL *mediaUrl = [NSURL fileURLWithPath:path];
//    [_playerView setURL:mediaUrl];
}

@end
