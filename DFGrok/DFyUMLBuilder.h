//
//  DFyUMLBuilder.h
//  DFGrok
//
//  Created by Sam Taylor on 28/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFModelBuilder.h"

@interface DFyUMLBuilder : NSObject
- (id)initWithDefinitions:(NSDictionary*)definitions
  keyContainerDefinitions:(NSDictionary*)keyContainerDefinitions
           andColourPairs:(NSDictionary*)colourPairs;
- (NSString*)generate_yUML;
@end
