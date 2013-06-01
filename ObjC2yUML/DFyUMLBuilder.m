//
//  DFyUMLBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 28/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFyUMLBuilder.h"
// Definitions
#import "DFDefinition.h"
#import "DFClassDefinition.h"
#import "DFProtocolDefinition.h"
#import "DFPropertyDefinition.h"

@interface DFyUMLBuilder ()
@property (nonatomic) NSDictionary* definitions;
@property (nonatomic) NSMutableArray* doneProtocols; // track which protocols have already been mapped
@end

@implementation DFyUMLBuilder

- (id)initWithDefinitions:(NSDictionary*)definitions {
    self = [super init];
    if (self) {
        self.definitions = definitions;
        self.doneProtocols = [NSMutableArray array];
    }
    return self;
}

- (NSString*)generate_yUML {
    NSMutableString* code = [NSMutableString string];
    
    // Test
    [self.definitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFDefinition* definition, BOOL *stop) {
        if ([definition isKindOfClass:[DFClassDefinition class]]) {
            DFClassDefinition* classDef = (DFClassDefinition*)definition;
            
            // Superclass relationship. Only include superclasses which are also key classes
            if ([classDef.superclassDef.name length] && [self.definitions objectForKey:classDef.superclassDef.name]) {
                [code appendFormat:@"[%@]^-[%@],\n", classDef.superclassDef.name, classDef.name];
            } else {
                [code appendFormat:@"[%@],\n", classDef.name];
            }
            
            // Implements protocols
            [classDef.protocols enumerateKeysAndObjectsUsingBlock:^(NSString* protocolKey, DFProtocolDefinition* protocolDef, BOOL *stop) {
                if (![[self doneProtocols] containsObject:protocolDef]) {
                    [self.doneProtocols addObject:protocolDef];
                    [code appendFormat:@"[%@{bg:orchid}]^-.-[%@],\n", protocolDef.name, classDef.name];
                    [code appendString:[self generateChildrenOfContainer:protocolDef]];
                }
            }];
            
            [code appendString:[self generateChildrenOfContainer:classDef]];
        }
    }];
    
    return code;
}

- (NSString*)generateChildrenOfContainer:(DFContainerDefinition*)containerDef {
    NSMutableString* code = [NSMutableString string];
    
    // Properties // TODO: typecheck
    [containerDef.childDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFPropertyDefinition* propertyDef, BOOL *stop) {
        if (propertyDef.isWeak) {
            [code appendFormat:@"[%@]+->[%@],\n", containerDef.name, propertyDef.className];
        } else {
            [code appendFormat:@"[%@]++->[%@],\n", containerDef.name, propertyDef.className];
        }
    }];
    return code;
}

@end
