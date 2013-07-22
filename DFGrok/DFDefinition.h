//
//  DFDefinition.h
//  DFGrok
//
//  Created by Sam Taylor on 21/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFDefinitionInterface.h"

@class DFContainerDefinition;

@interface DFDefinition : NSObject <DFDefinitionInterface>

- (id)initWithName:(NSString*)name;

@end
