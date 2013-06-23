//
//  DFDataModel.h
//  UMLTestProject
//
//  Created by Sam Taylor on 19/05/2013.
//  Copyright (c) 2013 Sam Taylor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DFDataModelDelegate;

@protocol DFDataModelInterface <NSObject>
@property (nonatomic, weak) id<DFDataModelDelegate> delegate;
@end

@protocol DFDataModelDelegate <NSObject>
@optional
- (void)dataModelDidUpdate:(id<DFDataModelInterface>)dataModel;
@end

@interface DFDataModel : NSObject <DFDataModelInterface>
@end
