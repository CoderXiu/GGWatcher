//
//  GGWatcher.m
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#import "GGWatcher.h"

#import "GGTimer.h"

@implementation GGWatcherReport

- (instancetype)initWithValue:(NSString *)value {
    if (self = [super init]) {
        _value = value.copy;
        _timestamp = self.class.currentTimeStamp;
    }
    return self;
}

+ (NSString *)currentTimeStamp {
    time_t current = time(NULL);
    struct tm *currentTime = localtime(&current);
    return [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d",
            currentTime->tm_year + 1900,
            currentTime->tm_mon + 1,
            currentTime->tm_mday,
            currentTime->tm_hour,
            currentTime->tm_min,
            currentTime->tm_sec];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_value forKey:NSStringFromSelector(@selector(value))];
    [aCoder encodeObject:_timestamp forKey:NSStringFromSelector(@selector(timestamp))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _value = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(value))];
        _timestamp = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(timestamp))];
    }
    return self;
}

@end

@implementation GGWatcher

@synthesize identifier, interval, running;

- (void)start {}

- (void)stop {}

- (GGWatcherReport *)report { return nil; }

@end

@interface GGWatcherEngine () {
    GGTimer *_timer;
    NSMutableDictionary<NSString *, GGWatcher *> *_watchers;
}

@end

@implementation GGWatcherEngine

- (instancetype)init {
    if (self = [super init]) {
        self.timeInterval = 1.f;
        _watchers = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Public

- (NSDictionary<NSString *,GGWatcher *> *)watchers {
    return _watchers.copy;
}

- (void)addWatcher:(GGWatcher *)watcher {
    if (![watcher isKindOfClass:GGWatcher.class]) {
        return;
    }
    _watchers[watcher.identifier] = watcher;
    if (_running && !watcher.isRunning) [watcher start];
}

- (void)removeWatcher:(GGWatcher *)watcher {
    if (!watcher) return;
    _watchers[watcher.identifier] = nil;
}

- (void)start {
    if (_timer.isValid) return;

    for (GGWatcher *watcher in _watchers.allValues) {
        if (!watcher.isRunning) [watcher start];
    }

    _running = YES;
    _timer = [GGTimer timerWithInterval:self.timeInterval target:self action:@selector(_watch) userInfo:nil repeats:YES];
    _timer.targetQueue = dispatch_get_global_queue(0, 0);
    [_timer schedule];
}

- (void)stop {
    [_timer invalidate];
    _running = NO;
}

#pragma mark - Private

- (void)_watch {
    NSMutableDictionary *log = [NSMutableDictionary dictionary];
    for (GGWatcher *watcher in [_watchers allValues]) {
        log[watcher.identifier] = watcher.report;
    }
    [self _watcherEngie:self log:log];
}

- (void)_watcherEngie:(GGWatcherEngine *)engine log:(NSDictionary *)logs {
    if (self.logger) {
        self.logger(logs);
    }
}

@end
