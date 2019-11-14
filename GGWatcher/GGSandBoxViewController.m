//
//  GGSandBoxViewController.m
//  GGWatcher
//
//  Created by wxiubin on 2019/11/14.
//  Copyright © 2019 iosgg. All rights reserved.
//

#import "GGSandBoxViewController.h"

@interface GGSandBoxViewController ()

@property (nonatomic, strong) NSMutableArray *files;

@property (nonatomic, strong) NSFileManager  *fileManager;

@end

@implementation GGSandBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"沙盒管理";
    [self.navigationController setNavigationBarHidden:NO];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editSandbox:) ];

    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"SANDBOX_CELL"];

    if (!self.filePath) self.filePath = NSHomeDirectory();

    self.fileManager = [NSFileManager defaultManager];
    self.files = [NSMutableArray arrayWithArray: [self.fileManager contentsOfDirectoryAtPath:self.filePath error:nil]];
}

- (void)editSandbox:(id)sender {
    self.tableView.editing = !self.tableView.editing;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SANDBOX_CELL" forIndexPath:indexPath];
    cell.textLabel.text = self.files[indexPath.row];
    NSString *subPath = [self.filePath stringByAppendingPathComponent:self.files[indexPath.row]];
    BOOL directiory = NO;
    [_fileManager fileExistsAtPath:subPath isDirectory:&directiory];
    cell.accessoryType = directiory ? UITableViewCellAccessoryDisclosureIndicator :UITableViewCellAccessoryNone;

    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle ) {
        NSString *subPath = [self.filePath stringByAppendingPathComponent:self.files[indexPath.row]];
        NSError *error = nil;
        [_fileManager removeItemAtPath:subPath error:&error];
        if (!error) {
            [self.files removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            NSLog(@"delete failed at path:%@", subPath);
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *current = self.files[indexPath.row];
    NSString *subPath = [self.filePath stringByAppendingPathComponent:current];
    BOOL directiory = NO;
    [_fileManager fileExistsAtPath:subPath isDirectory:&directiory];

    if (directiory) {
        GGSandBoxViewController *controller = [[self.class alloc] init];
        controller.title = current;
        controller.filePath = subPath;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        [self shareDocumentPath:subPath];
    }
}

// 分享沙盒地址
- (void)shareDocumentPath:(NSString *_Nonnull)path {

    NSArray *objectsToShare = @[[NSURL fileURLWithPath:path]];

    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
                                    UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    controller.excludedActivityTypes = excludedActivities;

    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        controller.popoverPresentationController.sourceView = self.view;
        controller.popoverPresentationController.sourceRect = CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height, 10, 10);
    }
    [self presentViewController:controller animated:YES completion:nil];
}

@end
