//
//  DFModelBuilder.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 22/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFClangParserDelegate.h"

typedef void(^CompletionBlock)(NSError*);

@interface DFModelBuilder : NSObject <DFClangParserDelegate>
@property (nonatomic, readonly) NSMutableDictionary* definitions;

- (id)initWithFilenames:(NSArray*)fileNames;
- (void)buildModelWithCompletion:(CompletionBlock)completion;
// Return classes for which we have found an @implementation
- (NSMutableDictionary*)keyClassDefinitions;
@end
