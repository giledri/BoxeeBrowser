//
//  BBFtp.h
//  BoxeeBrowser
//
//  Created by John Doe on 4/25/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBFtpDelegate <NSObject>

- (void)downloadCompleted:(NSString *)filename toLocalPath:(NSString *)path;
- (void)downloadFailed:(NSString *)filename withError:(NSString *)errorString;

@end

@interface BBFtp : NSObject <NSStreamDelegate>

- (void)initWithAddress:(NSString *)address andEventSink:(id <BBFtpDelegate>) delegate;
- (void)downloadFile:(NSString *)filePath toLocalPath:(NSString *)targetPath;

@end
