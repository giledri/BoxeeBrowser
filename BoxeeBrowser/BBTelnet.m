//
//  BBTelnet.m
//  BoxeeBrowser
//
//  Created by John Doe on 4/24/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBTelnet.h"

@interface BBTelnet()

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic) NSString *receivedText;
@property (strong, nonatomic) NSMutableArray *expectedTexts;
@property (strong, nonatomic) NSMutableArray *nextCommands;
@property (strong, nonatomic) NSMutableArray *commandsToWrite;

@end

@implementation BBTelnet
/*
@synthesize inputStream;
@synthesize outputStream;
@synthesize receivedText;
@synthesize expectedTexts;
@synthesize nextCommands;
@synthesize commandsToWrite;
*/

- (void)connectToAddress:(NSString *)address AndPort:(UInt32)port
{
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)address, port, &readStream, &writeStream);
    self.inputStream = (__bridge NSInputStream *)readStream;
    self.outputStream = (__bridge NSOutputStream *)writeStream;
    
    [self.inputStream setDelegate:self];
    [self.outputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
    
    self.receivedText = @"";
    self.expectedTexts = [[NSMutableArray alloc] init];
    self.nextCommands = [[NSMutableArray alloc] init];
    self.commandsToWrite = [[NSMutableArray alloc] init];
}

- (void)disconnect
{
    [self.inputStream close];
    [self.outputStream close];
}

- (void)doWriteCommand:(NSString *)command
{
        NSData *data = [[NSData alloc] initWithData:[[command  stringByAppendingString:@"\r"] dataUsingEncoding:NSASCIIStringEncoding]];
        NSLog(@"client writing: %@", command);
        NSInteger result = [self.outputStream write:[data bytes] maxLength:[data length]];
        if (result == -1)
        {
            NSLog(@"Error writing to stream");
        }
}

- (void)writeCommand:(NSString *)command
{
    if ([self.outputStream hasSpaceAvailable])
    {
        [self doWriteCommand:command];
    }
    else
    {
        NSLog(@"Steam is not ready, queuing command");
        [self.commandsToWrite addObject:command];
    }
}

- (void)whenReceive:(NSString *)text writeCommand:(NSString *)command
{
    [self.expectedTexts addObject:text];
    [self.nextCommands addObject:command];
}

- (void)whenReceive:(NSString *)text notifySink:(id <BBTelnetDelegate>)delegate
{
    [self.expectedTexts addObject:text];
    [self.nextCommands addObject:delegate];
}


- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent
{
    typedef enum {
        NSStreamEventNone = 0,
        NSStreamEventOpenCompleted = 1 << 0,
        NSStreamEventHasBytesAvailable = 1 << 1,
        NSStreamEventHasSpaceAvailable = 1 << 2,
        NSStreamEventErrorOccurred = 1 << 3,
        NSStreamEventEndEncountered = 1 << 4
    } events;
    
    uint8_t buffer[1024];
    NSInteger len;
    NSError *theError;
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened now");
            break;
            
        case NSStreamEventHasBytesAvailable:
            NSLog(@"has bytes");
            if (theStream == self.inputStream) {
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                            NSCharacterSet *trimCharacters = [NSCharacterSet characterSetWithCharactersInString:@" "];
                            self.receivedText = [[self.receivedText stringByAppendingString:output] stringByTrimmingCharactersInSet:trimCharacters];
                            
                            NSString * expectedText = [self.expectedTexts firstObject];
                            NSUInteger fromIndex = [self.receivedText length] - [expectedText length];
                            if ([[self.receivedText substringFromIndex:fromIndex] isEqualToString:expectedText])
                            {
                                id command = [self.nextCommands firstObject];
                                if ([command isKindOfClass:[NSString class]])
                                {
                                    [self writeCommand:command];
                                }
                                else if ([command conformsToProtocol:@protocol(BBTelnetDelegate)])
                                {
                                    NSLog(@"notifying caller that expected text was received");
                                    [command expectedTextReceived:expectedText];
                                }
                                else
                                {
                                    NSLog(@"command is not a string and not conformsToProtocol BBTelnetNotifySink, so it is ignored");
                                }
                                
                                self.receivedText = @"";
                                [self.expectedTexts removeObjectAtIndex:0];
                                [self.nextCommands removeObjectAtIndex:0];
                            }
                        }
                    }
                }
            } else {
                NSLog(@"it is NOT theStream == inputStream");
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream has space available now");
            if (theStream == self.outputStream)
            {
                for (NSString *command in self.commandsToWrite)
                {
                    [self writeCommand:command];
                }
                
                [self.commandsToWrite removeAllObjects];
            }
            break;
            
        case NSStreamEventErrorOccurred:
            theError = [theStream streamError];
            NSLog(@"Error on stream: (%li) \"%@\"", (long)[theError code], [theError localizedDescription]);
            break;
            
        case NSStreamEventEndEncountered:
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            break;
            
        default:
            NSLog(@"Unknown event %lu", streamEvent);
    }
    
}

@end
