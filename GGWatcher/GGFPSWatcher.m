//
//  GGFPSWatcher.m
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GGFPSWatcher.h"

@class GGFPSMonitorCore;
@protocol GGFPSMonitorCoreDelegate <NSObject>

- (void)fpsMonitorCore:(GGFPSMonitorCore *)fpsMonitorCore fps:(CGFloat)fps;

@end

@interface GGFPSMonitorCore : NSObject

@property (nonatomic, weak, nullable) id<GGFPSMonitorCoreDelegate> delegate;

/**
 * Appoint any runloop arugment. default is main runloop
 */
@property (nonatomic) NSRunLoop *customRunloop;

/**
 * Appoint any runloop mode. default is common mode
 */
@property (nonatomic) NSRunLoopMode customRunloopMode;

/**
 * Start FPS monitor. Receive result from delegate
 * Core code is CADisplayLink.
 */
- (void)startMonitoring;

/**
 * Stop FPS monitor.
 */
- (void)stopMonitoring;

@end

@implementation GGFPSMonitorCore {
    CADisplayLink *_displayLink;
    NSTimeInterval _beginTime;
    CGFloat _fps;
    NSUInteger _count;
}

- (instancetype)init {
    if (self = [super init]) {
        _customRunloop = [NSRunLoop mainRunLoop];
        _customRunloopMode = NSRunLoopCommonModes;
    }
    return self;
}

- (void)startMonitoring {
    if (_displayLink) return;

    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(_displayLinkTick:)];
    [_displayLink addToRunLoop:_customRunloop forMode:_customRunloopMode];
}

- (void)stopMonitoring {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }

    _fps = 0.f;
    _beginTime = 0.f;
    _count = 0;
}

- (void)_displayLinkTick:(CADisplayLink *)link {
    if (_beginTime == 0) {
        _beginTime = link.timestamp;
        return;
    }
    _count++;

    NSTimeInterval interval = link.timestamp - _beginTime;
    if (interval < 1) return;

    _fps = _count / interval;

    // delegate result fps number
    if (_delegate && [_delegate respondsToSelector:@selector(fpsMonitorCore:fps:)]) {
        [_delegate fpsMonitorCore:self fps:_fps];
    }

    _beginTime = link.timestamp;
    _count = 0;
}

@end

@interface GGFPSWatcher () <GGFPSMonitorCoreDelegate>

@end

@implementation GGFPSWatcher {
    GGFPSMonitorCore *_core;
    CGFloat _fps;
}

- (instancetype)init {
    if (self = [super init]) {
        _core = [[GGFPSMonitorCore alloc] init];
        _core.delegate = self;
    }
    return self;
}

- (NSString *)identifier {
    return @"FPS";
}

- (GGWatcherReport *)report {
    return [[GGWatcherReport alloc] initWithValue:[NSString stringWithFormat:@"%2.f", _fps]];
}

- (void)start {
    [super start];
    [_core startMonitoring];
}

- (void)stop {
    [super stop];
    [_core stopMonitoring];
}

#pragma mark - GGFPSMonitorCoreDelegate

- (void)fpsMonitorCore:(GGFPSMonitorCore *)fpsMonitorCore fps:(CGFloat)fps {
    _fps = fps;
}

@end
