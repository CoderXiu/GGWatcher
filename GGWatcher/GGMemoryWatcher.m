//
//  GGMemoryWatcher.m
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#include <mach/mach.h>

#import "GGMemoryWatcher.h"

@interface MDMemoryMonitorCore : NSObject

/**
 * Aplication usage memory calculation
 @return memory unit MB
 */
+ (SInt64)applicationUseMemory;

/**
 * The Device Max memory number
 @return max memory. unit MB
 */
+ (SInt64)deviceTotalMemory;

/**
 * The Device can be use free memory.

 @return free memory. unit bytes
 */
+ (SInt64)deviceFreeMemory;

@end

@implementation MDMemoryMonitorCore

int64_t application_use_memory(void) {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    int64_t useMemory = (int64_t) vmInfo.phys_footprint;
    return (kernelReturn == KERN_SUCCESS) ? (useMemory / 1024 / 1024) : -1; // size in bytes
}

int64_t device_free_memory(void) {
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return 0;
    }

    return vm_page_size * (vmStats.free_count + vmStats.inactive_count);
}

+ (SInt64)applicationUseMemory {
    return application_use_memory();
}

+ (SInt64)deviceFreeMemory {
    return device_free_memory();
}

+ (SInt64)deviceTotalMemory {
    return [NSProcessInfo processInfo].physicalMemory / 1024 / 1024;
}

@end

@implementation GGMemoryWatcher

- (NSString *)identifier {
    return @"Memory";
}

- (GGWatcherReport *)report {
    return [[GGWatcherReport alloc] initWithValue:@(MDMemoryMonitorCore.applicationUseMemory).stringValue];
}

@end
