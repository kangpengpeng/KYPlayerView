//
//  KYFastView.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/25.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYFastView.h"

@interface KYFastView()
/** 中间增量视图 */
@property (nonatomic, strong)UILabel *fastLb;
/** 底部小视图 */
@property (nonatomic, strong)UILabel *assitLb;
@end

@implementation KYFastView {
    /** 进度值 */
    CGFloat _fastProgress;
}

#pragma mark: - 外部暴露方法
/** 设置快进时间 */
- (void)setFastTime:(NSString *)fastTime {
    self.fastLb.text = fastTime;
}
/** 设置快进进度 */
- (void)setFastProgress:(CGFloat)fastProgress {    
    _fastProgress = (isnan(fastProgress) || fastProgress<0) ? 0 : fastProgress;
    [self setNeedsDisplay];
}
/** 设置总时间和快进至的时间 */
- (void)setFastTime:(NSString *)fastTime totalTime:(NSString *)totalTime {
    self.assitLb.text = [NSString stringWithFormat:@"%@/%@", fastTime, totalTime];
}


#pragma mark: - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews {
    float lbW = self.frame.size.width;
    float lbH = self.frame.size.height/2;
    self.fastLb.frame = CGRectMake(0, lbH/2, lbW, lbH);
    [self addSubview:self.fastLb];
    self.assitLb.frame = CGRectMake(0, self.frame.size.height-30, lbW, lbH);
    [self addSubview:self.assitLb];
}

#pragma mark: - Override Super Function
// 绘制播放进度UI
- (void)drawRect:(CGRect)rect {
    CGFloat lineW = 3;
    CGFloat lineX = 15;
    // rect.size.height - 10;
    CGFloat lineY = 10;
    CGFloat lineLength = rect.size.width - 2*lineX;
    UIBezierPath *bgPath = [UIBezierPath bezierPath];
    [bgPath moveToPoint:CGPointMake(lineX, lineY)];
    [bgPath addLineToPoint:CGPointMake(rect.size.width-lineX, lineY)];
    bgPath.lineWidth = lineW;
    [[UIColor colorWithWhite:0.5 alpha:0.5] setStroke];
    [bgPath stroke];
    
    UIBezierPath *fastPath = [UIBezierPath bezierPath];
    [fastPath moveToPoint:CGPointMake(lineX, lineY)];
    [fastPath addLineToPoint:CGPointMake(lineX + lineLength*_fastProgress, lineY)];
    fastPath.lineWidth = lineW;
    [[UIColor colorWithRed:237/255.0 green:105/255.0 blue:57/255.0 alpha:1] setStroke];
    [fastPath stroke];
}

#pragma mark: - 属性
- (UILabel *)fastLb {
    if (!_fastLb) {
        _fastLb = [[UILabel alloc] init];
        _fastLb.textColor = [UIColor whiteColor];
        _fastLb.textAlignment = NSTextAlignmentCenter;
        _fastLb.font = [UIFont systemFontOfSize:22];
    }
    return _fastLb;
}

- (UILabel *)assitLb {
    if (!_assitLb) {
        _assitLb = [[UILabel alloc] init];
        _assitLb.textColor = [UIColor whiteColor];
        _assitLb.textAlignment = NSTextAlignmentCenter;
        _assitLb.font = [UIFont systemFontOfSize:12];
    }
    return _assitLb;
}

#pragma mark: - delloc
- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
