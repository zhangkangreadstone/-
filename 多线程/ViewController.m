//
//  ViewController.m
//  MoreThread
//
//  Created by LSH on 2018/01/02.
//  Copyright © 2018年 ZhangKang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,assign) NSInteger tickets;
@property (nonatomic,strong) NSThread *window0;

@property (nonatomic,strong) NSThread *window1;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //多线程

    //队列、任务
    /*
     队列是负责调度任务的，
     队列：串行、并行
     串行队列：只能一个接一个的调度任务。
     并行队列：可以不用管前面的任务是否完成，只要有空闲的线程可以处理任务就会去调度。


     任务：同步、异步
     同步：只能在当前线程中执行，不会开辟新线程

     异步：可以开辟新线程执行任务

     并发队列的并发功能只有在异步（dispatch_async）函数下才有效，也就是说只有异步任务在并行队列里才会开启新线程

     ----------------------------------------------------------------------------|
     |      区别       |     并发队列     |   串行队列     |       主队列             |
     |----------------------------------------------------------------------------
     |    同步(sync)   |  没有开启新线程，  | 没有开启新线程，| 主线程调用：死锁卡住不执行 其他
     |                |  串行执行任务     | 串行执行任务    | 线程调用：没有开启新线程，串行执行任务
     |----------------------------------------------------------------------------
     |    异步(async)  | 有开启新线程，并   |  有开启新线程(1条)|  没有开启新线程，         |
     |                |  发执行任务       | 串行执行任务     |       串行执行任务       |
     ----------------------------------------------------------------------------


     */

    //GCD =================================================================
    //    dispatch_async(dispatch_get_main_queue(), ^{//主线程串行队列  //在主线程中同步主队列会锁死
    //
    //    });
    //
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{//全局并发队列
    //
    //    });

    //    [self sceneTwoTestB];

    //    [self sellTickets];
//    [self operationSelector];
    [self barrGCD];


    //开启常驻线程
    // 创建线程，并调用run1方法执行任务
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(runSelector) object:nil];
    // 开启线程
    [thread start];

}
//正常线程 一条线  加上runloop 就是一个环，会一直转下去，变成了常驻线程
- (void)runSelector
{
    [[NSRunLoop currentRunLoop]addPort:[NSPort port] forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop]run];
}

- (void)barrGCD
{
    dispatch_queue_t queue = dispatch_queue_create("customerQueue", DISPATCH_QUEUE_CONCURRENT);
//    queue = dispatch_get_global_queue(0, 0);//不能用它想一下为啥（子线程开辟的太多）
    dispatch_async(queue, ^{
        NSLog(@"----①--------%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"----②--------%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        NSLog(@"----barrier③--------%@",[NSThread currentThread]);
        sleep(6);
    });
    dispatch_async(queue, ^{
        NSLog(@"----④--------%@",[NSThread currentThread]);

    });
    dispatch_async(queue, ^{
        NSLog(@"----⑤--------%@",[NSThread currentThread]);
    });
}


//GCD组
- (void)groupTasks
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"0---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });

    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"--=-=-=-=-=-任务①②都执行完毕");
    });

}
//单界面多网络请求 -- 信号量
- (void)sceneTwoTestB {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);//创建信号量

    // 执行循序1
    dispatch_group_async(group, queue, ^{
        NSLog(@"-------------000");
        dispatch_semaphore_signal(semaphore);//开走一辆车，留下一个车位
    });
    // 执行循序2
    dispatch_group_async(group, queue, ^{
        NSLog(@"-------------111");
        dispatch_semaphore_signal(semaphore);//开走一辆车，留下一个车位
    });

    dispatch_group_notify(group, queue, ^{
        // 执行循序3
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//有车位了进入，没有就堵塞，等待。。。。
        // 执行顺序5
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);//当，两个都能进入车位的时候就能继续执行下面的
        // 执行顺序7
        dispatch_async(dispatch_get_main_queue(), ^{//回到主线程
            // 刷新界面
            NSLog(@"-------------000111");
        });
    });
}



//线程安全的
- (void)sellTickets
{
    self.tickets = 50;

    self.window0 = [[NSThread alloc]initWithTarget:self selector:@selector(sellticketsWindow) object:nil];
    self.window0.name = @"卖票窗口0";

    self.window1 = [[NSThread alloc]initWithTarget:self selector:@selector(sellticketsWindow) object:nil];
    self.window1.name = @"卖票窗口1";

    [self.window1 start];
    [self.window0 start];
}

- (void)sellticketsWindow
{
    @synchronized (self) {
        if (self.tickets > 0) {
            self.tickets --;
            NSLog(@"-卖票窗口是---%@",[[NSThread currentThread] name]);
        }else{
            NSLog(@"票卖完了");
        }
    }
}


- (void)operationSelector
{
    //NSOperationQueue / NSOperation ===========================================
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];//自定义队列
    //    NSOperationQueue *mainQ = [NSOperationQueue mainQueue];//主队列
    //    queue.maxConcurrentOperationCount = 1;//设置最大并发数，设置为1，就是单线程执行 ，串行效果
    //子类 NSBlockOperation
    NSOperation *operation0 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation操作0===========%@",[NSThread currentThread]);
    }];

    NSOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"NSBlockOperation操作1===========%@",[NSThread currentThread]);
    }];

    //子类 NSInvocationOperation

    NSInvocationOperation *operation00 = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(invocationSelector) object:nil];
    //NSBlockOperation 可以在Block里直接处理，而NSInvocationOperation处理参数 通过object传字典处理

    //不添加依赖 此处默认是并行执行
    //    [operation0 addDependency:operation1];//添加依赖顺序 可以模拟串行

    [queue addOperation:operation0];
    [queue addOperation:operation1];
    [queue addOperation:operation00];

    [queue addOperationWithBlock:^{
        NSLog(@"addOperationWithBlock操作0===========%@",[NSThread currentThread]);
    }];

    [queue addOperationWithBlock:^{
        NSLog(@"addOperationWithBlock操作1===========%@",[NSThread currentThread]);
    }];

    [queue addOperationWithBlock:^{
        NSLog(@"addOperationWithBlock操作2===========%@",[NSThread currentThread]);

    }];
}

- (void)invocationSelector
{
    NSLog(@"NSInvocationOperation操作2===========%@",[NSThread currentThread]);
}

@end
