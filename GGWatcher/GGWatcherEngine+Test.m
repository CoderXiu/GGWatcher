//
//  GGWatcherEngine+Test.m
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#import "GGWatcherEngine+Test.h"

#import "GGWatcher+Engine.h"

#import "GGSandBoxViewController.h"

@implementation GGWatcherEngine (Test)

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _test];
    });
}

+ (void)_test {
    GGWatcherEngine *engine = [GGWatcherEngine engine];
    engine.logger = ^(NSDictionary<NSString *,GGWatcherReport *> * _Nonnull logs) {
        [self log:logs];
    };
    [engine start];

    UIButton *sandBox = [UIButton new];
    sandBox.frame = CGRectMake(100, 100, 60, 44);
    sandBox.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [sandBox setTitle:@"沙盒" forState:(UIControlStateNormal)];
    [[UIApplication sharedApplication].keyWindow addSubview:sandBox];
    [sandBox addTarget:self action:@selector(_openSandBox) forControlEvents:(UIControlEventTouchUpInside)];
}

+ (void)log:(NSDictionary<NSString *,GGWatcherReport *> *)logs {
    static int time = 0;
    const int max = 180;
    static NSMutableString *message;
    if (!message) {
        message = [NSMutableString string];
        [logs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, GGWatcherReport * _Nonnull obj, BOOL * _Nonnull stop) {
            [message appendFormat:@"%@          ", key];
        }];
        [message appendString:@"\n"];
    }

    [logs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, GGWatcherReport * _Nonnull obj, BOOL * _Nonnull stop) {
        [message appendFormat:@"%@          ", obj.value];
    }];
    [message appendString:@"\n"];

    if (time++ > max) {
        time = 0;
        [self write:message];
        message = nil;
    }
}

+ (void)write:(NSString *)message {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *fileName = [NSString stringWithFormat:@"%@.txt", NSDate.date.description];;
    NSString *path = [paths.firstObject stringByAppendingPathComponent:fileName];
    NSError *error;
    [message writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];

}

+ (void)_openSandBox {
    UINavigationController *root = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([root isKindOfClass:UINavigationController.class]) {
        [root pushViewController:GGSandBoxViewController.new animated:YES];
    } else {
        UIViewController *vc = GGSandBoxViewController.new;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        [root presentViewController:navi animated:YES completion:nil];
    }
}

@end
