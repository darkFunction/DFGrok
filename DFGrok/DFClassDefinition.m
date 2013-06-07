//
//  DFClassDefinition.m
//  DFGrok
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFClassDefinition.h"

@implementation DFClassDefinition

- (BOOL)isSubclassOf:(DFClassDefinition*)parent {
    DFClassDefinition* def = self;
    
    while ((def = def.superclassDef)) {
        if (def == parent) {
            return YES;
        }
    }
    return NO;
}


@end
