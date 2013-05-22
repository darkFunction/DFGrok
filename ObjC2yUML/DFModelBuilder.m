//
//  DFModelBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 22/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFModelBuilder.h"
#import "DFDefinition.h"
#import "DFClangParser.h"

@interface DFModelBuilder ( /* Private */ )
@property (nonatomic) NSMutableArray* definitions;
@property (nonatomic) NSMutableArray* foundImplementations;
@property (nonatomic) DFDefinition* currentDefintion;
@end

@implementation DFModelBuilder

- (id)initWithFilenames:(NSArray*)fileNames {
    self  = [super init];
    if (self) {
        
        self.definitions = [NSMutableArray array];
        self.foundImplementations = [NSMutableArray array];
        
        [self buildModel:fileNames];
    }
    return self;
}

- (void)buildModel:(NSArray*)fileNames {
    [fileNames enumerateObjectsUsingBlock:^(NSString* fileName, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            DFClangParser* parser = [[DFClangParser alloc] initWithFileName:fileName];
            parser.delegate = self;
            [parser parseWithCompletion:^(NSError* error){
                
            }];
        }
    }];
}

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    const char * const cName = declaration->entityInfo->name;
    if (cName == NULL)
        return;
    
    NSString *declarationName = [NSString stringWithUTF8String:cName];
    
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCClass:
        {
            break;
        }
        case CXIdxEntity_ObjCCategory:
        {
            break;
        }
        case CXIdxEntity_ObjCProtocol:
        {
            break;
        }
        case CXIdxEntity_ObjCProperty:
        {
            break;
        }
        default:
            break;
    }
}


@end
