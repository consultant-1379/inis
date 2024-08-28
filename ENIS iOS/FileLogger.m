//
//  FileLogger.m
//  ENIS
//
//  Created by Patrick Russell on 24/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import "FileLogger.h"
#import "SSKeychain.h"

@implementation FileLogger
- (void)dealloc {
    [logFile release]; logFile = nil;
    [super dealloc];
}

- (id) init {   
    if (self == [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"application.log"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath]){
            [fileManager createFileAtPath:filePath
                                 contents:nil
                               attributes:nil];
            FLog(@"IOS Version: %@", [[UIDevice currentDevice] systemVersion]);
            FLog(@"Device Type: %@", [[UIDevice currentDevice] name]);
            NSString *retrieveuuid = [SSKeychain passwordForService:@"com.ericsson.nis" account:@"user"];
            FLog(@"Device UUID is: %@", retrieveuuid);
            
        }
        logFile = [[NSFileHandle fileHandleForWritingAtPath:filePath] retain];
        [logFile seekToEndOfFile];
        
    }
    return self;
}

- (void)log:(NSString *)format, ... {    
    va_list ap;
    va_start(ap, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    NSLog(@"%@",message);
    [logFile writeData:[[message stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [logFile synchronizeFile];
    [message release];
    
}

+ (FileLogger *)sharedInstance {
    static FileLogger *instance = nil;
    if (instance == nil) instance = [[FileLogger alloc] init];
    return instance;
}

@end
