//
//  DFPropertyDefinition.h
//  DFGrok
//
//  Created by Sam Taylor on 18/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFDefinition.h"
#import "DFPropertyDefinitionInterface.h"

@interface DFPropertyDefinition : DFDefinition <DFPropertyDefinitionInterface>

- (id)initWithName:(NSString*)name andTokens:(NSArray*)tokens;

@end
