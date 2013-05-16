//
//  DFClassDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFClassDefinition : NSObject
@property (nonatomic, readonly) NSString* name;
@property (nonatomic) DFClassDefinition* superClass;
@property (nonatomic) NSArray* children;

- (id)initWithName:(NSString*)name;
@end
