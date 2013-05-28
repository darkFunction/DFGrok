//
//  DFModelBuilder.m
//  ObjC2yUML
//
//  Created by Sam Taylor on 22/05/2013.
//  Copyright (c) 2013 darkFunction Software. All rights reserved.
//

#import "DFModelBuilder.h"
#import "DFClangParser.h"
// Definitions
#import "DFDefinition.h"
#import "DFClassDefinition.h"
#import "DFProtocolDefinition.h"
#import "DFPropertyDefinition.h"

@interface DFModelBuilder ( /* Private */ )
@property (nonatomic) NSMutableDictionary* definitions;
@property (nonatomic) NSMutableArray* implementationNames;
@property (nonatomic) NSArray* fileNames;
@property (nonatomic) DFContainerDefinition* currentContainerDef;
@property (nonatomic, copy) CompletionBlock completion;
@end

@implementation DFModelBuilder

- (id)initWithFilenames:(NSArray*)fileNames {
    self  = [super init];
    if (self) {
        
        self.definitions = [NSMutableDictionary dictionary];
        self.implementationNames = [NSMutableArray array];
        self.fileNames = fileNames;
    }
    return self;
}

- (void)buildModelWithCompletion:(CompletionBlock)completion {
    [self.fileNames enumerateObjectsUsingBlock:^(NSString* fileName, NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            DFClangParser* parser = [[DFClangParser alloc] initWithFileName:fileName];
            parser.delegate = self;
            [parser parseWithCompletion:^(NSError* error){
                if (error && completion) {
                    completion(error);
                    return;
                }
            }];
        }
    }];
    
    if (completion) {
        completion(nil);
    }
}

- (NSMutableDictionary*)keyClassDefinitions {
    NSMutableDictionary* keyClasses = [NSMutableDictionary dictionaryWithCapacity:[self.implementationNames count]];
    
    [self.implementationNames enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        DFClassDefinition* classDef = [self.definitions objectForKey:obj];
        [keyClasses setObject:classDef forKey:obj];
    }];
    
    return keyClasses;
}

#pragma mark - DFClangParserDelegate

- (void)classParser:(id)parser foundDeclaration:(const CXIdxDeclInfo *)declaration {
    const char * const cName = declaration->entityInfo->name;
    if (cName == NULL)
        return;
    
    switch (declaration->entityInfo->kind) {
        case CXIdxEntity_ObjCClass:
            self.currentContainerDef = [self processClassDeclaration:declaration];
            break;
            
        case CXIdxEntity_ObjCProtocol:
            self.currentContainerDef = (DFProtocolDefinition*)[self getDefinitionWithName:[NSString stringWithUTF8String:cName] andType:[DFProtocolDefinition class]];
            break;
        
        case CXIdxEntity_ObjCProperty:
            [self processPropertyDeclaration:declaration];
            break;
            
        default:
            break;
    }
}

#pragma mark - Declaration processors

- (DFClassDefinition*)processClassDeclaration:(const CXIdxDeclInfo *)declaration {
    NSString* name = [NSString stringWithUTF8String:declaration->entityInfo->name];
    
    DFClassDefinition* classDef = (DFClassDefinition*)[self getDefinitionWithName:name andType:[DFClassDefinition class]];
    
    if (declaration->isContainer) {
        const CXIdxObjCContainerDeclInfo* containerInfo = clang_index_getObjCContainerDeclInfo(declaration);
        if (containerInfo) {
            if (containerInfo->kind == CXIdxObjCContainer_Implementation) {
                // Found an implementation
                [self.implementationNames addObject:name];
            } else if (containerInfo->kind == CXIdxObjCContainer_Interface) {
                const CXIdxObjCInterfaceDeclInfo* declarationInfo = clang_index_getObjCInterfaceDeclInfo(declaration);
                if (declarationInfo) {
                    
                    // Find superclass
                    const CXIdxBaseClassInfo* superclassInfo = declarationInfo->superInfo;
                    if (superclassInfo) {
                        const char* cName = superclassInfo->base->name;
                        if (cName) {
                            NSString* superclassName = [NSString stringWithUTF8String:cName];
                            classDef.superclassDef = (DFClassDefinition*)[self getDefinitionWithName:superclassName andType:[DFClassDefinition class]];
                            cName = NULL;
                        }
                    }
                    
                    // Find protocols
                    for (int i=0; i<declarationInfo->protocols->numProtocols; ++i) {
                        const CXIdxObjCProtocolRefInfo* protocolRefInfo = declarationInfo->protocols->protocols[i];
                        NSString* protocolName = [NSString stringWithUTF8String:protocolRefInfo->protocol->name];
                        
                        DFProtocolDefinition* protocolDef = (DFProtocolDefinition*)[self getDefinitionWithName:protocolName andType:[DFProtocolDefinition class]];
                        if (![classDef.protocols objectForKey:protocolName]) {
                            [classDef.protocols setObject:protocolDef forKey:protocolName];
                        }
                    }
                }
            }
        }
    }
    
    return classDef;
}

- (void)processPropertyDeclaration:(const CXIdxDeclInfo *)declaration {
    NSString* name = [NSString stringWithUTF8String:declaration->entityInfo->name];
    
    if (self.currentContainerDef && ![self.currentContainerDef.childDefinitions objectForKey:name]) {
        const CXIdxObjCPropertyDeclInfo *propertyDeclaration = clang_index_getObjCPropertyDeclInfo(declaration);
        if (propertyDeclaration) {
            // Parse property info from type encoding
            NSString* typeEncoding = [NSString stringWithUTF8String:clang_getCString(clang_getDeclObjCTypeEncoding(propertyDeclaration->declInfo->cursor))];
            NSString* propertyClassDefName = [DFPropertyDefinition classNameFromEncoding:typeEncoding];
            // TODO
            //NSArray* propertyProtocolDefNames = [DFPropertyDefinition protocolNamesFromEncoding:typeEncoding];
            DFPropertyReferenceType propertyRefType = [DFPropertyDefinition referenceTypeFromEncoding:typeEncoding];
            
            if ([propertyClassDefName length]) {
                DFPropertyDefinition* propertyDef = [[DFPropertyDefinition alloc] initWithName:name];
                propertyDef.referenceType = propertyRefType;
                propertyDef.classDefinition = (DFClassDefinition*)[self getDefinitionWithName:propertyClassDefName andType:[DFClassDefinition class]];
                [self.currentContainerDef.childDefinitions setObject:propertyDef forKey:name];
            }
        }
    }
}

#pragma mark - Utility methods

- (DFDefinition*)getDefinitionWithName:(NSString*)name andType:(Class)classType {
    if (![classType isSubclassOfClass:[DFDefinition class]]) {
        return nil;
    }
    
    DFDefinition* def = [self.definitions objectForKey:name];
    if (!def) {
        def = [[classType alloc] initWithName:name];
        [self.definitions setObject:def forKey:name];
    }
    return def;
}

@end
