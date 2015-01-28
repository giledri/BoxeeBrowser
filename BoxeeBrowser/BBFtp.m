	//
//  BBFtp.m
//  BoxeeBrowser
//
//  Created by John Doe on 4/25/14.
//  Copyright (c) 2014 Gil Edri. All rights reserved.
//

#import "BBFtp.h"

@interface BBFtp()

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *localPath;

@property (strong, nonatomic)NSString *serverAddress;
@property (strong, nonatomic)id <BBFtpDelegate> eventSink;

@property (strong, nonatomic)NSMutableArray *pendingFiles;
@property (strong, nonatomic)NSMutableArray *pendingTargets;

@end

@implementation BBFtp

- (void)initWithAddress:(NSString *)address andEventSink:(id <BBFtpDelegate>) delegate
{
    self.serverAddress = address;
    self.eventSink = delegate;
    
    self.pendingFiles = [[NSMutableArray alloc] init];
    self.pendingTargets = [[NSMutableArray alloc] init];
}

- (void)downloadFile:(NSString *)filePath toLocalPath:(NSString *)targetPath
{
    if (self.fileName != nil)
    {
        [self.pendingFiles addObject:filePath];
        [self.pendingTargets addObject:targetPath];
        
        return;
    }
    
    [self doDownloadFile:filePath toLocalPath:targetPath];
}

- (void)doDownloadFile:(NSString *)filePath toLocalPath:(NSString *)targetPath
{
    self.fileName = [targetPath lastPathComponent];
    self.localPath = targetPath;
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@/%@", self.serverAddress, filePath]];

    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.localPath append:NO];
    assert(self.outputStream != nil);
    [self.outputStream open];
    
    self.inputStream = CFBridgingRelease(CFReadStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url));
    assert(self.inputStream != nil);
    
    [self.inputStream setDelegate:self];
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)eventCode
{
    NSInteger   bytesRead;
    uint8_t     buffer[32768];
    NSError     *theError;
    
    switch (eventCode)
    {
        case NSStreamEventOpenCompleted:
            NSLog(@"Opened connection");
            break;
            
        case NSStreamEventHasBytesAvailable:
            //NSLog(@"has bytes");
            
            bytesRead = [self.inputStream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == -1)
            {
                [self stopReceiveWithError:@"Network read error"];
            }
            else if (bytesRead == 0)
            {
                NSLog(@"download completed");
                [self stopReceive];
                [self.eventSink downloadCompleted:self.fileName toLocalPath:self.localPath];
                
                if (self.pendingFiles.count > 0)
                {
                    NSString *filePath = [self.pendingFiles firstObject];
                    NSString *targetPath = [self.pendingTargets firstObject];
                    
                    [self.pendingFiles removeObjectAtIndex:0];
                    [self.pendingTargets removeObjectAtIndex:0];
                    
                    [self doDownloadFile:filePath toLocalPath:targetPath];
                }
            }
            else
            {
                //NSLog(@"Receiving");
                
                NSInteger   bytesWritten;
                NSInteger   bytesWrittenSoFar;
                
                // Write to the file.
                
                bytesWrittenSoFar = 0;
                do {
                    bytesWritten = [self.outputStream write:&buffer[bytesWrittenSoFar] maxLength:(NSUInteger) (bytesRead - bytesWrittenSoFar)];
                    
                    if (bytesWritten == -1)
                    {
                        [self stopReceiveWithError:@"File write error"];
                        break;
                    }
                    
                    bytesWrittenSoFar += bytesWritten;
                    
                } while (bytesWrittenSoFar != bytesRead);
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            // should never happen for the output stream
            NSLog(@"Event not expected %lu", eventCode);
            break;
            
        case NSStreamEventErrorOccurred:
            theError = [theStream streamError];
            NSLog(@"Error on stream: (%li) \"%@\"", (long)[theError code], [theError localizedDescription]);
            break;
            
        case NSStreamEventEndEncountered:
            NSLog(@"end encountered");
            // ignore
            break;

        default:
            NSLog(@"Unknown event %lu", eventCode);
            break;
    }
}

- (void)stopReceive
{
    [self stopReceiveWithError:nil];
}

- (void)stopReceiveWithError:(NSString *)errorString
{
    if (errorString != nil)
    {
        NSLog(@"%@", errorString);
        [self.eventSink downloadFailed:self.fileName withError:errorString];
    }
    
    if (self.inputStream != nil)
    {
        [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.inputStream.delegate = nil;
        [self.inputStream close];
        self.inputStream = nil;
    }
    
    if (self.outputStream != nil)
    {
        [self.outputStream close];
        self.outputStream = nil;
    }
}

@end
