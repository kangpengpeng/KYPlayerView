# KYPlayerView

[![CI Status](https://img.shields.io/travis/搁浅de烟花/KYPlayerView.svg?style=flat)](https://travis-ci.org/搁浅de烟花/KYPlayerView)
[![Version](https://img.shields.io/cocoapods/v/KYPlayerView.svg?style=flat)](https://cocoapods.org/pods/KYPlayerView)
[![License](https://img.shields.io/cocoapods/l/KYPlayerView.svg?style=flat)](https://cocoapods.org/pods/KYPlayerView)
[![Platform](https://img.shields.io/cocoapods/p/KYPlayerView.svg?style=flat)](https://cocoapods.org/pods/KYPlayerView)

## Example

初始化：

```
    _playerView = [[KYPlayerView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    _playerView.delegate = self;
    [self.view addSubview:_playerView];
    /**
     远程URL 使用如下代码
     NSString *path = @"https://media.w3.org/2010/05/sintel/trailer.mp4";
     [_playerView setURLWithString:path];
     */
    // 本地URL
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test.mp4" ofType:nil];
    //NSURL *videoUrl = [NSURL fileURLWithPath:path];
    [_playerView setURLWithString:path];
    //[_playerView setURL:videoUrl];
    [_playerView setMediaTitle:@"望庐山普利 -- 飞流直下三千尺，疑似银河落九天！"];
    [_playerView setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_playerView setEnableShowCenterPlayButton:NO];
    [_playerView setGobackShow:NO];
    // 如果需要自动播放，请手动调用 play 方法
    //[_playerView play];
```


对播放器状态进行监听，请实现如下相关协议方法
```
@protocol KYPlayerViewDelegate <NSObject>
@optional
/// 播放器状态更新
/// @param playerView 播放视图
/// @param state 变更后的状态
- (void)ky_playerView:(KYPlayerView *)playerView updateStatus:(KYPlayerStatus)state;
/// 播放进度更新
/// @param playerView 播放视图
/// @param playTime 当前播放时长
/// @param totalTime 总时长
- (void)ky_playerView:(KYPlayerView *)playerView currentPlayingTime:(CGFloat)playTime totalTime:(CGFloat)totalTime;
/// 播放结束
/// @param playerView 播放视图
/// @param isEnd 是否结束
- (void)ky_playerView:(KYPlayerView *)playerView didPlayEnd:(BOOL)isEnd;
/// 缓冲进度
/// @param playerView 播放视图
/// @param progress 缓冲进度
- (void)ky_playerView:(KYPlayerView *)playerView didCacheProgress:(CGFloat)progress;
@end
```

播放状态代理

## Requirements

## Installation

KYPlayerView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KYPlayerView', '~> 0.1.0'
```

## Author

搁浅de烟花, 353327533@qq.com, kangpp@163.com

## License

KYPlayerView is available under the MIT license. See the LICENSE file for more info.
