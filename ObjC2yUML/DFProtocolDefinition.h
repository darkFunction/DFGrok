//
//  DFProtocolDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 20/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFProtocolDefinition : NSObject
@property (nonatomic) NSString* name;
@property (nonatomic) DFProtocolDefinition* superProtoDef;
@property (nonatomic) NSMutableDictionary* propertyDefs;

- (id)initWithName:(NSString*)name;
@end
