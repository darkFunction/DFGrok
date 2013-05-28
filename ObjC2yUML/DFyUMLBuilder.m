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
@end

@implementation DFyUMLBuilder

- (id)initWithDefinitions:(NSDictionary*)definitions {
    self = [super init];
    if (self) {
        self.definitions = definitions;
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
                [code appendFormat:@"[<%@>]^-.-[%@],\n", protocolDef.name, classDef.name];
            }];
            
            // Properties
            [classDef.childDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFPropertyDefinition* propertyDef, BOOL *stop) {
                // Only map properties that corresspond to key classes, or protocols which key classes implement
                __block BOOL map = NO;
                if ([self.definitions objectForKey:propertyDef.classDefinition.name]) {
                    map = YES;
                }
                NSLog(@"%@", propertyDef.classDefinition.name);
//                [self.definitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFDefinition* definition, BOOL *stop) {
//                    if ([definition isKindOfClass:[DFClassDefinition class]]) {
//                        DFClassDefinition* classDef = (DFClassDefinition*)definition;
//                        if ([classDef.protocols objectForKey:propertyDef.classDefinition.name]) {
//                            map = YES;
//                            *stop = YES;
//                        }
//                    }
//                }];
                
                if (map) {
                    if (propertyDef.isWeak) {
                        [code appendFormat:@"[%@]+->[%@],\n", classDef.name, propertyDef.classDefinition.name];
                    } else {
                        [code appendFormat:@"[%@]++->[%@],\n", classDef.name, propertyDef.classDefinition.name];
                    }
                }
            }];
        }
    }];
    
    return code;
}

@end
