//
//  People.h
//  RunTimeDemo
//
//  Created by apple on 16/9/1.
//  Copyright © 2016年 pengjf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface People : NSObject
@property (nonatomic,strong)NSString *name;
@property (nonatomic,assign)NSInteger age;

@property (nonatomic,strong)NSString *ID;
@property (nonatomic,assign)float weight;


//定义一个IMP执行的方法  N：在这里表示只能使用加号方法
+ (void)showLog;

- (void)test:(BOOL)yes;

- (void)resolveThisMethodDynamically;

- (NSInteger)manTest;
@end
