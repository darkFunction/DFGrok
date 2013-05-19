//
//  DFDataModelContainer.h
//  UMLTestProject
//
//  Created by Sam Taylor on 19/05/2013.
//  Copyright (c) 2013 Sam Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFDataModel.h"

@interface DFDataModelContainer : NSObject  <DFDataModelInterface, DFDataModelDelegate>
- (void)addDataModel:(id<DFDataModelInterface>)dataModel;
@end
