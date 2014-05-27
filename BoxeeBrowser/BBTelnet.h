//
//  BBTelnet.h
//  BoxeeBrowser
//
//  Created by John Doe on 4/24/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BBTelnetDelegate

- (void)expectedTextReceived:(NSString *)text;

@end

@interface BBTelnet : NSObject <NSStreamDelegate>

- (void)connectToAddress:(NSString *)address AndPort:(UInt32)port;

- (void)disconnect;

- (void)writeCommand:(NSString *)command;

- (void)whenReceive:(NSString *)text writeCommand:(NSString *)command;

- (void)whenReceive:(NSString *)text notifySink:(id <BBTelnetDelegate>)delegate;

@end