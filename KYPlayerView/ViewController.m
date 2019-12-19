//
//  ViewController.m
//  KYPlayerView
//
//  Created by 康鹏鹏 on 2019/10/23.
//  Copyright © 2019年 kangpp. All rights reserved.
//

#import "ViewController.h"
#import "KYPlayerView.h"
#import "KYVideoViewController.h"

@interface ViewController ()
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    KYVideoViewController *vc = [[KYVideoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
