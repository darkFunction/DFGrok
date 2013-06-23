//
//  DFEntityDefinition.m
//  DFGrok
//
//  Created by Sam Taylor on 21/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFContainerDefinition.h"
#import "DFProtocolDefinition.h"

@interface DFContainerDefinition ( /* Private */ )
@property (nonatomic, readwrite) NSMutableDictionary* childDefinitions;
@property (nonatomic, readwrite) NSMutableDictionary* protocols;
@end

@implementation DFContainerDefinition

- (id)initWithName:(NSString *)name {
    self = [super initWithName:name];
    if (self) {
        self.protocols = [NSMutableDictionary dictionary];
        self.childDefinitions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)implementsProtocolDefinition:(DFProtocolDefinition*)protoDef {
    if ([self.protocols objectForKey:protoDef.name]) {
        return YES;
    }
    
    // Search protocols recursively
    __block BOOL found = NO;
    [self.protocols enumerateKeysAndObjectsUsingBlock:^(id key, DFProtocolDefinition* containerProtoDef, BOOL *stop) {
        if ([containerProtoDef implementsProtocolDefinition:protoDef]) {
            found = YES;
            *stop = YES;
        }
    }];
    
    return found;
}

@end
