//
//  DFyUMLBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFyUMLBuilder.h"
#include "DFClassParser.h"

@interface DFyUMLBuilder ( /* Private */ )
@property (nonatomic) NSArray* filenames;
@end

@implementation DFyUMLBuilder

- (id)initWithFilenames:(NSArray*)filenames {
    self  = [super init];
    if (self) {
        _filenames = filenames;
    }
    return self;
}

- (NSString*)buildyUML {
    [self.filenames enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        DFClassParser* parser = [[DFClassParser alloc] initWithFileName:obj];
        [parser parseWithCompletion:^(NSError* error){
            //
        }];
    }];
}

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    
}

@end
