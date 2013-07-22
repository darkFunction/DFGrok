//
//  DFSemanticAnalyser.m
//  DFGrok
//
//  Created by Sam Taylor on 23/06/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFSemanticAnalyser.h"
// Definitions
#import "DFDefinition.h"
#import "DFClassDefinition.h"
#import "DFProtocolDefinition.h"
#import "DFPropertyDefinition.h"

@interface DFSemanticAnalyser ( /* Private */ )
@property (nonatomic, copy) NSDictionary* definitions;
@end

@implementation DFSemanticAnalyser

- (id)initWithDefinitions:(NSDictionary*)definitions {
    self = [super init];
    if (self) {
        self.definitions = definitions;
    }
    return self;
}

- (NSDictionary*)transformedDefinitions {
    
    [self copyPropertiesFromProtocols];
    
    return self.definitions;
}

// Copies properties down from protocols into the classes which implement them
- (void)copyPropertiesFromProtocols {
    [self.definitions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //if (self.definitions)
    }];
}

- (NSArray*)classesWhichImplementProtocols {
    return nil;
}

@end
