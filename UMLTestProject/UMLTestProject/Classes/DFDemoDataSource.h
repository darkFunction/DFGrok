//
//  DFDemoDataModel.h
//  UMLTestProject
//
//  Created by Sam Taylor on 19/05/2013.
//  Copyright (c) 2013 Sam Taylor. All rights reserved.
//

#import "DFDataModelContainer.h"

@interface DFDemoDataSource : NSObject <DFDataModelContainerDelegate>
@property (nonatomic) NSDictionary* testDict;
@end
