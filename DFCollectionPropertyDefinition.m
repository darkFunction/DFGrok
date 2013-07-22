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
@property (nonatomic) NSMutableArray* cachedProtocolNames;
@property (nonatomic, readwrite, getter = isWeak) BOOL weak;
@end

@implementation DFCollectionPropertyDefinition

- (id)initWithContainerDefintion:(DFContainerDefinition*)containerDef
                            name:(NSString*)name
                          isWeak:(BOOL)weak {
    
    self = [super initWithName:name];
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
    if (!self.cachedProtocolNames && self.containerDef.protocols.count) {
        self.cachedProtocolNames = [NSMutableArray arrayWithCapacity:self.containerDef.protocols.count];
        
        [self.containerDef.protocols enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self.cachedProtocolNames addObject:key];
        }];
    }
    
    return self.cachedProtocolNames;
}

- (BOOL)isMultiple {
    return YES;
}

@end
