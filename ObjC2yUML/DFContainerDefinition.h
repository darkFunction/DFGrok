//
//  DFEntityDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 21/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFDefinition.h"

@interface DFContainerDefinition : DFDefinition
@property (nonatomic, readonly) NSMutableDictionary* childDefinitions;
@property (nonatomic, readonly) NSMutableArray* implementsProtocols;
@end
