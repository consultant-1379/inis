//
//  POPReciever.h
//  ENIS
//
//  Created by Patrick Russell on 30/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BsimFileContents.h"
#import "Response.h"
#import "CkoEmail.h"

@interface POPReciever : NSObject{    
    
    BsimFileContents *bsimFile;
}
@property (nonatomic, retain) BsimFileContents *bsimFile;

-(NSMutableArray *)getNewItemsFromEmail;

@end
