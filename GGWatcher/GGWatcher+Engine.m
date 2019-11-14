//
//  GGWatcher+Engine.m
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#import "GGWatcher+Engine.h"

#import "GGMemoryWatcher.h"
#import "GGFPSWatcher.h"
#import "GGCPUWatcher.h"

@implementation GGWatcherEngine (Engine)

+ (instancetype)engine {
    static GGWatcherEngine *engine = nil;
    if (!engine) {
        engine = [GGWatcherEngine new];
        [engine addWatcher:GGCPUWatcher.new];
        [engine addWatcher:GGFPSWatcher.new];
        [engine addWatcher:GGMemoryWatcher.new];
    }
    return engine;
}

@end
