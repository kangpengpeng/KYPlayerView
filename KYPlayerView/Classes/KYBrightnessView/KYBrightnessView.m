//
//  KYBrightnessView.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/11/26.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "KYBrightnessView.h"

@interface KYBrightnessView()
@property (nonatomic, strong)UIImageView *iconIV;
@end

@implementation KYBrightnessView {
    CGFloat _sliderValue;
    dispatch_block_t _hideAnimationBlock;
}

- (UIImageView *)iconIV {
    if (!_iconIV) {
        _iconIV = [[UIImageView alloc] init];
    }
    return _iconIV;
}

- (void)setupSubviews {
    CGFloat ivW = 20;
    CGFloat ivX = (self.frame.size.width-ivW) / 2;
    CGFloat ivY = self.frame.size.height - ivW - 10;
    self.iconIV.frame = CGRectMake(ivX, ivY, ivW, ivW);
    [self addSubview:self.iconIV];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setupSubviews];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sliderValue = 0;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        [self setupSubviews];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat lineW = 4;
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
    [[UIColor colorWithWhite:0.5 alpha:0.5] setStroke];
    [bgPath stroke];
    
    UIBezierPath *brightPath = [UIBezierPath bezierPath];
    [brightPath moveToPoint:startP];
    [brightPath addLineToPoint:CGPointMake(x, startY - lineLength*_sliderValue)];
    brightPath.lineWidth = lineW;
    //[[UIColor colorWithRed:237/255.0 green:105/255.0 blue:57/255.0 alpha:1] setStroke];
    [[UIColor whiteColor] setStroke];
    [brightPath stroke];
}


- (void)setSliderValue:(CGFloat)value {
    _sliderValue = value;
    [self setNeedsDisplay];
    [self setHidden:NO];
    [self setHidden:YES delay:3];
}

- (CGFloat)getSliderValue {
    return _sliderValue;
}

- (void)setIconImage:(UIImage *)image {
    [self.iconIV setImage:image];
}

- (void)setHidden:(BOOL)hidden {
    if (_hideAnimationBlock) dispatch_block_cancel(_hideAnimationBlock);
    [super setHidden:hidden];
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


#pragma mark: - delloc
- (void)dealloc {
    //NSLog(@"%s", __func__);
}
@end
