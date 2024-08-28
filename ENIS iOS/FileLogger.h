//
//  FileLogger.h
//  ENIS
//
//  Created by Patrick Russell on 24/04/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

@interface FileLogger : NSObject {
    
    NSFileHandle *logFile;
    
}

+ (FileLogger *)sharedInstance;

- (void)log:(NSString *)format, ...;

@end

#define FLog(fmt, ...) [[FileLogger sharedInstance] log:fmt, ##__VA_ARGS__]
