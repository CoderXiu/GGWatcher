//
//  GGWatcher.h
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGWatcherReport : NSObject <NSCoding>

@property (nonatomic, copy, nullable, readonly) NSString *value;
@property (nonatomic, copy, nullable, readonly) NSString *timestamp;

@property (nonatomic, copy, class, readonly) NSString *currentTimeStamp;

- (instancetype)initWithValue:(NSString *)value;

@end

@protocol GGWatcher <NSObject>

@property (nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, assign) NSTimeInterval interval;

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

- (void)start;

- (void)stop;

- (nullable GGWatcherReport *)report;

@end

@interface GGWatcher : NSObject <GGWatcher>

@end


@interface GGWatcherEngine : NSObject

/// default is 1.f
@property (nonatomic, assign) NSTimeInterval timeInterval;

@property (nonatomic, assign, readonly, getter=isRunning) BOOL running;

@property (nonatomic, copy) NSDictionary<NSString *, GGWatcher *> *watchers;

@property (nonatomic, copy) void(^logger)(NSDictionary<NSString *, GGWatcherReport *> *logs);

- (void)addWatcher:(GGWatcher *)watcher;
- (void)removeWatcher:(GGWatcher *)watcher;

- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
