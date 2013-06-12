//
//  DFyUMLBuilder.m
//  DFGrok
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

// Note, in yUML, the first in a relationship pait is placed ABOVE the second in the pair. So it is better to use
// SUPERCLASS_OF and IMPLEMENTED_BY.

#define OWNS_WEAK       @"+->"
#define OWNS_STRONG     @"++->"
#define IMPLEMENTS      @"-.-^"
#define SUBCLASSES      @"-^"
#define SUPERCLASS_OF   @"^-"
#define IMPLEMENTED_BY  @"^-.-"

@interface DFyUMLBuilder ()
@property (nonatomic) NSDictionary* definitions;
@property (nonatomic) NSDictionary* keyDefinitions;
@property (nonatomic) NSMutableArray* doneProtocols; // track which protocols have already been mapped
@property (nonatomic) NSDictionary* colourPairs;
@end

@implementation DFyUMLBuilder

- (id)initWithDefinitions:(NSDictionary*)definitions
            keyDefintions:(NSDictionary*)keyDefinitions
           andColourPairs:(NSDictionary*)colourPairs {
    
    self = [super init];
    if (self) {
        self.definitions = definitions;
        self.keyDefinitions = keyDefinitions;
        self.doneProtocols = [NSMutableArray array];
        self.colourPairs = colourPairs;
    }
    return self;
}

- (NSString*)generate_yUML {
    NSMutableString* code = [NSMutableString string];
    
    [self.keyDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFDefinition* definition, BOOL *stop) {
        if ([definition isKindOfClass:[DFClassDefinition class]]) {
            DFClassDefinition* classDef = (DFClassDefinition*)definition;
            
            // Create the object with colours, methods or whatever
            [code appendString:[self printInitialDefinition:definition]];
            
            // Superclass relationship. Only include superclasses which are also key definitions
            if ([classDef.superclassDef.name length]) {// && [self.keyDefinitions objectForKey:classDef.superclassDef.name]) {
                [code appendFormat:@"[%@]%@[%@]\n", classDef.superclassDef.name, SUPERCLASS_OF, classDef.name];
            } else {
                [code appendFormat:@"[%@],\n", classDef.name];
            }
            
            // Implements protocols
            [classDef.protocols enumerateKeysAndObjectsUsingBlock:^(NSString* protocolKey, DFProtocolDefinition* protocolDef, BOOL *stop) {
                if (![[self doneProtocols] containsObject:protocolDef]) {
                    [self.doneProtocols addObject:protocolDef];
                    [code appendFormat:@"[%@]%@[%@],\n", protocolDef.name, IMPLEMENTED_BY,classDef.name];
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
        if ([self.keyDefinitions objectForKey:propertyDef.className]) {
            [code appendFormat:@"[%@]%@[%@],\n", containerDef.name, (propertyDef.isWeak ? OWNS_WEAK : OWNS_STRONG), ((DFDefinition*)[self.definitions objectForKey:propertyDef.className]).name];
        }
    }];
    return code;
}

- (NSString*)printInitialDefinition:(DFDefinition*)definition {
    NSString* colour = [self.colourPairs objectForKey:definition.name];
    
    if (!colour) {
        if ([definition isKindOfClass:[DFClassDefinition class]]) {
            colour = [self colourForClassDefinition:(DFClassDefinition*)definition];
        }
    }
    
    if ([colour length]) {
        return [NSString stringWithFormat:@"[%@{bg:%@}]", definition.name, colour];
    }
    return [NSString stringWithFormat:@"[%@]", definition.name];
}

- (NSString*)colourForClassDefinition:(DFClassDefinition*)classDef {
    DFClassDefinition* superDef = nil;
    NSString* colour = nil;
    
    do {
        DFClassDefinition* superDef = classDef.superclassDef;
        colour = [self.colourPairs objectForKey:superDef];
        if (colour)
            break;
    } while (superDef);
    
    return colour;
}

@end
