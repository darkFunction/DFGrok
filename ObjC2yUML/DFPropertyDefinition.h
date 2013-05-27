//
//  DFPropertyDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 18/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFDefinition.h"
#import "DFClassDefinition.h"

typedef NS_ENUM(NSInteger, DFPropertyReferenceType) {
    DFPropertyReferenceTypeUnknown,
    DFPropertyReferenceTypeStrong,
    DFPropertyReferenceTypeWeak
};

@interface DFPropertyDefinition : DFDefinition

// Static
+ (NSString*)classNameFromEncoding:(NSString*)encoding;
+ (DFPropertyReferenceType)referenceTypeFromEncoding:(NSString*)encoding;

// Instance
@property (nonatomic) DFPropertyReferenceType referenceType;
@property (nonatomic) DFClassDefinition* classDefinition;
- (BOOL)isWeak;

@end
