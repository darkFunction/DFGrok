//
//  DFyUMLBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 28/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFyUMLBuilder.h"

@interface DFyUMLBuilder ()
@property (nonatomic) NSDictionary* definitions;
@end

@implementation DFyUMLBuilder

- (id)initWithDefinitions:(NSDictionary*)definitions {
    self = [super init];
    if (self) {
        self.definitions = definitions;
    }
    return self;
}

- (NSString*)generate_yUML {
    
    // Test
    [self.definitions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"%@", key);
    }];
    
    return nil;
}

@end
