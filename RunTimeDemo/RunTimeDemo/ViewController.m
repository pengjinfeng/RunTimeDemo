//
//  ViewController.m
//  RunTimeDemo
//
//  Created by apple on 16/9/1.
//  Copyright © 2016年 pengjf. All rights reserved.
//
#import <objc/runtime.h>
#import "ViewController.h"
#import "People.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //打印出所有的属性
    [self showProprityWithClassName:"People"];
    //获取IMP并执行SEL(一个是类方法，一个是对象方法)
//    [self getIMPPointer];
//    [self dynamicMethod];
//    //动态方法解析
//    [self setPropritor];
    //重定向
    [self redirect];
    
}


- (void)showProprityWithClassName:(const char*)class{
    
    //通过objc_getClass获取类，详解请看类的结构体
    id personClass = objc_getClass(class);
    unsigned int outCount;
    //获取累的属性
    objc_property_t *properties = class_copyPropertyList(personClass, &outCount);
    //输出属性名称以及属性数据类型
    for (int i=0; i<outCount; i++) {
        objc_property_t propert = properties[i];
        printf("%s:%s\n",property_getName(propert),property_getAttributes(propert));
    }
    //释放
    free(properties);
}
- (void)getIMPPointer{
    
   // 总结：IMP就是一个指针，只要知道IMP的地址就可以使用一个对象去执行这个实现方法(IMP 只能执行类方法)
    
    //定义一个IMP  格式：typedef id (*IMP)(id, SEL, ...);
    void (*methodPointer1)(id,SEL);
     //methodForSelector根据@selector返回IMP指针地址
    methodPointer1 = (void (*)(id,SEL))[[People class] methodForSelector:@selector(showLog)];
    //执行这个IMP
    methodPointer1([People class],@selector(showLog));
    
}

-(void)dynamicMethod{
    
    // 总结：IMP就是一个指针，只要知道IMP的地址就可以使用一个对象去执行这个实现方法(IMP执行这个方法)
    
    People *people = [[People alloc] init];
    //定义一个IMP  格式：typedef id (*IMP)(id, SEL, ...);
    void (*methodPointer2)(id,SEL,BOOL);
    methodPointer2 = (void (*)(id,SEL,BOOL))[people methodForSelector:@selector(test:)];
    methodPointer2([People class],@selector(test:),YES);
    
   
}


//动态方法解析    当 Runtime 系统在 Cache 和类的方法列表(包括父类)中找不到要执行的方法时，Runtime 会调用 resolveInstanceMethod: 或 resolveClassMethod: 来给我们一次动态添加方法实现的机会。我们需要用 class_addMethod 函数完成向特定类添加特定方法实现的操作文／Ammar（简书作者）
//原文链接：http://www.jianshu.com/p/1e06bfee99d0
//著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。

- (void)setPropritor{
    People *people = [[People alloc] init];
    [people resolveThisMethodDynamically];
}

//重定向   消息转发机制执行前，Runtime 系统允许我们替换消息的接收者为其他对象
- (void)redirect{
    People *people = [[People alloc] init];
    NSInteger value = [people manTest];
    NSLog(@"manTest == %ld",(long)value);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
