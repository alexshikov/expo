// Copyright 2016-present 650 Industries. All rights reserved.

#import <ReactABI18_0_0/ABI18_0_0RCTBridgeModule.h>

@interface ABI18_0_0EXFileSystem : NSObject <ABI18_0_0RCTBridgeModule>

+ (BOOL)ensureDirExistsWithPath:(NSString *)path;

@end