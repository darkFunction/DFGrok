//
//  DFImplementationFinder.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 16/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFClassParserDelegate.h"

@interface DFImplementationFinder : NSObject <DFClassParserDelegate>
- (id)initWithFilenames:(NSArray*)fileNames;
- (NSDictionary*)createClassDefinitions;
@end
