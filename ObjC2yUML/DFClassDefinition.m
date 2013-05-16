//
//  DFClassDefinition.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFClassDefinition.h"

@implementation DFClassDefinition

- (id)initWithName:(NSString*)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

@end
