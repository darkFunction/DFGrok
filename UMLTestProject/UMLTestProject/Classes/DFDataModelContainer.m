//
//  DFDataModelContainer.m
//  UMLTestProject
//
//  Created by Sam Taylor on 19/05/2013.
//  Copyright (c) 2013 Sam Taylor. All rights reserved.
//

#import "DFDataModelContainer.h"
#import "DFDemoDataSource.h"

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
    DFDemoDataSource* testSource = [[DFDemoDataSource alloc] init];
    NSMutableDictionary* breasts = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [testSource.testDict objectForKey:@"fuck"];
    [self.dataModels addObject:breasts];
    [breasts removeAllObjects];
}

#pragma mark - DFDataModelDelegate
- (void)dataModelDidUpdate:(id<DFDataModelInterface>)dataModel {
    [self.delegate dataModelDidUpdate:dataModel];
}

@end
