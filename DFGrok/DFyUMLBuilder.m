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
@property (nonatomic) NSDictionary* keyContainerDefinitions;
@property (nonatomic) NSDictionary* colourPairs;
@property (nonatomic) NSMutableArray* printedDefs;
@end

@implementation DFyUMLBuilder

- (id)initWithDefinitions:(NSDictionary*)definitions
  keyContainerDefinitions:(NSDictionary*)keyContainerDefinitions
           andColourPairs:(NSDictionary*)colourPairs {
    
    self = [super init];
    if (self) {
        self.definitions = definitions;
        self.keyContainerDefinitions = keyContainerDefinitions;
        self.printedDefs = [NSMutableArray array];
        self.colourPairs = colourPairs;
    }
    return self;
}

- (NSString*)generate_yUML {
    NSMutableString* code = [NSMutableString string];

    [self.keyContainerDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFDefinition* definition, BOOL *stop) {
        if ([definition isKindOfClass:[DFClassDefinition class]]) {
            DFClassDefinition* classDef = (DFClassDefinition*)definition;
            
            // Superclass relationship. Only include superclasses which are also key definitions
            if ([self shouldPrintContainer:classDef.superclassDef]) {
                [code appendFormat:@"%@%@%@\n", [self printDef:classDef.superclassDef], SUPERCLASS_OF, [self printDef:classDef]];
            } else {
                [code appendFormat:@"%@,\n", [self printDef:classDef]];
            }
            
            // Implements protocols
            [code appendString:[self generateProtocolsOfContainer:classDef]];
            
            // Properties
            [code appendString:[self generateChildrenOfContainer:classDef]];
        }
    }];
    
    return code;
}

- (NSString*)generateChildrenOfContainer:(DFContainerDefinition*)containerDef {
    __block NSMutableString* code = [NSMutableString string];

    void(^printProperty)(DFContainerDefinition*, BOOL, BOOL, DFContainerDefinition*, NSString*) = ^(DFContainerDefinition* owner, BOOL isWeak, BOOL isMulti, DFContainerDefinition* child, NSString* name){
    
        [code appendFormat:@"%@%@%@%@%@,\n", [self printDef:owner], name, (isWeak ? OWNS_WEAK : OWNS_STRONG), isMulti ? @"*" : @"", [self printDef:child]];
    };
    
    // Properties
    [containerDef.childDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<DFPropertyDefinitionInterface> propertyDef, BOOL *stop) {
        
        if ([self isKeyClass:[self.definitions objectForKey:propertyDef.className]]) {
            printProperty(containerDef, propertyDef.isWeak, propertyDef.isMultiple, [self.definitions objectForKey:propertyDef.className], propertyDef.name);
        } else {
            [propertyDef.protocolNames enumerateObjectsUsingBlock:^(NSString* protoName, NSUInteger idx, BOOL *stop) {
                if ( [self isKeyProtocol:[self.definitions objectForKey:protoName]] ) {
                    printProperty(containerDef, propertyDef.isWeak, propertyDef.isMultiple, [self.definitions objectForKey:protoName], propertyDef.name);
                }
            }];
        }
        
    }];
    return code;
}

- (NSString*)generateProtocolsOfContainer:(DFContainerDefinition*)containerDef {
    
    NSMutableString* code = [NSMutableString string];
    [containerDef.protocols enumerateKeysAndObjectsUsingBlock:^(NSString* protocolKey, DFProtocolDefinition* protocolDef, BOOL *stop) {
        if ([self shouldPrintContainer:protocolDef]) {
            
            if (![[self printedDefs] containsObject:protocolDef]) {
                [code appendString:[self generateChildrenOfContainer:protocolDef]];
                [code appendString:[self generateProtocolsOfContainer:protocolDef]];
            }
            
            [code appendFormat:@"%@%@%@,\n", [self printDef:protocolDef], IMPLEMENTED_BY,[self printDef:containerDef]];
        }
        
    }];
    return code;
}

- (NSString*)printDef:(DFContainerDefinition*)definition {
    NSAssert(definition, @"Attempt to print nil definition");
    
    if (![self.printedDefs containsObject:definition]) {
        [self.printedDefs addObject:definition];
        
        return [self printInitialDefinition:definition];
    }
    
    return [NSString stringWithFormat:@"[%@]", definition.name];
}

- (NSString*)printInitialDefinition:(DFContainerDefinition*)definition {
    NSString* colour = nil;
    
    if (!colour) {
        colour = [self colourForContainerDefinition:definition];
    }
    
    if ([colour length]) {
        return [NSString stringWithFormat:@"[%@{bg:%@}]", definition.name, colour];
    }
    return [NSString stringWithFormat:@"[%@]", definition.name];
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
        BOOL replacedByColour = [self.colourPairs objectForKey:def.name] && ![self.keyContainerDefinitions objectForKey:def.name];
        return !replacedByColour;
    }
    return NO;
}

- (BOOL)isKeyClass:(DFClassDefinition*)classDef {
    if ([self.keyContainerDefinitions objectForKey:classDef.name]) {
        return YES;
    }
    return NO;
}

- (BOOL)isKeyProtocol:(DFProtocolDefinition*)protoDef {
    __block BOOL isProtocolOfKeyClass = NO;
    
    [self.keyContainerDefinitions enumerateKeysAndObjectsUsingBlock:^(id key, DFDefinition* keyDef, BOOL *stop) {
        if ([(DFContainerDefinition*)keyDef implementsProtocolDefinition:protoDef]) {
            isProtocolOfKeyClass = YES;
            *stop = YES;
        }
    }];
    
    return isProtocolOfKeyClass;
}

@end
