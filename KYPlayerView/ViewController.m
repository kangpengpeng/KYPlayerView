//
//  ViewController.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/10/23.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "ViewController.h"
#import "KYPlayerView.h"
#import "KYPlayer/KYVolumeView/KYVolumeView.h"
//#import "KYPlayer/MBProgressHUD+KYShowManager/MBProgressHUD+KYShowManager.h"


@interface ViewController ()
@property (nonatomic, strong)KYPlayerView *playerView;

@property (nonatomic, strong)KYVolumeView *volumeView;

@property (nonatomic, strong)UIActivityIndicatorView *activiy;
@end

@implementation ViewController {
    dispatch_block_t _block;
}


- (void)setupSubviews {
    
    _playerView = [[KYPlayerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    [self.view addSubview:_playerView];

//    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
//    NSURL *mediaUrl = [NSURL fileURLWithPath:path];
//    [_playerView setURL:mediaUrl];
//    [_playerView play];
    
    NSString *path = @"https://media.w3.org/2010/05/sintel/trailer.mp4";
    [_playerView setURLWithString:path];
//    [_playerView play];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
//    self.view.backgroundColor = [UIColor blackColor];
    
//    self.volumeView = [[KYVolumeView alloc] init];
////    self.volumeView = [[KYVolumeView alloc] initWithFrame:CGRectMake(0, 0, 50, 200)];
//    self.volumeView.frame = CGRectMake(0, 0, 200, 50);
//    self.volumeView.center = self.view.center;
//    [self.volumeView setVolumeViewType:KYVolumeTypeHorizontal];
//    [self.view addSubview:self.volumeView];

    
//    UIActivityIndicatorView *activiy = [[UIActivityIndicatorView alloc] init];
//    activiy.frame = CGRectMake(100, 100, 100, 100);
//    activiy.center = self.view.center;
//    activiy.backgroundColor = [UIColor blackColor];
//    //设置小菊花颜色
//    activiy.color = [UIColor whiteColor];
//    activiy.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    
//    [activiy startAnimating];
//    [self.view addSubview:activiy];
//    self.activiy = activiy;
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static float v = 0;
    v += 0.06;
//    [self.volumeView setVolumeValue:v];
//    [self.volumeView setIncreaseVolumeValue:0.06];
    
    
    [self.activiy stopAnimating];
}



@end
