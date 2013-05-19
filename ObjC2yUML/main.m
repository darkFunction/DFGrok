//
//  main.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFyUMLBuilder.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        NSArray* filenames = [NSArray arrayWithObjects: @"/Users/samtaylor/Projects/ObjC2yUML/ObjC2yUML/DFClassDefinition.m",
                                                        @"/Users/samtaylor/Projects/ObjC2yUML/ObjC2yUML/DFClassParser.m",
                                                        nil];
        DFyUMLBuilder* builder = [[DFyUMLBuilder alloc] initWithFilenames:filenames];
        
        NSString* yUML = [builder buildyUML];
        NSLog(@"%@", yUML);
        
    }
    return 0;
}