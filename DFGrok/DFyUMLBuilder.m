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
            if ([self shouldPrintSuperclassOf:classDef]) {
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
    NSMutableString* code = [NSMutableString string];
    
    // Properties
    [containerDef.childDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFPropertyDefinition* propertyDef, BOOL *stop) {
        
        if ([self isKeyClass:[self.definitions objectForKey:propertyDef.className]]) {
            [code appendFormat:@"%@%@%@,\n", [self printDef:containerDef], (propertyDef.isWeak ? OWNS_WEAK : OWNS_STRONG), [self printDef:((DFDefinition*)[self.definitions objectForKey:propertyDef.className])]];
        } else {
            [propertyDef.protocolNames enumerateObjectsUsingBlock:^(NSString* protoName, NSUInteger idx, BOOL *stop) {
                if ( [self isKeyProtocol:[self.definitions objectForKey:protoName]] ) {
                    [code appendFormat:@"%@%@%@,\n", [self printDef:containerDef], (propertyDef.isWeak ? OWNS_WEAK : OWNS_STRONG), [self printDef:((DFDefinition*)[self.definitions objectForKey:protoName])]];
                }
            }];
        }
        
    }];
    return code;
}

- (NSString*)generateProtocolsOfContainer:(DFContainerDefinition*)containerDef {
    NSMutableString* code = [NSMutableString string];
    [containerDef.protocols enumerateKeysAndObjectsUsingBlock:^(NSString* protocolKey, DFProtocolDefinition* protocolDef, BOOL *stop) {
        if (![[self printedDefs] containsObject:protocolDef]) {
            [code appendString:[self generateChildrenOfContainer:protocolDef]];
            [code appendString:[self generateProtocolsOfContainer:protocolDef]];
        }
        
        [code appendFormat:@"%@%@%@,\n", [self printDef:protocolDef], IMPLEMENTED_BY,[self printDef:containerDef]];
        
    }];
    return code;
}

- (NSString*)printDef:(DFDefinition*)definition {
    NSAssert(definition, @"Attempt to print nil definition");
    
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
        } else if ([definition isKindOfClass:[DFProtocolDefinition class]]) {
            colour = @"pink";
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

#pragma mark - Utility methods

- (BOOL)shouldPrintSuperclassOf:(DFClassDefinition*)classDef {
    if ( [classDef.superclassDef.name length] ) {
        BOOL replacedByColour = [self.colourPairs objectForKey:classDef.superclassDef.name] && ![self.keyContainerDefinitions objectForKey:classDef.superclassDef.name];
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
