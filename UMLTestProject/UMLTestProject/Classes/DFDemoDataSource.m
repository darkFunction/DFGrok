//
//  DFDemoDataModel.m
//  UMLTestProject
//
//  Created by Sam Taylor on 19/05/2013.
//  Copyright (c) 2013 Sam Taylor. All rights reserved.
//

#import "DFDemoDataSource.h"
#import "DFDataModelContainer.h"
#import "DFDemoDataModelOne.h"
#import "DFDemoDataModelTwo.h"

@interface DFDemoDataSource ( /* Private */ )
@property (nonatomic) DFDataModelContainer* dataModelContainer;
@end

@implementation DFDemoDataSource

- (id)init {
    self = [super init];
    if (self) {
        self.dataModelContainer = [[DFDataModelContainer alloc] init];
        
        [self populateDataModelContainer:self.dataModelContainer];
    }
    return self;
}

- (void)populateDataModelContainer:(DFDataModelContainer*)dataModelContainer {
    DFDataModel* dataModelOne = [[DFDemoDataModelOne alloc] init];
    DFDataModel* dataModelTwo = [[DFDemoDataModelTwo alloc] init];
    
    [dataModelContainer addDataModel:dataModelOne];
    [dataModelContainer addDataModel:dataModelTwo];
}

@end
