//
//  DFyUMLBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFyUMLBuilder.h"
#import "DFClassParser.h"
#import "DFClassModel.h"

@interface DFyUMLBuilder ( /* Private */ )
@property (nonatomic) NSArray* fileNames;
@property (nonatomic) NSMutableDictionary* classModels;
@property (nonatomic) NSMutableDictionary* superclasses;
@end

@implementation DFyUMLBuilder

- (id)initWithFilenames:(NSArray*)fileNames {
    self  = [super init];
    if (self) {
        _fileNames = fileNames;
    }
    return self;
}

- (NSString*)buildyUML {
    self.classModels = [[NSMutableDictionary alloc] init];
    
    [self.fileNames enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            self.superclasses = [[NSMutableDictionary alloc] init];
            DFClassParser* parser = [[DFClassParser alloc] initWithFileName:obj];
            parser.delegate = self;
            [parser parseWithCompletion:^(NSError* error){
                self.superclasses = nil;
            }];
        }
    }];
    
    return nil;
}

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    
    const char * const name = declaration->entityInfo->name;
    if (name == NULL)
        return;

    NSString *declarationName = [NSString stringWithUTF8String:name];
    
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCClass:
        {            
            // Keep a dictionary of class names -> superclass names
            const CXIdxObjCInterfaceDeclInfo* declarationInfo = clang_index_getObjCInterfaceDeclInfo(declaration);
            if (declarationInfo) {

                const CXIdxObjCContainerDeclInfo* containerInfo = clang_index_getObjCContainerDeclInfo(declaration);
                if (containerInfo && containerInfo->kind == CXIdxObjCContainer_Interface) {
                    const CXIdxBaseClassInfo* superClassInfo = declarationInfo->superInfo;
                    if (superClassInfo) {
                        const char* name = superClassInfo->base->name;
                        if (name) {
                            NSString* superClassName = [NSString stringWithUTF8String:name];
                            [self.superclasses setObject:superClassName forKey:declarationName];
                        }
                        name = NULL;
                    }
                }
            }
            
            // Check if we have found an @implementation
            if (declaration->isContainer) {
                const CXIdxObjCContainerDeclInfo* containerInfo = clang_index_getObjCContainerDeclInfo(declaration);
                if (containerInfo && containerInfo->kind == CXIdxObjCContainer_Implementation) {
                    
                    // Get a class definition
                    DFClassModel* classModel = [self.classModels objectForKey:declarationName];
                    if (!classModel) {
                        classModel = [[DFClassModel alloc] init];
                        [self.classModels setObject:classModel forKey:declarationName];
                        classModel.name = declarationName;
                        
                        // We can safely assume that we have already parsed the interface and so found the superclass
                        classModel.superClass = [self.superclasses objectForKey:declarationName];
                    }
                }
            }
            
            break;
        }
            
        default:
        {
            break;
        }
    }
}

- (CXIdxClientFile)classParser:(DFClassParser*)parser includedFile:(const CXIdxIncludedFileInfo *)includedFile {    

    return NULL;
}




@end
