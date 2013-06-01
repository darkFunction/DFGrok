//
//  DFClassDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFContainerDefinition.h"

@interface DFClassDefinition : DFContainerDefinition
@property (nonatomic) DFClassDefinition* superclassDef;
@end
