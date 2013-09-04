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
#import "DFPropertyDefinitionInterface.h"

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
@property (nonatomic) NSDictionary* keyClassDefinitions;
@property (nonatomic) NSDictionary* colourPairs;
@property (nonatomic) NSMutableArray* printedDefs;
// TODO: move into model builder? Virtual class defs are defs created from properties that don't represent an actual class and its protocols, eg, UIView<SomeProtocol> - doesn't exist but we need to model it
@property (nonatomic) NSMutableArray* virtualDefs;
@end

@implementation DFyUMLBuilder

- (id)initWithDefinitions:(NSDictionary*)definitions
      keyClassDefinitions:(NSDictionary*)keyClassDefinitions
           andColourPairs:(NSDictionary*)colourPairs {
    
    self = [super init];
    if (self) {
        self.definitions = definitions;
        self.keyClassDefinitions = keyClassDefinitions;
        self.printedDefs = [NSMutableArray array];
        self.virtualDefs = [NSMutableArray array];
        self.colourPairs = colourPairs;
    }
    return self;
}

- (NSString*)generate_yUML {
    NSMutableString* code = [NSMutableString string];

    [self.keyClassDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFClassDefinition* classDef, BOOL *stop) {
        
        // Superclass relationship. Only include superclasses which are also key definitions
        if ([self shouldPrintContainer:classDef.superclassDef]) {
            [code appendFormat:@"%@%@%@\n", [self printClass:classDef.superclassDef], SUPERCLASS_OF, [self printClass:classDef]];
        } else {
            [code appendFormat:@"%@,\n", [self printClass:classDef]];
        }

        // Protocols
        [code appendString:[self generateProtocolsOfClass:classDef]];
        
        // Properties
        [code appendString:[self generateChildrenOfClass:classDef]];
    }];
    
    // Link the virtual defs with their concrete counterparts.
    // TODO: optimise this junk
    [self.virtualDefs enumerateObjectsUsingBlock:^(DFClassDefinition* virtualDef, NSUInteger idx, BOOL *stop) {
        [self.printedDefs enumerateObjectsUsingBlock:^(DFClassDefinition* def, NSUInteger idx, BOOL *stop) {

            if ([virtualDef isSubclassOf:def]) {
                [code appendFormat:@"%@%@%@,\n", [self printClass:def], SUPERCLASS_OF, [self printClass:virtualDef includeProtocols:YES]];
            } else {
                // If the def has a superclass which is also a subclass of the virtual def, don't show the relationship here as it will be shown higher up
                if (! [def.superclassDef isSubclassOf:virtualDef]) {
                    if ([def isSubclassOf:virtualDef]) {
                        [code appendFormat:@"%@%@%@,\n", [self printClass:virtualDef includeProtocols:YES], IMPLEMENTED_BY, [self printClass:def]];
                    }
                }
            }
        }];
    }];
    
    
    return code;
}

- (NSString*)generateProtocolsOfClass:(DFClassDefinition*)classDef {
    return [self generateProtocolsOfContainer:classDef withConcreteAdopter:classDef];
}

- (NSString*)generateProtocolsOfContainer:(DFContainerDefinition*)containerDef withConcreteAdopter:(DFClassDefinition*)classDef {
    
    NSMutableString* code = [NSMutableString string];
    [containerDef.protocols enumerateKeysAndObjectsUsingBlock:^(NSString* protocolKey, DFProtocolDefinition* protocolDef, BOOL *stop) {
        if ([self shouldPrintContainer:protocolDef]) {
            
            if (![[self printedDefs] containsObject:protocolDef]) {
                [code appendString:[self generateChildrenOfContainer:protocolDef withConcreteAdopter:classDef]];
                [code appendString:[self generateProtocolsOfContainer:protocolDef withConcreteAdopter:classDef]];
            }
        }
        
    }];
    return code;
}
- (NSString*)generateChildrenOfClass:(DFClassDefinition*)classDef {
    return [self generateChildrenOfContainer:classDef withConcreteAdopter:classDef];
}

- (NSString*)generateChildrenOfContainer:(DFContainerDefinition*)containerDef withConcreteAdopter:(DFClassDefinition*)classDef {
    __block NSMutableString* code = [NSMutableString string];
    
    // Properties
    [containerDef.childDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<DFPropertyDefinitionInterface> propertyDef, BOOL *stop) {
        __block BOOL shouldPrint = NO;
        if ([self isKeyClass:[self.definitions objectForKey:propertyDef.typeName]]) {
            shouldPrint = YES; 
        } else {
            [propertyDef.protocolNames enumerateObjectsUsingBlock:^(NSString* protoName, NSUInteger idx, BOOL *stop) {
                if ( [self isKeyProtocol:[self.definitions objectForKey:protoName]] ) {
                    shouldPrint = *stop = YES;
                }
            }];
        }
        
        if (shouldPrint) {
            DFClassDefinition* existingDef = [self.definitions objectForKey:propertyDef.typeName];
            
            __block BOOL addedMore = NO;
            NSMutableArray* protocolNames = [NSMutableArray arrayWithArray:existingDef.protocols.allKeys];
            NSArray* extraProtocolNames = propertyDef.protocolNames;
            [extraProtocolNames enumerateObjectsUsingBlock:^(NSString* name, NSUInteger idx, BOOL *stop) {
                if (![existingDef.protocols objectForKey:name]) {
                    addedMore = YES;
                    [protocolNames addObject:name];
                }
            }];
            
            DFClassDefinition* childDef = existingDef;
            
            if (addedMore) {
                // Create a new definition for our property class
                childDef = [[DFClassDefinition alloc] initWithName:propertyDef.typeName];
                
                [protocolNames enumerateObjectsUsingBlock:^(NSString* name, NSUInteger idx, BOOL *stop) {
                    DFProtocolDefinition* protocolDef = [[DFProtocolDefinition alloc] initWithName:name];
                    [childDef.protocols setValue:protocolDef forKey:name];
                }];
                
                [self.virtualDefs addObject:childDef];
            }
            
            [code appendFormat:@"%@%@%@%@%@,\n",
                [self printClass:classDef],
                propertyDef.name,
                (propertyDef.isWeak ? OWNS_WEAK : OWNS_STRONG),
                propertyDef.isMultiple ? @"*" : @"",
                [self printClass:childDef includeProtocols:addedMore]
             ];
        }
        
    }];
    
    return code;
}

- (NSString*)printClass:(DFClassDefinition*)classDef {
    return [self printClass:classDef includeProtocols:NO];
}

- (NSString*)printClass:(DFClassDefinition*)classDef includeProtocols:(BOOL)includeProtocols {
    NSAssert(classDef, @"Attempt to print nil definition");
    
    BOOL isInitialDefiniton = NO;
    
    if (![self.printedDefs containsObject:classDef]) {
        [self.printedDefs addObject:classDef];
        
        isInitialDefiniton = YES;
    }
    
    return [self printClass:classDef withColour:isInitialDefiniton includeProtocols:includeProtocols];
}

- (NSString*)printClass:(DFClassDefinition*)classDef withColour:(BOOL)withColour includeProtocols:(BOOL)includeProtocols {
    return [self printClassWithName:classDef.name protocolNames:(includeProtocols ? classDef.protocols.allKeys : nil) andColour:withColour ? [self colourForContainerDefinition:classDef] : nil];
}

- (NSString*)printClassWithName:(NSString*)className
                  protocolNames:(NSArray*)protocolNames
                      andColour:(NSString*)colourName {
    
    NSMutableString* code = [NSMutableString string];
    
    if (!protocolNames.count) {
        [code appendString:className];
    } else {
        // Class
        [code appendFormat:@"%@\\n", className];
    
        [protocolNames enumerateObjectsUsingBlock:^(NSString* name, NSUInteger idx, BOOL *stop) {
            name = [name stringByReplacingOccurrencesOfString:@"<" withString:@"\\<"];
            name = [name stringByReplacingOccurrencesOfString:@">" withString:@"\\>"];
            if (idx == protocolNames.count - 1) {
                [code appendString:name];
            } else {
                [code appendFormat:@"%@", name];
            }
        }];
    }
    
    
    // Append colour
    if ([colourName length]) {
        code = [NSString stringWithFormat:@"%@{bg:%@}", code, colourName];
    }
    
    return [NSString stringWithFormat:@"[%@]", code];
}

- (NSString*)colourForContainerDefinition:(DFContainerDefinition*)containerDef {
    NSString* colour = nil;
    
    if ([containerDef isKindOfClass:[DFClassDefinition class]]) {
        DFClassDefinition* def = (DFClassDefinition*)containerDef;
        
        while (def) {
            colour = [self.colourPairs objectForKey:def.name];
            if (colour) {
                break;
            }
            def = def.superclassDef;
        }
    } else if ([containerDef isKindOfClass:[DFProtocolDefinition class]]) {
        colour = [self colourForProtocol:(DFProtocolDefinition*)containerDef];
    }
    
    if (!colour) {
        colour = @"white";
    }
    
    return colour;
}

// Find first super-protocol that has a colour.
- (NSString*)colourForProtocol:(DFProtocolDefinition*)protoDef {
    __block NSString* colour = nil;
    
    DFProtocolDefinition* def = protoDef;
    colour = [self.colourPairs objectForKey:def.name];
    if (!colour) {
        [protoDef.protocols enumerateKeysAndObjectsUsingBlock:^(id key, DFProtocolDefinition* superProto, BOOL *stop) {
            colour = [self colourForProtocol:superProto];
            if (colour) {
                *stop = YES;
            }
        }];
    }
    
    return colour;
}

#pragma mark - Utility methods

- (BOOL)shouldPrintContainer:(DFContainerDefinition*)def {
    if ( [def.name length] ) {
        BOOL replacedByColour = [self.colourPairs objectForKey:def.name] && ![self.keyClassDefinitions objectForKey:def.name];
        return !replacedByColour;
    }
    return NO;
}

- (BOOL)isKeyClass:(DFClassDefinition*)classDef {
    if ([self.keyClassDefinitions objectForKey:classDef.name]) {
        return YES;
    }
    return NO;
}

- (BOOL)isKeyProtocol:(DFProtocolDefinition*)protoDef {
    __block BOOL isProtocolOfKeyClass = NO;
    
    [self.keyClassDefinitions enumerateKeysAndObjectsUsingBlock:^(id key, DFDefinition* keyDef, BOOL *stop) {
        if ([(DFContainerDefinition*)keyDef implementsProtocolDefinition:protoDef]) {
            isProtocolOfKeyClass = YES;
            *stop = YES;
        }
    }];
    
    return isProtocolOfKeyClass;
}

@end
