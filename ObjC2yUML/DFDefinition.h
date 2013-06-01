//
//  DFDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 21/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DFContainerDefinition;

@interface DFDefinition : NSObject
@property (nonatomic, copy, readonly) NSString* name;

- (id)initWithName:(NSString*)name;
@end
