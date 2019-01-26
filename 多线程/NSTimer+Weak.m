//
//  NSTimer+Weak.m
//  多线程
//
//  Created by LSH on 2019/1/25.
//  Copyright © 2019 None. All rights reserved.
//

#import "NSTimer+Weak.h"

@implementation NSTimer (Weak)

+ (NSTimer *)helper_scheduedTimerWithTimeInterval:(NSTimeInterval)seconds
                                            block:(void(^)(id info))block
                                         userinfo:(id)userinfo
                                          repeats:(BOOL)repeats
{
  return  [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(helper_block:) userInfo:@[[block copy] , userinfo] repeats:repeats];
}

+ (void)helper_block:(NSTimer *)timer
{
    NSArray *infoArr = timer.userInfo;
    void (^myblock)(id userinfo) = infoArr[0];
    id info = infoArr[1];
    if (myblock) {
        myblock(info);
    }
}

@end
