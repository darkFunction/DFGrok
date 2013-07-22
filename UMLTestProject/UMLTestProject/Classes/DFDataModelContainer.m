//
//  DFDataModelContainer.m
//  UMLTestProject
//
//  Created by Sam Taylor on 19/05/2013.
//  Copyright (c) 2013 Sam Taylor. All rights reserved.
//

#import "DFDataModelContainer.h"
#import "DFDemoDataSource.h"
#import "DFDemoDataModelOne.h"

@interface DFDataModelContainer ( /* Private */ )
@property (nonatomic) NSMutableArray* dataModels;
@end

@implementation DFDataModelContainer
@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        self.dataModels = [NSMutableArray array];
    }
    return self;
}

- (void)addDataModel:(id<DFDataModelInterface>)dataModel {
    [self.dataModels addObject:dataModel];
}

- (void)testAddConcreteDataModel:(DFDemoDataModelOne*)helpmeh {
    [self.dataModels addObject:helpmeh];
}

#pragma mark - DFDataModelDelegate
- (void)dataModelDidUpdate:(id<DFDataModelInterface>)dataModel {
    [self.delegate dataModelDidUpdate:dataModel];
}

@end
