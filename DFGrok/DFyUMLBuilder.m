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
            
            // Properties
            [code appendString:[self generateChildrenOfClass:classDef]];
        }
    }];
    
    return code;
}

- (NSString*)generateChildrenOfClass:(DFClassDefinition*)classDef {
    __block NSMutableString* code = [NSMutableString string];
    
    // Properties
    [classDef.childDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, id<DFPropertyDefinitionInterface> propertyDef, BOOL *stop) {
        __block BOOL shouldPrint = NO;
        if ([self isKeyClass:[self.definitions objectForKey:propertyDef.typeName]]) {
            shouldPrint = YES; 
        } else {
            [propertyDef.protocolNames enumerateObjectsUsingBlock:^(NSString* protoName, NSUInteger idx, BOOL *stop) {
                if ( [self isKeyProtocol:[self.definitions objectForKey:protoName]] ) {
                    shouldPrint = YES;
                    *stop = YES;
                }
            }];
        }
        
        if (shouldPrint) {
            
            NSMutableArray* protocolNames = [NSMutableArray arrayWithArray:[[self.definitions objectForKey:propertyDef.typeName] protocols].allKeys];
            NSArray* extraProtocolNames = propertyDef.protocolNames;
            [protocolNames addObjectsFromArray:extraProtocolNames];
            
            [code appendFormat:@"%@%@%@%@%@,\n",
                [self printDef:classDef],
                propertyDef.name,
                (propertyDef.isWeak ? OWNS_WEAK : OWNS_STRONG),
                propertyDef.isMultiple ? @"*" : @"",
                [self printClassWithName:propertyDef.typeName protocolNames:protocolNames andColour:[self colourForContainerDefinition:[self.definitions objectForKey:propertyDef.typeName]]]
             ];
        }
        
    }];
    return code;
}

- (NSString*)printDef:(DFContainerDefinition*)definition {
    NSAssert(definition, @"Attempt to print nil definition");
    NSAssert([definition isKindOfClass:[DFClassDefinition class]], @"Currently only supports class definitions");
    
    BOOL isInitialDefiniton = NO;
    
    if (![self.printedDefs containsObject:definition]) {
        [self.printedDefs addObject:definition];
        
        isInitialDefiniton = YES;
    }
    
    return [self printClass:(DFClassDefinition*)definition withColour:isInitialDefiniton];
}

- (NSString*)printClassWithName:(NSString*)className
                  protocolNames:(NSArray*)protocolNames
                      andColour:(NSString*)colourName {
    
    NSMutableString* code = [NSMutableString string];
    
    // First, append protocols
    if (protocolNames.count) {
        [protocolNames enumerateObjectsUsingBlock:^(NSString* name, NSUInteger idx, BOOL *stop) {
            name = [name stringByReplacingOccurrencesOfString:@"<" withString:@"\\<"];
            name = [name stringByReplacingOccurrencesOfString:@">" withString:@"\\>"];
            if (idx == protocolNames.count - 1) {
                [code appendString:name];
            } else {
                [code appendFormat:@"%@\\n", name];
            }
        }];
        
        // Line
        [code appendString:@"|\\n"];
        
        // Class
        [code appendFormat:@"%@\\n\\n", className];
    } else {
        [code appendString:className];
    }
    
    
    // Append colour
    if ([colourName length]) {
        code = [NSString stringWithFormat:@"%@{bg:%@}", code, colourName];
    }
    
    return [NSString stringWithFormat:@"[%@]", code];
}


- (NSString*)printClass:(DFClassDefinition*)classDef withColour:(BOOL)withColour {
    return [self printClassWithName:classDef.name protocolNames:classDef.protocols.allKeys andColour:withColour ? [self colourForContainerDefinition:classDef] : nil];
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
