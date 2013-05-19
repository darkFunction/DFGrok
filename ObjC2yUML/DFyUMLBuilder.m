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
#import "DFPropertyDefinition.h"

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
    
    // Now we have a model of the parts we are interested in
    
    NSMutableString* yUML = [[NSMutableString alloc] init];
    [self.classDefinitions enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFClassDefinition* classDef, BOOL *stop) {
        [yUML appendFormat:@"[%@]^-[%@],", classDef.superclassDef.name, classDef.name];
        [classDef.propertyDefs enumerateKeysAndObjectsUsingBlock:^(NSString* key, DFPropertyDefinition* propertyDef, BOOL *stop) {
            [yUML appendFormat:propertyDef.isWeak ? (@"[%@]+->[%@],") : (@"[%@]++->[%@],"), classDef.name, propertyDef.name];
        }];
    }];

    
    self.classDefinitions = nil;

    return yUML;
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
                                classDefinition.superclassDef = superClassDefintion;
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
        case CXIdxEntity_ObjCCategory:
            self.currentClass = nil;
            break;
        case CXIdxEntity_ObjCProperty:
        {
            if (self.currentClass) {
                const CXIdxObjCPropertyDeclInfo *propertyDeclaration = clang_index_getObjCPropertyDeclInfo(declaration);                
                if (propertyDeclaration) {
                    NSString* typeEncoding = [NSString stringWithUTF8String:clang_getCString(clang_getDeclObjCTypeEncoding(propertyDeclaration->declInfo->cursor))];
                    DFPropertyDefinition* propertyDef = [[DFPropertyDefinition alloc] initWithClangEncoding:typeEncoding];
                    
                    // Don't care about properties which are not of the classes we found implementations for
                    if ([self.classDefinitions objectForKey:propertyDef.name]) {
                        if (![self.currentClass.propertyDefs objectForKey:propertyDef]) {
                            NSLog(@"Setting property type (%@) on class (%@)", propertyDef.name, self.currentClass.name);
                            [self.currentClass.propertyDefs setObject:propertyDef forKey:declarationName];
                        }
                    }
                }
            }
            break;
        }
        default:
            break;
    }
}


@end
