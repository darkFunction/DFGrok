//
//  DFModelBuilder.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 22/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFClangParserDelegate.h"

@interface DFModelBuilder : NSObject <DFClangParserDelegate>
- (id)initWithFilenames:(NSArray*)fileNames;
@end
