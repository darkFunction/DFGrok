//
//  main.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 11/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DFClassParser.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        DFClassParser* parser = [[DFClassParser alloc] initWithFileName:@"/Users/samtaylor/Desktop/Projects/StuntTank/trunk/StuntTank/GameObject.m"];
        [parser parseWithCompletion:nil];
        
    }
    return 0;
}