//
//  DFDefinition.m
//  DFGrok
//
//  Created by Sam Taylor on 21/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFDefinition.h"
#import "DFContainerDefinition.h"

@interface DFDefinition ( /* Private */ )
@property (nonatomic, copy, readwrite) NSString* name;
@end

@implementation DFDefinition

- (id)initWithName:(NSString*)name {
    if (![name length]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.name = name;
    }
    return self;
}

@end
