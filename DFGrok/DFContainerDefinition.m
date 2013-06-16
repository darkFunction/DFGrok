//
//  DFEntityDefinition.m
//  DFGrok
//
//  Created by Sam Taylor on 21/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFContainerDefinition.h"
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

@end
