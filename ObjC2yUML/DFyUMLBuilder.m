//
//  DFyUMLBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 12/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFyUMLBuilder.h"
#import "DFClassParser.h"
#import "DFClassDefinition.h"
#import "DFImplementationFinder.h"

@interface DFyUMLBuilder ( /* Private */ )
@property (nonatomic) NSArray* fileNames;
@property (nonatomic) NSDictionary* classDefinitions;
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
    DFImplementationFinder* implementationFinder = [[DFImplementationFinder alloc] initWithFilenames:self.fileNames];
    self.classDefinitions = [implementationFinder createClassDefinitions];
    
    [self.fileNames enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            DFClassParser* parser = [[DFClassParser alloc] initWithFileName:obj];
            parser.delegate = self;
            [parser parseWithCompletion:^(NSError* error){
                
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
    
    DFClassDefinition* classDefinition = [self.classDefinitions objectForKey:declarationName];
    if (!classDefinition) {
        return; // not interested
    }
    
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCClass:
        {
            const CXIdxObjCInterfaceDeclInfo* declarationInfo = clang_index_getObjCInterfaceDeclInfo(declaration);
            if (declarationInfo) {
                const CXIdxObjCContainerDeclInfo* containerInfo = clang_index_getObjCContainerDeclInfo(declaration);
                if (containerInfo && containerInfo->kind == CXIdxObjCContainer_Interface) {
                    
                    // Find superclass
                    const CXIdxBaseClassInfo* superClassInfo = declarationInfo->superInfo;
                    if (superClassInfo) {
                        const char* name = superClassInfo->base->name;
                        if (name) {
                            DFClassDefinition* superClassDefintion = [[DFClassDefinition alloc] initWithName:[NSString stringWithUTF8String:name]];
                            classDefinition.superClass = superClassDefintion;
                        }
                        name = NULL;
                    }
                    
                    // Find children
                    
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
