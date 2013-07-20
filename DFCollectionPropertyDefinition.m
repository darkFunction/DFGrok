//
//  DFCollectionPropertyDefinition.m
//  DFGrok
//
//  Created by Sam Taylor on 20/07/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFCollectionPropertyDefinition.h"
#import "DFContainerDefinition.h"

@interface DFCollectionPropertyDefinition ( /* Private */ )
@property (nonatomic) DFContainerDefinition* containerDef;
@property (nonatomic) NSMutableArray* protocolNames;
@property (nonatomic, readwrite, getter = isWeak) BOOL weak;
@end

@implementation DFCollectionPropertyDefinition

- (id)initWithContainerDefintion:(DFContainerDefinition*)containerDef isWeak:(BOOL)weak {
    self = [super initWithName:containerDef.name];
    if (self) {
        self.containerDef = containerDef;
        self.weak = weak;
    }
    return self;
}

#pragma mark - DFPropertyDefintionInterface

- (NSString*)className {
    return self.containerDef.name;
}

- (NSMutableArray*)protocolNames {
    if (!self.protocolNames && self.containerDef.protocols.count) {
        self.protocolNames = [NSMutableArray arrayWithCapacity:self.containerDef.protocols.count];
        
        [self.containerDef.protocols enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.protocolNames addObject:key];
        }];
    }
    
    return self.protocolNames;
}

- (BOOL)isMultiple {
    return YES;
}

@end
