//
//  DFCollectionPropertyDefinition.h
//  DFGrok
//
//  Created by Sam Taylor on 20/07/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFPropertyDefinitionInterface.h"
#import "DFDefinition.h"

@class DFContainerDefinition;

@interface DFCollectionPropertyDefinition : DFDefinition <DFPropertyDefinitionInterface>

- (id)initWithContainerDefintion:(DFContainerDefinition*)containerDef isWeak:(BOOL)weak;

@end
