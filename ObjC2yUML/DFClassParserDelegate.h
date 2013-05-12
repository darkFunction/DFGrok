//
//  DFClassParserDelegate.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <clang-c/Index.h>

@class DFClassParser;

@protocol DFClassParserDelegate <NSObject>
- (void)classParser:(DFClassParser*)parser foundDeclaration:(CXIdxDeclInfo const *)declaration;
@end