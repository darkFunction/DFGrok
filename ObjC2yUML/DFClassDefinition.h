//
//  DFClassDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFClassDefinition : NSObject
@property (nonatomic) NSString* name;
@property (nonatomic) DFClassDefinition* superclassDef;
@property (nonatomic) NSMutableDictionary* propertyDefs;
@property (nonatomic) NSMutableArray* protocols;

- (id)initWithName:(NSString*)name;
@end
