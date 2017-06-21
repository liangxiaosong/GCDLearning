//
//  ViewController.m
//  GCD
//
//  Created by LPPZ-User01 on 2017/3/20.
//  Copyright © 2017年 LPPZ-User01. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSThread          *thread1;
@property (nonatomic, strong) NSLock            *lock;
@property (nonatomic, assign) NSInteger         cnt;
@property (nonatomic, strong) NSOperationQueue  *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#warning 八没懂
    /*
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSLog(@"五秒后执行这");
    });
    NSLog(@"不影响");

    //异步后台线程
    //执行较慢的任务，例如大量计算，网络请求等
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         NSLog(@"在异步并行队列中执行");
    });

    dispatch_queue_t queue = dispatch_queue_create("com.realank.GCDDemo.myQueue", NULL);
    dispatch_async(queue, ^{
        NSLog(@"在异步并行队列中执行");
    });
    //上面的代码，分别创建了一个异步后台并行线程和一个自创建的异步后台串行线程。

    //用于在后台线程的任务将要完成时，切换到主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"刷新UI");
    });

    //同步后台线程
    //主要用途：在新线程中执行任务，并且等待线程执行完毕再向后执行，几乎不用
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         NSLog(@"在同步并行队列中执行");
    });

    dispatch_queue_t queueTwo = dispatch_queue_create("com.realank.GCDDemo.youQueue", NULL);
    dispatch_sync(queueTwo, ^{
        NSLog(@"在同步串行队列中执行");
    });
    //上面的代码，分别创建了一个异步后台并行线程和一个自创建的异步后台串行线程。

    //同步主线程（慎用）
    //主要用途：只有在其它线程中才可能执行此方法，否则会死锁
    dispatch_sync(dispatch_get_main_queue(), ^{
         NSLog(@"在同步主线程中执行，慎用，否则会死锁");
    });

    //延时执行线程
    //主要用途：用于等待一段时间以后再执行的任务
    dispatch_queue_t queueThree = dispatch_get_main_queue();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), queueThree, ^{
         NSLog(@"延时2秒执行");
    });
    NSLog(@"延时线程已部署");

    //线程
    [self Thread];
*/

    [self GCD];
}

- (void)GCD {
    /*
     一、串行 serial queue
     特点：执行queue中的第一个任务，结束后在执行第二个任务，第二个任务结束在执行第三个任务，，，，任何一个任务的执行必须在上一个任务的执行结束后。
     1、获取mainQueue。mainQueue会在主线程中执行，即：主线程中执行队列中的各个任务
     */
//    [self serialQueue];
    /*
        2 、 自己创建serial queue。//自己创建的serial queue不会在主线程中执行，queue会开辟一个子线程，在子线程中执行队列中的各个任务
     */
//    [self mySelfQueue];

    /*
        二、并行 concurrent
        queue是另外一种队列。其特点：队列中的任 务，第一个先执行，不等第一个执行完毕，第二个就开始执行了，不等第二个任务执行完毕，第三个就开始执行了，以此类推。后面的任务执行的晚，但是不会等前面的执行完才执行。
        concurrent queue会根据需要开辟若干个线程，并行执行队列中的任务（开始较晚的任务未必最后结束，开始较早的任务未必最先完成），开辟的线程数量 取决于多方面因素，比如：任务的数量，系统的内存资源等等，会以最优的方式开辟线程---根据需要开辟适当的线程。
     //1、获得global queue
     //    [self globalQueue];
     //2.自己创建concurrent queue
     //    [self myConcurrentQueue];
     */

    /*延时调用*/
//    [self after];
    /*若干任务执行完之后，想执行某任务*/
//    [self groble];


    /*GCD中提供了API让某个任务执行若干次。*/
//    [self apply];
    [self syncAction];

}

- (void)syncAction{

    dispatch_group_t group =dispatch_group_create();
    dispatch_queue_t globalQueue=dispatch_get_global_queue(0, 0);

    dispatch_group_enter(group);

    //模拟多线程耗时操作
    dispatch_group_async(group, globalQueue, ^{
        sleep(3);
        NSLog(@"%@---block1结束。。。",[NSThread currentThread]);
        dispatch_group_leave(group);
    });
    NSLog(@"%@---1结束。。。",[NSThread currentThread]);

    dispatch_group_enter(group);
    //模拟多线程耗时操作
    dispatch_group_async(group, globalQueue, ^{
        sleep(3);
        NSLog(@"%@---block2结束。。。",[NSThread currentThread]);
        dispatch_group_leave(group);
    });
    NSLog(@"%@---2结束。。。",[NSThread currentThread]);

    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"%@---全部结束。。。",[NSThread currentThread]);
    });

}

- (void)apply{
    NSArray *array = [NSArray arrayWithObjects:@"红楼梦",@"水浒传",@"三国演义",@"西游记", nil];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        //dispathc_apply 是dispatch_sync 和dispatch_group的关联API.它以指定的次数将指定的Block加入到指定的队列中。并等待队列中操作全部完成.
        dispatch_apply([array count], queue, ^(size_t index) {
            for (int i = 0; i < array.count; i ++) {
                NSLog(@"%@所在线程%@,是否是主线程:%d ========= %d",[array objectAtIndex:index],[NSThread currentThread],[[NSThread currentThread] isMainThread],i);
            }
        });
        //用于在后台线程的任务将要完成时，切换到主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"刷新UI");
        });
    });
}

- (void)groble {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t myConcurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    //dispatch_group_async用于把不同的任务归为一组
    //dispatch_group_notify当指定组的任务执行完毕之后，执行给定的任务
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第1个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第2个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第3个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第4个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第5个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第6个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    dispatch_group_notify(group, myConcurrentQueue, ^{
        NSLog(@"group中的任务都执行完毕之后，执行此任务。所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//dispatch_group_notify group中的任务都执行完毕之后，执行的任务
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第7个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
    dispatch_group_async(group, myConcurrentQueue, ^{
        NSLog(@"第8个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });
}

- (void)after {
    double delayInSeconds = 3.0;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    //两中方式：主线程 dispatch_get_main_queue()
    //子线程
    dispatch_queue_t myConcurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_after(time, myConcurrentQueue, ^{
        NSLog(@"world");
    });
    NSLog(@"你妹啊");
}

/**
 自定义全局队列
 */
- (void)myConcurrentQueue {
    dispatch_queue_t myConcurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第1个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第2个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第3个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第4个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第5个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第6个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第7个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第8个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第9个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(myConcurrentQueue, ^{
        NSLog(@"第10个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
}

/**
 全局队列
 */
- (void)globalQueue {
    //第一个参数控制globalQueue的优先级，一共有4个优先级DISPATCH_QUEUE_PRIORITY_HIGH、DISPATCH_QUEUE_PRIORITY_DEFAULT、DISPATCH_QUEUE_PRIORITY_LOW、DISPATCH_QUEUE_PRIORITY_BACKGROUND。第二个参数是苹果预留参数，未来会用，目前填写为0
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSLog(@"第1个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第2个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第3个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第4个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第5个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第6个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第7个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第8个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第9个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(globalQueue, ^{
        NSLog(@"第10个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
}


/**
 串行
 */
- (void)serialQueue {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        NSLog(@"第1个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mainQueue, ^{
        NSLog(@"第2个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mainQueue, ^{
        NSLog(@"第3个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mainQueue, ^{
        NSLog(@"第4个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mainQueue, ^{
        NSLog(@"第5个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）

//    dispatch_group_t group = dispatch_group_create();
//    dispatch_queue_t myQueue = dispatch_queue_create("MyConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_group_notify(group, myQueue, ^{
//        NSLog(@"其他线程执行完毕再调用这");
//    });
}

- (void)mySelfQueue {
    dispatch_queue_t mySerialQueue = dispatch_queue_create("MySerialQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(mySerialQueue, ^{
        NSLog(@"第1个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mySerialQueue, ^{
        NSLog(@"第2个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mySerialQueue, ^{
        NSLog(@"第3个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mySerialQueue, ^{
        NSLog(@"第4个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
    dispatch_async(mySerialQueue, ^{
        NSLog(@"第5个任务,所在线程%@,是否是主线程:%d",[NSThread currentThread],[[NSThread currentThread] isMainThread]);
    });//在block里写要执行的任务（代码）
}


- (void)Thread {
#if 0
    [self func1];
    [self func2];
    [self func3];
    [NSThread detachNewThreadSelector:@selector(func1) toTarget:self withObject:nil];
    [NSThread detachNewThreadSelector:@selector(func2) toTarget:self withObject:nil];

    [NSThread detachNewThreadSelector:@selector(func3) toTarget:self withObject:nil];

    // 六。监听线程结束
    //可以建立观察者，监听一个线程是否结束
    //要先注册观察者
    //注册观察这的时候内部会专门建立一个线程监听其他线程是否结束
    //当线程结束的时候，一般会发送一个结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(threadWillEnd:) name:NSThreadWillExitNotification object:nil];
    //子线程 一旦创建启动 就会和主线程 同时异步执行
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(thread1Click:) object:@"线程1"];
    thread1.name = @"thread1";
    [thread1 start];

    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(thread2Click:) object:@"线程2"];
    thread2.name = @"thread2";
    [thread2 start];

    //七、多个线程之间的通信
    _thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(thread1Click:) object:@"线程1"];
    [_thread1 start];

    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(thread2Click:) object:@"线程2"];
    [thread2 start];
    NSThread *thread3 = [[NSThread alloc] initWithTarget:self selector:@selector(thread3Click:) object:@"线程3"];
    [thread3 start];

    //八、线程锁
    //当多个线程同时操作同一个资源的时候，这时如果不处理，那么这个资源有可能就会紊乱，达不到我们想要的效果，所以如果我们要保证同时访问的重要数据不紊乱，我们需要添加线程锁，阻塞线程，使线程同步。排队访问
    //1.必须要先创建锁
    _lock = [[NSLock alloc] init];
    _cnt = 0;
    //创建两个线程 操作同一个资源变量
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(thread1Click:) object:@"线程1"];
    [thread1 start];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(thread2Click:) object:@"线程2"];
    [thread2 start];
    /*
     九、任务队列
     NSThread操作线程是最基本的类，NSOperation是一个轻量级的线程，任务队列得到的子线程的效率要高于NSTread。
     NSOperation是以任务为导向的管理线程机制，将操作（任务）放入到线程池里，会自动执行，弱化线程的概念（任务：可以简单的理解为线程）
     */
    //创建一个线程池
    _queue = [[NSOperationQueue alloc] init];
    //设置 一个队列中 允许 最大 任务的并发 个数
    _queue.maxConcurrentOperationCount = 5;
    //如果写成1  表示 线程池中的任务 一个一个 串行执行
    [self createInvocationOperation];
    [self createBlockOperation];
    //十、GCD
    //    [self createGlobalQueue];
    //    [self createPrivateQueue];
    [self createMainQueue];

#else
    //八、线程锁
    //当多个线程同时操作同一个资源的时候，这时如果不处理，那么这个资源有可能就会紊乱，达不到我们想要的效果，所以如果我们要保证同时访问的重要数据不紊乱，我们需要添加线程锁，阻塞线程，使线程同步。排队访问
    //1.必须要先创建锁
    _lock = [[NSLock alloc] init];
    _cnt = 0;
    //创建两个线程 操作同一个资源变量
    NSThread *thread1 = [[NSThread alloc] initWithTarget:self selector:@selector(thread1Click:) object:@"线程1"];
    [thread1 start];
    NSThread *thread2 = [[NSThread alloc] initWithTarget:self selector:@selector(thread2Click:) object:@"线程2"];
    [thread2 start];

#endif

}

//#pragma mark - 全局队列
///*
// 3.全局队列
// // 并行队列（全局）不需要我们创建，通过dispatch_get_global_queue()方法获得
// // 三个可用队列
// // 第一个参数是选取按个全局队列，一般采用DEFAULT，默认优先级队列
// // 第二个参数是保留标志，目前的版本没有任何用处(不代表以后版本)，直接设置为0就可以了
// // DISPATCH_QUEUE_PRIORITY_HIGH
// // DISPATCH_QUEUE_PRIORITY_DEFAULT
// // DISPATCH_QUEUE_PRIORITY_LOW
// dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
// */
//- (void)createGlobalQueue {
//    //全局队列 内部任务 异步/并行 执行
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSInteger i = 0; i < 10; i++) {
//            [NSThread sleepForTimeInterval:0.5];
//            NSLog(@"全局队列任务1:%ld",i);
//        }
//    });
//
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSInteger i = 0; i < 10; i++) {
//            [NSThread sleepForTimeInterval:0.5];
//            NSLog(@"全局队列任务2:%ld",i);
//        }
//    });
//}
//
//#pragma mark - 私有队列
///*
// 2.创建私有队列 用户队列/串行队列
// // C接口，创建一个私有队列 ，队列名是一个C字符串，没有特别的要求，Apple建议用倒装的标识符来表示(这个名字，更多用于调试)
// 私有队列内部也是串行操作
// */
//- (void)createPrivateQueue {
//    //创建一个私有队列
//    //私有队列 相对于主线程 异步
//    //私有队列内部的任务 是 串行执行
//    //下面函数的第一个参数 就是一个标签字符串 标识队列
//    dispatch_queue_t queue = dispatch_queue_create("com.1507", NULL);
//
//    //增加任务
//    dispatch_async(queue, ^{
//        for (NSInteger i = 0; i < 10; i++) {
//            [NSThread sleepForTimeInterval:0.5];
//            NSLog(@"私有队列任务1");
//        }
//    });
//    //增加任务 这两个任务 是 ？
//    dispatch_async(queue, ^{
//        for (NSInteger i = 0; i < 10; i++) {
//            [NSThread sleepForTimeInterval:0.5];
//            NSLog(@"私有队列任务2");
//        }
//    });
//    //私有队列 相当于 NSOperationQueue 队列 内部最大并发个数是1
//}
//
//#pragma mark - 主线程队列
//- (void)createMainQueue {
//    //主线程队列 只需要获取 --》一般都是在子线程获取 在子线程获取才有意义
//    //1.获取主线程队列 -->主线程队列内部 都是 串行
//    dispatch_queue_t queue = dispatch_get_main_queue();
//
//    //dispatch_async 相对于 当前线程 异步给 queue 增加一个任务
//    dispatch_async(queue, ^{
//        //给主线程 增加一个任务
//        for (NSInteger i = 0; i < 10; i++) {
//            NSLog(@"主线程任务1_i:%ld",i);
//            [NSThread sleepForTimeInterval:0.5];
//        }
//    });
//    //增加任务 是异步 的 主线程 队列内部 是串行执行任务的
//    dispatch_async(dispatch_get_main_queue(), ^{
//        for (NSInteger i = 0; i < 10; i++) {
//            NSLog(@"主线程任务2_i:%ld",i);
//            [NSThread sleepForTimeInterval:0.5];
//        }
//    });
//}

/*
 NSOperation 是一个抽象类  NSOperation 方法 需要有子类自己实现
 //创建任务对象 都是 NSOperation 的子类对象
 //NSBlockOperation  NSInvocationOperation
 任务 要和 任务队列/线程池 结合使用
 */
//#pragma mark - block任务
//- (void)createBlockOperation {
//    NSBlockOperation *blockOp1 = [NSBlockOperation blockOperationWithBlock:^{
//        for (NSInteger i = 0; i < 10; i++) {
//            NSLog(@"block任务:%ld",i);
//            [NSThread sleepForTimeInterval:0.3];
//        }
//    }];
//    [blockOp1 setCompletionBlock:^{
//        //block 任务完成之后 会回调 这个block
//        NSLog(@"block任务完成");
//    }];
//    //放在线程池中
//    [_queue addOperation:blockOp1];
//}
//
//#pragma mark - 任务
////第一种任务
//- (void)createInvocationOperation {
//    NSInvocationOperation *op1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operation1:) object:@"任务1"];
//    //[op1 start]; 任务 默认start 相对于主线程是同步
//    //把任务 放入 线程池
//    [_queue addOperation:op1];//一旦放入 这个 任务 就会异步启动
//    NSInvocationOperation *op2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operation2:) object:@"任务2"];
//    //把任务 放入 线程池
//    [_queue addOperation:op2];
//    NSInvocationOperation *op3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operation3:) object:@"任务3"];
//    //把任务 放入 线程池
//    [_queue addOperation:op3];
//}
//
//- (void)operation3:(id)obj {
//    NSLog(@"obj:%@",obj);
//    for (NSInteger i = 0; i < 10; i++) {
//        [NSThread sleepForTimeInterval:0.5];
//        NSLog(@"op3:i->%ld",i);
//    }
//    NSLog(@"任务3即将结束");
//}
//
//- (void)operation2:(id)obj {
//    NSLog(@"obj:%@",obj);
//    for (NSInteger i = 0; i < 10; i++) {
//        [NSThread sleepForTimeInterval:0.5];
//        NSLog(@"op2:i->%ld",i);
//    }
//    NSLog(@"任务2即将结束");
//}
//
//- (void)operation1:(id)obj {
//    NSLog(@"obj:%@",obj);
//    for (NSInteger i = 0; i < 10; i++) {
//        [NSThread sleepForTimeInterval:0.5];
//        NSLog(@"op1:i->%ld",i);
//    }
//    NSLog(@"任务1即将结束");
//}


#pragma mark ------------ 八 ----------------

- (void)thread1Click:(id)obj {
#if 0
    //加锁
    [_lock lock];
    NSLog(@"thread1开始");
    for (NSInteger i = 0 ; i < 10; i++) {
        _cnt += 2;//想让 _cnt 连续+2
        NSLog(@"thread1_cnt:%ld",_cnt);
        [NSThread sleepForTimeInterval:0.2];
    }
    NSLog(@"thread1即将结束");
    [_lock unlock];//解锁
    //访问资源结束解锁
#else
    // @synchronized (self){} 类似于 加锁和解锁过程
    @synchronized (self) {
        //使线程对当前对象进行操作时，同步进行,阻塞线程
        //跟加锁原理是一样的,执行 @synchronized(self)会判断有没有加锁，加过锁那么阻塞，没有加锁就继续执行
        NSLog(@"thread1开始");
        for (NSInteger i = 0 ; i < 10; i++) {
            _cnt += 2;//想让 _cnt 连续+2
            NSLog(@"thread1_cnt:%ld",_cnt);
            [NSThread sleepForTimeInterval:0.2];
        }
        NSLog(@"thread1即将结束");
    }
#endif
}

- (void)thread2Click:(id)obj {
    [_lock lock];
    NSLog(@"thread2开始");

    for (NSInteger i = 0 ; i < 10; i++) {
        _cnt -= 2;//让 _cnt连续-5
        NSLog(@"thread2_cnt:%ld",_cnt);
        [NSThread sleepForTimeInterval:0.2];
    }
    NSLog(@"thread2即将结束");
    [_lock unlock];
}

/*
#pragma mark ------------ 七 ----------------

- (void)thread1Click:(id)obj {
    NSLog(@"%s",__func__);
    while (1) {
        if ([[NSThread currentThread] isCancelled]) {
             //要判断 当前这个线程 是否 被取消过(是否发送过取消信号)
            //如果被取消过，那么我们可以让当前函数结束那么这个线程也就结束了
            //break;//结束循环
            NSLog(@"子线程1即将结束");
            //return;//返回 函数
            [NSThread exit];//线程退出
        }
        NSLog(@"thread1");
        [NSThread sleepForTimeInterval:0.5];
    }
    NSLog(@"子线程1即将结束");
}

- (void)thread2Click:(id)obj {
    NSLog(@"%s",__func__);
    for (NSInteger i = 0; i < 10; i++) {
        [NSThread sleepForTimeInterval:0.2];
        NSLog(@"thread2:_i:%ld",i);
    }
    NSLog(@"子线程2即将结束");
    //当 thread2 即将结束之后 通知 thread1结束

    [_thread1 cancel];
    // cancel 在这里 只是给_thread1 发送了一个cancel 信号，最终thread1的取消，取决于 thread1的，如果要取消thread1,那么需要在thread1执行调用的函数内部 进行判断
}

- (void)thread3Click:(id)obj {
    NSLog(@"%s",__func__);
    for (NSInteger i = 0; i < 10; i++) {
        [NSThread sleepForTimeInterval:0.2];
        NSLog(@"thread3:_i:%ld",i);
    }
    NSLog(@"子线程3即将结束");
}

#pragma mark ------------ 六 ----------------

- (void)thread1Click:(id)obj {
    //打印当前线程和主线程
    NSLog(@"thread:%@ isMain:%d",[NSThread currentThread],[NSThread isMainThread]);
    NSLog(@"%s",__func__);
    for (NSInteger i = 0; i < 10; i ++) {
        NSLog(@"func1_i:%ld",i);
        [NSThread sleepForTimeInterval:1];
    }
    NSLog(@"thread1即将结束");
}

- (void)thread2Click:(id)obj {
    NSLog(@"thread:%@ isMain:%d",[NSThread currentThread],[NSThread isMainThread]);
    NSLog(@"%s",__func__);
    for (NSInteger i = 0; i < 10; i ++) {
        NSLog(@"func2_i:%ld",i);
        [NSThread sleepForTimeInterval:0.2];
    }
    NSLog(@"thread2即将结束");
}

//当监听到线程结束的时候调用这个函数
//上面的两个线程结束都会调用这个函数
- (void)threadWillEnd:(NSNotification *)info {
    NSLog(@"thread:%@ isMain:%d_func:%s",[NSThread currentThread],[NSThread isMainThread],__func__);
    NSLog(@"obj:%@",info.object);//谁发的通知
}

#pragma mark -------------- 这是分界线 ------------------------

- (void)func1 {
    for (NSInteger i = 0; i < 20; i ++) {
        NSLog(@"func1:i->%ld",i);
        [NSThread sleepForTimeInterval:0.5];
    }
    NSLog(@"func1即将结束");
}
- (void)func2 {
    for (NSInteger i = 0; i < 20; i ++) {
        NSLog(@"func2:i->%ld",i);
        [NSThread sleepForTimeInterval:0.5];
    }
    NSLog(@"func2即将结束");
}
- (void)func3 {
    for (NSInteger i = 0; i < 20; i ++) {
        NSLog(@"func3:i->%ld",i);
        [NSThread sleepForTimeInterval:0.5];
    }
    NSLog(@"func3即将结束");
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
