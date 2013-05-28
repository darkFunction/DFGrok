//
//  DFModelBuilder.h
//  ObjC2yUML
//
//  Created by Sam Taylor on 22/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFClangParserDelegate.h"

@protocol DFModelBuilderDelegate;

@interface DFModelBuilder : NSObject <DFClangParserDelegate>
@property (nonatomic, weak) id<DFModelBuilderDelegate> delegate;
- (id)initWithFilenames:(NSArray*)fileNames;

// Return classes for which we have found an @implementation
- (NSMutableDictionary*)keyClasses;
@end

@protocol DFModelBuilderDelegate <NSObject>
- (void)modelCompleted:(DFModelBuilder*)modelBuilder;
@end
