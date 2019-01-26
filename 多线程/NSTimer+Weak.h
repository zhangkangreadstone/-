//
//  NSTimer+Weak.h
//  多线程
//
//  Created by LSH on 2019/1/25.
//  Copyright © 2019 None. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Weak)

+ (NSTimer *)helper_scheduedTimerWithTimeInterval:(NSTimeInterval)seconds
                                            block:(void(^)(id info))block
                                         userinfo:(id)userinfo
                                          repeats:(BOOL)repeats;



@end

NS_ASSUME_NONNULL_END
