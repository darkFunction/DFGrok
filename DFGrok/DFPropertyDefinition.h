//
//  DFPropertyDefinition.h
//  DFGrok
//
//  Created by Sam Taylor on 18/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <clang-c/Index.h>
#import "DFDefinition.h"

@interface DFPropertyDefinition : DFDefinition
@property (nonatomic, readonly, getter = isWeak) BOOL weak;
@property (nonatomic, readonly) NSString* className;
@property (nonatomic, readonly) NSMutableArray* protocolNames;

- (id)initWithDeclaration:(const CXIdxObjCPropertyDeclInfo*)declaration andTranslationUnit:(CXTranslationUnit)translationUnit;

@end
