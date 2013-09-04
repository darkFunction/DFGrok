//
//  DFCollectionPropertyDefinition.m
//  DFGrok
//
//  Created by Sam Taylor on 20/07/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFCollectionPropertyDefinition.h"

@interface DFCollectionPropertyDefinition ( /* Private */ )
@property (nonatomic) NSArray* protocolNames;
@property (nonatomic, readwrite) NSString* typeName;
@property (nonatomic, readwrite, getter = isWeak) BOOL weak;
@end

@implementation DFCollectionPropertyDefinition

- (id)initWithTypeName:(NSString*)typeName
         protocolNames:(NSArray*)protocolNames
                  name:(NSString*)name
                isWeak:(BOOL)weak {
    
    self = [super initWithName:name];
    if (self) {
        self.typeName = typeName;
        self.protocolNames = protocolNames;
        self.weak = weak;
    }
    return self;
}

#pragma mark - DFPropertyDefintionInterface

- (BOOL)isMultiple {
    return YES;
}

@end
