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
@property (nonatomic) NSDictionary* colourPairs;
@property (nonatomic) NSMutableArray* printedDefs;
@end

@implementation DFyUMLBuilder

- (id)initWithDefinitions:(NSDictionary*)definitions
            keyDefintions:(NSDictionary*)keyDefinitions
           andColourPairs:(NSDictionary*)colourPairs {
    
    self = [super init];
    if (self) {
        self.definitions = definitions;
        self.keyDefinitions = keyDefinitions;
        self.printedDefs = [NSMutableArray array];
        self.colourPairs = colourPairs;
    }
    return self;
}

- (NSString*)generate_yUML {
    NSMutableString* code = [NSMutableString string];
    
    [self.keyDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFDefinition* definition, BOOL *stop) {
        if ([definition isKindOfClass:[DFClassDefinition class]]) {
            DFClassDefinition* classDef = (DFClassDefinition*)definition;
            
            // Superclass relationship. Only include superclasses which are also key definitions
            if ([classDef.superclassDef.name length]) {// && [self.keyDefinitions objectForKey:classDef.superclassDef.name]) {
                [code appendFormat:@"%@%@%@\n", [self printDef:classDef.superclassDef], SUPERCLASS_OF, [self printDef:classDef]];
            } else {
                [code appendFormat:@"%@,\n", [self printDef:classDef]];
            }
            
            // Implements protocols
            [classDef.protocols enumerateKeysAndObjectsUsingBlock:^(NSString* protocolKey, DFProtocolDefinition* protocolDef, BOOL *stop) {
                if (![[self printedDefs] containsObject:protocolDef]) {
                    [code appendFormat:@"%@%@%@,\n", [self printDef:protocolDef], IMPLEMENTED_BY,[self printDef:classDef]];
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
            [code appendFormat:@"%@%@%@,\n", [self printDef:containerDef], (propertyDef.isWeak ? OWNS_WEAK : OWNS_STRONG), [self printDef:((DFDefinition*)[self.definitions objectForKey:propertyDef.className])]];
        }
    }];
    return code;
}

- (NSString*)printDef:(DFDefinition*)definition {
    if (![self.printedDefs containsObject:definition]) {
        [self.printedDefs addObject:definition];
        
        return [self printInitialDefinition:definition];
    }
    
    return [NSString stringWithFormat:@"[%@]", definition.name];
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
    NSString* colour = nil;
    DFClassDefinition* def = classDef;
    
    while (def) {
        colour = [self.colourPairs objectForKey:def.name];
        if (colour) {
            break;
        }
        def = def.superclassDef;
    }
    
    return colour;
}

@end
