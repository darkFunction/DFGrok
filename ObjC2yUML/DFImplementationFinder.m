//
//  DFImplementationFinder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 16/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFImplementationFinder.h"
#import "DFClassParser.h"
#import "DFClassDefinition.h"

@interface DFImplementationFinder (/* Private */)
@property (nonatomic) NSArray* fileNames;
@property (nonatomic) NSMutableDictionary* classDefinitions;
@end

@implementation DFImplementationFinder

- (id)initWithFilenames:(NSArray*)fileNames {
    self  = [super init];
    if (self) {
        _fileNames = fileNames;
    }
    return self;
}

- (NSDictionary*)createClassDefinitions {
    self.classDefinitions = [[NSMutableDictionary alloc] init];
    
    [self.fileNames enumerateObjectsUsingBlock:^(NSString* filename, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            DFClassParser* parser = [[DFClassParser alloc] initWithFileName:filename];
            parser.delegate = self;
            [parser parseWithCompletion:^(NSError* error){
                // TODO
            }];
        }
    }];
    
    NSMutableDictionary* returnDict = self.classDefinitions;
    self.classDefinitions = nil;
    return returnDict;
}

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    
    const char * const name = declaration->entityInfo->name;
    if (name == NULL)
        return;
    
    NSString *declarationName = [NSString stringWithUTF8String:name];
    
    if(declaration->entityInfo->kind == CXIdxEntity_ObjCClass && declaration->isContainer) {
        const CXIdxObjCContainerDeclInfo* containerInfo = clang_index_getObjCContainerDeclInfo(declaration);
        if (containerInfo && containerInfo->kind == CXIdxObjCContainer_Implementation) {
            
            // Get a class definition
            DFClassDefinition* classDefinition = [self.classDefinitions objectForKey:declarationName];
            if (!classDefinition) {
                classDefinition = [[DFClassDefinition alloc] initWithName:declarationName];
                [self.classDefinitions setObject:classDefinition forKey:declarationName];
            }
        }
    }
    
}

@end
