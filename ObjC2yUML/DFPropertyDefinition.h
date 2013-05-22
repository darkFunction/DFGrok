//
//  DFPropertyDefinition.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 18/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFDefinition.h"

typedef NS_ENUM(NSInteger, DFPropertyReferenceType) {
    DFPropertyReferenceTypeStrong,
    DFPropertyReferenceTypeWeak
};

@interface DFPropertyDefinition : DFDefinition
@property (nonatomic, readonly) DFPropertyReferenceType referenceType;

- (id)initWithClangEncoding:(NSString*)encoding;
- (BOOL)isWeak;

@end
