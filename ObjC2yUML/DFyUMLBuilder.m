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
@property (nonatomic) DFClassDefinition* currentClass;
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
    
    // Hmm. Think it might be possible to do this all in one go by getting translation unit associated with an
    // implementation cursor and querying it for superclass etc... TODO: investigate
    
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
    
    self.classDefinitions = nil;
    
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
            // Is it an implementation we have previously found?
            DFClassDefinition* classDefinition = [self.classDefinitions objectForKey:declarationName];
            if (classDefinition) {
                self.currentClass = classDefinition;
                
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
                    }
                }
            } else {
                self.currentClass = nil;
            }
            break;
        }
        case CXIdxEntity_ObjCProperty:
        {
            if (self.currentClass) {
                const CXIdxObjCPropertyDeclInfo *propertyDeclaration = clang_index_getObjCPropertyDeclInfo(declaration);
                
                NSString* typeEncoding = [NSString stringWithUTF8String:clang_getCString(clang_getDeclObjCTypeEncoding(propertyDeclaration->declInfo->cursor))];
                NSString* className = nil;
                
                if (propertyDeclaration) {                    
                    // Only interested in properties of the same type as the implementations we found
                    DFClassDefinition* classDefinition = [[self classDefinitions] objectForKey:className];
                    if (classDefinition) {
                        if (![self.currentClass.children objectForKey:declarationName]) {
                            [self.currentClass.children setObject:classDefinition forKey:declarationName];
                            NSLog(@"%@ . %@", self.currentClass.name, declarationName);
                        }
                    }
                    // TODO: clang_Cursor_getObjCPropertyAttributes will be in latest clang release for weak/strong references. (r.
                }
            }
            break;
        }
        default:
            break;
    }
}


@end
