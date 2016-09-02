//
//  People.m
//  RunTimeDemo
//
//  Created by apple on 16/9/1.
//  Copyright © 2016年 pengjf. All rights reserved.
//

#import "People.h"
#import <objc/runtime.h>
#import "Man.h"
@implementation People

/*
 RunTime的详解   @dynamic@synthesize区别
 @dynamic 修饰的属性将不会有构造方法，即不会执行Setter，Getter方法
 其getter和setter方法会在程序运行的时候或者用其他方式动态绑定，以便让编译器通过编译
 @synthesize 就是告诉编译器，对这个属性自动生成setter，getter方法
 
 */

/*
 RunTime的详解
 在runtime中 class类的运行时  详细http://www.jianshu.com/p/1e06bfee99d0
     struct objc_class {
     Class isa  OBJC_ISA_AVAILABILITY;    //objc_class 中也有一个 isa 指针
     
     #if !__OBJC2__
     Class super_class                                        OBJC2_UNAVAILABLE;  //记录superClass
     const char *name                                         OBJC2_UNAVAILABLE;   //类名
     long version                                             OBJC2_UNAVAILABLE;
     long info                                                OBJC2_UNAVAILABLE;
     long instance_size                                       OBJC2_UNAVAILABLE;
     struct objc_ivar_list *ivars     //成员属性集合                        OBJC2_UNAVAILABLE;
     struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;            //方法集合（我们可以在这各类里面添加方法，所以我们可以动态为一个类添加方法。这也是类别的实现原理）
     struct objc_cache *cache        //缓存所有的方法
         OBJC2_UNAVAILABLE;
     struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;            //协议的集合
     #endif
     
     } OBJC2_UNAVAILABLE;
 
*/
@dynamic age;
@dynamic weight;

//测试IMP来执行方法
+ (void)showLog{
    NSLog(@"hello ----------类----IMP来执行方法------------");
}
- (void)test:(BOOL)yes{
    if (yes) {
        NSLog(@"hello ----------对象----IMP来执行方法------------");
    }else{
        NSLog(@"hello ----------对象----IMP来执行方法------------");
    }
}


//动态方法解析
//注意：
//动态方法解析会在消息转发机制侵入前执行，动态方法解析器将会首先给予提供该方法选择器对应的 IMP 的机会。如果你想让该方法选择器被传送到转发机制，就让 resolveInstanceMethod: 方法返回 NO。
void hello(id self,SEL _cmd){
    NSLog(@"hello --------------动态方法解析------------");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(resolveThisMethodDynamically)) {
        class_addMethod([self class], sel, (IMP)hello, "v@:");
        return YES;
    }
    return [self resolveInstanceMethod:sel];
}

//重定向   消息转发机制执行前，Runtime 系统允许我们替换消息的接收者为其他对象。通过 - (id)forwardingTargetForSelector:(SEL)aSelector 方法。
//如果此方法返回 nil 或者 self，则会计入消息转发机制(forwardInvocation:)，否则将向返回的对象重新发送消息
- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == @selector(manTest)) {
        Man *man = [[Man alloc] init];
       return nil;
    }
    return  [super forwardingTargetForSelector:aSelector];
}
//转发
//当动态方法解析不做处理返回 NO 时，则会触发消息转发机制。这时 forwardInvocation: 方法会被执行，我们可以重写这个方法来自定义我们的转发逻辑：唯一参数是个 NSInvocation 类型的对象，该对象封装了原始的消息和消息的参数。我们可以实现 forwardInvocation: 方法来对不能处理的消息做一些处理。也可以将消息转发给其他对象处理，而不抛出错误
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    Man *man = [[Man alloc] init];
    if ([man respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:man];
    }else{
        [super forwardInvocation:anInvocation];
    }
}
//必须要重写这个方法,不然就会抛出异常
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (aSelector == @selector(manTest)) {
        NSMethodSignature *sign = [NSMethodSignature signatureWithObjCTypes:"v@:"];
        return sign;
    }
    return nil;
}

/**
 总结：runTime运行时方法的调用就是消息的发送以及消息的接受，接收消息通过IMP去执行实现方法，再这个过程中我们需要深入了解  屏幕快照 2016-09-02 上午10.52.11
 要点：（1）在 forwardInvocation: 消息发送前，Runtime 系统会向对象发送methodSignatureForSelector: 消息，并取到返回的方法签名用于生成 NSInvocation 对象。所以重写 forwardInvocation: 的同时也要重写 methodSignatureForSelector: 方法，否则会抛异常。
 
 （2）当一个对象由于没有相应的方法实现而无法相应某消息时，运行时系统将通过 forwardInvocation: 消息通知该对象。每个对象都继承了 forwardInvocation: 方法。但是， NSObject 中的方法实现只是简单的调用了 doesNotRecognizeSelector:。通过实现自己的 forwardInvocation: 方法，我们可以将消息转发给其他对象。forwardInvocation: 方法就是一个不能识别消息的分发中心，将这些不能识别的消息转发给不同的接收对象，或者转发给同一个对象，再或者将消息翻译成另外的消息，亦或者简单的“吃掉”某些消息，因此没有响应也不会报错。这一切都取决于方法的具体实现。
 
 （3）forwardInvocation:方法只有在消息接收对象中无法正常响应消息时才会被调用。所以，如果我们向往一个对象将一个消息转发给其他对象时，要确保这个对象不能有该消息的所对应的方法。否则，forwardInvocation:将不可能被调用。
 
    可以在一个类里面定义方法，使用另一个类来实现这个方法
 
 **/

@end
