//
//  DFPropertyDefinitionInterface.h
//  DFGrok
//
//  Created by Sam Taylor on 20/07/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFDefinitionInterface.h"

@protocol DFPropertyDefinitionInterface <DFDefinitionInterface>
- (NSString*)typeName;
- (NSMutableArray*)protocolNames;
- (BOOL)isWeak;
- (BOOL)isMultiple;
@end
