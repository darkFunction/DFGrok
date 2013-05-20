//
//  DFProtocolDefinition.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 20/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFProtocolDefinition.h"

@implementation DFProtocolDefinition

- (id)initWithName:(NSString*)name {
    self = [super init];
    if (self) {
        _name = [name copy];
        _propertyDefs = [NSMutableDictionary dictionary];
    }
    return self;
}
@end
