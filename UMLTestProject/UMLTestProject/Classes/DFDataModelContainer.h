//
//  DFDataModelContainer.h
//  UMLTestProject
//
//  Created by Sam Taylor on 19/05/2013.
//  Copyright (c) 2013 Sam Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFDataModel.h"

@protocol DFDataModelContainerDelegate;

@interface DFDataModelContainer : NSObject  <DFDataModelDelegate>
@property (nonatomic, weak) id<DFDataModelContainerDelegate> delegate;
- (void)addDataModel:(id<DFDataModelInterface>)dataModel;
@end

@protocol DFDataModelContainerDelegate <NSObject>
- (void)containerDidUpdate:(DFDataModelContainer*)container;
@end

