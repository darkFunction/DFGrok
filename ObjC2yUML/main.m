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
        
        NSArray* filenames = [NSArray arrayWithObject:@"/Users/samtaylor/Desktop/Projects/StuntTank/trunk/StuntTank/GameObject.m"];
        DFyUMLBuilder* builder = [[DFyUMLBuilder alloc] initWithFilenames:filenames];
        
    }
    return 0;
}