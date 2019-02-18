//
//  ViewController.m
//  BlockCaptureDemo
//
//  Created by lyy on 2019/1/23.
//  Copyright © 2019 lyy. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

typedef void(^BlockDemo)(void);
@interface ViewController ()

@property(strong,nonatomic)NSString *test;
@property(copy,nonatomic)BlockDemo block;
@property(strong,nonatomic)Person *person;

@end

int globalA = 10;



struct __ViewController__modifyVariable_block_desc_0 {
    size_t reserved;
    size_t Block_size;
    void (*copy)(void);
    void (*dispose)(void);
};

struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
};

struct __Block_byref_a_0 {
    void *__isa;
    struct __Block_byref_a_0 *__forwarding;
    int __flags;
    int __size;
    int a;
};

struct __ViewController__modifyVariable_block_impl_0 {
    struct __block_impl impl;
    struct __ViewController__modifyVariable_block_desc_0* Desc;
    struct __Block_byref_a_0 *a; // by ref
    
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self circyleReference];
}

- (void)circyleReference {
    self.person = [Person new];
    /*
     __weak: 不会产生强引用，指向的对象销毁后自动将指针置位nil
     __unsafe_unretained:不会产生强引用，但指向的对象销毁后，指针存储地址值不变，不安全
     */
    __unsafe_unretained ViewController *weakSelf = self;
    self.person.name = @"yy";
    self.block =  ^{
        NSLog(@"%@",weakSelf.person.name);
    };
    self.block();
}
/*

- (void)blockTest {
    __block int a = 10;
    __block Person *person = [Person new];
    person.name = @"mm";
    ^{
        a = 11;
        person = [Person new];
        person.name = @"modified";
        NSLog(@"%d---%@",a,person.name);
    }();
    NSLog(@"%@",^{
        a = 11;
        person = [Person new];
        person.name = @"modified";
        NSLog(@"%d---%@",a,person.name);
    });
    NSLog(@"---------------------");
}

- (void)blockModifyVariable {
    __block int a = 10;
    __block Person *person = [Person new];
    person.name = @"mm";
    BlockDemo block = ^{
        a = 11;
        person = [Person new];
        person.name = @"modified";
        NSLog(@"%d---%@",a,person.name);
    };
    block();
}


- (void)modifyVariable {
    __block int a = 10;
    
    __block Person *person = [Person new];
    person.name = @"mm";
    
    BlockDemo block = ^{
        a = 11;
        NSLog(@"%d---%@",a,person.name);
    };
    BlockDemo block1 = ^{
        a = 12;
        NSLog(@"%d",a);
    };
    struct __ViewController__modifyVariable_block_impl_0* blockImpl = (__bridge struct __ViewController__modifyVariable_block_impl_0*)block;
    struct __ViewController__modifyVariable_block_impl_0* blockImpl1 = (__bridge struct __ViewController__modifyVariable_block_impl_0*)block1;
    NSLog(@"%p -- %p",blockImpl->a,blockImpl1->a);
    block();
    block1();
}


- (void)blockCaptureObject {
    Person *person = [Person new];
    person.name = @"jack";
    
    __weak Person *weakPerson = person;
    BlockDemo block = ^{
        NSLog(@"%@",weakPerson.name);
    };
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
    
}

 
- (void)usingBlock {
    NSArray *array = @[@"1"];
    Person *person = [Person new];
    person.name = @"jack";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"enumerateObjectsUsingBlock:%@",person.name);
        }];
    });
}

- (void)GCDBlcokCaptureObject {
    Person *person = nil;
    person = [Person new];
    person.name = @"jacden";
    person.friends = @[@"s",@"2"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"----name:%@-----",person.name);
        NSLog(@"------dispatch_after-------");
    });
    person.name = @"lily";
    /*
    1、修改person这个指针，block内部打印结果为：----name:jacden-----
     person = [Person new];
     person.name = @"lily";
     
     2、修改指针指向内存中对象的属性，block内部打印结果为：----name:lily-----
     person.name = @"lily";
     
     这是因为block捕获auto变量跟外部变量的类型是一致的，此时外部是Person *指针，block会内部有个Person *指针指向外部变量，情况1是修改了外部person的指向，而block内部的Person *指针仍指向原来的变量。所有打印结果仍然是jacden；情况2只是修改了person指针指向的对象的属性值，即是指向的内存内的对象发生了改变，指针指向的地址跟block内部指向的地址是一样的，所有打印结果是最新值；
     */
//}


/**



- (void)GCDBlcok {
    Person *person = nil;
    person = [Person new];
    person.name = @"jacden";
    person.friends = @[@"s",@"2"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"------dispatch_after-------");
        
    });
}


- (void)blockAsParameter{
    int a = 1;
    int c = 2;
    // 访问自动变量
    NSLog(@"%@",^{NSLog(@"%d",a);});
    // block作为函数/方法返回值
    NSLog(@"%@",[[self getBlock] class]);
    // 强指针指向block
    BlockDemo strongBlock = ^{NSLog(@"%d",c);};
    NSLog(@"%@",[strongBlock class]);
}


- (BlockDemo)getBlock {
    int b = 1;
    return ^{
        NSLog(@"%d",b);
    };
}


- (void)captureAutoVariable {
    int a = 0;
    void(^block)(void) = ^{
        NSLog(@"%d",a);
    };
    block();
    NSLog(@"noCapture:%@",[block class]);
    NSLog(@"noCapture_copy:%@",[[block copy] class]);
}

- (void)captureAutoAndStaticVariable {
    int a = 10;
    static int b = 10;
    
    void(^block)(void) = ^{
        NSLog(@"autoAndStatic:%d----%d",a,b);
    };
    a = 11;
    b = 20;
    block();
    NSLog(@"autoAndStatic:%@",[block class]);
    NSLog(@"autoAndStatic_copy:%@",[[block copy] class]);
}

- (void)captureGlobalVariable {
    void(^block)(void) = ^{
        NSLog(@"globalVariable:%d",globalA);
    };
    globalA = 11;
    block();
    NSLog(@"globalVariable:%@",[block class]);
    NSLog(@"globalVariable_copy:%@",[[block copy] class]);
}

- (void)captureOCObject {
    Person *p = [Person new];
    p.name = @"lily";
    void(^block)(void) = ^{
        NSLog(@"%@",p.name);
    };
    block();
    NSLog(@"captureOCObject:%@",[block class]);
    NSLog(@"captureOCObject_copy:%@",[[block copy] class]);
//    [p release];
}


- (void)typeOfBlcok {
    void(^block)(void) = ^{
        
    };
    NSLog(@"%@",[block superclass]);
    NSLog(@"%@",[[block superclass] superclass]);
    NSLog(@"%@",[[[block superclass] superclass] superclass]);
    NSLog(@"%@",[[[block superclass] superclass] superclass]);
    block();
}
*/
@end
