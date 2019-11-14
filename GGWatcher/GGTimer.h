//
//  GGTimer.h
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGTimer : NSObject

// Maximum leeway seconds, default is 0.f;
@property (assign) NSTimeInterval leeway;

@property (assign, readonly) NSTimeInterval interval;
@property (assign, readonly) BOOL repeats;
@property (assign, readonly, getter=isValid) BOOL valid;

// Default is main queue.
@property (strong, nullable) dispatch_queue_t targetQueue;

@property (weak, nullable, readonly) id target;
@property (assign, nullable, readonly) SEL action;

@property (weak, readonly, nullable) id userInfo;

@property (copy, nullable, readonly) void (^block)(GGTimer *timer);

+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats;
+ (instancetype)scheduledTimerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GGTimer *timer))block;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats;
- (instancetype)initWithInterval:(NSTimeInterval)interval target:(id)target action:(SEL)action userInfo:(nullable id)userInfo repeats:(BOOL)repeats NS_DESIGNATED_INITIALIZER;

+ (instancetype)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GGTimer *timer))block;
- (instancetype)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(GGTimer *timer))block NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (void)schedule;

- (void)fire;
- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
