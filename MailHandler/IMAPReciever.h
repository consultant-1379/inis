//
//  IMAPReciever.h
//  ENIS
//
//  Created by Patrick Russell on 02/05/2012.
//  Copyright (c) 2012 Ericsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BsimFileContents.h"
#import "CkoImap.h"

bool forceSecurity;

@interface IMAPReciever : NSObject{
    
    BsimFileContents *bsimFile;
    CkoImap *imap;
    Properties *props;
    bool useSsl;
}

@property (nonatomic, retain) BsimFileContents *bsimFile;
@property (nonatomic, retain) CkoImap *imap;
@property bool useSsl;
@property (nonatomic, retain) Properties *props;

-(NSArray *)getNewItemsFromEmail;

@end
