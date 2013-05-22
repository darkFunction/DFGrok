//
//  DFyUMLBuilder.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFClangParserDelegate.h"

@interface DFyUMLBuilder : NSObject <DFClangParserDelegate>
- (id)initWithFilenames:(NSArray*)fileNames;
- (NSString*)buildyUML;
@end
