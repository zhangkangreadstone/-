//
//  AViewController.m
//  多线程
//
//  Created by LSH on 2019/1/25.
//  Copyright © 2019 None. All rights reserved.
//

#import "AViewController.h"
#import "NSTimer+Weak.h"

@interface AViewController ()
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
    self.timer = [NSTimer helper_scheduedTimerWithTimeInterval:1.0 block:^(id info) {
        [weakSelf print:info];
    } userinfo:@[@"1" , @"2"] repeats:YES];
}
- (void)print:(id)info
{
    NSLog(@"执行block:%@" , info);
}
-(void)dealloc
{
    NSLog(@"AViewController已经销毁");
    [self.timer invalidate];
    self.timer = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
