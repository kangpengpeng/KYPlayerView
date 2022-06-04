//
//  KYBackButton.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2022/6/3.
//  Copyright © 2022 kangpp. All rights reserved.
//

#import "KYBackButton.h"

@implementation KYBackButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    // 原图比例 W : H = 24 : 36
    // 上边距和下边距
    if (self.currentImage) {
        CGFloat height = contentRect.size.height/2;
        // 根据高度计算宽度
        CGFloat width = height;
        // 再计算 X Y 坐标
        CGFloat x = 16;
        CGFloat y = (contentRect.size.height - height) / 2;
        //NSLog(@"w=%f, h=%f", width, height);
        return CGRectMake(x, y, width, height);
    }
    return CGRectZero;
}
@end
