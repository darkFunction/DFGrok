//
//  DFClassModel.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFClassModel : NSObject
@property (nonatomic) NSString* name;
@property (nonatomic) DFClassModel* superClass;
@property (nonatomic) NSArray* children;
@end
